import { ethers, waffle } from "hardhat"
import { Wallet, Contract, BigNumber } from "ethers"
import { deployContract, link } from "ethereum-waffle"
const overrides = { gasLimit: 12500000 }

import Altar from "../../artifacts/contracts/Altar.sol/Altar.json"
import Void from "../../artifacts/contracts/Void.sol/Void.json"
import Shadowlings from "../../artifacts/contracts/Shadowlings.sol/Shadowlings.json"

export interface ShadowFixture {
  altar: Contract
  token: Contract
  shdw: Contract
  mock721: Contract
  mock1155: Contract
}

export async function shadowFixture(
  [wallet]: Wallet[],
  provider: any
): Promise<ShadowFixture> {
  // deploys altar, no constructor args
  const altar = await deployContract(wallet, Altar, [], overrides)
  // deploys dependency contracts with altar as the constructor arg
  const token = await deployContract(wallet, Void, [altar.address], overrides)
  const shdw = await deployContract(
    wallet,
    Shadowlings,
    [altar.address],
    overrides
  )

  // sets the new contracts in the altar
  await altar.initialize(token.address, shdw.address)

  let mock721 = await (await ethers.getContractFactory("MockERC721")).deploy()
  let mock1155 = await (await ethers.getContractFactory("MockERC1155")).deploy()

  await mock721.setApprovalForAll(altar.address, true)
  await mock1155.setApprovalForAll(altar.address, true)

  for (let i = 2; i < 9; i++) {
    await altar.setCurrencyCost(i, 1)
  }

  return { altar, token, shdw, mock721, mock1155 }
}
