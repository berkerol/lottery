const Lottery = artifacts.require('Lottery');

module.exports = (deployer, network, accounts) => {
  deployer.deploy(Lottery, accounts[0], { from: accounts[0] });
};
