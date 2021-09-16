import hre, { ethers, waffle } from "hardhat"
import { Signer, Contract, Wallet } from "ethers"
import { log } from "./shared/utils"
import { getContract } from "../scripts/utils"
import { expect } from "chai"
import { ShadowFixture, shadowFixture } from "./shared/fixtures"
import { parseEther } from "ethers/lib/utils"
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
  let forShadowling: number = 0

  const loadFixture = createFixtureLoader(accounts, waffle.provider)

  beforeEach(async function () {
    owner = accounts[0].address
    fixture = await loadFixture(shadowFixture)
    ;({ altar, token, shdw, mock721, mock1155 } = fixture)
    tokenId = 1

    await altar.setBaseCost(mock721.address, parseEther("10000"))
    await altar.setBaseCost(mock1155.address, parseEther("10000"))
    await mock721.mintId(tokenId)
    await mock1155.mintId(tokenId)
  })

  describe("altar#list", function () {
    it("should list with no premium", async function () {
      await expect(altar.setBaseCost(mock721.address, 1))
        .to.emit(altar, "SetBaseCost")
        .withArgs(owner, mock721.address, 1)

      expect((await altar.cost(mock721.address)).toString()).to.be.eq("1")
      expect(
        (await altar.totalCost(mock721.address, tokenId)).toString()
      ).to.be.eq("1")
    })

    it("should list with premium", async function () {
      await expect(altar.setBaseCost(mock721.address, 1))
        .to.emit(altar, "SetBaseCost")
        .withArgs(owner, mock721.address, 1)

      await expect(altar.setPremiumCost(mock721.address, tokenId, 1))
        .to.emit(altar, "SetPremiumCost")
        .withArgs(owner, mock721.address, tokenId, 1)

      expect(
        (await altar.premium(mock721.address, tokenId)).toString()
      ).to.be.eq("1")
      expect(
        (await altar.totalCost(mock721.address, tokenId)).toString()
      ).to.be.eq("2")
    })

    it("should setBaseCost to 0", async function () {
      await altar.setBaseCost(mock1155.address, 1)
      await expect(altar.setBaseCost(mock1155.address, 0)).to.emit(
        altar,
        "SetBaseCost"
      )
    })
  })

  describe("altar#sacrifice", function () {
    it("721#should list then do sacrifice", async function () {
      let cost = await altar.totalCost(mock721.address, tokenId)
      await expect(altar.sacrifice721(mock721.address, tokenId, forShadowling))
        .to.emit(altar, "Sacrificed")
        .withArgs(
          owner,
          mock721.address,
          tokenId,
          1,
          cost.toString(),
          forShadowling
        )
    })

    it("altar#forShadowling: should list then sacrifice for shadowling", async function () {
      await expect(() =>
        altar.sacrifice721(mock721.address, tokenId, 20)
      ).to.changeTokenBalance(token, accounts[0], "0")
    })

    it("721#should list then sacrifice and get void", async function () {
      let cost = await altar.totalCost(mock721.address, tokenId)
      await expect(() =>
        altar.sacrifice721(mock721.address, tokenId, forShadowling)
      ).to.changeTokenBalance(token, accounts[0], cost)
    })

    it("1155#should list then sacrifice", async function () {
      let amount = 1
      await expect(altar.setBaseCost(mock1155.address, 1))
        .to.emit(altar, "SetBaseCost")
        .withArgs(owner, mock1155.address, 1)

      let cost = await altar.totalCost(mock1155.address, tokenId)
      await expect(
        altar.sacrifice1155(mock1155.address, tokenId, amount, forShadowling)
      )
        .to.emit(altar, "Sacrificed")
        .withArgs(
          owner,
          mock1155.address,
          tokenId,
          amount,
          cost.toString(),
          forShadowling
        )

      expect(
        (await altar.premium(mock1155.address, tokenId)).toString()
      ).to.be.eq("0")
    })

    it("1155#should list then sacrifice and get void", async function () {
      let amount = 1
      await expect(altar.setBaseCost(mock1155.address, 1))
        .to.emit(altar, "SetBaseCost")
        .withArgs(owner, mock1155.address, 1)

      let cost = await altar.totalCost(mock1155.address, tokenId)
      await expect(() =>
        altar.sacrifice1155(mock1155.address, tokenId, amount, forShadowling)
      ).to.changeTokenBalance(token, accounts[0], cost)

      expect(
        (await altar.premium(mock1155.address, tokenId)).toString()
      ).to.be.eq("0")
    })
  })

  describe("revert cases", function () {
    it("721#should revert if not owner", async function () {
      await altar.sacrifice721(mock721.address, tokenId, forShadowling)
      await expect(
        altar.connect(accounts[1]).takeSingle(mock721.address, tokenId)
      ).to.be.reverted
    })

    it("1155#should revert if not owner", async function () {
      await altar.sacrifice1155(mock1155.address, tokenId, 1, forShadowling)
      await expect(
        altar.connect(accounts[1]).takeMany(mock721.address, tokenId, 1)
      ).to.be.reverted
    })

    it("setBaseCost#revert if not owner", async function () {
      await altar.setBaseCost(mock1155.address, 1)
      await expect(altar.connect(accounts[1]).setBaseCost(mock1155.address, 0))
        .to.be.reverted
    })
  })

  describe("owner actions", function () {
    it("721#take", async function () {
      await altar.sacrifice721(mock721.address, tokenId, forShadowling)
      await expect(altar.takeSingle(mock721.address, tokenId))
        .to.emit(altar, "Taken")
        .withArgs(owner, mock721.address, tokenId, 1)
    })

    it("1155#take", async function () {
      let amount = 4
      for (let i = 0; i < amount + 1; i++) {
        await mock1155.mint()
      }
      await altar.setBaseCost(mock1155.address, 1)
      await altar.sacrifice1155(mock1155.address, 0, 1, forShadowling)
      await expect(altar.takeMany(mock1155.address, 0, 1))
        .to.emit(altar, "Taken")
        .withArgs(owner, mock1155.address, 0, 1)
    })
  })
})
