pragma solidity ^0.4.24;

import "./AgentRole.sol";
import "../openzeppelin-solidity-2.0.0/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "../openzeppelin-solidity-2.0.0/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol";

contract SimplePrivateSale is FinalizableCrowdsale, PostDeliveryCrowdsale, AgentRole {
    // 私募代理人额度上限 9 亿
    uint256 public constant PRIVATE_SALE_AGENT_AMOUNT   = 900000000 * 10 ** 18;
    // 单独地址持有上限 3 亿
    uint256 public constant ADDRESS_HOLDING_AMOUNT      = 300000000 * 10 ** 18;
    // 私募中的 Ether 兑换比率，1 Ether = 100000 SPT
    uint256 public constant EXCHANGE_RATE_IN_PRIVATE_SALE = 100000;
    // 一周时间的时间戳增量常数
    uint256 public constant TIMESTAMP_INCREMENT_OF_WEEK     = 604800;
    // 两个月时间的时间戳增量常数（60天）
    uint256 public constant TIMESTAMP_INCREMENT_OF_2MONTH   = 5184000;

    // 已售出的 token 总量
    uint256 private totalSaledTokens;
    // 私募代理人售出的 token 数量
    mapping(address => uint256) private agentSaledTokens;

    constructor(address wallet, IERC20 token)
        Crowdsale(EXCHANGE_RATE_IN_PRIVATE_SALE, wallet, token)
        TimedCrowdsale(block.timestamp, block.timestamp + TIMESTAMP_INCREMENT_OF_2MONTH)
        public
    {

    }

    /**
     * @dev 重写基础合约的 _finalization 函数，此函数会在 finalize 函数被调用时被执行
     */
    function _finalization() internal {
        super._finalization();
        // 私募期结束后，调用 finalize 函数来将所有销售收入转到 wallet 地址
        wallet().transfer(address(this).balance);
        // 如果 token 没有全部售出，则将剩余 token 转到 wallet 地址
        uint256 totalBalance = token().balanceOf(address(this));
        if (totalSaledTokens < totalBalance) {
            token().transfer(wallet(), totalBalance - totalSaledTokens);
        }
    }

    /**
     * @dev 重写基础合约的 _getTokenAmount 来计算优惠期兑换比率
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256)
    {
        // 计算折扣后实际 token 数量
        uint256 purchaseValue;
        if (block.timestamp <= openingTime().add(TIMESTAMP_INCREMENT_OF_WEEK)) {
            // 私募期的第一周 7 折优惠
            purchaseValue = weiAmount.mul(rate()).mul(10).div(7);
        } else if (block.timestamp <= openingTime().add(TIMESTAMP_INCREMENT_OF_WEEK.mul(2))) {
            // 私募期的第二周 8 折优惠
            purchaseValue = weiAmount.mul(rate()).mul(10).div(8);
        } else if (block.timestamp <= openingTime().add(TIMESTAMP_INCREMENT_OF_WEEK.mul(3))) {
            // 私募期的第三周 9 折优惠
            purchaseValue = weiAmount.mul(rate()).mul(10).div(9);
        } else {
            purchaseValue = weiAmount.mul(rate());
        }
        return purchaseValue;
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *   super._preValidatePurchase(beneficiary, weiAmount);
     *   require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(
        address beneficiary,
        uint256 weiAmount
    )
        internal
        view
        onlyAgent
    {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    /**
     * @dev Overrides parent by storing balances instead of issuing tokens right away.
     * @param beneficiary Token purchaser
     * @param tokenAmount Amount of tokens purchased
     */
    function _processPurchase(
        address beneficiary,
        uint256 tokenAmount
    )
        internal
    {
        super._processPurchase(beneficiary, tokenAmount);
        agentSaledTokens[msg.sender] += tokenAmount;
        totalSaledTokens += tokenAmount;
    }

    /**
     * @dev 重写 _postValidatePurchase 函数来做相关业务的检查
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(
        address beneficiary,
        uint256 weiAmount
    )
        internal
        view
    {
        super._postValidatePurchase(beneficiary, weiAmount);
        // optional override
        require(balanceOf(beneficiary) <= ADDRESS_HOLDING_AMOUNT, "The beneficiary cannot hold over 300 million tokens.");
        require(agentSaledTokens[msg.sender] <= PRIVATE_SALE_AGENT_AMOUNT, "Each agent cannot issue over 900 million tokens.");
        require(totalSaledTokens <= token().balanceOf(address(this)), "Saled tokens' amount exceeded the limitation of private sale.");
    }

    /**
     * @dev 供代理人使用的直接从其可售卖 token 额度中销售的函数
     * @param beneficiary Token purchaser
     * @param tokenAmount Amount of tokens purchased
     */
    function offChainSale(address beneficiary, uint256 tokenAmount) public onlyAgent {
        _processPurchase(beneficiary, tokenAmount);
        _postValidatePurchase(beneficiary, 0);
    }

}
