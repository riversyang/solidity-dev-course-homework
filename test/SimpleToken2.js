var SimpleToken2 = artifacts.require("../contracts/SimpleToken2");
var send = require('./TimeTravel.js');

contract('SimpleToken2', function(accounts) {
    var stInstance;

    SimpleToken2.deployed().then(token => {
        const events = token.allEvents({fromBlock: 0, toBlock: "latest"});
        events.watch(function(error, result) {
            if (!error) {
                console.log("Token event " + result.event + " detected: ");
                if (result.event == "OwnershipTransferred") {
                    console.log("   previousOwner: " + result.args.previousOwner);
                    console.log("   newOwner: " + result.args.newOwner);
                } else if (result.event == "AgentAdded") {
                    console.log("   account: " + result.args.account);
                } else if (result.event == "Transfer") {
                    console.log("   from: " + result.args.from);
                    console.log("   to: " + result.args.to);
                    console.log("   value: " + result.args.value.toNumber());
                } else if (result.event == "Approval") {
                    console.log("   owner: " + result.args.owner);
                    console.log("   spender: " + result.args.spender);
                    console.log("   value: " + result.args.value.toNumber());
                } else {
                    console.log(result);
                }
            } else {
                console.log("Error occurred while watching events.");
            }
        });
        stInstance = token;
    });

    it("Passes testcase 0 ", async function() {
        let token = await stInstance;
        try {
            await token.privateSale(accounts[6], {from: accounts[1], value: 10 ** 18});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only agents can call this function.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    it("Passes testcase 1 ", async function() {
        let token = await stInstance;
        try {
            await token.withdrawPrivateSaleCoins(accounts[6], 10 ** 18 * 100000, {from: accounts[2]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only agents can call this function.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    it("Passes testcase 2 ", async function() {
        let token = await stInstance;
        await token.addAgent(accounts[1]);
        await send('evm_mine');
        await token.privateSale(accounts[4], {from: accounts[1], value: 10 ** 18});
        await send('evm_mine');
        let amount = await token.balanceOf.call(accounts[4]);
        assert.equal(amount.toNumber(), 10 ** 18 * 100000 * 10 / 7);
    });

    it("Passes testcase 3 ", async function() {
        await send('evm_increaseTime', 3600 * 24 * 7);
        let token = await stInstance;
        await token.addAgent(accounts[0]);
        await send('evm_mine');
        await token.privateSale(accounts[5], {value: 10 ** 18});
        await send('evm_mine');
        let amount = await token.balanceOf.call(accounts[5]);
        assert.equal(amount.toNumber(), 10 ** 18 * 100000 * 10 / 8);
    });

    it("Passes testcase 4 ", async function() {
        await send('evm_increaseTime', 3600 * 24 * 7);
        let token = await stInstance;
        await token.privateSale(accounts[6], {from: accounts[1], value: 10 ** 18});
        let amount = await token.balanceOf.call(accounts[6]);
        assert.equal(amount.toNumber(), 10 ** 18 * 100000 * 10 / 9);
        await send('evm_mine');
    });

    it("Passes testcase 5 ", async function() {
        await send('evm_increaseTime', 3600 * 24 * 7);
        let token = await stInstance;
        await token.sendTransaction({from: accounts[1], value: 10 ** 18});
        let amount = await token.balanceOf.call(accounts[1]);
        assert.equal(amount.toNumber(), 10 ** 18 * 100000);
        await send('evm_mine');
    });

    it("Passes testcase 6 ", async function() {
        let token = await stInstance;
        await token.withdrawPrivateSaleCoins(accounts[7], 10 ** 18 * 200000);
        let amount = await token.balanceOf.call(accounts[7]);
        assert.equal(amount.toNumber(), 10 ** 18 * 200000);
        await send('evm_mine');
    });

    it("Passes testcase 7 ", async function() {
        let token = await stInstance;
        try {
            await token.transfer(accounts[8], 10 ** 18 * 100000, {from: accounts[7]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert You can not call transfer within private sale period.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    it("Passes testcase 8 ", async function() {
        let token = await stInstance;
        await token.approve(accounts[8], 10 ** 18 * 150000, {from:accounts[7]});
        await send('evm_mine');
        try {
            await token.transferFrom(accounts[7], accounts[3], 10 ** 18 * 100000, {from: accounts[8]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only agent can call transferFrom within private sale period.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    after(async function() {
        console.log("Test finished.")
        await send('evm_mine');
    });

});