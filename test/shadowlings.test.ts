import hre, { ethers, waffle } from "hardhat"
import { Contract, Wallet } from "ethers"
import fs from "fs"
import { ShadowFixture, shadowFixture } from "./shared/fixtures"
const { createFixtureLoader } = waffle

import { log, parseTokenURI, parseImage } from "./shared/utils"
import { expect } from "chai"
import {
  formatBytes32String,
  keccak256,
  parseEther,
  sha256,
  solidityKeccak256,
} from "ethers/lib/utils"

describe("Shadowlings", function () {
  let accounts: Wallet[] = waffle.provider.getWallets()
  let altar: Contract
  let token: Contract
  let tokenId: number
  let owner: string
  let mock721: Contract
  let mock1155: Contract
  let fixture: ShadowFixture
  let shdw: Contract, revealHash: string

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

    await altar.setBaseCost(mock721.address, parseEther("1000000"))
    await altar.setBaseCost(mock1155.address, parseEther("1000000"))
    await mock721.mintId(tokenId)
    await mock1155.mintId(tokenId)
    await altar.sacrifice721(mock721.address, tokenId, 0)
    revealHash = formatBytes32String("pug")
    const hashedKey = await altar.getHash(revealHash)
    await altar.commitKey(hashedKey)
    await hre.network.provider.send("evm_mine")
  })

  it("shadowling#owner", async function () {
    expect(await shdw.owner()).to.be.eq(altar.address)
  })

  describe("altar#claim", function () {
    it("should claim tokenId 1", async function () {
      await altar.claim(tokenId, revealHash)
      let uri = await shdw.tokenURI(tokenId)
      let json = parseTokenURI(uri)
      log(json)
    })

    it("should claim tokenId 1, print its props, then change it and re print", async function () {
      await altar.claim(tokenId, revealHash)
      let uri = await shdw.tokenURI(tokenId)
      let json = parseTokenURI(uri)
      log(json)
      revealHash = formatBytes32String("yoga")
      const hashedKey = await altar.getHash(revealHash)
      await altar.commitKey(hashedKey)
      await hre.network.provider.send("evm_mine")
      await altar.modify(tokenId, 2, revealHash)
      uri = await shdw.tokenURI(tokenId)
      json = parseTokenURI(uri)
      log(json)
    })
  })

  describe("altar#modify", function () {
    it("should modify all four traits", async function () {
      let i = tokenId
      await altar.claim(i, revealHash)
      let uri = await shdw.tokenURI(i)
      let json = parseTokenURI(uri)
      log(json)
      revealHash = formatBytes32String("pog")
      const hashedKey = await altar.getHash(revealHash)
      await altar.commitKey(hashedKey)
      await hre.network.provider.send("evm_mine")
      await altar.modify(i, 2, revealHash)
      uri = await shdw.tokenURI(i)
      json = parseTokenURI(uri)
      log(json)
    })

    it("should remove all four traits then add them", async function () {
      let i = tokenId
      await altar.claim(i, revealHash)
      revealHash = formatBytes32String("gop")
      const hashedKey = await altar.getHash(revealHash)
      await altar.commitKey(hashedKey)
      await hre.network.provider.send("evm_mine")
      await altar.modify(i, 6, revealHash)
      let uri = await shdw.tokenURI(i)
      let json = parseTokenURI(uri)
      log(json)
      revealHash = formatBytes32String("yoda")
      const hashed = await altar.getHash(revealHash)
      await altar.commitKey(hashed)
      await hre.network.provider.send("evm_mine")
      await altar.modify(i, 5, revealHash)
      uri = await shdw.tokenURI(i)
      json = parseTokenURI(uri)
      log(json)
    })

    it("should claim 50", async function () {
      let images: string[] = []
      let imageData: any = {}
      for (let i = 100; i < 150; i++) {
        revealHash = formatBytes32String((i * Math.random()).toString())
        await altar.commitKey(await altar.getHash(revealHash))
        await hre.network.provider.send("evm_mine")
        try {
          await altar.claim(i, revealHash)
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
