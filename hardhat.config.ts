import path from "path"
import "hardhat-deploy"
import "hardhat-contract-sizer"
import "@nomiclabs/hardhat-waffle"
import "@nomiclabs/hardhat-ethers"
import { HardhatUserConfig } from "hardhat/config"
import "./scripts/generateKeys"
import "./scripts/dropKeys"

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100,
          },
        },
      },
      {
        version: "0.6.8",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100,
          },
        },
      },
    ],
  },
  paths: {
    artifacts: path.join(__dirname, "artifacts"),
    tests: path.join(__dirname, "test"),
  },
  mocha: {
    timeout: 1000000,
  },
  namedAccounts: {
    deployer: {
      default: "",
    },
  },
}

export default config
