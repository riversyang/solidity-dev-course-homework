var SimpleToken3 = artifacts.require("../contracts/SimpleToken3");
var SimplePrivateSale = artifacts.require("../contracts/SimplePrivateSale");
var send = require('./TimeTravel.js');

contract('SimpleToken3', function(accounts) {
    var stInstance;
    var spsInstance;

    SimpleToken3.deployed().then(token => {
        const events = token.allEvents({fromBlock: 0, toBlock: "latest"});
        events.watch(function(error, result) {
            if (!error) {
                console.log("Token event " + result.event + " detected: ");
                if (result.event == "OwnershipTransferred") {
                    console.log("   previousOwner: " + result.args.previousOwner);
                    console.log("   newOwner: " + result.args.newOwner);
                } else if (result.event == "Transfer") {
                    console.log("   from: " + result.args.from);
                    console.log("   to: " + result.args.to);
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

        let spsContractAddress = await token.getPrivateSaleContractAddress.call();
        spsInstance = await SimplePrivateSale.at(spsContractAddress);

        const events = spsInstance.allEvents({fromBlock: 0, toBlock: "latest"});
        events.watch(function(error, result) {
            if (!error) {
                console.log("PrivateSale event " + result.event + " detected: ");
                if (result.event == "PrimaryTransferred") {
                    console.log("   recipient: " + result.args.recipient);
                } else if (result.event == "AgentAdded") {
                    console.log("   account: " + result.args.account);
                } else if (result.event == "TokensPurchased") {
                    console.log("   purchaser: " + result.args.purchaser);
                    console.log("   beneficiary: " + result.args.beneficiary);
                    console.log("   value: " + result.args.value.toNumber());
                    console.log("   amount: " + result.args.amount.toNumber());
                } else {
                    console.log(result);
                }
            } else {
                console.log("Error occurred while watching events.");
            }
        });
        await send('evm_mine');
    });

    it("Passes testcase 1 ", async function() {
        try {
            await spsInstance.buyTokens(accounts[6], {value: 10 ** 18});
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

        await token.addPrivateSaleAgent(accounts[0]);

        await spsInstance.buyTokens(accounts[4], {value: 10 ** 18});
        let amount = await spsInstance.balanceOf.call(accounts[4]);
        assert.equal(amount.toNumber(), 10 ** 18 * 100000 * 10 / 7);
        await send('evm_mine');
    });

    it("Passes testcase 3 ", async function() {
        await send('evm_increaseTime', 3600 * 24 * 7);

        await spsInstance.buyTokens(accounts[5], {value: 10 ** 18});
        let amount = await spsInstance.balanceOf.call(accounts[5]);
        assert.equal(amount.toNumber(), 10 ** 18 * 100000 * 10 / 8);
        await send('evm_mine');
    });

    it("Passes testcase 4 ", async function() {
        await send('evm_increaseTime', 3600 * 24 * 7);

        await spsInstance.buyTokens(accounts[6], {value: 10 ** 18});
        let amount = await spsInstance.balanceOf.call(accounts[6]);
        assert.equal(amount.toNumber(), 10 ** 18 * 100000 * 10 / 9);
        await send('evm_mine');
    });

    it("Passes testcase 5 ", async function() {
        await send('evm_increaseTime', 3600 * 24 * 7);

        await spsInstance.send(10 ** 18);
        let amount = await spsInstance.balanceOf.call(accounts[0]);
        assert.equal(amount.toNumber(), 10 ** 18 * 100000);
        await send('evm_mine');
    });

    it("Passes testcase 6 ", async function() {
        await spsInstance.offChainSale(accounts[7], 10 ** 18 * 200000);
        let amount = await spsInstance.balanceOf.call(accounts[7]);
        assert.equal(amount.toNumber(), 10 ** 18 * 200000);
        await send('evm_mine');
    });

    it("Passes testcase 7 ", async function() {
        try {
            await spsInstance.sendTransaction({from: accounts[1], value: 10 ** 18});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only agents can call this function.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    it("Passes testcase 8 ", async function() {
        try {
            await spsInstance.offChainSale(accounts[7], 10 ** 18 * 200000, {from: accounts[8]});
            throw null;
        } catch(error) {
            assert(error, "Expected an error but did not get one");
            let prefix = "VM Exception while processing transaction: revert Only agents can call this function.";
            assert(error.message.startsWith(prefix), "Expected an error starting with '" + prefix + "' but got '" + error.message + "' instead");
        }
        await send('evm_mine');
    });

    after(async function() {
        console.log("Test finished.")
        await send('evm_mine');
    });

});