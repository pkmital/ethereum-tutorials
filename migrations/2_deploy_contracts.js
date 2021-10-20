var BasicContract = artifacts.require("./BasicContract.sol");

module.exports = function(deployer) {
  deployer.deploy(BasicContract);
};
