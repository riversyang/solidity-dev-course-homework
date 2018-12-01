pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity/contracts/payment/PullPayment.sol";

contract PersonalPayment is Ownable, PullPayment {
    // 使用库合约
    using SafeMath for uint256;
    // 其他状态变量
    // 目前需要支付的款项总额
    uint256 public totalPayments;
    // 余额不足以发起支付的通知
    event BlanceNotEnough(uint256 lackAmount);

    function asyncPay(address _dest, uint256 _amount) public onlyOwner {
        // TODO
        require(_dest != address(0));
        require(_dest != owner);
        require(_amount > 0);

        if (_amount > address(this).balance) {
            emit BlanceNotEnough(_amount.sub(address(this).balance));
        } else {
            asyncTransfer(_dest, _amount);
            totalPayments = totalPayments.add(_amount);
        }
    }

    function withdrawPayments() public {
        // TODO
        uint256 withdrawAmount = payments(msg.sender);
        require(withdrawAmount > 0);

        totalPayments = totalPayments.sub(withdrawAmount);
        super.withdrawPayments();
    }

    function destroy() public onlyOwner {
        // TODO
        require(totalPayments == 0);

        selfdestruct(owner);
    }

    function() external payable onlyOwner {
    }

}