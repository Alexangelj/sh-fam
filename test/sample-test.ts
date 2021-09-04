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

  it("should claim tokenId 1, print its props, then change it and re print", async function () {
    let i = 10
    await sh.claim(i)
    let uri = await sh.tokenURI(i)
    let json = parseTokenURI(uri)
    log(json)
    await sh.modify(i)
    uri = await sh.tokenURI(i)
    json = parseTokenURI(uri)
    log(json)
  })

  it("should summon a shadowchain entity", async function () {
    let i = 10
    await sh.summon(i)
    let uri = await sh.tokenURI(i)
    let json = parseTokenURI(uri)
    log(json)
    await sh.modify(i)
    uri = await sh.tokenURI(i)
    json = parseTokenURI(uri)
    log(json)
  })

  it.skip("should claim until 50", async function () {
    let images = []
    let imageData: any = {}
    for (let i = 0; i < 50; i++) {
      try {
        await sh.claim(i)
      } catch (err) {
        console.log("Error on:", i, err)
      }
      const uri = await sh.tokenURI(i)
      const json = parseTokenURI(uri)
      const image = parseImage(json)
      images.push(image)
      imageData[i] = json.image
      log(json)
    }

    await fs.promises.writeFile("./data.json", JSON.stringify(imageData))
  })
})
