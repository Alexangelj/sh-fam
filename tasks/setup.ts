import { task } from "hardhat/config"
import {
  BASE_COSTS,
  CURRENCY_COSTS,
  PREMIUM_COSTS,
  SHADOWLING_COST,
} from "../scripts/constants"
import { AddressZero } from "@ethersproject/constants"

task("setup", "Initializes state of altar").setAction(async (args, hre) => {
  const { deployer } = await hre.getNamedAccounts()
  const signer = await hre.ethers.getSigner(deployer)
  console.log("Using wallet", deployer)

  const chainId: number = +(await hre.getChainId())
  console.log(
    `\n\n\nDeploying to network ${hre.network.name} on chain ${chainId}`
  )

  const voidToken = await hre.ethers.getContract("Void", signer)
  console.log(`    - Using Void at address: ${voidToken.address}`)

  const altar = await hre.ethers.getContract("Altar", signer)
  console.log(`    - Using Altar at address: ${altar.address}`)

  const shadowling = await hre.ethers.getContract("Shadowling", signer)
  console.log(`    - Using Shadowling at address: ${shadowling.address}`)

  // set the void token in the altar
  let voidAddress = await altar.void()
  if (voidAddress == AddressZero) {
    console.log(
      `\n Setting void token address in altar to ${voidToken.address}`
    )
    await altar.setVoid(voidToken.address)
    voidAddress = await altar.void()
  }

  // set the shadowling contract in the altar
  let shadowlingAddress = await altar.shadowling()
  if (shadowlingAddress == AddressZero) {
    console.log(
      `\n Setting shadowling address in altar to ${shadowling.address}`
    )
    await altar.setShadowling(shadowling.address)
    shadowlingAddress = await altar.shadowling()
  }

  // set the cost to mint a shadowling in void tokens
  await altar.setShadowlingCost(SHADOWLING_COST)
  console.log(`   - Set Shadowling cost to: ${SHADOWLING_COST}`)

  // for each currency type, set its cost in void tokens
  for (let i = 2; i < 9; i++) {
    if ((await altar.currencyCost(i)).eq(0)) {
      console.log(`   - Set CurrencyId: ${i} cost to: ${CURRENCY_COSTS[i]}`)
      await altar.setCurrencyCost(i, CURRENCY_COSTS[i])
    }
  }

  const baseCostKeys = Object.keys(BASE_COSTS)
  const premiumCostKeys = Object.keys(PREMIUM_COSTS)
  const nftsToListLength = baseCostKeys.length

  // for each nft with a cost, set its cost in the contract
  console.log(`\n Setting void tokens minted from burning nfts`)
  for (let i = 0; i < nftsToListLength; i++) {
    let token = baseCostKeys[i] // get the token which has a base cost
    let base = BASE_COSTS[token] // get the base cost of that token
    if ((await altar.cost(token)).eq(0)) {
      console.log(`   - Set token ${token} base cost to: ${base}`)
      await altar.setBaseCost(token, base) // set the base cost
    }
    if (premiumCostKeys.includes(token)) {
      // if the token has at least 1 id with premium cost
      let premiumCostIds = Object.keys(PREMIUM_COSTS[token]) // get all the ids
      for (let id = 0; id < premiumCostIds.length; id++) {
        if ((await altar.premium(token, id)).eq(0)) {
          // for each id, set the premium cost
          const premium = PREMIUM_COSTS[token][id]
          console.log(
            `   - Set token ${token} with id ${id} premium cost to: ${premium}`
          )
          await altar.setPremiumCost(token, id, premium)
        }
      }
    }
  }
})
