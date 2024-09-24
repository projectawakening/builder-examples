import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  systems: {
    GateKeeperSystem: {
      name: "GateKeeperSystem",
      openAccess: true,
    }
  },
  tables: {
    GateKeeperConfig: {
      schema: {
        smartObjectId: "uint256",
        itemIn: "uint256",
        targetItemQuantity: "uint256",
        isGoalReached: "bool",
      },
      key: ["smartObjectId"],
    }
  },
});
