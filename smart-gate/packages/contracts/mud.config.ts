import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "example",
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