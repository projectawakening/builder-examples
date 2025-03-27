import { useRecord } from "../mud/useRecord";
import worldMudConfig from "contracts/eveworld/mud.config";
import { SmartCharacter } from "@eveworld/types";
import { stash } from "../mud/stash";
import { useAccount, useClient, usePublicClient, useConnectorClient } from "wagmi";
import { erc20Abi, getContract } from "viem";
import { chainId } from "../common";
import { observer } from "@latticexyz/explorer/observer";
import { useEffect, useState } from "react";

import { getWorldDeploy } from "../mud/getWorldDeploy";

/**
 * `useSmartCharacter` hook
 *
 * This hook fetches information about a user based on whether their connected wallet address
 * is registered to a character ID in a MUD table. It retrieves data from two MUD tables:
 * 1. `CharactersByAddressTable` - Maps an address to a character ID.
 * 2. `EntityRecordOffchainTable` - Contains metadata for the character, such as its name.
 *
 * Note:
 * - Some fields, like ERC-20 token balances, are not fetched from MUD and must be queried
 *   separately (e.g., using the `balanceOf` function of the respective token's contract).
 * - This hook provides a foundation for creating SmartCharacter objects that can be expanded
 *   based on your needs.
 */

// Extend the original SmartCharacter interface
type ExtendedSmartCharacter = SmartCharacter & {
  corpId: number;
}

export function useSmartCharacter() {
  const { address } = useAccount();

  const client = useClient({ chainId });
  const publicClient = usePublicClient({ chainId });

  const { data: sessionClient } = useConnectorClient();

  var chainID = import.meta.env.VITE_CHAIN_ID
  
  const [worldAddress, setWorldAddress] = useState<`0x${string}`>("0x");

  const [eveBalanceWei, setEveBalanceWei] = useState<BigInt>(0)
  const [GASBalanceWei, setGASBalanceWei] = useState<BigInt>(0)

  //Array of ID's for the players owned smart assemblies
  const [ownedSmartAssemblies, setOwnedSmartAssemblies] = useState<BigInt[]>([]);
  
  useEffect(() => {
    const getWorldAddress = async () => {
      const { address: worldAddress } = await getWorldDeploy(chainID ?? 1);
      setWorldAddress(worldAddress);
    };

    getWorldAddress();
  }, []);   

  
  useEffect(() => {
    const getBalance = async() => {      
      //Get the GAS Balance
      const GASBalance = await publicClient.getBalance({
        address: address
      })

      setGASBalanceWei(GASBalance)

      //If it's local, don't get the EVE Token Balance as it's not currently supported
      if(chainID == 31337) {
        return
      }      

      let EVETokenAddress = import.meta.env.VITE_EVE_TOKEN_ADDRESS

      //Get the erc20 ABI
      const contract = getContract({
        address: EVETokenAddress,
        abi: erc20Abi,
        client: {
          public: client,
          wallet: sessionClient?.extend(observer()),
        }
      })
  
      //Use the balanceOf smart contract read function
      const balance = await contract.read.balanceOf([
        address.toString()
      ])

      setEveBalanceWei(balance)
    }

    getBalance()
  }, [])

  //Get an array of ID's for owned smart assemblies
  useEffect(() => {
    const getOwnedAssemblies = async () => {     
      if(!address) return;

      var chainID = import.meta.env.VITE_CHAIN_ID
      var ownedArray : BigInt[] = [] 

      //If this DApp is on your local anvil chain, set the owner as a default
      if(chainID == 31337){
        ownedArray.push(import.meta.env.VITE_SMARTASSEMBLY_ID)

        setOwnedSmartAssemblies(ownedArray);
        return;
      } 

      const worldAddress = await getWorldDeploy(chainID);      

      const response = await fetch("https://indexer.mud.pyropechain.com/q", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify([
          {
            address: worldAddress.address,
            query: `SELECT "tokenId", "owner" FROM erc721deploybl__Owners WHERE "owner" = '${address}';`,
          },
        ]),
      }).then((res) => res.json());

      for(var i = 1; i < response.result[0].length; i++){
        ownedArray.push(response.result[0][i][0]);
      }

      setOwnedSmartAssemblies(ownedArray)
    }

    getOwnedAssemblies();
  }, [address])

  /**
   * Fetch the character ID associated with the user's wallet address.
   * - Queries `CharactersByAddressTable` in the MUD stash.
   * - Key: `{ characterAddress }`
   */
  const smartCharacterByAddress = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.CharactersByAddressTable,
    key: {
      characterAddress: address as `0x${string}` || "",
    },
  });

  /**
   * Fetch metadata for the character using the retrieved character ID.
   * - Queries `EntityRecordOffchainTable` in the MUD stash.
   * - Key: `{ entityId }`
   * - If no character ID is found, defaults to `BigInt(0)` (no record).
   */
  const smartCharacterRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.EntityRecordOffchainTable,
    key: {
      entityId: smartCharacterByAddress?.characterId || BigInt(0),
    },
  });

  
  const characterRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.CharactersTable,
    key: {
      characterId: smartCharacterByAddress?.characterId || BigInt(0),
    },
  });

  /**
   * Step 3: Construct the `SmartCharacter` object.
   * - This object consolidates all fetched data and adds placeholder values for balances.
   *
   * @type {SmartCharacter}
   */
  const smartCharacter: ExtendedSmartCharacter = {
    address: smartCharacterByAddress?.characterAddress || address || "0x",
    id: smartCharacterByAddress?.characterId.toString() || "",
    name: smartCharacterRecord?.name || "",
    corpId: characterRecord?.corpId,
    isSmartCharacter: smartCharacterRecord != undefined,
    eveBalanceWei: 0, // TODO: Query EVE token balance for the wallet address.
    gasBalanceWei: 0, // TODO: Query gas token balance for the wallet address.
    image: "",
    smartAssemblies: [], // Placeholder for smart assemblies owned by this character
  };

  return { smartCharacter };
}
