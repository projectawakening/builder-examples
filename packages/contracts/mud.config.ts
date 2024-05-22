import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "test",
  systems: {
    WarEffort: {
      name: "WarEffort",
      openAccess: true,
    },
  },
  tables: {
    /*********************
     * WAR EFFORT MODULE *
     *********************/
    /**
     * Used to store the transfer details when a item is exchanged
     */
    WarEffortTable: {
      keySchema: {
        smartObjectId: "uint256",
      },
      valueSchema: {
        isGoalReached: "bool",
        acceptedItemTypeId: "uint256",
        targetQuantity: "uint256",
      },
      tableIdArgument: true,
    },
  },
});
