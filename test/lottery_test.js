/* global artifacts contract before describe it web3 */

const truffleAssert = require('truffle-assertions');

const Lottery = artifacts.require('Lottery');

const BN = web3.utils.BN;

const timeout = ms => {
  return new Promise(resolve => setTimeout(resolve, ms));
};

contract('Lottery', accounts => {
  let lottery;
  let tickets;
  before(async () => {
    lottery = await Lottery.deployed();
    tickets = [];
  });
  describe('one period', () => {
    it('should execute all functionalities', async () => {
      for (let i = 0; i < accounts.length; i++) {
        const account = accounts[i];
        for (let j = 0; j < 1; j++) {
          const randomNumber = Math.ceil(Math.random(10000));
          const hash = new BN(await lottery.hash(randomNumber, { from: account }));
          truffleAssert.eventEmitted(await lottery.submit(hash, { from: account, value: web3.utils.toWei('2', 'ether') }), 'SubmittedTicket', event => {
            tickets.push({
              randomNumber,
              hash,
              ticketNumber: event.ticketNumber,
              sender: account
            });
            return !!event.ticketNumber;
          });
        }
      }
      const account = accounts[0];
      const randomNumber = Math.ceil(Math.random(10000));
      const hash = new BN(await lottery.hash(randomNumber, { from: account }));
      await truffleAssert.reverts(lottery.submit(hash, { from: account, value: web3.utils.toWei('1', 'ether') }));
      await timeout(5000);
      for (let i = 0; i < tickets.length; i++) {
        const ticket = tickets[i];
        await truffleAssert.passes(lottery.reveal(ticket.randomNumber, ticket.ticketNumber, { from: ticket.sender }));
      }
      const ticket = tickets[0];
      await truffleAssert.reverts(lottery.reveal(ticket.randomNumber, 10, { from: ticket.sender }));
      await truffleAssert.reverts(lottery.reveal(ticket.randomNumber, ticket.ticketNumber, { from: accounts[1] }));
      await truffleAssert.reverts(lottery.reveal(0, ticket.ticketNumber, { from: ticket.sender }));
      await truffleAssert.reverts(lottery.reveal(ticket.randomNumber, ticket.ticketNumber, { from: ticket.sender }));
      for (let i = 0; i < accounts.length; i++) {
        const account = accounts[i];
        await truffleAssert.passes(lottery.withdraw({ from: account }));
      }
    });
  });
});
