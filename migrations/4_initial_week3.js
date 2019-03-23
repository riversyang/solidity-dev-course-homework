var SimpleToken3 = artifacts.require("./SimpleToken3.sol");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(SimpleToken3, accounts[9]);
};
