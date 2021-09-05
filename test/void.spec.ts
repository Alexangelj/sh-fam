import hre, { ethers } from "hardhat"
import { Signer, Contract } from "ethers"
import { log } from "./shared/utils"

describe("Altar", function () {
  let accounts: Signer[], altar: Contract, tokenId: number

  beforeEach(async function () {
    accounts = await ethers.getSigners()
    const AltarFactory = await ethers.getContractFactory("Altar")
    altar = await AltarFactory.deploy()
    await altar.deployed()

    tokenId = Math.floor(6969 * Math.random())
  })

  it("should claim tokenId 1, print its props, then change it and re print", async function () {})
})
