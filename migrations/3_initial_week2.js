var PersonalPayment = artifacts.require("./PersonalPayment.sol");
var SimpleToken1 = artifacts.require("./SimpleToken1.sol");
var SimpleToken2 = artifacts.require("./SimpleToken2.sol");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(PersonalPayment);
    deployer.deploy(SimpleToken1, accounts[9]);
    deployer.deploy(SimpleToken2, accounts[9]);
};
