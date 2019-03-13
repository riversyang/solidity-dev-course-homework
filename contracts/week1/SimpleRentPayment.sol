pragma solidity ^0.4.24;

contract SimpleRentPayment {
    uint256 constant ONE_HOUR = 3600;
    uint256 constant MIN_PERIOD = 12;
    uint256 constant BASE_PAYMENT_AMOUNT = 10 ** 18;

    address public payer;
    address public payee;

    uint256 public startTime;

    uint256 public withdrawedAmount;

    modifier onlyPayer() {
        require(msg.sender == payer, "Only payer can call the function.");
        _;
    }

    modifier onlyPayee() {
        require(msg.sender == payee, "Only payee can call the function.");
        _;
    }

    modifier afterMinPeriod() {
        uint256 period;

        period = (block.timestamp - startTime) / ONE_HOUR;
        require(period >= 12, "Contract is in minimum payment period.");
        _;
    }

    constructor(address _payee) public payable {
        payer = msg.sender;
        payee = _payee;
        startTime = block.timestamp;
    }

    function() external payable onlyPayer {
    }

    function withdraw() external onlyPayee {
        uint256 maxWithdrawAmount;
        uint256 withdrawAmount;
        
        maxWithdrawAmount = BASE_PAYMENT_AMOUNT * ((block.timestamp - startTime) / ONE_HOUR);
        require(maxWithdrawAmount > withdrawedAmount, "You already withdrawed all you can get.");
        withdrawAmount = maxWithdrawAmount - withdrawedAmount;
        require(address(this).balance >= withdrawAmount, "Contract balance is not enough.");
        withdrawedAmount += withdrawAmount;
        msg.sender.transfer(withdrawAmount);
    }

    function endPayment() external onlyPayer afterMinPeriod {
        require(withdrawedAmount >= BASE_PAYMENT_AMOUNT * MIN_PERIOD, "You cannot end payment before payee withdraw their rent of minimum period.");
        selfdestruct(payer);
    }
}