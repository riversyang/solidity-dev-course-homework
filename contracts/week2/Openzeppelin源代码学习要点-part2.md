## OpenZepplin 源代码详解 - part2

#### ERC20

* ERC20Basic（ERC20Basic.sol）

* BasicToken（BasicToken.sol）

* ERC20（ERC20.sol）

* SafeERC20（SafeERC20.sol）

  理解这里仅仅增加 require 检查的意义。

* ERC20 详情（DetailedERC20.sol）

  理解 decimals 的意义。

* 标准 Token（StandardToken.sol）

  理解 ERC20 标准接口在应用层面的潜在问题（由 allowance 函数和 approve 函数的调用时序所可能引发的错误），也就是 increaseApproval 和 decreaseApproval 这两个函数的意义。

* 可销毁的 Token（BurnableToken.sol）

* 可销毁的标准 Token（StandardBurnableToken.sol）

* 可暂停运作的标准 Token（PausableToken.sol）

* 可增发的标准 Token（MintableToken.sol）

* 有增发上限的标准 Token（CappedToken.sol）

* 可授权增发的标准 Token（RBACMintableToken.sol）

* 锁定 Token 的提取（TokenTimelock.sol）

  理解这个合约的逻辑和应用场景。

* 定期发放 Token（TokenVesting.sol）

  理解这个合约的逻辑（它涉及三个账户）和应用场景（基于 Token 的工资发放、收益发放、养老金等等）。

#### Crowdsale

* Crowdsale（Crowdsale.sol）

注意 fallback 函数中调用 buyTokens 函数的方式（这种写法并不会产生一个 call/callcode/delegatecall/staticcall，而是一个合约内部代码的跳转，所以运行时上下文没有任何变化）。

理解 buyTokens 函数的逻辑。

* 有上限的 Crowdsale（CappedCrowdsale.sol）

* 有独立上限的 Crowdsale（IndividuallyCappedCrowdsale.sol）

* 有时限的 Crowdsale（TimedCrowdsale.sol）

* 有白名单的 Crowdsale（WhitelistedCrowdsale.sol）

* 自动涨价的 Crowdsale（IncreasingPriceCrowdsale.sol）

* 可增发的 Crowdsale（MintedCrowdsale.sol）

* 有额度的 Crowdsale（AllowanceCrowdsale.sol）

* 有完结处理的 Crowdsale（FinalizableCrowdsale.sol）

* 后发送 Token 的 Crowdsale（PostDeliveryCrowdsale.sol）

* 可退款的 Crowdsale（RefundableCrowdsale.sol）

#### ERC721

* ERC721Basic（ERC721Basic.sol）

* ERC721（ERC721.sol）

* ERC721Receiver（ERC721Receiver.sol）

* ERC721Holder（ERC721Holder.sol）

* ERC721BasicToken（ERC721BasicToken.sol）

* ERC721Token（ERC721Token.sol）

