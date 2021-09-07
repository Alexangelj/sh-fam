import { task } from "hardhat/config"
import { parseEther } from "@ethersproject/units"

task(
  "setBaseCost",
  "Set the base amount of void tokens received from burning NFT"
)
  .addParam("token", "Address of token")
  .addParam("cost", "Void minted for burning token")
  .setAction(async (args, hre) => {
    const { deployer } = await hre.getNamedAccounts()
    const signer = await hre.ethers.getSigner(deployer)
    console.log("Using wallet", deployer)

    const altar = await hre.ethers.getContract("Altar", signer)
    console.log(`Using altar at address ${altar.address}`)

    console.log("Setting costs...")
    let tx: any
    try {
      console.log("Setting base costs...")
      tx = await altar.setBaseCost(args.token, parseEther(args.cost))
    } catch (err) {
      console.log({ err })
    }

    let receipt = await tx.wait()

    console.log(receipt)

    console.log("Done!")
  })
