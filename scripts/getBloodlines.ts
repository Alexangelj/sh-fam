import { run, ethers } from "hardhat"
import { xmons } from "../0xmons"
import fs from "fs"

async function main() {
  await run("compile")

  const accounts = await ethers.getSigners()

  let epithets = xmons.xmons.map((xmon: any) => xmon.Epithets)
  epithets = epithets.reduce((prev, curr) => prev + "," + curr)

  await fs.promises.writeFile("./epithets.json", JSON.stringify(epithets))

  console.log(
    "Accounts:",
    accounts.map((a) => a.address)
  )
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
