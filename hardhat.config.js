require('@nomiclabs/hardhat-ethers')
require("@nomiclabs/hardhat-etherscan");

require('dotenv/config')

function getAccounts() {
  const key = process.env.DEPLOYER_PRIVATE_KEY
  return [key ?? '0x0000000000000000000000000000000000000000000000000000000000000000']
}

function getRpcUrl(network) {
  return `https://${network}-api.flare.network/ext/bc/C/rpc`
}

function getApiUrl(network) {
  return `https://${network}-explorer.flare.network/api`
}

function getBrowserUrl(network) {
  return `https://${network}-explorer.flare.network/`
}

module.exports = {
  networks: {
    hardhat: {
      chainId: 14,
      hardfork: 'london',
      accounts: {
        accountsBalance: '10000000000000000000000000',
      },
    },
    coston: {
      url: getRpcUrl('coston'),
      chainId: 16,
      accounts: getAccounts(),
    },
    coston2: {
      url: getRpcUrl('coston2'),
      chainId: 114,
      accounts: getAccounts(),
    },
    songbird: {
      url: getRpcUrl('songbird'),
      chainId: 19,
      accounts: getAccounts(),
    },
    flare: {
      url: getRpcUrl('flare'),
      chainId: 14,
      accounts: getAccounts(),
    },
  },
  etherscan: {
    apiKey: {
      coston: '...',
      coston2: '...',
      songbird: '...',
      flare: '...',
    },
    customChains: [
      {
        network: 'coston',
        chainId: 16,
        urls: {
          apiURL: getApiUrl('coston'),
          browserURL: getBrowserUrl('coston')
        }
      },
      {
        network: 'coston2',
        chainId: 114,
        urls: {
          apiURL: getApiUrl('coston2'),
          browserURL: getBrowserUrl('coston2')
        }
      },
      {
        network: 'songbird',
        chainId: 19,
        urls: {
          apiURL: getApiUrl('songbird'),
          browserURL: getBrowserUrl('songbird')
        }
      },
      {
        network: 'flare',
        chainId: 14,
        urls: {
          apiURL: getApiUrl('flare'),
          browserURL: getBrowserUrl('flare')
        }
      },
    ]
  },
  solidity: {
    version: '0.8.17',
    settings: {
      metadata: {
        bytecodeHash: 'none',
      },
      evmVersion: 'london',
      optimizer: {
        enabled: true,
        runs: 10000,
      },
    },
  },
}
