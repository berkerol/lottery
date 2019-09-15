# Lottery

[![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project=berkerol_lottery&metric=alert_status)](https://sonarcloud.io/dashboard?id=berkerol_lottery)
[![Renovate](https://badges.renovateapi.com/github/berkerol/lottery)](https://renovatebot.com/)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](https://github.com/berkerol/lottery/issues)
[![semistandard](https://img.shields.io/badge/code%20style-semistandard-brightgreen.svg)](https://github.com/Flet/semistandard)
[![ECMAScript](https://img.shields.io/badge/ECMAScript-latest-brightgreen.svg)](https://www.ecma-international.org/ecma-262)
[![license](https://img.shields.io/badge/license-GNU%20GPL%20v3.0-blue.svg)](https://github.com/berkerol/lottery/blob/master/LICENSE)

Decentralized autonomous lottery. Submit the hash of a chosen random number and pay 2 ethers then reveal the chosen random number and given ticket number. One round consists of submission and reveal stages which are 1 day long. Withdraw the prize anytime after the round ends. Runs on Ropsten Test Network. You need [Metamask](https://metamask.io/) or another wallet to interact.

[![button](view.png)](https://berkerol.github.io/lottery/lottery.html)

## Prizes

|1st|2nd|3rd|4th|5th|6th|7th|8th|9th|10th|
|---|---|---|---|---|---|---|---|---|---|
|50000|25000|10000|7500|5000|2500|1000|900|800|700|

|11th|12th|13th|14th|15th|16th|17th|18th|19th|20th|
|---|---|---|---|---|---|---|---|---|---|
|600|500|450|400|350|300|250|200|150|100|

|Last 4 digits|Last 3 digits|Last 2 digits|
|---|---|---|
|40|10|4|

If enough money to pay for all the prizes is not collected, then cots of tickets (2 ethers) are refunded.

## Installation

```
$ npm install -g ganache-cli
$ npm install -g truffle
$ npm install
```

## Usage

```
$ ganache-cli
$ npm test
```

## Contribution

Feel free to [contribute](https://github.com/berkerol/lottery/issues) according to the [semistandard rules](https://github.com/Flet/semistandard) and [latest ECMAScript Specification](https://www.ecma-international.org/ecma-262).

## Distribution

You can distribute this software freely under [GNU GPL v3.0](https://github.com/berkerol/lottery/blob/master/LICENSE).
