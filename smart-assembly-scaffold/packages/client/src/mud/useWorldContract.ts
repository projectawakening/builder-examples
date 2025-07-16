import { useAccount, useClient, useConnectorClient } from "wagmi";
import { chainId, worldAbi } from "../common";
import {
  Account,
  Chain,
  Client,
  GetContractReturnType,
  Transport,
  getContract,
} from "viem";
import { useQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { getWorldDeploy } from "./getWorldDeploy";
import { observer } from "@latticexyz/explorer/observer";

export function useWorldContract():
  | GetContractReturnType<
      typeof worldAbi,
      {
        public: Client<Transport, Chain>;
        wallet: Client<Transport, Chain, Account>;
      }
    >
  | undefined {
  const [worldAddress, setWorldAddress] = useState<`0x${string}`>("0x");

  const { chain } = useAccount();
  const client = useClient({ chainId });
  const { data: sessionClient } = useConnectorClient();

  useEffect(() => {
    const getWorldAddress = async () => {
      try {
        const currentChainId = chain?.id ?? chainId ?? 31337;
        console.log("Getting world deploy for chain ID:", currentChainId);

        const { address: worldAddress } = await getWorldDeploy(currentChainId);
        console.log("World address retrieved:", worldAddress);

        setWorldAddress(worldAddress);
      } catch (error) {
        console.error("Failed to get world address:", error);
        // Fallback to default if available
        if (chainId === 31337) {
          setWorldAddress("0x0165878A594ca255338adfa4d48449f69242Eb8F");
        }
      }
    };

    getWorldAddress();
  }, [chain?.id, chainId]);

  const { data: worldContract } = useQuery({
    queryKey: ["worldContract", client?.uid, sessionClient?.uid, worldAddress],
    queryFn: () => {
      if (!client || !sessionClient) {
        throw new Error("Not connected.");
      }

      if (!worldAddress || worldAddress === "0x") {
        throw new Error("World address not available yet.");
      }

      console.log("Creating world contract with address:", worldAddress);

      return getContract({
        abi: worldAbi,
        address: worldAddress,
        client: {
          public: client,
          wallet: sessionClient.extend(observer()),
        },
      });
    },
    enabled: !!(
      client &&
      sessionClient &&
      worldAddress &&
      worldAddress !== "0x"
    ),
    staleTime: Infinity,
    refetchOnMount: false,
    refetchOnReconnect: false,
    refetchOnWindowFocus: false,
  });

  return worldContract;
}
