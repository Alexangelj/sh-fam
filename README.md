# Shadowlings

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

## Tools

First, deploy the contracts using `npx hardhat deploy --network <networkName>`

Second, setup the contracts state using `npx hardhat setup --network <networkName>`

Finally, verify the contracts using `npx hardhat verifyAll --network <networkName>`

To set the base cost of an NFT, i.e. the void tokens minted in exchange for it, do `npx hardhat setBaseCost --token <address> --cost <amount of void>`

To set the premium cost of an NFT, i.e. the void tokens minted in exchange a specific tokenId, do `npx hardhat setBaseCost --token <address> --tokenid <specific tokenid> --premium <amount of premium>`

To set the Currency usage cost in void tokens, do `npx hardhat setCurrencyCost --currencyid <id of currency> --cost <amount of void to burn>`

To mint a Shadowling, do `npx hardhat claim --tokenid <id of token to mint>`, note: need void tokens to claim a shadowling
