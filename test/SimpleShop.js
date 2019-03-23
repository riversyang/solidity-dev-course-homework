var SimpleShop = artifacts.require("../contracts/SimpleShop");
var send = require('./TimeTravel.js');

contract('SimpleShop', function(accounts) {
    var ssInstance;

    SimpleShop.deployed().then(shop => {
        const events = shop.allEvents({fromBlock: 0, toBlock: "latest"});
        events.watch(function(error, result) {
            if (!error) {
                console.log("Shop event " + result.event + " detected: ");
                if (result.event == "PurchaseCreated") {
                    console.log("   number: " + result.args.number.toNumber());
                } else if (result.event == "PurchaseAborted") {
                    console.log("   number: " + result.args.number.toNumber());
                } else if (result.event == "PurchaseConfirmed") {
                    console.log("   number: " + result.args.number.toNumber());
                } else if (result.event == "PurchaseCompleted") {
                    console.log("   number: " + result.args.number.toNumber());
                } else {
                    console.log(result);
                }
            } else {
                console.log("Error occurred while watching events.");
            }
        });
        ssInstance = shop;
    });

    it("Passes testcase 0 ", async function() {
        let shop = await ssInstance;

        try {
            await shop.createPurchase(10 ** 18);
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You need to transfer double amount of Purchase value.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        try {
            await shop.createPurchase(10 ** 18, {value: 10 ** 18});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You need to transfer double amount of Purchase value.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
    });

    it("Passes testcase 1 ", async function() {
        let shop = await ssInstance;

        let pv;
        let value;
        let state;

        pv = 10 ** 18;
        await shop.createPurchase(pv, {value: pv * 2});
        value = await shop.getPurchaseValue.call(1);
        assert.equal(value.toNumber(), pv);
        state = await shop.getPurchaseState.call(1);
        assert.equal(state.toNumber(), 0);

        pv = 10 ** 17 * 7;
        await shop.createPurchase(pv, {value: pv * 2});
        value = await shop.getPurchaseValue.call(2);
        assert.equal(value.toNumber(), pv);
        state = await shop.getPurchaseState.call(2);
        assert.equal(state.toNumber(), 0);

        pv = 10 ** 17 * 5;
        await shop.createPurchase(pv, {value: pv * 2});
        value = await shop.getPurchaseValue.call(3);
        assert.equal(value.toNumber(), pv);
        state = await shop.getPurchaseState.call(3);
        assert.equal(state.toNumber(), 0);

        pv = 10 ** 17 * 3;
        await shop.createPurchase(pv, {value: pv * 2});
        value = await shop.getPurchaseValue.call(4);
        assert.equal(value.toNumber(), pv);
        state = await shop.getPurchaseState.call(4);
        assert.equal(state.toNumber(), 0);

        pv = 10 ** 17 * 2;
        await shop.createPurchase(pv, {value: pv * 2});
        value = await shop.getPurchaseValue.call(5);
        assert.equal(value.toNumber(), pv);
        state = await shop.getPurchaseState.call(5);
        assert.equal(state.toNumber(), 0);

        await send('evm_mine');
    });

    it("Passes testcase 2 ", async function() {
        let shop = await ssInstance;

        let oldBalance = web3.eth.getBalance(accounts[0]);
        console.log("Balance before abort:  " + oldBalance.toNumber());
        let txInfo = await shop.abortPurchase(1);
        let tx = web3.eth.getTransaction(txInfo.tx);
        let txFee = txInfo.receipt.gasUsed * tx.gasPrice;
        console.log("Transaction fee:       " + txFee);
        let newBalance = web3.eth.getBalance(accounts[0]);
        console.log("Balance after abort:   " + newBalance.toNumber());
        let withdrawAmount = newBalance.toNumber() + txFee - oldBalance.toNumber();
        console.log("Withdrawed Amount:     " + withdrawAmount);
        assert.equal(withdrawAmount, 10 ** 18 * 2);
        await send('evm_mine');
    });

    it("Passes testcase 3 ", async function() {
        let shop = await ssInstance;

        try {
            await shop.confirmPurchase(1, {from: accounts[1]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You can only confirm a purchase which is just created.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        try {
            await shop.confirmPurchase(2, {from: accounts[1]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You need to transfer double amount of Purchase value.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        try {
            await shop.confirmPurchase(2, {from: accounts[1], value: 10 ** 17 * 8});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You need to transfer double amount of Purchase value.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    it("Passes testcase 4 ", async function() {
        let shop = await ssInstance;

        let pv;
        let buyer;
        let state;

        pv = 10 ** 17 * 7;
        await shop.confirmPurchase(2, {from: accounts[1], value: pv * 2});
        buyer = await shop.getPurchaseBuyer.call(2);
        assert.equal(buyer, accounts[1]);
        state = await shop.getPurchaseState.call(2);
        assert.equal(state.toNumber(), 2);

        pv = 10 ** 17 * 5;
        await shop.confirmPurchase(3, {from: accounts[2], value: pv * 2});
        buyer = await shop.getPurchaseBuyer.call(3);
        assert.equal(buyer, accounts[2]);
        state = await shop.getPurchaseState.call(3);
        assert.equal(state.toNumber(), 2);

        pv = 10 ** 17 * 3;
        await shop.confirmPurchase(4, {from: accounts[2], value: pv * 2});
        buyer = await shop.getPurchaseBuyer.call(4);
        assert.equal(buyer, accounts[2]);
        state = await shop.getPurchaseState.call(4);
        assert.equal(state.toNumber(), 2);

        pv = 10 ** 17 * 2;
        await shop.confirmPurchase(5, {from: accounts[2], value: pv * 2});
        buyer = await shop.getPurchaseBuyer.call(5);
        assert.equal(buyer, accounts[2]);
        state = await shop.getPurchaseState.call(5);
        assert.equal(state.toNumber(), 2);

        await send('evm_mine');
    });

    it("Passes testcase 5 ", async function() {
        let shop = await ssInstance;

        try {
            await shop.abortPurchase(2);
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You can only abort a purchase which is just created.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        try {
            await shop.abortPurchase(3);
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You can only abort a purchase which is just created.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        try {
            await shop.abortPurchase(4);
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You can only abort a purchase which is just created.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        try {
            await shop.abortPurchase(5);
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You can only abort a purchase which is just created.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    it("Passes testcase 6 ", async function() {
        let shop = await ssInstance;

        try {
            await shop.confirmReceived(1);
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You can only confirm received for a confirmed purchase.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        try {
            await shop.confirmReceived(2, {from: accounts[2]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only buyer can confirm received for this purchase now.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        try {
            await shop.confirmReceived(3, {from: accounts[1]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only buyer can confirm received for this purchase now.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    it("Passes testcase 7 ", async function() {
        let shop = await ssInstance;

        let oldBalance0 = web3.eth.getBalance(accounts[0]);
        let oldBalance1 = web3.eth.getBalance(accounts[1]);
        console.log("Balance0 before confirm:   " + oldBalance0.toNumber());
        console.log("Balance1 before confirm:   " + oldBalance1.toNumber());
        let txInfo = await shop.confirmReceived(2, {from: accounts[1]});
        let tx = web3.eth.getTransaction(txInfo.tx);
        let txFee = txInfo.receipt.gasUsed * tx.gasPrice;
        console.log("Transaction fee:           " + txFee);
        let newBalance0 = web3.eth.getBalance(accounts[0]);
        let newBalance1 = web3.eth.getBalance(accounts[1]);
        console.log("Balance0 after confirm:    " + newBalance0.toNumber());
        console.log("Balance1 after confirm:    " + newBalance1.toNumber());
        let withdrawAmount0 = newBalance0.toNumber() - oldBalance0.toNumber();
        let withdrawAmount1 = newBalance1.toNumber() + txFee - oldBalance1.toNumber();
        console.log("Withdrawed Amount0:        " + withdrawAmount0);
        assert.equal(withdrawAmount0, 10 ** 17 * 7 * 3);
        console.log("Withdrawed Amount1:        " + withdrawAmount1);
        assert.equal(withdrawAmount1, 10 ** 17 * 7);
        await send('evm_mine');
    });

    it("Passes testcase 8 ", async function() {
        let shop = await ssInstance;

        let oldBalance0 = web3.eth.getBalance(accounts[0]);
        let oldBalance2 = web3.eth.getBalance(accounts[2]);
        console.log("Balance0 before confirm:   " + oldBalance0.toNumber());
        console.log("Balance2 before confirm:   " + oldBalance2.toNumber());
        let txInfo = await shop.confirmReceived(3, {from: accounts[2]});
        let tx = web3.eth.getTransaction(txInfo.tx);
        let txFee = txInfo.receipt.gasUsed * tx.gasPrice;
        console.log("Transaction fee:           " + txFee);
        let newBalance0 = web3.eth.getBalance(accounts[0]);
        let newBalance2 = web3.eth.getBalance(accounts[2]);
        console.log("Balance0 after confirm:    " + newBalance0.toNumber());
        console.log("Balance2 after confirm:    " + newBalance2.toNumber());
        let withdrawAmount0 = newBalance0.toNumber() - oldBalance0.toNumber();
        let withdrawAmount2 = newBalance2.toNumber() + txFee - oldBalance2.toNumber();
        console.log("Withdrawed Amount0:        " + withdrawAmount0);
        assert.equal(withdrawAmount0, 10 ** 17 * 5 * 3);
        console.log("Withdrawed Amount2:        " + withdrawAmount2);
        assert.equal(withdrawAmount2, 10 ** 17 * 5);
        await send('evm_mine');
    });

    it("Passes testcase 9 ", async function() {
        let shop = await ssInstance;

        try {
            await shop.confirmReceived(4);
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only buyer can confirm received for this purchase now.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }

        await send('evm_increaseTime', 3600 * 24);

        try {
            await shop.confirmReceived(5, {from: accounts[1]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only seller and buyer can confirm received for this purchase now.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }

        let oldBalance0 = web3.eth.getBalance(accounts[0]);
        let oldBalance2 = web3.eth.getBalance(accounts[2]);
        console.log("Balance0 before confirm:   " + oldBalance0.toNumber());
        console.log("Balance2 before confirm:   " + oldBalance2.toNumber());
        let txInfo = await shop.confirmReceived(5);
        let tx = web3.eth.getTransaction(txInfo.tx);
        let txFee = txInfo.receipt.gasUsed * tx.gasPrice;
        console.log("Transaction fee:           " + txFee);
        let newBalance0 = web3.eth.getBalance(accounts[0]);
        let newBalance2 = web3.eth.getBalance(accounts[2]);
        console.log("Balance0 after confirm:    " + newBalance0.toNumber());
        console.log("Balance2 after confirm:    " + newBalance2.toNumber());
        let withdrawAmount0 = newBalance0.toNumber() + txFee - oldBalance0.toNumber();
        let withdrawAmount2 = newBalance2.toNumber() - oldBalance2.toNumber();
        console.log("Withdrawed Amount0:        " + withdrawAmount0);
        assert.equal(withdrawAmount0, 10 ** 17 * 2 * 3);
        console.log("Withdrawed Amount2:        " + withdrawAmount2);
        assert.equal(withdrawAmount2, 10 ** 17 * 2);

        await send('evm_mine');
    });

    after(async function() {
        console.log("Test finished.")
        await send('evm_mine');
    });

});