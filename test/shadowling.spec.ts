import hre, { ethers } from "hardhat"
import { Signer, Contract } from "ethers"
import fs from "fs"

import { log, parseTokenURI, parseImage } from "./shared/utils"

describe("Shadowling", function () {
  let accounts: Signer[], sh: Contract, tokenId: number

  beforeEach(async function () {
    accounts = await ethers.getSigners()
    const ShadowFactory = await ethers.getContractFactory("Shadowling")
    sh = await ShadowFactory.deploy()
    await sh.deployed()
    for (let i = 2; i < 10; i++) {
      await sh.mint(i, 1)
    }

    for (let i = 0; i < 275; i++) {
      await hre.network.provider.send("evm_mine")
    }
    await hre.network.provider.send("evm_setAutomine", [true])

    tokenId = Math.floor(6969 * Math.random())
  })

  it("should claim tokenId 1, print its props, then change it and re print", async function () {
    await sh.claim(tokenId)
    let uri = await sh.tokenURI(tokenId)
    let json = parseTokenURI(uri)
    log(json)
    await sh.modify(tokenId, 2)
    uri = await sh.tokenURI(tokenId)
    json = parseTokenURI(uri)
    log(json)
  })

  it("should modify all four traits", async function () {
    let i = tokenId
    await sh.summon(i)
    let uri = await sh.tokenURI(i)
    let json = parseTokenURI(uri)
    log(json)
    await sh.modify(i, 2)
    uri = await sh.tokenURI(i)
    json = parseTokenURI(uri)
    log(json)
  })

  it("should remove all four traits", async function () {
    let i = tokenId
    await sh.summon(i)
    let uri = await sh.tokenURI(i)
    let json = parseTokenURI(uri)
    log(json)
    await sh.modify(i, 6)
    uri = await sh.tokenURI(i)
    json = parseTokenURI(uri)
    log(json)
  })

  it("should remove all four traits then add them", async function () {
    let i = tokenId
    await sh.summon(i)
    await sh.modify(i, 6)
    let uri = await sh.tokenURI(i)
    let json = parseTokenURI(uri)
    log(json)
    await hre.network.provider.send("evm_mine")
    await sh.modify(i, 5)
    uri = await sh.tokenURI(i)
    json = parseTokenURI(uri)
    log(json)
  })

  it("should summon a shadowchain entity", async function () {
    let i = tokenId
    await sh.summon(i)
    let uri = await sh.tokenURI(i)
    let json = parseTokenURI(uri)
    log(json)
  })

  it("should claim until 50", async function () {
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
