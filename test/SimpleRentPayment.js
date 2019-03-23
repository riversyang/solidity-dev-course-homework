var SimpleRentPayment = artifacts.require("../contracts/SimpleRentPayment");
var send = require('./TimeTravel.js');

contract('SimpleRentPayment', function(accounts) {
    var srpInstance = SimpleRentPayment.deployed();

    it("Passes testcase 0 ", async function() {
        let srp = await srpInstance;

        try {
            await srp.withdraw();
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only payee can call the function.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
    });

    it("Passes testcase 1 ", async function() {
        let srp = await srpInstance;

        try {
            await srp.withdraw({from: accounts[1]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You already withdrawed all you can get.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
    });

    it("Passes testcase 2 ", async function() {
        let srp = await srpInstance;

        let contractBalance = web3.eth.getBalance(srp.address);
        console.log("Balance of contract:       " + contractBalance.toNumber());

        await send('evm_increaseTime', 3600);

        let oldBalance = web3.eth.getBalance(accounts[1]);
        console.log("Balance before withdraw:   " + oldBalance.toNumber());
        let txInfo = await srp.withdraw({from: accounts[1]});
        let tx = web3.eth.getTransaction(txInfo.tx);
        let txFee = txInfo.receipt.gasUsed * tx.gasPrice;
        console.log("Transaction fee:           " + txFee);
        let newBalance = web3.eth.getBalance(accounts[1]);
        console.log("Balance after withdraw:    " + newBalance.toNumber());
        let withdrawAmount = newBalance.toNumber() + txFee - oldBalance.toNumber();
        console.log("Withdrawed Amount:         " + withdrawAmount);
        assert.equal(withdrawAmount, 10 ** 18);
    });

    it("Passes testcase 3 ", async function() {
        let srp = await srpInstance;

        let contractBalance = web3.eth.getBalance(srp.address);
        console.log("Balance of contract:       " + contractBalance.toNumber());

        await send('evm_increaseTime', 3600 * 2);

        let oldBalance = web3.eth.getBalance(accounts[1]);
        console.log("Balance before withdraw:   " + oldBalance.toNumber());
        let txInfo = await srp.withdraw({from: accounts[1]});
        let tx = web3.eth.getTransaction(txInfo.tx);
        let txFee = txInfo.receipt.gasUsed * tx.gasPrice;
        console.log("Transaction fee:           " + txFee);
        let newBalance = web3.eth.getBalance(accounts[1]);
        console.log("Balance after withdraw:    " + newBalance.toNumber());
        let withdrawAmount = newBalance.toNumber() + txFee - oldBalance.toNumber();
        console.log("Withdrawed Amount:         " + withdrawAmount);
        assert.equal(withdrawAmount, 10 ** 18 * 2);
    });

    it("Passes testcase 4 ", async function() {
        let srp = await srpInstance;

        try {
            await srp.endPayment({from: accounts[1]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only payer can call the function.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
    });

    it("Passes testcase 5 ", async function() {
        let srp = await srpInstance;

        try {
            await srp.endPayment();
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Contract is in minimum payment period.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
    });

    it("Passes testcase 6 ", async function() {
        let srp = await srpInstance;

        await send('evm_increaseTime', 3600 * 9);

        try {
            await srp.endPayment();
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You cannot end payment before payee withdraw their rent of minimum period.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
    });

    it("Passes testcase 7 ", async function() {
        let srp = await srpInstance;

        let contractBalance = web3.eth.getBalance(srp.address);
        console.log("Balance of contract:       " + contractBalance.toNumber());

        let oldBalance = web3.eth.getBalance(accounts[1]);
        console.log("Balance before withdraw:   " + oldBalance.toNumber());
        let txInfo = await srp.withdraw({from: accounts[1]});
        let tx = web3.eth.getTransaction(txInfo.tx);
        let txFee = txInfo.receipt.gasUsed * tx.gasPrice;
        console.log("Transaction fee:           " + txFee);
        let newBalance = web3.eth.getBalance(accounts[1]);
        console.log("Balance after withdraw:    " + newBalance.toNumber());
        let withdrawAmount = newBalance.toNumber() + txFee - oldBalance.toNumber();
        console.log("Withdrawed Amount:         " + withdrawAmount);
        assert.equal(withdrawAmount, 10 ** 18 * 9);
    });

    it("Passes testcase 8 ", async function() {
        let srp = await srpInstance;

        let oldBalance = web3.eth.getBalance(accounts[0]);
        console.log("Balance before withdraw:   " + oldBalance.toNumber());
        let txInfo = await srp.endPayment();
        let tx = web3.eth.getTransaction(txInfo.tx);
        let txFee = txInfo.receipt.gasUsed * tx.gasPrice;
        console.log("Transaction fee:           " + txFee);
        let newBalance = web3.eth.getBalance(accounts[0]);
        console.log("Balance after withdraw:    " + newBalance.toNumber());
        let withdrawAmount = newBalance.toNumber() + txFee - oldBalance.toNumber();
        console.log("Selfdestructed Amount:     " + withdrawAmount);
        assert.equal(withdrawAmount, 10 ** 18 * 8);
    });

    after(async function() {
        console.log("Test finished.")
    });

});
