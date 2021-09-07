import { parseEther } from "@ethersproject/units"
import hre, { run, ethers } from "hardhat"
const { AddressZero } = ethers.constants

async function main() {
  const { deployer } = await hre.getNamedAccounts()

  const chainId: number = +(await hre.getChainId())
  console.log(
    `\n\n\nDeploying to network ${hre.network.name} on chain ${chainId}`
  )

  const signer = await hre.ethers.getSigner(deployer)
  console.log("Using wallet", deployer)

  const altar = await ethers.getContract("Altar", signer)
  console.log(`    - Using Altar at address: ${altar.address}`)

  const tokenToList = ""
  const idToList = 0
  const base = parseEther("100")
  const premium = parseEther("0")

  try {
    await altar.list(tokenToList, idToList, base, premium)
  } catch (err) {
    console.log({ err })
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
