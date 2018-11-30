## OpenZepplin 源代码详解 - part1

#### 通用基础合约

* 地址工具（AddressUtils.sol）

  注意在合约的构造函数执行过程中，合约的关联代码是空。

* 椭圆曲线公钥恢复（ECRecovery.sol）

  动态类型（比如本例中的 bytes）的数据存储结构和访问方式

* 限制合约余额（LimitBalance.sol）

* Merkle 证明（MerkleProof.sol）

* 拒绝重入（ReentrancyGuard.sol）

  通常建议将函数具体实现和控制调用的 wrapper 分为两个函数。

#### 算术运算

* 基本算数（Math.sol）

* 安全算数（SafeMath.sol）

  注意 assert 的用法：assert 通常用来检查那些 unexpected 数据错误或者正常情况下不会发生的错误（不经常会发生的、小概率错误），不能添加提示消息，不会返还 gas；require 通常用来检查输入参数或者计算结果是否符合设计要求，检查一些正常情况下会发生的错误，比如余额不足、某个特定数据不满足业务功能要求，可以添加提示消息，会返还 gas。

#### 自省（Introspection）

* ERC165

* 接口查询基础合约（SupportsInterfaceWithLookup.sol）

  注意 ShowUsage 合约中如何使用这个接口。

#### 归属权

* 归属权（Ownable.sol）

* 用户角色（Roles.sol）

  注意 struct 和 library 合约的这种常用设计模式。

* 基于角色的访问控制（RBAC.sol）

  学习这种对库合约的使用方法。

  注意事件中将地址信息声明为 indexed。

  注意 mapping 类型对于不存在的 key 的默认值处理方式（例如在 hasRole 函数中）。

* 超级用户（Superuser.sol）

  学习这种经典的用户权限管理模式。

* 归属权转移（Claimable.sol）

* 有时限的归属权转移（DelayedClaimable.sol）

* 归属权继承（Heritable.sol）

  理解整个继承流程的设计：proclaimDeath、heartbeat 和 claimHeirOwnership 函数的制约关系。

* 合约不该归属于合约（HasNoContracts.sol）

  理解第 20 行程序的逻辑：如果目标地址实现了 Ownable 接口、且其 owner 为当前合约地址，则将其 owner 改为当前合约的 owner。
  
  理解这个合约在实践中的意义。（如果一个合约的 owner 是另一个合约，会有什么问题？）
  
* 合约不持有以太币（HasNoEther.sol）

  注意 fallback 函数的用法。
  
* 合约可取回 Token（CanReclaimToken.sol）

  简单地将合约地址所持有的 token 转移到 owner 地址。

* 合约不持有 Token（HasNoTokens.sol）

  注意 revert 的用法：revert 通常用在那些必定要撤销状态修改，或者在复杂的逻辑判断（比如嵌套多层的 if 条件判断）中仅某个分支需要撤销状态修改的情况下；它可以附加提示消息，且会返还 gas。

* 合约什么都不持有（NoOwner.sol）

#### 访问控制

* 签名保镖（SignatureBouncer.sol）

  注意第 113、134 行对 bytes 类型进行初始化的方法。
  
  理解这个模式在实践中的意义。

* 白名单（Whitelist.sol）

#### 生命周期

* 可自毁（Destructible.sol）

* 可暂停运作（Pausable.sol）

* Token 可自毁（TokenDestructible.sol）

#### 支付和悬赏

* 分割付款（SplitPayment.sol）

  注意理解这个合约的数据设计和 claim 函数的逻辑。（为什么不在每次账户余额变动的时候去计算每个 payee 的可提取额度，并单独保存他们的可提取额度？）

  理解这个合约的实践意义（比如可以用于 DAO 或者股东分红等场景）。

* 托管（Escrow.sol）

* 条件托管（ConditionalEscrow.sol）

* 偿还托管（RefundEscrow.sol）

  注意这个合约重写了 deposit 函数；用了一个 enum 来控制合约状态；实现了 ConditionalEscrow 的 withdrawAllowed 函数。

* 需收款人主动提取的付款（PullPayment.sol）

  这是一个安全的付款模式（也就是所谓的 withdraw 模式），有很强的实践意义。

* 悬赏（Bounty.sol）

  理解这个合约的逻辑。

