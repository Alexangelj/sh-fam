import { task } from "hardhat/config"
import { parseEther } from "@ethersproject/units"

task(
  "setShadowlingCost",
  "Set amount of void tokens burned per shadowling mint"
)
  .addParam("cost", "Void burned to mint a shadowling")
  .setAction(async (args, hre) => {
    const { deployer } = await hre.getNamedAccounts()
    const signer = await hre.ethers.getSigner(deployer)
    console.log("Using wallet", deployer)

    const altar = await hre.ethers.getContract("Altar", signer)
    console.log(`Using altar at address ${altar.address}`)

    console.log("Setting shadowling cost...")
    let tx: any
    try {
      tx = await altar.setShadowlingCost(parseEther(args.cost))
    } catch (err) {
      console.log({ err })
    }

    let receipt = await tx.wait()

    console.log(receipt)

    console.log("Done!")
  })
