pragma solidity ^0.4.24;

import "../openzeppelin-solidity-2.0.0/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity-2.0.0/contracts/access/Roles.sol";
import "../openzeppelin-solidity-2.0.0/contracts/token/ERC20/ERC20.sol";

contract SimpleToken is Ownable, ERC20 {
    // 使用 SafeMath
    using SafeMath for uint256;
    // 使用 Roles
    using Roles for Roles.Role;

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

    // 代理人角色名单
    Roles.Role private agents;
    // 添加代理人
    event AgentAdded(address indexed account);
    // 移除代理人
    event AgentRemoved(address indexed account);

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
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    modifier onlyAgent() {
        require(isAgent(msg.sender), "Only agents can call the function.");
        _;
    }

    function isAgent(address account) public view returns (bool) {
        return agents.has(account);
    }

    /**
     * @dev 添加私募代理人地址到白名单并设置其限额
     * @param _account 私募代理人地址
     * @param _amount 私募代理人的转账限额
     */
    function addAgent(address _account, uint256 _amount) public onlyOwner {
        // TODO
    }

    /**
     * @dev 将私募代理人地址从白名单移除
     * @param _account 私募代理人地址
     */
    function removeAgent(address _account) public onlyOwner {
        // TODO
    }

    /**
     * @dev 私募代理人自己放弃代理人权限
     */
    function renounceAgent() public onlyAgent {
        // TODO
    }

    function _addAgent(address account) internal {
        agents.add(account);
        emit AgentAdded(account);
    }

    function _removeAgent(address account) internal {
        agents.remove(account);
        emit AgentRemoved(account);
    }

    /**
     * @dev 变更 Owner 的钱包地址
     * @param _ownerWallet Owner 的钱包地址
     */
    function changeOwnerWallet(address _ownerWallet) public onlyOwner {
        ownerWallet = _ownerWallet;
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
    function privateSale(address _beneficiary) public payable onlyAgent
    {
        // TODO
    }

    /**
     * @dev 人工私募处理，即直接用私募代理人的额度进行转账
     * @param _addr 收取 token 地址
     * @param _amount 转账 token 数量
     */
    function withdrawPrivateSaleCoins(address _addr, uint256 _amount) public onlyAgent
    {
        // TODO
    }

    /**
     * @dev 合约余额提取
     */
    function withdrawFunds() public onlyOwner {
         // TODO
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
     * @dev 重写基础合约的 transfer 函数
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        // 记得调用 super.transfer 函数
        // TODO
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
    }

}