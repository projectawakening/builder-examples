import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "murderous",
  tables: {
    TurretBlacklist: {
      schema: {
        smartObjectId: "uint256",
        isSet: "bool",
        blacklistKeyword: "string",
      },
      key: ["smartObjectId"],
    },
  },
});
