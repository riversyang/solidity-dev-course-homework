pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "../openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

/**
* @dev 初始token改由合约保管
* @dev 管理员的私募转币/私募后提币通过 withdrawPrivateSaleCoinsByOwner 实现
*/
contract SimpleToken2 is Ownable, RBAC, StandardToken {
    using SafeMath for uint256;

    string public constant name    = "SPT";
    string public constant symbol  = "SPT";
    uint8 public constant decimals = 18;

    // 发行量总量 100 亿
    uint256 public constant INITIAL_SUPPLY              = 10000000000 * (10 ** uint256(decimals));
    // 私募额度 60 亿
    uint256 public constant PRIVATE_SALE_AMOUNT         = 6000000000 * (10 ** uint256(decimals));
    // 私募代理人额度上限 9 亿
    uint256 public constant PRIVATE_SALE_AGENT_AMOUNT   = 900000000 * (10 ** uint256(decimals));
    // 单独地址持有上限 3 亿
    uint256 public constant ADDRESS_HOLDING_AMOUNT      = 300000000 * (10 ** uint256(decimals));

    // 私募中的 Ether 兑换比率，1 Ether = 100000 SPT
    uint256 public constant EXCHANGE_RATE_IN_PRIVATE_SALE = 100000;

    // 一周时间的时间戳增量常数
    uint256 public constant TIMESTAMP_INCREMENT_OF_WEEK     = 604800;
    // 两个月时间的时间戳增量常数（60天）
    uint256 public constant TIMESTAMP_INCREMENT_OF_2MONTH   = 5184000;

    // 私募代理人的 Role 常量
    string public constant ROLE_PRIVATESALEWHITELIST = "privateSaleWhitelist";

    // 合约创建的时间戳
    uint256 public contractStartTime;

    // 所有私募代理人的已分发数额总数
    uint256 public totalPrivateSalesReleased;

    // 私募代理人实际转出（售出）的 token 数量映射
    mapping (address => uint256) private privateSalesReleased;

    // Owner 的钱包地址
    address ownerWallet;

    /**
     * @dev 构造函数时需传入 Owner 指定的钱包地址
     * @param _ownerWallet Owner 的钱包地址
     */
    constructor(address _ownerWallet) public {
        ownerWallet = _ownerWallet;
        contractStartTime = block.timestamp;
        totalSupply_ = INITIAL_SUPPLY;
        balances[address(this)] = totalSupply_;
    }

    /**
     * @dev 变更 Owner 的钱包地址
     * @param _ownerWallet Owner 的钱包地址
     */
    function changeOwnerWallet(address _ownerWallet) public onlyOwner {
        ownerWallet = _ownerWallet;
    }

    /**
     * @dev 添加私募代理人地址到白名单并设置其限额
     * @param _addr 私募代理人地址
     */
    function addAddressToPrivateWhiteList(address _addr)
        public onlyOwner
    {
        addRole(_addr, ROLE_PRIVATESALEWHITELIST);
    }

    /**
     * @dev 将私募代理人地址从白名单移除
     * @param _addr 私募代理人地址
     */
    function removeAddressFromPrivateWhiteList(address _addr)
        public onlyOwner
    {
        removeRole(_addr, ROLE_PRIVATESALEWHITELIST);
    }

    /**
     * @dev 允许接受转账的 fallback 函数
     */
    function() external payable {
        privateSale(msg.sender);
    }

    /**
     * @dev 私募处理
     * @param _beneficiary 收取 token 地址
     */
    function privateSale(address _beneficiary)
        public payable onlyRole(ROLE_PRIVATESALEWHITELIST)
    {
        // 计算折扣后实际 token 数量
        uint256 purchaseValue;
        if (block.timestamp <= contractStartTime.add(TIMESTAMP_INCREMENT_OF_WEEK)) {
            // 私募期的第一周 7 折优惠
            purchaseValue = msg.value.mul(EXCHANGE_RATE_IN_PRIVATE_SALE).mul(10).div(7);
        } else if (block.timestamp <= contractStartTime.add(TIMESTAMP_INCREMENT_OF_WEEK.mul(2))) {
            // 私募期的第二周 8 折优惠
            purchaseValue = msg.value.mul(EXCHANGE_RATE_IN_PRIVATE_SALE).mul(10).div(8);
        } else if (block.timestamp <= contractStartTime.add(TIMESTAMP_INCREMENT_OF_WEEK.mul(3))) {
            // 私募期的第三周 9 折优惠
            purchaseValue = msg.value.mul(EXCHANGE_RATE_IN_PRIVATE_SALE).mul(10).div(9);
        } else {
            purchaseValue = msg.value.mul(EXCHANGE_RATE_IN_PRIVATE_SALE);
        }
        // 检查私募总额度
        totalPrivateSalesReleased = totalPrivateSalesReleased.add(purchaseValue);
        require(totalPrivateSalesReleased <= PRIVATE_SALE_AMOUNT);
        // 检查私募代理人个人额度
        privateSalesReleased[msg.sender] = privateSalesReleased[msg.sender].add(purchaseValue);
        require(privateSalesReleased[msg.sender] <= PRIVATE_SALE_AGENT_AMOUNT);
        // 转账
        this.transfer(_beneficiary, purchaseValue);
    }

    /**
     * @dev 人工私募处理，即直接用私募代理人的额度进行转账
     * @param _addr 收取 token 地址
     * @param _amount 转账 token 数量
     */
    function withdrawPrivateSaleCoins(address _addr, uint256 _amount)
        public onlyRole(ROLE_PRIVATESALEWHITELIST)
    {
        // 检查私募总额度
        totalPrivateSalesReleased = totalPrivateSalesReleased.add(_amount);
        require(totalPrivateSalesReleased <= PRIVATE_SALE_AMOUNT);
        // 检查私募代理人个人额度
        privateSalesReleased[msg.sender] = privateSalesReleased[msg.sender].add(_amount);
        require(privateSalesReleased[msg.sender] <= PRIVATE_SALE_AGENT_AMOUNT);
        // 转账
        this.transfer(_addr, _amount);
    }

    /**
     * @dev 管理员人工私募（私募期中）/管理员提币（私募期后）
     * @param _addr 收取 token 地址
     * @param _amount 转账 token 数量
     */
    function withdrawPrivateSaleCoinsByOwner(address _addr, uint256 _amount)
        public onlyOwner
    {
        require(totalPrivateSalesReleased.add(_amount) <= PRIVATE_SALE_AMOUNT || isPrivateSaleFinished());
        if (!isPrivateSaleFinished()) {
            totalPrivateSalesReleased = totalPrivateSalesReleased.add(_amount);
        }
        this.transfer(_addr, _amount);
    }

    /**
     * @dev 合约余额提取
     */
    function withdrawFunds() public onlyOwner {
        require(isPrivateSaleFinished());
        ownerWallet.transfer(address(this).balance);
    }

    /**
     * @dev 获得私募代理人地址已转出（售出）的 token 数量
     * @param _addr 私募代理人地址
     * @return 私募代理人地址的已转出的 token 数量
     */
    function privateSaleReleased(address _addr) public view returns(uint256) {
        return privateSalesReleased[_addr];
    }

    /**
     * @dev 新transfer保证地址的token余额不大于总量的3%
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(isPrivateSaleFinished() || msg.sender == address(this));
        require(_value.add(balances[_to]) <= ADDRESS_HOLDING_AMOUNT);
        super.transfer(_to, _value);
    }

    /**
     * @dev 新transferFrom保证地址的token余额不大于总量的3%
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(isPrivateSaleFinished());
        require(_value.add(balances[_to]) <= ADDRESS_HOLDING_AMOUNT);
        super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev 检查私募是否已经结束
     */
    function isPrivateSaleFinished() internal view returns (bool) {
        return block.timestamp > contractStartTime + TIMESTAMP_INCREMENT_OF_2MONTH;
    }

}
