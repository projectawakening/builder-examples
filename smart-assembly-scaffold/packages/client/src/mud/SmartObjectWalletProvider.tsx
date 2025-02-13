// src/providers/WalletAddressProvider.tsx

import { SmartObjectProvider } from "@eveworld/contexts";
import { ConnectWallet } from "@eveworld/ui-components";
import React from "react";
import { useAccount } from "wagmi";

interface SmartObjectWalletProviderProps {
  children: React.ReactNode;
}

const SmartObjectWalletProvider: React.FC<SmartObjectWalletProviderProps> = ({
  children,
}) => {
  const { address } = useAccount();

  if (!address) return <ConnectWallet />;

  return (
    <SmartObjectProvider walletAddress={address}>
      {children}
    </SmartObjectProvider>
  );
};

export default SmartObjectWalletProvider;
