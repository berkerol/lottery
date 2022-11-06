const Lottery = artifacts.require('Lottery'); // eslint-disable-line no-undef

module.exports = (deployer, network, accounts) => {
  deployer.deploy(Lottery, accounts[0], { from: accounts[0] });
};
