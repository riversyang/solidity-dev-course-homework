## 第五课作业参考答案

这个作业其实就是一个简单的合约审计报告，希望大家能认真看懂这个简单的投注赌场合约的逻辑并找出逻辑上和代码书写上的一些问题。

因为版本较早，构造函数还是 function 的形式，但对我们理解整个合约影响不大（它也是一次性执行的初始化处理）。合约里用的 Oraclize 服务也是我希望大家看一下的程序，还是很有参考价值的；即使不关心这个程序，关于 Oracle 的基本思路我们在第二课作业里也已经了解过了，所以我觉得这对我们理解这个合约也没什么太大障碍。

下边是参考答案，合约逻辑上的问题主要集中在最后的奖金发放函数，当然函数可见性问题也要重视。

第1行：pragma 中使用了 `^0.4.11` 来指定使用高于 `0.4.11` 版本的编译器；应该使用固定版本 `0.4.11`。

第14行：变量 `totalBet` 的名字不合适，因为它保存的是所有下注的合计值。应该改为 `totalBets`。

第30行：定义了一个未使用的数组 `players` ；应该把它删除。

第50行：这个 if 条件判断有漏洞，应该增加 else 分支，把 maxAmountOfBets 设置为 LIMIT_AMOUNT_BETS；否则 maxAmountOfBets 将为默认值 10。感觉上这不太合理，不过严格地说并不是错误。

第60行：函数 `checkPlayerExists()` 应该被声明为 `public view` 。

第61行：没有检查输入参数 `player` 是否为 0 地址。应该使用 `require(player != address(0));` 语句来检查。

第69行： `bet()` 函数还是应该加上 `public` 修饰，尽管默认就是 `public`。

第72、75、78、81行：应该使用 `require()` 来检查函数输入参数，而不是 `assert()` 。

第90行：可能会溢出，应该使用 SafeMath 来做这个加法。

第98行： `generateNumberWinner()` 应该是 `internal` 或者 `private` 函数。

第103行： `oraclize_newRandomDSQuery()` 函数的结果应该保存为状态变量，并在 `__callback` 函数中与传入的 queryID 进行检查。

第110行： `__callback()` 函数应该声明为 `external` 。

第117行：应该使用 `require()` 。

第119行：应该使用 `keccak256` 函数代替 `sha3()` 函数。

第125行： `distributePrizes()` 函数应该被声明为 `internal` 或者 `private` 。 

第126行：numberBetPlayers[numberWinner].length 为 0 的情况没有考虑，也就是某个数字没有任何人投注；这种情况是需要特殊处理的，比如可以把奖金平分给所有参加的人；与此对应，第129行的那个奖金发放的循环也应该相应修改。

第126行：这个处理之前应该增加一个处理，判断 this.balance 是否小于 totalBet，如果小于，应该用 this.balance 来计算奖励。这是因为在注册 oraclize 请求时需要支付一定的 price（也就是使用这个外部数据服务的费用，相关逻辑可以在 usingOraclize 的源码中的 oraclize_query 函数中看到），这个 price 会从合约账户的 balance 中扣除，理论上会导致 this.balance 小于 totalBet。

第129行：发放奖金的这个循环，如果获胜者中某个地址是合约地址，且没有声明 payable 的 fallback 函数、或者 fallback 函数使用的 gas 超过 2300，那么这个循环将永远是失败状态，即这个函数会永远失败，所有奖金都会被锁定在这个合约里。这里有两种解决方法，一种是把奖金发放改为 withdraw 模式，即这里不进行直接转账，而另外提供一个提取奖金的函数，供获胜者调用，同时记录获胜者提取情况，直到所有人都提取了奖金才算游戏结束，但对于这个赌场合约来讲这大概并不合理。所以大概会采取第二种方案：在这个循环里用 send 函数进行转账，因为这个函数不会直接导致 revert，而是有返回值，所以某个地址转账失败，仅影响那个地址，这样的话，这个函数就可以正常处理结束；合约中剩余的余额大概还需要设计一个逻辑来处理，但这个合约整体上就可以正常运转了。另外一个简单的方法就是在 bet 函数里限制只能 EOA 来调用。

第134行：这里没有清理 playerBetsNumber，会导致在之前游戏中已经下过注的用户再下注时会无法通过 checkPlayerExists 函数的检查。因为这里清理数据的目的肯定是希望这个合约可以反复使用，所以这个处理当然没有达到设计目标。这里正确的清理方法应该是：

```
// Delete all the players for each number
for(uint j = 1; j <= 10; j++){
    for (uint k = 0; k < numberBetPlayers[j].length; k++) {
        playerBetsNumber[numberBetPlayers[j][k]] = 0;
        numberBetPlayers[j][k] = 0;
    }
    numberBetPlayers[j].length = 0;
}
```

这样还可以得到相应的 gas 返还，并且节省了合约的存储。

