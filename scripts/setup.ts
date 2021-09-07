import { parseEther } from "@ethersproject/units"
import hre, { run, ethers } from "hardhat"
import { BASE_COSTS, CURRENCY_COSTS, PREMIUM_COSTS } from "./constants"
const { AddressZero } = ethers.constants

async function main() {
  const { deployer } = await hre.getNamedAccounts()

  const chainId: number = +(await hre.getChainId())
  console.log(
    `\n\n\nDeploying to network ${hre.network.name} on chain ${chainId}`
  )

  const signer = await hre.ethers.getSigner(deployer)
  console.log("Using wallet", deployer)

  const voidToken = await ethers.getContract("Void", signer)
  console.log(`    - Using Void at address: ${voidToken.address}`)

  const altar = await ethers.getContract("Altar", signer)
  console.log(`    - Using Altar at address: ${altar.address}`)

  const shadowling = await ethers.getContract("Shadowling", signer)
  console.log(`    - Using Shadowling at address: ${shadowling.address}`)

  // set the void token in the altar
  let voidAddress = await altar.void()
  if (voidAddress == AddressZero) {
    await altar.setVoid(voidToken.address)
    voidAddress = await altar.void()
  }

  // set the shadowling contract in the altar
  let shadowlingAddress = await altar.shadowling()
  if (shadowlingAddress == AddressZero) {
    await altar.setShadowling(voidToken.address)
    shadowlingAddress = await altar.shadowling()
  }

  // for each currency type, set its cost in void tokens
  for (let i = 2; i < 9; i++) {
    await altar.setCurrencyCost(i, CURRENCY_COSTS[i])
  }

  const baseCostKeys = Object.keys(BASE_COSTS)
  const nftsToListLength = baseCostKeys.length

  // for each nft with a cost, set it in the contract
  for (let i = 0; i < nftsToListLength; i++) {
    let token = baseCostKeys[i]
    let base = BASE_COSTS[token]
    await altar.list(token, 0, base, 0)
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
