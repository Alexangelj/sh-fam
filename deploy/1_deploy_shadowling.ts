import { HardhatRuntimeEnvironment } from "hardhat/types"
import { DeployFunction } from "hardhat-deploy/types"

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre
  const { deploy } = deployments

  const { deployer } = await getNamedAccounts()

  console.log(`\n Deploying Altar`)
  const altar = await deploy("Altar", {
    from: deployer,
    args: [],
    log: true,
  })

  console.log(`\n Deploying Void Token`)
  await deploy("Void", {
    from: deployer,
    args: [altar.address],
    log: true,
  })

  console.log(`\n Deploying Shadowlings`)
  await deploy("Shadowlings", {
    from: deployer,
    args: [altar.address],
    log: true,
  })
}
export default func
func.tags = ["Shadowlings"]
