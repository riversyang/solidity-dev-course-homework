# 第二课作业

### 编程题1：

基于 SimplePoS 合约，读懂其数据结构和已经完成的 addMiner、removeMiner 函数，然后完成 selectNewMiner 函数，基于矿工的 stake 数值随机选出一个新矿工即可。随机数可以不用 Oracle 获取。

比如有两个矿工，矿工 1 的 stake 是 4，矿工 2 的 stake 是 6，则要求算法每次选取当前矿工时，矿工 1 有 40% 的几率被选中，矿工 2 有 60% 的几率被选中。

### 编程题2：

读懂 SimpleRndOracle 合约，完成其中的 registerRequest 函数和 feedbackRndData 函数；并尝试编写测试合约和 truffle 测试程序来测试这个合约。

![](./image/OraclePattern.png)

truffle 测试程序中可以直接用常量设定返回的随机数值，测试合约能收到在测试程序中设定的这个常量即可。
