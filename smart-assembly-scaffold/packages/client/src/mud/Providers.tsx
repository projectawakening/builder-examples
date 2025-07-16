import { WagmiProvider } from "wagmi";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";
import { ReactNode } from "react";
import { StashSyncProvider } from "./StashSyncProvider";
import { createSyncAdapter } from "@latticexyz/store-sync/internal";
import { SyncProvider } from "@latticexyz/store-sync/react";
import { stash } from "./stash";
import { Address } from "viem";
import { wagmiConfig } from "./wagmiConfig";
import { darkTheme, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { NotificationProvider } from "@eveworld/contexts";

const queryClient = new QueryClient();

export type Props = {
  worldDeploy: {
    chainId: number;
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
          <SyncProvider
            chainId={worldDeploy.chainId}
            address={worldDeploy.address}
            startBlock={worldDeploy.blockNumber ?? undefined}
            adapter={createSyncAdapter({ stash })}
          >
            <NotificationProvider>{children}</NotificationProvider>
          </SyncProvider>
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
