import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  tables: {
    TurretWhitelist: {
      schema: {
        smartObjectId: "uint256",
        whitelist: "uint256[]"
      },
      key: ["smartObjectId"],
    },
  },
});
