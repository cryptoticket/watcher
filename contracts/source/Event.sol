pragma solidity ^0.4.23;

contract AccessControl {
    address public addressCT;
    address public addressTS;
    address public addressOG;

    mapping (address => bool) public sellers;

    bool isPaused = false;
    bool isCancelled = false;

    modifier onlyCT() {require(msg.sender == addressCT, "Access restricted"); _;}
    modifier onlyTS() {require(msg.sender == addressTS, "Access restricted"); _;}
    modifier onlyAdmin() {
        require(
            msg.sender == addressCT ||
            msg.sender == addressTS ||
            msg.sender == addressOG, "Access restricted"
        );
        _;
    }
    modifier onlySeller() {require(sellers[msg.sender] == true, "Access restricted"); _;}
    modifier isEventActive() {
        require(!isPaused && !isCancelled, "Event is paused");
        require(!isPaused && !isCancelled, "Event is canceled");
        _;
    }

    constructor (address _addressCT, address _addressTS, address _addressOG) public {
        addressCT = _addressCT;
        addressTS = _addressTS;
        addressOG = _addressOG;

        sellers[_addressCT] = true;
        sellers[_addressTS] = true;
        sellers[_addressOG] = true;
    }

    function setTS(address _addressTS) onlyCT() external {
        require(_addressTS != address(0), "Invalid address");
        addressTS = _addressTS;
    }

    function setOG(address _addressOG) onlyCT() external {
        require(_addressOG != address(0), "Invalid address");
        addressOG = _addressOG;
    }

    function setSeller(address _seller) onlyAdmin() external {
        require(_seller != address(0), "Invalid address");
        sellers[_seller] = true;
    }

    function unsetSeller(address _seller) onlyAdmin() external {
        require(_seller != address(0), "Invalid address");
        sellers[_seller] = false;
    }

    function pause() onlyAdmin() isEventActive() external {
        isPaused = true;
    }

    function unpause() onlyAdmin() external {
        require(isPaused, "Event is active");
        require(!isCancelled, "Event is cancelled");
        isPaused = false;
    }

    function cancel() onlyCT() external {
        isCancelled = true;
    }
}


contract EventSettings {
    uint public saleStart;
    uint public saleEnd;

    uint public allocated;
    uint public limitTotal;
    uint public limitPerHolder;

    bool isRefundable;
    bool isTransferable;

    modifier refundable() {require(isRefundable, "Event tickets is not refundable"); _;}
    modifier transferable() {require(isTransferable, "Event tickets is not transferable"); _;}

    modifier isSaleActive() {
        require(now > saleStart, "Event tickets sale not started yet");
        require(now < saleEnd, "Event tickets sale is finished");
        _;
    }

    constructor (
        uint _saleStart,
        uint _saleEnd,
        uint _limitTotal,
        uint _limitPerHolder,
        bool _isRefundable,
        bool _isTransferable
    )
        public
    {
        saleStart = _saleStart;
        saleEnd = _saleEnd;

        limitTotal = _limitTotal;
        limitPerHolder = _limitPerHolder;

        isRefundable = _isRefundable;
        isTransferable = _isTransferable;
    }
}


contract TicketsManagement is AccessControl, EventSettings {
    mapping (address => uint) public owners;
    mapping (bytes32 => address) public allocatedTickets;
    mapping (bytes32 => address) public redeemedTickets;

    event TicketAllocated(address _to, bytes32 _ticket, address _manager);
    event TicketRefunded(address _to, bytes32 _ticket, address _manager);
    event TicketRedeemed(address _from, bytes32 _ticket, address _manager);
    event TicketTransferred(address _from, address _to, bytes32 _ticket, address _manager);

    function allocate(address _to, bytes32 _ticket)
        onlyAdmin()
        isEventActive()
        isSaleActive()
        external
        returns(bool status)
    {
        require(_to != address(0), "Invalid address");
        require(allocatedTickets[_ticket] == address(0), "Ticket allocated");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        if (limitTotal > 0) {require(allocated < limitTotal, "Ticket limit exceeded");}
        if (limitPerHolder > 0) {require(owners[_to] < limitPerHolder, "Customer ticket limit exceeded");}

        allocated++;
        allocatedTickets[_ticket] = _to;
        owners[_to] += 1;

        emit TicketAllocated(_to, _ticket, msg.sender);
        return true;
    }

    function transfer(address _to, bytes32 _ticket)
        isEventActive()
        isSaleActive()
        external
        returns(bool status)
    {
        require(_to != address(0) && _to != msg.sender, "Invalid address");
        require(allocatedTickets[_ticket] == msg.sender, "Ticket not belong to customer");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        if (limitPerHolder > 0) {require(owners[_to] < limitPerHolder, "Customer ticket limit exceeded");}

        allocatedTickets[_ticket] = _to;
        owners[msg.sender] -= 1;
        owners[_to] += 1;

        emit TicketTransferred(msg.sender, _to, _ticket, msg.sender);
        return true;
    }

    function transferFrom(address _from, address _to, bytes32 _ticket)
        onlyAdmin()
        isEventActive()
        isSaleActive()
        external
        returns(bool status)
    {
        require(_to != address(0) && _from != address(0) && _to != _from, "Invalid address");
        require(allocatedTickets[_ticket] == _from, "Ticket not belong to customer");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        if (limitPerHolder > 0) {require(owners[_to] < limitPerHolder, "Customer ticket limit exceeded");}

        allocatedTickets[_ticket] = _to;
        owners[_from] -= 1;
        owners[_to] += 1;

        emit TicketTransferred(_from, _to, _ticket, msg.sender);
        return true;
    }

    function redeem(address _from, bytes32 _ticket)
        onlyAdmin()
        isEventActive()
        external
        returns(bool status)
    {
        require(_from != address(0), "Invalid address");
        require(allocatedTickets[_ticket] == _from, "Ticket not belong to customer");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        redeemedTickets[_ticket] = _from;
        owners[_from] -= 1;

        emit TicketRedeemed(_from, _ticket, msg.sender);
        return true;
    }

    function refund(address _to, bytes32 _ticket)
        onlyAdmin()
        refundable()
        external
        returns(bool status)
    {
        require(_to != address(0), "Invalid address");
        require(allocatedTickets[_ticket] == _to, "Ticket not belong to customer");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        allocated--;
        allocatedTickets[_ticket] = address(0);
        owners[_to] -= 1;

        emit TicketRefunded(_to, _ticket, msg.sender);
        return true;
    }
}


contract Event is TicketsManagement {
    string public version;
    string public metadata;

    event MetadataUpdated(string _metadata);

    constructor (
        string _version,
        string _ipfs,
        address _addressCT,
        address _addressTS,
        address _addressORG,
        uint _saleStart,
        uint _saleEnd,
        uint _limit,
        uint _limitPerHolder,
        bool _isRefundable,
        bool _isTransferable
    ) AccessControl(
        _addressCT,
        _addressTS,
        _addressORG
    ) EventSettings(
        _saleStart,
        _saleEnd,
        _limit,
        _limitPerHolder,
        _isRefundable,
        _isTransferable
    )
        public
    {
        version = _version;
        metadata = _ipfs;
    }

    function updateMetadata(string _ipfs) external onlyAdmin() returns(bool) {
        metadata = _ipfs;

        emit MetadataUpdated(_ipfs);
        return true;
    }
}