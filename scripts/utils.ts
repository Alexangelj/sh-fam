import fs from "fs"
import { Contract } from "ethers"
import { JsonRpcSigner } from "@ethersproject/providers"
import hre, { ethers } from "hardhat"

export const getSigner = async (address: string): Promise<JsonRpcSigner> => {
  return hre.ethers.provider.getSigner(address)
}

export const getContract = async (
  name: string,
  signer: any
): Promise<Contract> => {
  const contract = await hre.deployments.get(name)
  const instance: Contract = new ethers.Contract(
    contract.address,
    contract.abi,
    signer
  )
  return instance
}

export async function readLog(chainId: number, contractName: string) {
  try {
    const logRaw = await fs.promises.readFile("./deployments.json", {
      encoding: "utf-8",
      flag: "a+",
    })
    let log

    if (logRaw.length === 0) {
      log = {}
    } else {
      log = JSON.parse(logRaw)
    }

    if (!log[chainId]) {
      log[chainId] = {}
    }

    return log[chainId][contractName]
  } catch (e) {
    console.error(e)
  }
}
