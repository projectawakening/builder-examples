import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "dapp_dev2",
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
