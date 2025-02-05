import { useRecord } from "../mud/useRecord";
import { stash } from "../mud/stash";
import worldMudConfig from "contracts/eveworld/mud.config";
import {
  SmartAssemblies,
  SmartAssembly,
  SmartAssemblyType,
  State,
} from "@eveworld/types";
import { useEffect, useState } from "react";
import { getWorldDeploy } from "../mud/getWorldDeploy";
import { mapApiResult } from "../utils/mapApiResult";
import { getAddress } from "viem";

/**
 * `useSmartAssembly` hook
 *
 * This hook is designed to fetch and construct a `SmartAssembly` object based on a given `smartObjectId`.
 * The hook retrieves various properties of the assembly by querying multiple MUD tables, such as:
 * - Basic information (state, type, fuel, location).
 * - Ownership details (owner ID and name).
 * - Assembly-specific details (Smart Storage Unit, Smart Turret, Smart Gate).
 *
 * The resulting `smartAssembly` object is tailored based on the assembly type.
 *
 * @returns {Object} `smartAssembly` - The constructed SmartAssembly object, or `undefined` if the data is incomplete.
 */
export function useSmartAssembly() {
  const [owner, setOwner] = useState<`0x${string}` | undefined>();

  // Retrieve the Smart Assembly ID from environment variables
  const smartObjectId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);

  // Basic smart assembly information
  const smartDeployableStateView = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.DeployableState,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyType = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.SmartAssemblyTable,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyLocation = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.LocationTable,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyEntityOffchainRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.EntityRecordOffchainTable,
    key: {
      entityId: smartObjectId,
    },
  });

  const smartAssemblyEntityRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.EntityRecordTable,
    key: {
      entityId: smartObjectId,
    },
  });

  const smartAssemblyFuelBalance = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.DeployableFuelBalance,
    key: {
      smartObjectId,
    },
  });

  /**
   * Ownership Information
   *
   * This section retrieves the ownership details for a given `smartObjectId`.
   * Instead of importing the MUD configuration for this namespace, it directly
   * queries the Indexer API. This approach avoids additional dependencies.
   *
   * This method may not be available in local development due to CORS
   * restrictions on the sqlite indexer.
   * Local: http://localhost:13690/api/sqlite-indexer
   * Garnet: https://indexer.mud.garnetchain.com/q
   * Redstone: https://indexer.mud.redstonechain.com/q
   *
   * {@link https://mud.dev/indexer/sql}
   *
   * Steps:
   * 1. Call `getWorldDeploy` to fetch the world address using the chain ID.
   * 2. Execute an SQL query through the Indexer API.
   * 3. Map the API result using `mapApiResult`.
   */
  useEffect(() => {
    const getOwner = async () => {
      const worldAddress = await getWorldDeploy(import.meta.env.VITE_CHAIN_ID);

      // sql query from the indexer.
      const response = await fetch("https://indexer.mud.garnetchain.com/q", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify([
          {
            address: worldAddress.address,
            query: `SELECT tokenId, owner 
						FROM erc721deploybl__Owners 
						WHERE erc721deploybl__Owners.tokenId = ${smartObjectId};`,
          },
        ]),
      }).then((res) => res.json());

      const ownerApiResult = mapApiResult(response.result);
      setOwner(ownerApiResult.owner);
    };

    getOwner();
    // If on local and unable to query the sqlite indexer, you can manually set the owner
    // instead of calling the above function
    // setOwner("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
  }, [smartObjectId]);

  const smartCharacterByAddress = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.CharactersByAddressTable,
    key: {
      characterAddress: owner ? getAddress(owner as `0x${string}`) : "0x",
    },
  });

  const smartCharacterRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.EntityRecordOffchainTable,
    key: {
      entityId: smartCharacterByAddress?.characterId || BigInt(0),
    },
  });

  // Base Smart Assembly object (will be extended based on the assembly type)
  let smartAssemblyBase: SmartAssembly | undefined;

  if (
    owner != undefined &&
    smartCharacterRecord != undefined &&
    smartDeployableStateView?.smartObjectId
  ) {
    smartAssemblyBase = {
      id: smartDeployableStateView?.smartObjectId.toString() || "",
      itemId: Number(smartAssemblyEntityRecord?.itemId) || 0,
      ownerId: owner,
      ownerName: smartCharacterRecord?.name || "",
      chainId: import.meta.env.VITE_CHAIN_ID,
      name: smartAssemblyEntityOffchainRecord?.name || "",
      description: smartAssemblyEntityOffchainRecord?.description || "",
      dappUrl: smartAssemblyEntityOffchainRecord?.dappURL || "",
      image: "",
      isValid: smartDeployableStateView?.isValid || false,
      isOnline: smartDeployableStateView?.currentState == State.ONLINE,
      stateId: smartDeployableStateView?.currentState || State.NULL,
      state: smartDeployableStateView?.currentState || State.NULL,
      anchoredAtTime: smartDeployableStateView?.anchoredAt.toString() || "",
      solarSystemId: Number(smartAssemblyLocation?.solarSystemId),
      solarSystem: {
        solarSystemId: smartAssemblyLocation?.solarSystemId.toString() || "",
        solarSystemName: smartAssemblyLocation?.solarSystemId.toString() || "",
        solarSystemNameId:
          smartAssemblyLocation?.solarSystemId.toString() || "",
      },
      typeId: Number(smartAssemblyEntityRecord?.typeId) || 0,
      region: "", // TODO: Add logic for fetching region data
      locationX: smartAssemblyLocation?.x.toString() || "",
      locationY: smartAssemblyLocation?.y.toString() || "",
      locationZ: smartAssemblyLocation?.z.toString() || "",
      fuel: {
        fuelAmount: smartAssemblyFuelBalance?.fuelAmount || BigInt(0),
        fuelConsumptionPerMin:
          smartAssemblyFuelBalance?.fuelConsumptionPerMinute || BigInt(0),
        fuelMaxCapacity: smartAssemblyFuelBalance?.fuelMaxCapacity || BigInt(0),
        fuelUnitVolume: smartAssemblyFuelBalance?.fuelUnitVolume || BigInt(10),
      },
    };
  }

  /**
	Construct the SmartAssembly object based on its type.
	Some fields are left empty or assigned placeholder values since they are not used in this example.
	If needed, you can fetch additional data directly from the World API using the `fetch` method, 
	which encapsulates logic to retrieve this information.
	*/

  let smartAssembly: SmartAssemblyType<SmartAssemblies> | undefined;

  // SMART GATE VALUES //
  const smartgateLink = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.SmartGateLinkTable,
    key: {
      sourceGateId: smartObjectId,
    },
  });

  // SMART STORAGE UNIT VALUES //
  // Commented out for now until this table is fixed in the Garnet indexer db
  // const smartStorageUnitInv = useRecord({
  //   stash,
  //   table: worldMudConfig.namespaces.eveworld.tables.InventoryTable,
  //   key: {
  //     smartObjectId,
  //   },
  // });
  const smartStorageUnitInv = {
    capacity: BigInt(0),
    usedCapacity: BigInt(0),
  };

  if (smartAssemblyBase)
    switch (smartAssemblyType?.smartAssemblyType) {
      case 0:
        smartAssembly = {
          ...smartAssemblyBase,
          assemblyType: "SmartStorageUnit",
          inventory: {
            storageCapacity: smartStorageUnitInv?.capacity || BigInt(0),
            usedCapacity: smartStorageUnitInv?.usedCapacity || BigInt(0),
            storageItems: [],
            ephemeralInventoryList: [],
          },
        };
        break;
      case 1:
        smartAssembly = {
          ...smartAssemblyBase,
          assemblyType: "SmartTurret",
          proximity: {},
        };
        break;
      case 2:
        smartAssembly = {
          ...smartAssemblyBase,
          assemblyType: "SmartGate",
          gateLink: {
            gatesInRange: [],
            isLinked: smartgateLink?.isLinked || false,
            destinationGate:
              smartgateLink?.destinationGateId.toString() || undefined,
          },
        };
        break;
    }

  return { smartAssemblyBase, smartAssembly };
}
