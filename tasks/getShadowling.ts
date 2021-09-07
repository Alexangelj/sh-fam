import { task } from "hardhat/config"
import { parseEther } from "@ethersproject/units"

task(
  "getShadowling",
  "Gets the shadowling contract address from the altar"
).setAction(async (args, hre) => {
  const { deployer } = await hre.getNamedAccounts()
  const signer = await hre.ethers.getSigner(deployer)
  console.log("Using wallet", deployer)

  const altar = await hre.ethers.getContract("Altar", signer)
  console.log(`Using altar at address ${altar.address}`)

  let tx: any
  try {
    console.log("Getting shadowling")
    tx = await altar.shadowling()
  } catch (err) {
    console.log({ err })
  }

  console.log(`\n Shadowling: ${tx}`)

  const shadowling = await hre.ethers.getContract("Shadowling", signer)
  console.log(`Using shadowling at address ${shadowling.address}`)
  try {
    console.log("Getting altar from shadowling")
    tx = await shadowling.owner()
  } catch (err) {
    console.log({ err })
  }

  console.log(`\n Altar: ${tx}`)

  console.log("Done!")
})
