import { useAccount, useClient, useConnectorClient } from "wagmi";
import { chainId, worldAbi } from "../common";
import { erc20Abi, getContract, Hex } from "viem";
import { useSync } from "./useSync";
import { useQuery } from "@tanstack/react-query";
import { observer } from "@latticexyz/explorer/observer";
import { useEffect, useState } from "react";
import { getWorldDeploy } from "./getWorldDeploy";

type InferredUseSyncResult = ReturnType<typeof useSync>;

export function useWorldContract(): {
  worldContract: any,
  erc20Contract: any,
  waitForTransaction: InferredUseSyncResult['waitForTransaction'];
} | {
  worldContract?: undefined;
  erc20Contract?: undefined;
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
  
	/*
	 * Create an object for communicating with the deployed ERC20 Contract.
	 */
	const erc20Contract = sessionClient && getContract({
		address: import.meta.env.VITE_ERC20_TOKEN_ADDRESS as Hex,
		abi: erc20Abi,
    client: {
      public: client,
      wallet: sessionClient.extend(observer()),
    },
	});

  // console.log(client, sessionClient)

  return worldContract && waitForTransaction
    ? {
        worldContract,
        erc20Contract,
        waitForTransaction,
      }
    : {};
}