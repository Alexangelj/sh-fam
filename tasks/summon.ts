import { task } from "hardhat/config"
import { parseEther } from "@ethersproject/units"

task("summon", "Summons a shadowling from the shadowchain")
  .addParam("tokenid", "Shadowling tokenId to mint")
  .setAction(async (args, hre) => {
    const { deployer } = await hre.getNamedAccounts()
    const signer = await hre.ethers.getSigner(deployer)
    console.log("Using wallet", deployer)

    const altar = await hre.ethers.getContract("Altar", signer)
    console.log(`Using altar at address ${altar.address}`)

    console.log(`Summoning ${args.tokenid}...`)
    let tx: any
    try {
      tx = await altar.summon(args.tokenid)
    } catch (err) {
      console.log({ err })
    }

    let receipt = await tx.wait()

    console.log(receipt)

    console.log("Done!")
  })
