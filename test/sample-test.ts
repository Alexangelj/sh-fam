import { ethers } from "hardhat"
import { Signer, Contract } from "ethers"
import fs from "fs"

describe("Shadowling", function () {
  let accounts: Signer[], sh: Contract

  const parseTokenURI = (uri: string) => {
    const json = Buffer.from(uri.substring(29), "base64").toString() //(uri.substring(29));
    const result = JSON.parse(json)
    return result
  }

  const parseImage = (json: any) => {
    const imageHeader = "data:image/svg+xml;base64,"
    const image = Buffer.from(
      json.image.substring(imageHeader.length),
      "base64"
    ).toString()
    return image
  }

  beforeEach(async function () {
    accounts = await ethers.getSigners()
    const ShadowFactory = await ethers.getContractFactory("Shadowling")
    sh = await ShadowFactory.deploy()
    await sh.deployed()
  })

  function log(val: string, id?: string) {
    console.log(id ? id : "", val)
  }

  it("should claim 1 and print tokenURI", async function () {
    let i = 1
    await sh.claim(i)
    const uri = await sh.tokenURI(i)
    const json = parseTokenURI(uri)
    const image = parseImage(json)
    log(json)
    log(json.image)

    const imageData = { [i]: json.image }
    await fs.promises.writeFile("./data.json", JSON.stringify(imageData))
  })
})
