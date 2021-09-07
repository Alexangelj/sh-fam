import { task } from "hardhat/config"

task("verifyAll", "Verifies all contracts").setAction(async (args, hre) => {
  const voidToken = await hre.ethers.getContract("Void")
  const altar = await hre.ethers.getContract("Altar")
  const shadowling = await hre.ethers.getContract("Shadowling")

  console.log(`\n Verifying void token at: ${voidToken.address}`)

  await hre.run("verify:verify", {
    address: voidToken.address,
    constructorArguments: [altar.address],
  })

  console.log(`\n Verifying shadowling at: ${shadowling.address}`)
  await hre.run("verify:verify", {
    address: shadowling.address,
    constructorArguments: [altar.address],
  })

  console.log(`\n Verifying altar at: ${altar.address}`)
  await hre.run("verify:verify", {
    address: altar.address,
    constructorArguments: [],
  })

  console.log("Verified")
})
