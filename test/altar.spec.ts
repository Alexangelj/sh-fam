import hre, { ethers } from "hardhat"
import { Signer, Contract } from "ethers"
import { log } from "./shared/utils"
import { getContract } from "../scripts/utils"
import { expect } from "chai"

describe("Altar", function () {
  let accounts: Signer[],
    altar: Contract,
    token: Contract,
    tokenId: number,
    owner: string,
    nft: Contract,
    mixed: Contract

  beforeEach(async function () {
    accounts = await ethers.getSigners()
    owner = await accounts[0].getAddress()
    const AltarFactory = await ethers.getContractFactory("Altar")
    altar = await AltarFactory.deploy()
    await altar.deployed()
    token = await (
      await ethers.getContractFactory("Void")
    ).deploy(altar.address)

    nft = await (await ethers.getContractFactory("MockERC721")).deploy()
    tokenId = await nft.id()
    await nft.mint()

    mixed = await (await ethers.getContractFactory("MockERC1155")).deploy()
    tokenId = await mixed.id()
    await mixed.mint()
  })

  describe("altar#register", function () {
    it("should register with no premium", async function () {
      await expect(altar.register(nft.address, tokenId, 1, 0))
        .to.emit(altar, "Registered")
        .withArgs(owner, nft.address, 1, 0)

      expect((await altar.cost(nft.address)).toString()).to.be.eq("1")
      expect((await altar.value(nft.address, tokenId)).toString()).to.be.eq("1")
    })

    it("should register with premium", async function () {
      await expect(altar.register(nft.address, tokenId, 1, 1))
        .to.emit(altar, "Registered")
        .withArgs(owner, nft.address, 1, 1)

      expect((await altar.premium(nft.address)).toString()).to.be.eq("1")
      expect((await altar.value(nft.address, tokenId)).toString()).to.be.eq("2")
    })

    it("721#should register then sacrifice", async function () {
      await expect(altar.register(nft.address, tokenId, 1, 1))
        .to.emit(altar, "Registered")
        .withArgs(owner, nft.address, 1, 1)

      let cost = await altar.cost(nft.address)
      await expect(altar.sacrifice(nft.address, tokenId))
        .to.emit(altar, "Sacrificed")
        .withArgs(owner, nft.address, tokenId, cost.toString())

      expect((await altar.premium(nft.address)).toString()).to.be.eq("1")
    })

    it("721#should register then sacrifice and get void", async function () {
      await expect(altar.register(nft.address, tokenId, 1, 1))
        .to.emit(altar, "Registered")
        .withArgs(owner, nft.address, 1, 1)

      let cost = await altar.cost(nft.address)
      await expect(() =>
        altar.sacrifice(nft.address, tokenId)
      ).to.changeTokenBalance(token, owner, cost)

      expect((await altar.premium(nft.address)).toString()).to.be.eq("1")
    })

    it("1155#should register then sacrifice", async function () {
      let amount = 1
      await expect(altar.register(mixed.address, tokenId, 1, 0))
        .to.emit(altar, "Registered")
        .withArgs(owner, mixed.address, 1, 0)

      let cost = await altar.cost(mixed.address)
      await expect(altar.sacrifice(mixed.address, tokenId, amount))
        .to.emit(altar, "Sacrificed")
        .withArgs(owner, mixed.address, tokenId, cost.toString())

      expect((await altar.premium(mixed.address)).toString()).to.be.eq("1")
    })

    it("1155#should register then sacrifice and get void", async function () {
      let amount = 1
      await expect(altar.register(mixed.address, tokenId, 1, 0))
        .to.emit(altar, "Registered")
        .withArgs(owner, mixed.address, 1, 0)

      let cost = await altar.cost(mixed.address)
      await expect(() =>
        altar.sacrifice(mixed.address, tokenId, amount)
      ).to.changeTokenBalance(token, owner, cost)

      expect((await altar.premium(mixed.address)).toString()).to.be.eq("1")
    })

    it("should deregister", async function () {
      await altar.register(mixed.address, tokenId, 1, 0)
      await expect(altar.deregister(mixed.address, tokenId)).to.emit(
        altar,
        "Deregistered"
      )
    })
  })

  describe("revert cases", function () {
    beforeEach(async function () {
      await altar.register(nft.address, tokenId, 1, 0)
      await mixed.register(nft.address, tokenId, 1, 0)
    })

    it("register#should revert if base of 0", async function () {
      await expect(altar.register(mixed.address, tokenId, 0, 0)).to.be.reverted
    })

    it("721#should revert if not owner", async function () {
      await altar.sacrifice(nft.address, tokenId)
      await expect(altar.connect(accounts[1]).take(nft.address, tokenId)).to.be
        .reverted
    })

    it("1155#should revert if not owner", async function () {
      await altar.sacrifice(mixed.address, tokenId, 1)
      await expect(altar.connect(accounts[1]).take(nft.address, tokenId, 1)).to
        .be.reverted
    })

    it("deregister#revert if not owner", async function () {
      await altar.register(mixed.address, tokenId, 1, 0)
      await expect(
        altar.connect(accounts[1]).deregister(mixed.address, tokenId)
      ).to.emit(altar, "Deregistered")
    })
  })

  describe("owner actions", function () {
    it("721#take", async function () {
      await altar.sacrifice(nft.address, tokenId)
      await expect(altar.take(nft.address, tokenId))
        .to.emit(altar, "Taken")
        .withArgs(owner, nft.address, tokenId, 1)
    })

    it("1155#take", async function () {
      let amount = 4
      for (let i = 0; i < amount + 1; i++) {
        await altar.mint()
      }
      await altar.sacrifice(mixed.address, tokenId, amount)
      await expect(altar.take(nft.address, tokenId, amount))
        .to.emit(altar, "Taken")
        .withArgs(owner, nft.address, tokenId, amount)
    })
  })
})
