import { useAccount, useClient, useConnectorClient } from "wagmi";
import { chainId, worldAbi } from "../common";
import { getContract } from "viem";
import { useSync } from "./useSync";
import { useQuery } from "@tanstack/react-query";
import { observer } from "@latticexyz/explorer/observer";
import { useEffect, useState } from "react";
import { getWorldDeploy } from "./getWorldDeploy";

type InferredUseSyncResult = ReturnType<typeof useSync>;

export function useWorldContract():
  | {
      worldContract: any;
      waitForTransaction: InferredUseSyncResult["waitForTransaction"];
    }
  | {
      worldContract?: undefined;
      waitForTransaction?: undefined;
    } {
  const [worldAddress, setWorldAddress] = useState<`0x${string}`>("0x");

  const { waitForTransaction } = useSync();
  const client = useClient({ chainId });
  const { data: sessionClient } = useConnectorClient();
  const { chain } = useAccount();

  useEffect(() => {
    const getWorldAddress = async () => {
      const { address: worldAddress } = await getWorldDeploy(chain?.id ?? 1);
      setWorldAddress(worldAddress);
    };

    getWorldAddress();
  }, []);

  const { data: worldContract } = useQuery({
    queryKey: ["worldContract", worldAddress, client?.uid, sessionClient?.uid],
    queryFn: () => {
      if (!client || !sessionClient) {
        throw new Error("Not connected.");
      }

      return getContract({
        abi: worldAbi,
        address: worldAddress,
        client: {
          public: client,
          wallet: sessionClient.extend(observer()),
        },
      });
    },
    staleTime: Infinity,
    refetchOnMount: false,
    refetchOnReconnect: false,
    refetchOnWindowFocus: false,
  });

  return worldContract && waitForTransaction
    ? {
        worldContract,
        waitForTransaction,
      }
    : {};
}
