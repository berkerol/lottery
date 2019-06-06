/* global Web3 */

let userAddress;

window.addEventListener('load', async () => {
  if (window.ethereum) {
    window.web3 = new Web3(window.ethereum);
    try {
      await window.ethereum.enable();
    } catch (error) {
      window.alert('Unable to get account address!');
    }
  } else if (window.web3) {
    window.web3 = new Web3(window.web3.currentProvider);
  }
  if (window.web3) {
    userAddress = window.web3.eth.accounts[0];
  } else {
    window.alert('You need Metamask or another wallet to interact!');
  }
});

const contractAbi = '[{"inputs":[{"name":"charity_","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"ticketNumber","type":"uint256"}],"name":"SubmittedTicket","type":"event"},{"constant":false,"inputs":[{"name":"hash","type":"uint256"}],"name":"submit","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"randomNumber","type":"uint256"},{"name":"ticketNumber","type":"uint256"}],"name":"reveal","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getStage","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"number","type":"uint256"}],"name":"hash","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]';
const contractAddress = '0xff56a42417cd9b49f378b2cd180c60786c1ad56f';
const contract = window.web3.eth.contract(JSON.parse(contractAbi)).at(contractAddress);

window.submit = () => {
  contract.submit.sendTransaction(+document.getElementById('submitHash').value, { from: userAddress, value: window.web3.toWei('2', 'ether') }, (err, transactionHash) => {
    if (err) { console.error(err); }
    console.log(transactionHash);
  });
  contract.SubmittedTicket((err, result) => {
    if (err) { console.error(err); }
    document.getElementById('submitResult').innerHTML = 'Ticket number: ' + result.args.ticketNumber.toString(10);
  });
};

window.reveal = () => {
  contract.reveal.sendTransaction(+document.getElementById('revealRandomNumber').value, +document.getElementById('revealTicketNumber').value, { from: userAddress }, (err, transactionHash) => {
    if (err) { console.error(err); }
    console.log(transactionHash);
  });
};

window.withdraw = () => {
  contract.withdraw.sendTransaction({ from: userAddress }, (err, transactionHash) => {
    if (err) { console.error(err); }
    console.log(transactionHash);
  });
};

window.hash = () => {
  contract.hash.call(+document.getElementById('hashRandomNumber').value, { from: userAddress }, (err, result) => {
    if (err) { console.error(err); }
    document.getElementById('hashResult').innerHTML = 'Hash: ' + result.toString(10);
  });
};

const getStage = () => {
  contract.getStage.call({ from: userAddress }, (err, result) => {
    if (err) { console.error(err); }
    document.getElementById('stage').innerHTML = window.web3.toAscii(result).replace(/\0/g, '');
  });
};

getStage();
window.setInterval(() => {
  getStage();
}, 10000);
