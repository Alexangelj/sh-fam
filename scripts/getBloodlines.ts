import { run, ethers } from "hardhat"
import { xmons } from "../0xmons"
import fs from "fs"

async function main() {
  let bloodlines = xmons.xmons.map((xmon: any) => xmon.Name)
  function callbk(prev: any, curr: any, index: any) {
    if (index > 32) return prev
    return prev + "," + curr
  }
  bloodlines = bloodlines.reduce(callbk)

  await fs.promises.writeFile("./bloodlines.json", JSON.stringify(bloodlines))

  console.log("Bloodlines:", bloodlines)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
