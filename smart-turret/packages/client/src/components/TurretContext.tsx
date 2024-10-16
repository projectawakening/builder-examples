import { ReactNode, createContext, useEffect, useMemo, useState } from "react";
import { getContract, PublicClient, WalletClient, Abi } from "viem";

import { useConnection } from "@eveworld/contexts";
import { ContractConfig } from "@eveworld/contexts/WorldContext";

import IWorldAbi from "../../../contracts/out/IWorld.sol/IWorld.abi.json";

interface TurretWhitelist {
  eveTokenContract: ContractConfig | null;
  TurretWhitelistContract: ContractConfig | null;
  TurretWhitelistContractAddress: `0x${string}` | undefined;
}

const TurretWhitelistProvider = ({ children }: { children: ReactNode }) => {
  const [TurretWhitelistContractAddress, setTurretWhitelistContractAddress] =
    useState<`0x${string}` | undefined>(undefined);
  const { defaultNetwork, publicClient, walletClient, gatewayConfig } =
    useConnection();

  useEffect(() => {
    const getTurretWhitelistContractAddress = async () => {
      try {
        await fetch(`${gatewayConfig.gatewayHttp}/config`)
          .then((x) => x.json())
          .then((x) => {
            const contractAddress = x[0].contracts.world.address;

            if (!contractAddress)
              throw "Unable to get extraction protocol depot contract address";

            /** TODO: Can we change this to using a getter or MUD generated contract addresses? */
            setTurretWhitelistContractAddress(
              contractAddress ?? "0xaC3165820bceC4B86562E4a42bb03F08624FD687",
            );
          });
      } catch (e) {
        console.error("Error:", e);
      }
    };

    getTurretWhitelistContractAddress();
  }, [gatewayConfig]);

  const TurretWhitelistContract = useMemo(
    () =>
      getContract({
        abi: IWorldAbi as Abi,
        address: defaultNetwork.worldAddress,
        client: {
          public: publicClient as PublicClient,
          wallet: walletClient as WalletClient,
        },
      }),
    [defaultNetwork, walletClient],
  );

  return (
    <TurretWhitelistContext.Provider
      value={{
        TurretWhitelistContract,
        TurretWhitelistContractAddress,
      }}
    >
      {children}
    </TurretWhitelistContext.Provider>
  );
};

export const TurretWhitelistContext = createContext<TurretWhitelist>({
  TurretWhitelistContract: null,
  TurretWhitelistContractAddress: "0x",
});

export default TurretWhitelistProvider;