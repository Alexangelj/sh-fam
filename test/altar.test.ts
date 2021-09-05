import hre, { ethers, waffle } from "hardhat"
import { Signer, Contract, Wallet } from "ethers"
import { log } from "./shared/utils"
import { getContract } from "../scripts/utils"
import { expect } from "chai"
import { ShadowFixture, shadowFixture } from "./shared/fixtures"
const { createFixtureLoader } = waffle

describe("Altar", function () {
  let accounts: Wallet[] = waffle.provider.getWallets()
  let altar: Contract
  let token: Contract
  let tokenId: number
  let shdw: Contract
  let owner: string
  let mock721: Contract
  let mock1155: Contract
  let fixture: ShadowFixture

  const loadFixture = createFixtureLoader(accounts, waffle.provider)

  beforeEach(async function () {
    owner = accounts[0].address
    fixture = await loadFixture(shadowFixture)
    ;({ altar, token, shdw, mock721, mock1155 } = fixture)
    tokenId = 1
  })

  describe("altar#list", function () {
    it("should list with no premium", async function () {
      await expect(altar.list(mock721.address, tokenId, 1, 0))
        .to.emit(altar, "Listed")
        .withArgs(owner, mock721.address, 1, 0)

      expect((await altar.cost(mock721.address)).toString()).to.be.eq("1")
      expect(
        (await altar.totalCost(mock721.address, tokenId)).toString()
      ).to.be.eq("1")
    })

    it("should list with premium", async function () {
      await expect(altar.list(mock721.address, tokenId, 1, 1))
        .to.emit(altar, "Listed")
        .withArgs(owner, mock721.address, 1, 1)

      expect(
        (await altar.premium(mock721.address, tokenId)).toString()
      ).to.be.eq("1")
      expect(
        (await altar.totalCost(mock721.address, tokenId)).toString()
      ).to.be.eq("2")
    })

    it("721#should list then do offering", async function () {
      await expect(altar.list(mock721.address, tokenId, 1, 1))
        .to.emit(altar, "Listed")
        .withArgs(owner, mock721.address, 1, 1)

      let cost = await altar.totalCost(mock721.address, tokenId)
      await expect(altar.offering(mock721.address, tokenId))
        .to.emit(altar, "Sacrificed")
        .withArgs(owner, mock721.address, tokenId, cost.toString())

      expect(
        (await altar.premium(mock721.address, tokenId)).toString()
      ).to.be.eq("1")
    })

    it("721#should list then offering and get void", async function () {
      await expect(altar.list(mock721.address, tokenId, 1, 1))
        .to.emit(altar, "Listed")
        .withArgs(owner, mock721.address, 1, 1)

      let cost = await altar.totalCost(mock721.address, tokenId)
      await expect(() =>
        altar.offering(mock721.address, tokenId)
      ).to.changeTokenBalance(token, accounts[0], cost)

      expect(
        (await altar.premium(mock721.address, tokenId)).toString()
      ).to.be.eq("1")
    })

    it("1155#should list then offering", async function () {
      let amount = 1
      await expect(altar.list(mock1155.address, tokenId, 1, 0))
        .to.emit(altar, "Listed")
        .withArgs(owner, mock1155.address, 1, 0)

      let cost = await altar.totalCost(mock1155.address, tokenId)
      await expect(altar.sacrificeMany(mock1155.address, tokenId, amount))
        .to.emit(altar, "Sacrificed")
        .withArgs(owner, mock1155.address, tokenId, cost.toString())

      expect(
        (await altar.premium(mock1155.address, tokenId)).toString()
      ).to.be.eq("0")
    })

    it("1155#should list then offering and get void", async function () {
      let amount = 1
      await expect(altar.list(mock1155.address, tokenId, 1, 0))
        .to.emit(altar, "Listed")
        .withArgs(owner, mock1155.address, 1, 0)

      let cost = await altar.totalCost(mock1155.address, tokenId)
      await expect(() =>
        altar.sacrificeMany(mock1155.address, tokenId, amount)
      ).to.changeTokenBalance(token, accounts[0], cost)

      expect(
        (await altar.premium(mock1155.address, tokenId)).toString()
      ).to.be.eq("0")
    })

    it("should delist", async function () {
      await altar.list(mock1155.address, tokenId, 1, 0)
      await expect(altar.delist(mock1155.address, tokenId)).to.emit(
        altar,
        "Delisted"
      )
    })
  })

  describe("revert cases", function () {
    beforeEach(async function () {
      await altar.list(mock721.address, tokenId, 1, 0)
      await altar.list(mock1155.address, tokenId, 1, 0)
    })

    it("list#should revert if base of 0", async function () {
      await expect(altar.list(mock1155.address, tokenId, 0, 0)).to.be.reverted
    })

    it("721#should revert if not owner", async function () {
      await altar.offering(mock721.address, tokenId)
      await expect(
        altar.connect(accounts[1]).takeSingle(mock721.address, tokenId)
      ).to.be.reverted
    })

    it("1155#should revert if not owner", async function () {
      await altar.sacrificeMany(mock1155.address, tokenId, 1)
      await expect(
        altar.connect(accounts[1]).takeMany(mock721.address, tokenId, 1)
      ).to.be.reverted
    })

    it("delist#revert if not owner", async function () {
      await altar.list(mock1155.address, tokenId, 1, 0)
      await expect(altar.connect(accounts[1]).delist(mock1155.address, tokenId))
        .to.be.reverted
    })
  })

  describe("owner actions", function () {
    it("721#take", async function () {
      await altar.offering(mock721.address, tokenId)
      await expect(altar.takeSingle(mock721.address, tokenId))
        .to.emit(altar, "Taken")
        .withArgs(owner, mock721.address, tokenId, 1)
    })

    it("1155#take", async function () {
      let amount = 4
      for (let i = 0; i < amount + 1; i++) {
        await mock1155.mint()
      }
      await altar.list(mock1155.address, 0, 1, 0)
      await altar.sacrificeMany(mock1155.address, 0, 1)
      await expect(altar.takeMany(mock1155.address, 0, 1))
        .to.emit(altar, "Taken")
        .withArgs(owner, mock1155.address, 0, 1)
    })
  })
})
