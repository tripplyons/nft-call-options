import '@rainbow-me/rainbowkit/styles.css';
import { RainbowKitProvider, getDefaultWallets, connectorsForWallets, wallet, darkTheme } from '@rainbow-me/rainbowkit';
import { chain, configureChains, createClient, WagmiConfig } from 'wagmi';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { publicProvider } from 'wagmi/providers/public';
import Head from 'next/head';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { CacheProvider } from '@emotion/react';
import theme from '../src/theme';
import createEmotionCache from '../src/createEmotionCache';
import { ACCENT_COLOR, BG_COLOR, APP_NAME } from '../src/constants';

// Client-side cache, shared for the whole session of the user in the browser.
const clientSideEmotionCache = createEmotionCache();

const { chains, provider, webSocketProvider } = configureChains(
  [
    process.env.NEXT_PUBLIC_IS_TESTNET === "1" ? chain.polygonMumbai : chain.polygon,
  ],
  [
    alchemyProvider({
      // This is Alchemy's default API key.
      // You can get your own at https://dashboard.alchemyapi.io
      alchemyId: '_gg7wSSi0KMBsdKnGVfHDueq6xMB9EkC',
    }),
    publicProvider(),
  ]
);

const wallets = [
  {
    groupName: 'Popular',
    wallets: [
      wallet.metaMask({ chains, shimDisconnect: true }),
      wallet.walletConnect({ chains }),
      wallet.trust({ chains }),
      wallet.coinbase({ appName: APP_NAME, chains }),
    ],
  },
  {
    groupName: 'Other',
    wallets: [
      wallet.brave({ chains, shimDisconnect: true }),
      wallet.rainbow({ chains }),
      wallet.argent({ chains }),
      wallet.injected({ chains, shimDisconnect: true }),
    ],
  },
]

const connectors = connectorsForWallets(wallets);


const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
  webSocketProvider,
});

function MyApp({ emotionCache = clientSideEmotionCache, Component, pageProps }) {
  return (
    <CacheProvider value={emotionCache}>
      <Head>
        <title>{APP_NAME}</title>
        <meta name="viewport" content="initial-scale=1, width=device-width" />
      </Head>
      <ThemeProvider theme={theme}>
        {/* CssBaseline kickstart an elegant, consistent, and simple baseline to build upon. */}
        <CssBaseline />
        <WagmiConfig client={wagmiClient}>
          <RainbowKitProvider chains={chains} theme={darkTheme({
            accentColor: ACCENT_COLOR,
            accentColorForeground: BG_COLOR,
            borderRadius: 'small',
            fontStack: 'system',
            overlayBlur: 'small',
          })}>
            <Component {...pageProps} />
          </RainbowKitProvider>
        </WagmiConfig>
      </ThemeProvider>
    </CacheProvider>
  );
}

export default MyApp;
