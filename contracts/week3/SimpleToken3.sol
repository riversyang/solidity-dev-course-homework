pragma solidity ^0.4.24;

import "./SimplePrivateSale.sol";
import "../openzeppelin-solidity-2.0.0/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity-2.0.0/contracts/token/ERC20/ERC20.sol";
import "../openzeppelin-solidity-2.0.0/contracts/token/ERC20/ERC20Detailed.sol";

contract SimpleToken3 is Ownable, ERC20, ERC20Detailed {
    // 发行量总量 100 亿
    uint256 public constant INITIAL_SUPPLY              = 10000000000;
    // 私募额度 60 亿
    uint256 public constant PRIVATE_SALE_AMOUNT         = 6000000000;

    // Owner 的钱包地址
    address private ownerWallet;
    // 私募销售合约地址
    address private privateSaleContract;

    /**
     * @dev 构造函数时需传入 Owner 指定的钱包地址
     * @param _ownerWallet Owner 的钱包地址
     */
    constructor(address _ownerWallet)
        ERC20Detailed("SPT", "SPT", 18)
        public
    {
        ownerWallet = _ownerWallet;
        privateSaleContract = new SimplePrivateSale(_ownerWallet, IERC20(address(this)));
        _mint(privateSaleContract, PRIVATE_SALE_AMOUNT * 10 ** uint256(decimals()));
        _mint(msg.sender, (INITIAL_SUPPLY - PRIVATE_SALE_AMOUNT) * 10 ** uint256(decimals()));
    }

    /**
     * @dev 调用私募销售合约添加私募代理人
     * @param _agent 私募代理人地址
     */
    function addPrivateSaleAgent(address _agent) public onlyOwner {
        SimplePrivateSale(privateSaleContract).addAgent(_agent);
    }

    /**
     * @dev 获取私募销售合约地址
     * @return 私募销售合约地址
     */
    function getPrivateSaleContractAddress() public view returns (address) {
        return privateSaleContract;
    }

}
