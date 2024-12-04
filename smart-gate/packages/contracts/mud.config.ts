import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  tables: {
    GateAccess: {
      schema: {
        smartObjectId: "uint256",
        corp: "uint256"
      },
      key: ["smartObjectId"],
    }
  },
});