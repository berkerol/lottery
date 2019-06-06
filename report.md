# Notes on Logic of the Contract

## Period Mechanism

**Assumption:** This mechanism assumes that in each period of the lottery, at least one of the functions `submit`, `reveal` or `withdraw` methods. This assumption is meaningful since without calling these functions any updates will be made on lottery.

## Random Number Generation in Lottery

Random numbers are generated based on the numbers supplied by the users revealing their random numbers. `xor` variable is xorred with any such number. At the end of a period, `xor` is a random value. Using this value we are generating 23 random variables. Xorring it again and again gives us new random values and taking modulo of this hash, random numbers in specific ranges (0-100, 0-1000) are generated.

## Prize Distribution

Generated random numbers are compared with unique ticket numbers of the ticket owners. Determined prizes are distributed only if enough funds are collected. After the period ends at any time ticket owners can withdraw their prizes or refunds.

**Assumption**: The charity account should also withdraw the remaining refunds.
