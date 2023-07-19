import '@rainbow-me/rainbowkit/styles.css';
import '@/styles/globals.css';

//rainbowkit imports
import { getDefaultWallets, RainbowKitProvider } from '@rainbow-me/rainbowkit';
//wagmi imports

import { WagmiConfig, configureChains, createConfig } from 'wagmi';
import { sepolia } from 'wagmi/chains';
import { publicProvider } from 'wagmi/providers/public';

const { chains, publicClient } = configureChains([sepolia], [publicProvider()]);

const { connectors } = getDefaultWallets({
  appName: 'CryptoDevs DAO',
  projectId: 'ebdc5e933f6d66c03c71fed25598f60d',
  chains,
});

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
});

export default function App({ Component, pageProps }) {
  return (
    <WagmiConfig config={wagmiConfig}>
      <RainbowKitProvider chains={chains}>
        <Component {...pageProps} />
      </RainbowKitProvider>
    </WagmiConfig>
  );
}
