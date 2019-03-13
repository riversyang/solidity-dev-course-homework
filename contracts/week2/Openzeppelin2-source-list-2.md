## OpenZepplin 源代码详解 - part2

#### ERC20

* IERC20 - interface

* ERC20 - contract

  理解 ERC20 标准接口在应用层面的潜在问题（由 allowance 函数和 approve 函数的调用时序所可能引发的错误），也就是 increaseApproval 和 decreaseApproval 这两个函数的意义。

  > ERC20 标准的设计缺陷：
  >
  > 1. Approver 通过 DApp/客户端查询自己在 ERC20 合约中的 allowance，假设是 100；（注意，这通常不是一个交易，而是一次 DApp/客户端向其所连接到的某个节点的本地查询！）
  > 2. Approver 已授权的 spender 发起一个交易，调用 transferFrom，转走了 60，这样 allowance 实际已经变为 40；
  > 3. Approver 觉得授权额度太高了，想降低授权额度，于是发起一个交易，调用 approve 去更改授权额度为 70；（实际情况很有可能是 DApp/客户端在发起这个交易前重新检查了 allowance，这时其数值仍是 100，但因为网络延迟或者 gas 价格的问题，很可能出现在接近的时间内发出的第 2 步的交易被矿工先打包进区块并获得确认的情况；）
  > 4. 以上两个交易完成之后，实际效果是 spender 可以使用 130，而不是 approver 所希望的 70。

* SafeERC20 - library

* ERC20 详情（ERC20Detailed.sol）- contract

* 可销毁的 ERC20（ERC20Burnable.sol）- contract

* 可暂停运作的 ERC20（ERC20Pausable.sol）- contract

* 可增发的 ERC20（ERC20Mintable.sol）- contract

* 有增发上限的 ERC20（ERC20Capped.sol）- contract

* 锁定 Token 的提取（TokenTimelock.sol）

  理解这个合约的逻辑和应用场景。

#### Crowdsale

* Crowdsale - contract

注意 fallback 函数中调用 buyTokens 函数的方式（这种写法并不会产生一个 call/callcode/delegatecall/staticcall，而是一个合约内部代码的跳转，所以运行时上下文没有任何变化）。

理解 buyTokens 函数的逻辑。

#### Crowdsale - validation

* 有上限的 Crowdsale（CappedCrowdsale.sol）- contract
* 有独立上限的 Crowdsale（IndividuallyCappedCrowdsale.sol）- contract
* 有时限的 Crowdsale（TimedCrowdsale.sol）- contract

#### Crowdsale - price

* 自动涨价的 Crowdsale（IncreasingPriceCrowdsale.sol）- contract

#### Crowdsale - emission

* 可增发的 Crowdsale（MintedCrowdsale.sol）- contract
* 有额度的 Crowdsale（AllowanceCrowdsale.sol）- contract

#### Crowdsale - distribution

* 有完结处理的 Crowdsale（FinalizableCrowdsale.sol）- contract
* 后发送 Token 的 Crowdsale（PostDeliveryCrowdsale.sol）- contract
* 可退款的 Crowdsale（RefundableCrowdsale.sol）- contract

#### ERC721

* IERC721 - interface
* IERC721Enumerable - interface
* IERC721Metadata - interface
* IERC721Full - interface
* IERC721Receiver - interface
* ERC721 - contract
* ERC721Burnable - contract
* ERC721Enumerable - contract
* ERC721Metadata - contract
* ERC721Full - contract
* ERC721Mintable - contract
* ERC721MetadataMintable - contract
* ERC721Pausable - contract
* ERC721Holder - contract

