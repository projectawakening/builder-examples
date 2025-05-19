import { useRecord } from "../mud/useRecord";
import { useRecords } from "../mud/useRecords";
import { stash } from "../mud/stash";
import worldMudConfig from "contracts/evefrontier/mud.config";
import {
  SmartAssemblies,
  SmartAssembly,
  SmartAssemblyType,
  State,
  InventoryItem
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
export function useSmartAssembly(smartObjectId = 0n) {
  // Retrieve the Smart Assembly ID from environment variables if it's not already passed
  if (smartObjectId == 0n) {
    smartObjectId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);
  }

  // Basic smart assembly information
  const smartDeployableStateView = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.DeployableState,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyType = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.SmartAssembly,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyLocation = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.Location,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyEntityRecordMetadata = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.EntityRecordMetadata,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyEntityRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.EntityRecord,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyFuelBalance = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.Fuel,
    key: {
      smartObjectId,
    },
  });

  const smartAssemblyInventory = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.Inventory,
    key: {
      smartObjectId
    }
  })

  // Get all inventory items at once using a single useRecord call
  const inventoryItems = smartAssemblyInventory?.items?.map((item: any) => ({
    itemId: Number(item),
    quantity: 0,
    typeId: 0,
    name: ""
  })) || [];

  // Get all inventory item details using useRecords
  const inventoryItemDetails = useRecords({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.InventoryItem,
    keys: smartAssemblyInventory?.items?.map((item: bigint) => ({
      smartObjectId: smartObjectId,
      itemObjectId: item
    })) || []
  });

  // Update inventory items with details if available
  if (inventoryItemDetails) {
    inventoryItemDetails.forEach((detail) => {
      const item = inventoryItems.find((item: InventoryItem) => item.itemId === Number(detail.itemObjectId));
      if (item) {
        item.quantity = Number(detail.quantity);
      }
    });
  }

  const ownershipRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.OwnershipByObject,
    key: {
      smartObjectId,
    },
  });

  const smartCharacterByAddress = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.CharactersByAccount,
    key: {
      account: ownershipRecord?.account || "0x",
    },
  });

  const smartCharacterRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.EntityRecordMetadata,
    key: {
      smartObjectId: smartCharacterByAddress?.smartObjectId || BigInt(0),
    },
  });

  // Base Smart Assembly object (will be extended based on the assembly type)
  let smartAssemblyBase: SmartAssembly | undefined;

  if (
    ownershipRecord != undefined &&
    smartCharacterRecord != undefined &&
    smartDeployableStateView?.smartObjectId
  ) {
    smartAssemblyBase = {
      id: smartDeployableStateView?.smartObjectId.toString() || "",
      itemId: Number(smartAssemblyEntityRecord?.itemId) || 0,
      owner: {
        address: ownershipRecord?.account.toString() || "",
        id: smartCharacterRecord?.smartObjectId.toString() || "",
        name: smartCharacterRecord?.name || "",
      },
      chainId: import.meta.env.VITE_CHAIN_ID,
      name: smartAssemblyEntityRecordMetadata?.name || "",
      description: smartAssemblyEntityRecordMetadata?.description || "",
      dappURL: smartAssemblyEntityRecordMetadata?.dappURL || "",
      image: "",
      state: smartDeployableStateView?.currentState.toString() || State.NULL,
      solarSystemId: Number(smartAssemblyLocation?.solarSystemId),
      solarSystem: {
        id: smartAssemblyLocation?.solarSystemId.toString() || "",
        name: smartAssemblyLocation?.solarSystemId.toString() || "",
        location: {
          x: Number(smartAssemblyLocation?.x),
          y: Number(smartAssemblyLocation?.y),
          z: Number(smartAssemblyLocation?.z),
        },
      },
      typeId: Number(smartAssemblyEntityRecord?.typeId) || 0,
      region: "", // TODO: Add logic for fetching region data
      floorPrice: "0",
      fuel: {
        amount: smartAssemblyFuelBalance?.fuelAmount || BigInt(0),
        fuelConsumptionIntervalInSec:
          smartAssemblyFuelBalance?.fuelConsumptionIntervalInSeconds ||
          BigInt(0),
        maxCapacity: smartAssemblyFuelBalance?.fuelMaxCapacity || BigInt(0),
        unitVolume: smartAssemblyFuelBalance?.fuelUnitVolume || BigInt(10),
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
    table: worldMudConfig.namespaces.evefrontier.tables.SmartGateLink,
    key: {
      sourceGateId: smartObjectId,
    },
  });

  const smartStorageUnitInv = useRecord({
    stash,
    table: worldMudConfig.namespaces.evefrontier.tables.Inventory,
    key: {
      smartObjectId,
    },
  });

  if (smartAssemblyBase)
    switch (smartAssemblyType?.assemblyType) {
      case "SSU":
        smartAssembly = {
          ...smartAssemblyBase,
          type: "SmartStorageUnit",
          storage: {
            mainInventory: {
              capacity: smartStorageUnitInv?.capacity || BigInt(0),
              usedCapacity: smartStorageUnitInv?.usedCapacity || BigInt(0),
              items: inventoryItems || [],
            },
            ephemeralInventories: [],
          },
        };
        break;
      case "ST":
        smartAssembly = {
          ...smartAssemblyBase,
          type: "SmartTurret",
          proximity: {},
        };
        break;
      case "SG":
        smartAssembly = {
          ...smartAssemblyBase,
          type: "SmartGate",
          gate: {
            inRange: [],
            linked: smartgateLink?.isLinked || false,
            destinationId:
              smartgateLink?.destinationGateId.toString() || undefined,
          },
        };
        break;
    }

  return { smartAssemblyBase, smartAssembly };
}