require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();

const QUICKNODE_RPC_URL = process.env.RPC_URL;
const METAMASK_PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: '0.8.18',
  networks: {
    sepolia: {
      url: QUICKNODE_RPC_URL,
      accounts: [METAMASK_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
