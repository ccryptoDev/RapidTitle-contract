require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-etherscan");
const { privateKey, mnemonic, infuraKey, apiKey } = require("./secrets.json");

module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    mainnet: {
      url: "https://mainnet.infura.io/v3/" + infuraKey,
      gas: 10000000,
      accounts: [`0x${privateKey}`]
    },
    sepolia: {
		  url: 'https://eth-sepolia.g.alchemy.com/v2/v5h_FiMJrtauW0bi5PNrGLlIMxG4WISv',
      gas: 300000,
		  accounts: [`0x${privateKey}`]
	  },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/" + infuraKey,
      gas: 10000000,
      accounts: [`0x${privateKey}`]
    },
    kovan: {
      url: "https://kovan.infura.io/v3/" + infuraKey,
      gas: 10000000,
      accounts: [`0x${privateKey}`]
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: { mnemonic: mnemonic }
    },
    main: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: { mnemonic: mnemonic }
    }
  },
  etherscan: {
    apiKey: apiKey
  }
};
