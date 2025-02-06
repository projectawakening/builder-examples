import { useRecord } from "../mud/useRecord";
import worldMudConfig from "contracts/eveworld/mud.config";
import { SmartCharacter } from "@eveworld/types";
import { stash } from "../mud/stash";
import { useAccount } from "wagmi";

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

export function useSmartCharacter() {
  const { address } = useAccount();

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

  /**
   * Step 3: Construct the `SmartCharacter` object.
   * - This object consolidates all fetched data and adds placeholder values for balances.
   *
   * @type {SmartCharacter}
   */
  const smartCharacter: SmartCharacter = {
    address: smartCharacterByAddress?.characterAddress || address || "0x",
    id: smartCharacterByAddress?.characterId.toString() || "",
    name: smartCharacterRecord?.name || "",
    isSmartCharacter: smartCharacterRecord != undefined,
    eveBalanceWei: 0, // TODO: Query EVE token balance for the wallet address.
    gasBalanceWei: 0, // TODO: Query gas token balance for the wallet address.
    image: "",
    smartAssemblies: [], // Placeholder for smart assemblies owned by this character
  };

  return { smartCharacter };
}
