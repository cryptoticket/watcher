pragma solidity ^0.4.18;

contract AccessControl {
    address public addressCT;
    address public addressTS;
    address public addressOG;
    
    mapping (address => bool) public sellers;

    bool isPaused = false;
    bool isCancelled = false;

    modifier onlyCT() {require(msg.sender == addressCT); _;}
    modifier onlyTS() {require(msg.sender == addressTS); _;}
    modifier onlyAdmin() {require(msg.sender == addressCT || msg.sender == addressTS); _;}
    modifier onlySeller() {require(sellers[msg.sender] == true); _;}

    modifier isEventActive() {require(!isPaused && !isCancelled); _;}

    function AccessControl(address _addressCT, address _addressTS) public {
        addressCT = _addressCT;
        addressTS = _addressTS;

        sellers[_addressCT] = true;
        sellers[_addressTS] = true;
    }

    function setTS(address _addressTS) onlyCT() public {
        require(_addressTS != address(0));  
        addressTS = _addressTS;
    }

    function setSeller(address _seller) onlyAdmin() public {
        require(_seller != address(0));  
        sellers[_seller] = true;
    }

    function unsetSeller(address _seller) onlyAdmin() public {
        require(_seller != address(0));  
        sellers[_seller] = false;
    }

    function pause() onlyAdmin() isEventActive() public {
        isPaused = true;
    }

    function unpause() onlyAdmin() public {
        require(isPaused && !isCancelled);
        isPaused = false;
    }

    function cancel() onlyCT() public {
        isCancelled = true;
    }
}

contract EventSettings is AccessControl {
    string public version;

    uint public saleStart;
    uint public saleEnd;

    uint public allocated;
    uint public limitTotal;
    uint public limitPerHolder;

    bool isRefundable;
    bool isTransferable;

    modifier isSaleActive() {require(block.timestamp > saleStart && block.timestamp < saleEnd); _;}

    modifier refundable() {require(isRefundable); _;}
    modifier transferable() {require(isTransferable); _;}

    function EventSettings(string _version, uint _saleStart, uint _saleEnd,  uint _limitTotal, uint _limitPerHolder, bool _isRefundable, bool _isTransferable) public {
        version = _version;

        saleStart = _saleStart;
        saleEnd = _saleEnd;

        limitTotal = _limitTotal;
        limitPerHolder = _limitPerHolder;
        
        isRefundable = _isRefundable;
        isTransferable = _isTransferable;
    }
}

contract Tickets is EventSettings {
    mapping (address => uint) public owners;
    mapping (bytes32 => address) public allocatedTickets;
    mapping (bytes32 => address) public redeemedTickets;

    event TicketAllocated(address _to, bytes32 _ticket, address _manager);
    event TicketRefunded(address _to, bytes32 _ticket, address _manager);
    event TicketRedeemed(address _from, bytes32 _ticket, address _manager);
    event TicketTransferred(address _from, address _to, bytes32 _ticket, address _manager);

    function allocate(address _to, bytes32 _ticket) onlyAdmin() isEventActive() external returns(bool status) {
        require(_to != address(0));
        require(allocatedTickets[_ticket] == address(0) && redeemedTickets[_ticket] == address(0));

        if(limitTotal > 0) require(allocated < limitTotal);
        if(limitPerHolder > 0) require(owners[_to] < limitPerHolder);

        owners[_to] += 1;
        allocatedTickets[_ticket] = _to;
        allocated++;
            
        TicketAllocated(_to, _ticket, msg.sender);
        return true;
    }

    function refund(address _to, bytes32 _ticket) onlyAdmin() refundable() external returns(bool status) {
        require(_to != address(0));
        require(allocatedTickets[_ticket] == _to && redeemedTickets[_ticket] == address(0));

        owners[_to] -= 1;
        allocatedTickets[_ticket] = address(0);
        allocated--;
            
        TicketRefunded(_to, _ticket, msg.sender);
        return true;
    }

    function redeem(address _from, bytes32 _ticket) onlyAdmin() isEventActive() external returns(bool status) {
        require(_from != address(0));
        require(allocatedTickets[_ticket] == _from && redeemedTickets[_ticket] == address(0));

        owners[_from] -= 1;
        redeemedTickets[_ticket] = _from;

        TicketRedeemed(_from, _ticket, msg.sender);
        return true;
    }

    function transfer(address _to, bytes32 _ticket) isEventActive() external returns(bool status) {
        require(_to != address(0) && _to != msg.sender);
        require(allocatedTickets[_ticket] == msg.sender && redeemedTickets[_ticket] == address(0));

        if(limitPerHolder > 0) require(owners[_to] < limitPerHolder);
        
        owners[msg.sender] -= 1;
        owners[_to] += 1;
        allocatedTickets[_ticket] = _to;

        TicketTransferred(msg.sender, _to, _ticket, msg.sender);
        return true;
    }

    function transferFrom(address _from, address _to, bytes32 _ticket) onlyAdmin() isEventActive() external returns(bool status) {
        require(_to != address(0) && _from != address(0) && _to != _from);
        require(allocatedTickets[_ticket] == _from && redeemedTickets[_ticket] == address(0));

        if(limitPerHolder > 0) require(owners[_to] < limitPerHolder);

        owners[_from] -= 1;
        owners[_to] += 1;
        allocatedTickets[_ticket] = _to;

        TicketTransferred(_from, _to, _ticket, msg.sender);
        return true;
    }
}

contract SampleEvent is Tickets {
    string public metadata;
    
    function SampleEvent(
        string _version,
        string _ipfs,
        address _addressCT, address _addressTS, 
        uint _saleStart, uint _saleEnd, 
        uint _limit, uint _limitPerHolder, 
        bool _isRefundable, bool _isTransferable) 
        AccessControl(_addressCT, _addressTS)
        EventSettings(_version, _saleStart, _saleEnd, _limit, _limitPerHolder, _isRefundable, _isTransferable)
        public 
    {
        metadata = _ipfs;
    }

    function setMetadataHash(string _ipfs) public returns(bool) {
        metadata = _ipfs;
        return true;
    }
}