import { http, webSocket } from "viem";
import { anvil } from "viem/chains";
import {
  getDefaultConfig,
  getWalletConnectConnector,
  Wallet,
} from "@rainbow-me/rainbowkit";
import { garnet, redstone } from "@latticexyz/common/chains";
import {
  coinbaseWallet,
  injectedWallet,
  metaMaskWallet,
  oneKeyWallet,
  rainbowWallet,
  safeWallet,
  walletConnectWallet,
} from "@rainbow-me/rainbowkit/wallets";

type WalletConnectWalletOptions = Parameters<typeof walletConnectWallet>[0];
const transports = {
  [anvil.id]: webSocket(),
  [garnet.id]: http(),
  [redstone.id]: http(),
} as const;
export interface MyWalletOptions {
  projectId: string;
}
export const EVEVault =
  (options: MyWalletOptions) =>
  (
    createWalletParams: Omit<WalletConnectWalletOptions, "projectId">,
  ): Wallet => ({
    id: "eveVault",
    name: "EVE Vault",
    iconUrl: "https://vault.evefrontier.com/favicon-16.png",
    iconBackground: "#000",
    downloadUrls: {
      android:
        "https://artifacts.evefrontier.com/wallet/android/eve-vault-v1.0.5.apk",
      ios: "https://testflight.apple.com/join/w2NCeawN",
      chrome:
        "https://artifacts.evefrontier.com/wallet/extension/vault-v1.0.9/wallet-alpha.zip",
      qrCode: "https://vault.evefrontier.com",
    },
    mobile: {
      getUri: (uri: string) => uri,
    },
    qrCode: {
      getUri: (uri: string) => uri,
      instructions: {
        learnMoreUrl: "https://docs.evefrontier.com/EveVault/installation",
        steps: [
          {
            description:
              "We recommend putting EVE Vault on your home screen for faster access to your wallet.",
            step: "install",
            title: "Open the EVE Vault app",
          },
          {
            description:
              "After you scan, a connection prompt will appear for you to connect your wallet.",
            step: "scan",
            title: "Tap the scan button",
          },
        ],
      },
    },
    extension: {
      instructions: {
        learnMoreUrl: "https://docs.evefrontier.com/EveVault/installation",
        steps: [
          {
            description:
              "We recommend pinning EVE Vault for quicker access to your wallet.",
            step: "install",
            title: "Install the EVE Vault extension",
          },
          {
            description:
              "Be sure to back up your wallet using a secure method. Never share your secret phrase with anyone.",
            step: "create",
            title: "Create or Import a Wallet",
          },
          {
            description:
              "Once you set up your wallet, click below to refresh the browser and load up the extension.",
            step: "refresh",
            title: "Refresh your browser",
          },
        ],
      },
    },
    createConnector: getWalletConnectConnector({
      projectId: options.projectId,
    }),
  });

export const wagmiConfig = getDefaultConfig({
  projectId: "EVE_FRONTIER_DAPP",
  appName: document.title,
  wallets: [
    {
      groupName: "Recommended",
      wallets: [EVEVault({ projectId: "EVE_FRONTIER_DAPP" }), safeWallet],
    },
    {
      groupName: "Other",
      wallets: [
        injectedWallet,
        metaMaskWallet,
        oneKeyWallet,
        coinbaseWallet,
        walletConnectWallet,
        rainbowWallet,
      ],
    },
  ],
  autoConnect: true,
  multiInjectedProviderDiscovery: false,
  chains: [
    {
      ...redstone,
      blockExplorers: {
        ...redstone.blockExplorers,
        worldsExplorer: {
          name: "MUD Worlds Explorer",
          url: "https://explorer.mud.dev/redstone/worlds",
        },
      },
      iconUrl:
        "https://pbs.twimg.com/profile_images/1724553277147131904/cdma6E3g_400x400.jpg",
    },
    {
      ...garnet,
      blockExplorers: {
        ...garnet.blockExplorers,
        worldsExplorer: {
          name: "MUD Worlds Explorer",
          url: "https://explorer.mud.dev/garnet/worlds",
        },
      },
      iconUrl:
        "https://explorer.garnetchain.com/assets/configs/network_icon.svg",
    },
    {
      ...anvil,
      blockExplorers: {
        ...anvil.blockExplorers,
        worldsExplorer: {
          name: "MUD Worlds Explorer",
          url: "http://localhost:13690/anvil/worlds",
        },
      },
    },
  ],
  transports,
  pollingInterval: {
    [anvil.id]: 2000,
    [garnet.id]: 2000,
    [redstone.id]: 2000,
  },
});
