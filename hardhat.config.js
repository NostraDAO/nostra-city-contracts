require("@nomiclabs/hardhat-waffle");
require('hardhat-contract-sizer');
let secret = require('./secrets.json');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.10",
  settings: {
    optimizer: {
      enabled: false,
      runs: 10
    }
  },
  networks: {
    localhost: {
      url: secret.url,
      gasPrice: 20000000000,
      accounts: [secret.key]
    },
    hardhat: {
      gasPrice: 50000000000
    },
    testnet: {
      url: 'https://speedy-nodes-nyc.moralis.io/fd2a0b38275c004b283ea982/avalanche/testnet',
      gasPrice: 20000000000,
      accounts: [secret.key]
    },
    fuji: {
      url: 'https://speedy-nodes-nyc.moralis.io/fd2a0b38275c004b283ea982/avalanche/testnet',
      gasPrice: 40000000000,
      chainId: 43113,
      accounts: [secret.key]
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      //accounts: {mnemonic: mnemonic}
    }
  }

};
