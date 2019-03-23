var SimpleRentPayment = artifacts.require("./SimpleRentPayment.sol");
var SimpleShop = artifacts.require("./SimpleShop.sol");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(SimpleRentPayment, accounts[1], {value: 20 * (10 ** 18)});
    deployer.deploy(SimpleShop);
};
