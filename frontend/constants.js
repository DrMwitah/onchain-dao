import { getContractABI } from './abiUtils';

export const CryptoDevsNFTAddress =
  '0x311F86E2828151f66Ec9c7F8c5507573bC0Ca35d';
export const FakeNFTMarketplaceAddress =
  '0x48bA8CD5Bf69ac7b03fc3FF78bDB866413FA4E10';
export const CryptoDevsDAOAddress =
  '0x3c40961F45CC37a456EE239F7B03d58D5A446358';

export const CryptoDevsNFTABI = await getContractABI('CryptoDevsNFT');
export const FakeNFTMarketplaceABI = await getContractABI('FakeNFTMarketPlace');
export const CryptoDevsDAOABI = await getContractABI('CryptoDevsDAO');
