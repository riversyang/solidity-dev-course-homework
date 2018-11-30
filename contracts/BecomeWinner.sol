pragma solidity ^0.4.24;

contract BecomeWinner {
    // 游戏持续时间常量
    uint256 public constant INIT_DURATION = 3600;
    // 游戏持续时间增量
    uint256 public constant DURATION_INCREMENT = 30;
    // 游戏的结束时间
    uint256 public endTime;
    // 最终赢家地址
    address public winner;

    constructor() public payable {
        endTime = block.timestamp + INIT_DURATION;
        winner = msg.sender;
    }

    function() public payable {
    }

    function becomeWinner() external payable {
        require(msg.value > 0, "You must pay a little ether to become winner.");
        require(block.timestamp < endTime, "Game ended.");
        endTime = endTime + DURATION_INCREMENT;
        winner = msg.sender;
    }

    function withdrawPrize() external {
        require(msg.sender == winner, "Only winner can withdraw all prize.");
        require(block.timestamp >= endTime, "Game is not ended.");
        selfdestruct(winner);
    }

}