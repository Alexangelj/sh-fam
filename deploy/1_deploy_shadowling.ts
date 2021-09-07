import { HardhatRuntimeEnvironment } from "hardhat/types"
import { DeployFunction } from "hardhat-deploy/types"

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre
  const { deploy } = deployments

  const { deployer } = await getNamedAccounts()

  const altar = await deploy("Altar", {
    from: deployer,
    args: [],
    log: true,
  })

  await deploy("Void", {
    from: deployer,
    args: [altar.address],
    log: true,
  })

  await deploy("Shadowling", {
    from: deployer,
    args: [altar.address],
    log: true,
  })
}
export default func
func.tags = ["Shadowling"]
