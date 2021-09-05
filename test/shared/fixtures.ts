import { ethers, waffle } from "hardhat"
import { Wallet, Contract, BigNumber } from "ethers"
import { deployContract, link } from "ethereum-waffle"
const overrides = { gasLimit: 12500000 }

import Altar from "../../artifacts/contracts/Altar.sol/Altar.json"
import Void from "../../artifacts/contracts/Void.sol/Void.json"
import Shadowling from "../../artifacts/contracts/Shadowling.sol/Shadowling.json"

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
    Shadowling,
    [altar.address],
    overrides
  )

  // sets the new contracts in the altar
  await altar.setVoid(token.address)
  await altar.setShadowling(shdw.address)

  let mock721 = await (await ethers.getContractFactory("MockERC721")).deploy()
  let tokenId = await mock721.id()
  await mock721.mint()
  await mock721.mint()

  let mock1155 = await (await ethers.getContractFactory("MockERC1155")).deploy()
  await mock1155.mint()
  await mock1155.mint()

  await mock721.approve(altar.address, tokenId)
  await mock721.approve(altar.address, tokenId + 1)
  await mock1155.setApprovalForAll(altar.address, true)

  await altar.list(mock721.address, tokenId, 100, 0)
  await altar.offering(mock721.address, tokenId)

  for (let i = 2; i < 9; i++) {
    await altar.setCurrencyCost(i, 1)
  }

  return { altar, token, shdw, mock721, mock1155 }
}
