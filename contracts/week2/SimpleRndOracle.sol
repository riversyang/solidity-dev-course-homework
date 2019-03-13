pragma solidity ^0.4.24;

import "../openzeppelin-solidity-2.0.0/contracts/utils/Address.sol";
import "../openzeppelin-solidity-2.0.0/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity-2.0.0/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity-2.0.0/contracts/introspection/ERC165Checker.sol";

contract SimpleRndOracle is Ownable {
    // 使用 Address 库合约
    using Address for address;
    // 使用 SafeMath 库合约
    using SafeMath for uint256;
    // 使用 ERC165Checker 库合约
    using ERC165Checker for address;
    // 接受数据回调的函数选择器常量：bytes4(keccak256("receiveRnd(uint256)"))
    bytes4 public constant CALLBACK_FUNC_SIG = 0xa46d5843;
    // 记录所有请求服务的地址的数组
    address[] private allRequesters;
    // 请求数据服务的地址到其请求计数的映射
    mapping (address => uint256) private requesterNonce;
    // 请求数据服务的地址到其当前 requestID 的映射
    mapping (address => uint256) private requestIDs;
    // requestID 到其结果接收地址的映射
    mapping (uint256 => address) private callbackAddresses;
    // 此合约所信任的唯一的数据源地址
    address private trustedDataSource;
    // 通知外部世界已经接收到一个数据请求（已成功注册一个数据请求）
    event requestRegistered(address indexed _addr, uint256 _requestID);

    /**
     * @dev 构造函数
     * @param _trustedDataSource 合约信任的外部数据服务签名地址
     */
    constructor (address _trustedDataSource) public {
        trustedDataSource = _trustedDataSource;
    }

    /**
     * @dev 可接受捐赠的 fallback 函数
     */
    function() public payable {
        // empty fallback function to receive donation
    }

    /**
     * @dev 只允许 owner 调用的修改外部数据服务地址的函数
     * @param _trustedDataSource 合约信任的外部数据服务签名地址
     */
    function changeTrustedDataSource(address _trustedDataSource)
        public onlyOwner
    {
        trustedDataSource = _trustedDataSource;
    }

    /**
     * @dev 只允许 owner 使用的销毁服务合约并取回捐赠的函数
     */
    function destoryOracle() public onlyOwner {
        selfdestruct(owner());
    }

    /**
     * @dev 确保调用方是合约制定的信任数据源地址
     */
    modifier isTrustedDataSource() {
        require(trustedDataSource == msg.sender, "You are not trusted party.");
        _;
    }

    /**
     * @dev 供任意合约调用的注册随机数数据请求的函数
     */
    function registerRequest() external {
        // 需要注册的地址必须是合约地址
        require(msg.sender.isContract(), "Only contract address can register requests.");
        // TODO: add implementation
        // 注意，这里应该检查接收数据的合约是否有必要的回调函数
        require(msg.sender._supportsInterface(CALLBACK_FUNC_SIG), "Your constract does not support necessary interface.");
        // 这个检查不是必须的，但推荐增加，因为照目前的设计，同一个地址调用多次时只会保留最后一次调用的 requestID，而外部数据服务依然会多次返回数据，会有相应的资源浪费。并且这多次注册未必时“设计中的”，所以在此加入对是否已注册数据请求的检查是一种相对安全的数据服务设计。
        require(requestIDs[msg.sender] == 0, "You already registered a request, please wait.");
        uint256 nonce = requesterNonce[msg.sender].add(1);
        // requestID 应该是一个全局唯一的数值，因为这个合约是一个公共数据服务，所以其生成算法可以参考以太坊协议中生成新合约地址的算法。
        uint256 requestId = uint256(keccak256(abi.encodePacked(msg.sender, nonce)));
        requesterNonce[msg.sender] = nonce;
        requestIDs[msg.sender] = requestId;
        callbackAddresses[requestId] = msg.sender;
        emit requestRegistered(msg.sender, requestId);
    }

    /**
     * @dev 供外部数据服务地址调用的返回数据函数
     * @param _requestID 请求 ID
     * @param _rndNumber 返回的随机数
     */
    function feedbackRndData(uint256 _requestID, uint256 _rndNumber)
        external isTrustedDataSource
    {
        // TODO: add implementation
        // 以下两个处理是为了清理已经用过的数据，且能得到 gas 返还，是推荐的最佳实践
        IRndNumberReceiver receiver = IRndNumberReceiver(callbackAddresses[_requestID]);
        requestIDs[address(receiver)] = 0;
        callbackAddresses[_requestID] = 0;
        receiver.receiveRnd(_rndNumber);
    }

}

/**
 * @dev 接收随机数返回的 callback 接口，
 */
interface IRndNumberReceiver {
    function receiveRnd(uint256) external;
}
