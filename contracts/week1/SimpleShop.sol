pragma solidity ^0.4.24;

contract SimpleShop {
    // 一天的秒数
    uint256 public constant SECONDS_OF_DAY = 3600 * 24;
    // 订单状态枚举
    enum State { Created, Aborted, Confirmed, Completed }
    // 订单数据 struct
    struct Purchase {
        uint256 number;
        uint256 createdTime;
        uint256 confirmedTime;
        uint256 value;
        address buyer;
        State state;
    }
    // 所有订单数据
    Purchase[] private allPurchases;
    // 店铺主人（卖家）地址
    address public seller;
    // 订单状态变动事件
    event PurchaseCreated(uint256 number);
    event PurchaseAborted(uint256 number);
    event PurchaseConfirmed(uint256 number);
    event PurchaseCompleted(uint256 number);

    constructor() public {
        seller = msg.sender;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this function.");
        _;
    }

    modifier isValidPurchaseNumber(uint256 _number) {
        require(_number <= allPurchases.length, "Invalid purchase number.");
        _;
    }

    /**
     * @dev 创建订单
     * @param _value 订单金额
     * @notice 需同时转入两倍订单金额的 Ether
     */
    function createPurchase(uint256 _value) public payable onlySeller {
        require(msg.value == _value * 2, "You need to transfer double amount of Purchase value.");
        Purchase memory newPurchase = Purchase({
            number: allPurchases.length + 1,
            createdTime: block.timestamp,
            confirmedTime: 0,
            value: _value,
            buyer: address(0),
            state: State.Created
        });
        allPurchases.push(newPurchase);
        emit PurchaseCreated(newPurchase.number);
    }

    /**
     * @dev 取消订单
     * @param _number 要取消的订单编号
     */
    function abortPurchase(uint256 _number) public onlySeller isValidPurchaseNumber(_number) {
        Purchase storage cp = allPurchases[_number - 1];
        require(cp.state == State.Created, "You can only abort a purchase which is just created.");
        cp.state = State.Aborted;
        emit PurchaseAborted(_number);
        seller.transfer(cp.value * 2);
    }

    /**
     * @dev 确认订单
     * @param _number 要确认的订单编号
     * @notice 需同时转入两倍订单金额的 Ether
     */
    function confirmPurchase(uint256 _number) public payable isValidPurchaseNumber(_number) {
        Purchase storage cp = allPurchases[_number - 1];
        require(cp.state == State.Created, "You can only confirm a purchase which is just created.");
        require(msg.value == cp.value * 2, "You need to transfer double amount of Purchase value.");
        cp.confirmedTime = block.timestamp;
        cp.buyer = msg.sender;
        cp.state = State.Confirmed;
        emit PurchaseConfirmed(_number);
    }

    /**
     * @dev 确认收货
     * @param _number 要确认的订单编号
     */
    function confirmReceived(uint256 _number) public isValidPurchaseNumber(_number) {
        Purchase storage cp = allPurchases[_number - 1];
        require(cp.state == State.Confirmed, "You can only confirm received for a confirmed purchase.");
        if (block.timestamp - cp.confirmedTime > SECONDS_OF_DAY) {
            if (msg.sender != cp.buyer && msg.sender != seller) {
                revert("Only seller and buyer can confirm received for this purchase now.");
            }
        } else {
            if (msg.sender != cp.buyer) {
                revert("Only buyer can confirm received for this purchase now.");
            }
        }
        cp.state = State.Completed;
        emit PurchaseCompleted(_number);
        cp.buyer.transfer(cp.value);
        seller.transfer(cp.value * 3);
    }

    function getPurchaseCount() public view returns (uint256) {
        return allPurchases.length;
    }

    function getPurchaseValue(uint256 _number)
        public view isValidPurchaseNumber(_number)
        returns (uint256)
    {
        Purchase storage cp = allPurchases[_number - 1];
        return cp.value;
    }

    function getPurchaseCreatedTime(uint256 _number)
        public view isValidPurchaseNumber(_number)
        returns (uint256)
    {
        Purchase storage cp = allPurchases[_number - 1];
        return cp.createdTime;
    }

    function getPurchaseBuyer(uint256 _number)
        public view isValidPurchaseNumber(_number)
        returns (address)
    {
        Purchase storage cp = allPurchases[_number - 1];
        return cp.buyer;
    }

    function getPurchaseState(uint256 _number)
        public view isValidPurchaseNumber(_number)
        returns (uint256)
    {
        Purchase storage cp = allPurchases[_number - 1];
        return uint256(cp.state);
    }

}