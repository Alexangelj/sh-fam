import hre, { ethers, waffle } from "hardhat"
import { Contract, Wallet } from "ethers"
import fs from "fs"
import { ShadowFixture, shadowFixture } from "./shared/fixtures"
const { createFixtureLoader } = waffle

import { log, parseTokenURI, parseImage } from "./shared/utils"
import { expect } from "chai"

describe("Shadowling", function () {
  let accounts: Wallet[] = waffle.provider.getWallets()
  let altar: Contract
  let token: Contract
  let tokenId: number
  let owner: string
  let mock721: Contract
  let mock1155: Contract
  let fixture: ShadowFixture
  let shdw: Contract

  const loadFixture = createFixtureLoader(accounts, waffle.provider)

  beforeEach(async function () {
    owner = accounts[0].address
    fixture = await loadFixture(shadowFixture)
    ;({ altar, token, shdw, mock721, mock1155 } = fixture)

    for (let i = 0; i < 275; i++) {
      await hre.network.provider.send("evm_mine")
    }
    await hre.network.provider.send("evm_setAutomine", [true])

    tokenId = Math.floor(6969 * Math.random())

    await altar.setShadowlingCost(1)
    await altar.setBaseCost(mock721.address, 1000)
    await altar.setBaseCost(mock1155.address, 1000)
    await mock721.mintId(tokenId)
    await mock1155.mintId(tokenId)
    await altar.sacrifice721(mock721.address, tokenId, false)
  })

  it("shadowling#owner", async function () {
    expect(await shdw.owner()).to.be.eq(altar.address)
  })

  describe("altar#claim", function () {
    it("should claim tokenId 1", async function () {
      await altar.claim(tokenId)
      let uri = await shdw.tokenURI(tokenId)
      let json = parseTokenURI(uri)
      log(json)
    })

    it("should claim tokenId 1, print its props, then change it and re print", async function () {
      await altar.claim(tokenId)
      let uri = await shdw.tokenURI(tokenId)
      let json = parseTokenURI(uri)
      log(json)
      await altar.modify(tokenId, 2)
      uri = await shdw.tokenURI(tokenId)
      json = parseTokenURI(uri)
      log(json)
    })
  })

  describe("altar#summon", function () {
    it("should summon a shadowchain entity", async function () {
      let i = tokenId
      await altar.summon(i)
      let uri = await shdw.tokenURI(i)
      let json = parseTokenURI(uri)
      log(json)
    })
  })

  describe("altar#modify", function () {
    it("should modify all four traits", async function () {
      let i = tokenId
      await altar.summon(i)
      let uri = await shdw.tokenURI(i)
      let json = parseTokenURI(uri)
      log(json)
      await altar.modify(i, 2)
      uri = await shdw.tokenURI(i)
      json = parseTokenURI(uri)
      log(json)
    })

    it("should remove all four traits then add them", async function () {
      let i = tokenId
      await altar.summon(i)
      await altar.modify(i, 6)
      let uri = await shdw.tokenURI(i)
      let json = parseTokenURI(uri)
      log(json)
      await altar.modify(i, 5)
      uri = await shdw.tokenURI(i)
      json = parseTokenURI(uri)
      log(json)
    })

    it("should claim 50", async function () {
      let images: string[] = []
      let imageData: any = {}
      for (let i = 100; i < 150; i++) {
        try {
          await altar.claim(i)
        } catch (err) {
          console.log("Error on:", i, err)
        }
        const uri = await shdw.tokenURI(i)
        const json = parseTokenURI(uri)
        const image = parseImage(json)
        images.push(image)
        imageData[i] = json.image
        log(json)
      }

      await fs.promises.writeFile("./data.json", JSON.stringify(imageData))
    })
  })
})
