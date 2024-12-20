import { WagmiProvider } from "wagmi";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";
import { ReactNode } from "react";
import { StashSyncProvider } from "./StashSyncProvider";
import { stash } from "./stash";
import { Address } from "viem";
import { wagmiConfig } from "./wagmiConfig";
import { darkTheme, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { NotificationProvider } from "@eveworld/contexts";
import SmartObjectWalletProvider from "./SmartObjectWalletProvider";

const queryClient = new QueryClient();

export type Props = {
  worldDeploy: {
    address: Address;
    blockNumber: bigint | null;
  };
  children: ReactNode;
};

export function Providers({ worldDeploy, children }: Props) {
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider
          modalSize="compact"
          theme={darkTheme({
            accentColor: "hsla(26, 85%, 58%, 1)",
          })}
        >
          <StashSyncProvider
            address={worldDeploy.address}
            startBlock={worldDeploy.blockNumber ?? undefined}
            stash={stash}
          >
            <NotificationProvider>
              <SmartObjectWalletProvider>{children}</SmartObjectWalletProvider>
            </NotificationProvider>
          </StashSyncProvider>
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
