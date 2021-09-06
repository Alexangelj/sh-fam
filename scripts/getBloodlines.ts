import { run, ethers } from "hardhat"
import { xmons } from "../0xmons"
import fs from "fs"

async function main() {
  await run("compile")

  const accounts = await ethers.getSigners()

  //let epithets = xmons.xmons.map((xmon: any) => xmon.Epithets)
  let epithets = xmons.xmons.map((xmon: any) => xmon.Name)
  function callbk(prev: any, curr: any, index: any) {
    if (index > 32) return prev
    return prev + "," + curr
  }
  epithets = epithets.reduce(callbk)

  await fs.promises.writeFile("./epithets.json", JSON.stringify(epithets))

  console.log("Seeds:", epithets)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
