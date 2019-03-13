pragma solidity ^0.4.24;

import "../openzeppelin-solidity-2.0.0/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity-2.0.0/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity-2.0.0/contracts/payment/PullPayment.sol";

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
        require(_dest != address(0), "Destination address cannot be zero address.");
        require(_dest != owner(), "Destination address cannot be owner's address.");
        require(_amount > 0, "You need to specify the amount.");

        if (_amount > address(this).balance) {
            emit BlanceNotEnough(_amount.sub(address(this).balance));
        } else {
            _asyncTransfer(_dest, _amount);
            totalPayments = totalPayments.add(_amount);
        }
    }

    function withdrawPayments(address payee) public {
        // TODO
        uint256 withdrawAmount = payments(payee);
        require(withdrawAmount > 0, "There is no pending payment.");

        totalPayments = totalPayments.sub(withdrawAmount);
        super.withdrawPayments(payee);
    }

    function destroy() public onlyOwner {
        // TODO
        require(totalPayments == 0, "You cannot destroy the contract before you pay all pending payments.");

        selfdestruct(owner());
    }

    function() external payable onlyOwner {
    }

}