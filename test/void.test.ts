import hre, { ethers } from "hardhat"
import { Signer, Contract } from "ethers"
import { log } from "./shared/utils"
import { getContract } from "../scripts/utils"
import { expect } from "chai"

describe("Void", function () {
  let accounts: Signer[], altar: Contract, token: Contract, tokenId: number

  beforeEach(async function () {
    accounts = await ethers.getSigners()
    const AltarFactory = await ethers.getContractFactory("Altar")
    altar = await AltarFactory.deploy()
    await altar.deployed()
    token = await (
      await ethers.getContractFactory("Void")
    ).deploy(altar.address)
  })

  describe("void#constructor", function () {
    it("should have symbol", async function () {
      expect(await token.symbol()).to.be.eq("VOID")
    })

    it("should have name", async function () {
      expect(await token.name()).to.be.eq("Void Token")
    })

    it("should have altar", async function () {
      expect(await token.altar()).to.be.eq(altar.address)
    })
  })

  describe("success cases", function () {
    beforeEach(async function () {
      token = await (
        await ethers.getContractFactory("Void")
      ).deploy(await accounts[0].getAddress())
    })
    it("should mint from owners call", async function () {
      await expect(token.mint(altar.address, 1)).to.not.be.reverted
    })

    it("should burn from owners call", async function () {
      await expect(token.mint(altar.address, 1)).to.not.be.reverted
      await expect(token.burn(altar.address, 1)).to.not.be.reverted
    })
  })

  describe("revert cases", function () {
    it("should revert if minting from not owner", async function () {
      await expect(token.mint(altar.address, 1)).to.be.reverted
    })

    it("should revert if burning from not owner", async function () {
      await expect(token.burn(altar.address, 1)).to.be.reverted
    })
  })
})
