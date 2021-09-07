import { task } from "hardhat/config"
import crypto from "crypto"
import { BytesLike } from "@ethersproject/bytes"
import fs from "fs"

function generateRandomKey(): string {
  return crypto.randomBytes(32).toString("hex")
}

task("dropKeys", "Generate keys, saves them on-chain and on local disk")
  .addParam("amount", "Amount of keys to drop")
  .setAction(async (args, hre) => {
    console.log(`Dropping ${args.amount} keys...`)

    const keys: string[] = []
    const hashes: BytesLike[] = []

    for (let i = 0; i < args.amount; i += 1) {
      const key = generateRandomKey()
      console.log(key)
      keys.push(key)

      hashes.push(hre.ethers.utils.solidityKeccak256(["string"], [key]))
    }

    console.log("Keys generated!")

    console.log("Saving them in the .keys.log file...")

    const log = await fs.promises.readFile("./.keys", {
      encoding: "utf-8",
      flag: "a+",
    })

    await fs.promises.writeFile(
      "./.keys",
      log.length === 0
        ? log.concat(keys.join("\n"))
        : log.concat("\n", keys.join("\n"))
    )
    console.log("Done!")

    const { deployer } = await hre.getNamedAccounts()
    const signer = await hre.ethers.getSigner(deployer)
    console.log("Using wallet", deployer)

    const target = await hre.ethers.getContract("Shadowling", signer)
    console.log(`Using contract at address ${target.address}`)

    console.log("Adding the keys to the contract...")

    const tx = await target.addKeys(hashes)
    const receipt = await tx.wait()

    console.log(receipt)

    console.log("Done!")

    return { keys: keys, hashes: hashes }
  })
