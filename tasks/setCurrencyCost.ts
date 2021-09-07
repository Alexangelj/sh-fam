import { task } from "hardhat/config"
import { parseEther } from "@ethersproject/units"

task("setCurrencyCost", "Generate keys, saves them on-chain and on local disk")
  .addParam("currencyid", "CurrencyId number")
  .addParam("cost", "Void burned to use the currency type with currencyId")
  .setAction(async (args, hre) => {
    const { deployer } = await hre.getNamedAccounts()
    const signer = await hre.ethers.getSigner(deployer)
    console.log("Using wallet", deployer)

    const altar = await hre.ethers.getContract("Altar", signer)
    console.log(`Using altar at address ${altar.address}`)

    let tx: any
    try {
      console.log("Setting currency cost...")
      tx = await altar.setCurrencyCost(args.currencyid, parseEther(args.cost))
    } catch (err) {
      console.log({ err })
    }

    let receipt = await tx.wait()

    console.log(receipt)

    console.log("Done!")
  })
