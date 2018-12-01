pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/AddressUtils.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "../openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract SimpleToken is Ownable, RBAC, StandardToken {
    using AddressUtils for address;
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
        balances[msg.sender] = totalSupply_;
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
     * @param _amount 私募代理人的转账限额
     */
    function addAddressToPrivateWhiteList(address _addr, uint256 _amount)
        public onlyOwner
    {
        // TODO
        // 仅允许在合约创建两个月内调用
        require(block.timestamp <= contractStartTime.add(TIMESTAMP_INCREMENT_OF_2MONTH));

        addRole(_addr, ROLE_PRIVATESALEWHITELIST);
        approve(_addr, _amount);
    }

    /**
     * @dev 将私募代理人地址从白名单移除
     * @param _addr 私募代理人地址
     */
    function removeAddressFromPrivateWhiteList(address _addr)
        public onlyOwner
    {
        // TODO
        removeRole(_addr, ROLE_PRIVATESALEWHITELIST);
        approve(_addr, 0);
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
        // TODO
        // 仅允许 EOA 购买
        require(msg.sender == tx.origin);
        require(!msg.sender.isContract());
        // 仅允许在合约创建两个月内调用
        require(block.timestamp <= contractStartTime.add(TIMESTAMP_INCREMENT_OF_2MONTH));

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

        _privateSaleTransferFromOwner(_beneficiary, purchaseValue);
    }

    /**
     * @dev 人工私募处理，即直接用私募代理人的额度进行转账
     * @param _addr 收取 token 地址
     * @param _amount 转账 token 数量
     */
    function withdrawPrivateSaleCoins(address _addr, uint256 _amount)
        public onlyRole(ROLE_PRIVATESALEWHITELIST)
    {
        // TODO
        // 仅允许在合约创建两个月内调用
        require(block.timestamp <= contractStartTime.add(TIMESTAMP_INCREMENT_OF_2MONTH));

        _privateSaleTransferFromOwner(_addr, _amount);
    }

    /**
     * @dev 私募转账处理(从 Owner 持有的余额中转出)
     * @param _to 转入地址
     * @param _amount 转账数量
     */
    function _privateSaleTransferFromOwner(address _to, uint256 _amount)
        private returns (bool)
    {
        uint256 newPrivateSaleAmount = privateSalesReleased[msg.sender].add(_amount);
        uint256 newTotalPrivateSaleAmount = totalPrivateSalesReleased.add(_amount);
        // 检查私募代理人转账总额是否超限
        require(newPrivateSaleAmount <= PRIVATE_SALE_AGENT_AMOUNT);
        // 检查私募转账总额是否超限
        require(newTotalPrivateSaleAmount <= PRIVATE_SALE_AMOUNT);

        require(super.transferFrom(owner, _to, _amount));
        privateSalesReleased[msg.sender] = newPrivateSaleAmount;
        totalPrivateSalesReleased = newTotalPrivateSaleAmount;
        return true;
    }

    /**
     * @dev 合约余额提取
     */
    function withdrawFunds() public onlyOwner {
         // TODO
        require(block.timestamp > contractStartTime.add(TIMESTAMP_INCREMENT_OF_2MONTH));

        ownerWallet.transfer(address(this).balance);
    }

    /**
     * @dev 获得私募代理人地址已转出（售出）的 token 数量
     * @param _addr 私募代理人地址
     * @return 私募代理人地址的已转出的 token 数量
     */
    function privateSaleReleased(address _addr) public view returns (uint256) {
        return privateSalesReleased[_addr];
    }

    /**
     * @dev 重写基础合约的 transfer 函数
     */
    function transfer(address _to, uint256 _value)
        public returns (bool result)
    {
        // 记得调用 super.transfer 函数
        // TODO
        // 在合约创建后的两个月内，仅 owner 可以用 transfer 函数转账
        if (msg.sender != owner) {
            require(block.timestamp > contractStartTime.add(TIMESTAMP_INCREMENT_OF_2MONTH));
        }
        // 转账后目标地址的余额不能超过单个地址所能持有的 token 量上限
        require(balances[_to].add(_value) <= ADDRESS_HOLDING_AMOUNT);

        if (msg.sender == owner && block.timestamp <= contractStartTime.add(TIMESTAMP_INCREMENT_OF_2MONTH)) {
            // 在私募期间，owner 的转账额度需要算在私募总额度中
            uint256 newTotalPrivateSaleAmount = totalPrivateSalesReleased.add(_value);
            // 检查私募转账总额是否超限
            require(newTotalPrivateSaleAmount <= PRIVATE_SALE_AMOUNT);
            result = super.transfer(_to, _value);
            totalPrivateSalesReleased = newTotalPrivateSaleAmount;
        } else {
            result = super.transfer(_to, _value);
        }
        return result;
    }

    /**
     * @dev 重写基础合约的 transferFrom 函数
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        // 记得调用 super.transferFrom 函数
        // TODO
        // 在合约创建后的两个月内，仅私募代理人可以用 transferFrom 函数转账
        if (!hasRole(msg.sender, ROLE_PRIVATESALEWHITELIST)) {
            require(block.timestamp > contractStartTime.add(TIMESTAMP_INCREMENT_OF_2MONTH));
        }
        // 转账后目标地址的余额不能超过单个地址所能持有的 token 量上限
        require(balances[_to].add(_value) <= ADDRESS_HOLDING_AMOUNT);
        if (hasRole(msg.sender, ROLE_PRIVATESALEWHITELIST)) {
            if (block.timestamp <= contractStartTime.add(TIMESTAMP_INCREMENT_OF_2MONTH)) {
                return _privateSaleTransferFromOwner(_to, _value);
            }
        }
        return super.transferFrom(_from, _to, _value);
    }

}
