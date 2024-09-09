import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "test2",
  systems: {
    GateKeeper: {
      name: "GateKeeper",
      openAccess: true,
    }
  },
  tables: {
    GateKeeperConfig: {
      keySchema: {
        smartObjectId: "uint256",
      },
      valueSchema: {
        itemIn: "uint256",
        targetItemQuantity: "uint256",
        isGoalReached: "bool",
      }
    }
  },
});
