import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  tables: {
    GateAccess: {
      schema: {
        smartObjectId: "uint256",
        tribeId: "uint256"
      },
      key: ["smartObjectId"],
    }
  },
});