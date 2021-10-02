import path from "path"
import "hardhat-deploy"
import "hardhat-contract-sizer"
import "@nomiclabs/hardhat-waffle"
import "@nomiclabs/hardhat-ethers"
import "@nomiclabs/hardhat-etherscan"
import { HardhatUserConfig } from "hardhat/config"
import "./tasks/claim"
import "./tasks/getShadowling"
import "./tasks/setBaseCost"
import "./tasks/setCurrencyCost"
import "./tasks/setPremiumCost"
import "./tasks/setup"
import "./tasks/verifyAll"
import * as dotenv from "dotenv"
import { parseUnits } from "@ethersproject/units"

dotenv.config({ path: path.resolve(__dirname, "./.env") })

const { ETHERSCAN_API_KEY, DEPLOYER_KEY, MAINNET_RPC, KOVAN_RPC, RINKEBY_RPC } =
  process.env

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const maxFeePerGas = parseUnits("100", "gwei")
const maxPriorityFeePerGas = parseUnits("20", "gwei")

export default {
  networks: {
    hardhat: {
      hardfork: "london",
    },
    kovan: {
      accounts: [DEPLOYER_KEY],
      chainId: 42,
      url: KOVAN_RPC,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      type: "0x02",
    },

    rinkeby: {
      accounts: [DEPLOYER_KEY],
      chainId: 4,
      url: RINKEBY_RPC,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      type: "0x02",
    },
  },
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
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: ETHERSCAN_API_KEY,
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
      default: 0, // first account
    },
  },
  contractSizer: {
    runOnCompile: true,
  },
}
