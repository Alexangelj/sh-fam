import { task } from "hardhat/config"
import { parseEther } from "@ethersproject/units"

task(
  "setPremiumCost",
  "Set the extra amount of void tokens recevied from burning token with id"
)
  .addParam("token", "Address of token")
  .addParam("tokenid", "Extra value from burning token with id")
  .addParam("premium", "Void minted for burning token with a premium")
  .setAction(async (args, hre) => {
    const { deployer } = await hre.getNamedAccounts()
    const signer = await hre.ethers.getSigner(deployer)
    console.log("Using wallet", deployer)

    const altar = await hre.ethers.getContract("Altar", signer)
    console.log(`Using altar at address ${altar.address}`)

    let tx: any
    if (args.premium > 0 && args.tokenid) {
      try {
        console.log("Setting premium costs...")
        tx = await altar.setPremiumCost(
          args.token,
          args.tokenid,
          parseEther(args.premium)
        )
      } catch (err) {
        console.log({ err })
      }
    }

    let receipt = await tx.wait()

    console.log(receipt)

    console.log("Done!")
  })
