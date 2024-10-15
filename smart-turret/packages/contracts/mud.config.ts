import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "dapp_dev2",
  tables: {
    TurretWhitelist: {
      schema: {
        smartObjectId: "uint256",
        whitelist: "address[]"
      },
      key: ["smartObjectId"],
    }
  },
});
