import { createStash } from "@latticexyz/stash/internal";
import { defineWorld } from "@latticexyz/world";
import config from "contracts/mud.config";
import worldConfig from "contracts/eveworld/mud.config";

/* Define a local, client-only table
To handle where values need to be fetched
Across multiple on-chain tables */
export const localWorld = defineWorld({
  namespace: "storage",
  tables: {
    OwnerStorage: {
      schema: {
        smartObjectId: "uint256",
        typeIds: "uint256[]",
        inventoryItemIds: "uint256[]",
        quantities: "uint256[]",
      },
      key: ["smartObjectId"],
    },
    EphemeralStorage: {
      schema: {
        smartObjectId: "uint256",
        ephemeralInvOwner: "address",
        usedCapacity: "uint256",
        items: "uint256[]",
        quantity: "uint256[]",
      },
      key: ["smartObjectId", "ephemeralInvOwner"],
    },
  },
});

const combinedConfig = {
  namespaces: {
    ...worldConfig.namespaces,
    ...config.namespaces,
    ...localWorld.namespaces,
  },
};

export const stash = createStash(combinedConfig);
