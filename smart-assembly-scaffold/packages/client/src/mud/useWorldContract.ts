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
      const { address: worldAddress } = await getWorldDeploy(chain?.id ?? 1);
      setWorldAddress(worldAddress);
    };

    getWorldAddress();
  }, []);

  const { data: worldContract } = useQuery({
    queryKey: ["worldContract", client?.uid, sessionClient?.uid],
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

  return worldContract;
}
