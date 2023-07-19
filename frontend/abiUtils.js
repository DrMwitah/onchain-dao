const fs = require('fs-extra');
const path = require('path');

const getContractABI = async (contractName) => {
  try {
    // Replace the old artifactsDir with the correct one
    const artifactsDir = path.join(
      __dirname,
      '..',
      '..',
      '..',
      '..',

      'artifacts'
    );
    const abiFilePath = path.join(
      artifactsDir,
      'contracts',
      `${contractName}.sol`,
      `${contractName}.json`
    );
    const abiData = await fs.readJson(abiFilePath);
    return abiData.abi;
  } catch (error) {
    console.error('Error reading ABI:', error);
    return null;
  }
};

module.exports = {
  getContractABI,
};
