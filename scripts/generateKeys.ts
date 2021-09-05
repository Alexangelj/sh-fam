import { task } from "hardhat/config"
import crypto from "crypto"
import { BytesLike } from "@ethersproject/bytes"
import fs from "fs"

function generateRandomKey(): string {
  return crypto.randomBytes(32).toString("hex")
}

task("generateKeys", "Generate keys and saves them on local disk")
  .addParam("amount", "Amount of keys to generate")
  .setAction(async (args, hre) => {
    console.log(`\nGenerating ${args.amount} keys...\n`)

    const keys: string[] = []
    const hashes: BytesLike[] = []

    for (let i = 0; i < args.amount; i += 1) {
      const key = generateRandomKey()
      console.log(key)
      keys.push(key)

      hashes.push(hre.ethers.utils.solidityKeccak256(["string"], [key]))
    }

    console.log("\nKeys generated!")

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
    console.log("\nDone!\n")
    return { keys: keys, hashes: hashes }
  })
