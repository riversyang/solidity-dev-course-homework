pragma solidity ^0.4.24;

import "../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../openzeppelin-solidity/contracts/payment/PullPayment.sol";

contract PersonalPayment is Ownable, PullPayment {
    // 使用库合约
    using SafeMath for uint256;
    // 其他状态变量

    function asyncPay(address _dest, uint256 _amount) public onlyOwner {
        // TODO
    }

    function withdrawPayments() public {
        // TODO
    }

    function destroy() public onlyOwner {
        // TODO
    }

}