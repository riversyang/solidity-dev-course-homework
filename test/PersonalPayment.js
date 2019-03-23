var PersonalPayment = artifacts.require("../contracts/PersonalPayment");
var send = require('./TimeTravel.js');

contract('PersonalPayment', function(accounts) {
    var ppInstance;

    PersonalPayment.deployed().then(payment => {
        const events = payment.allEvents({fromBlock: 0, toBlock: "latest"});
        events.watch(function(error, result) {
            if (!error) {
                console.log("Token event " + result.event + " detected: ");
                if (result.event == "OwnershipTransferred") {
                    console.log("   previousOwner: " + result.args.previousOwner);
                    console.log("   newOwner: " + result.args.newOwner);
                } else if (result.event == "BlanceNotEnough") {
                    console.log("   lackAmount: " + result.args.lackAmount.toNumber());
                } else {
                    console.log(result);
                }
            } else {
                console.log("Error occurred while watching events.");
            }
        });
        ppInstance = payment;
    });

    it("Passes testcase 0 ", async function() {
        let payment = await ppInstance;

        await payment.send(10 ** 17 * 5);
        await send('evm_mine');

        await payment.asyncPay(accounts[1], 10 ** 18);
        await send('evm_mine');
    });

    it("Passes testcase 0 ", async function() {
        let payment = await ppInstance;

        await payment.send(10 ** 18);
        await send('evm_mine');

        await payment.asyncPay(accounts[1], 10 ** 18);
        await send('evm_mine');

        await payment.withdrawPayments(accounts[1]);
        await send('evm_mine');

        let newBalance = web3.eth.getBalance(accounts[1]);
        console.log(newBalance.toNumber());
    });

    after(async function() {
        console.log("Test finished.")
        await send('evm_mine');
    });

});