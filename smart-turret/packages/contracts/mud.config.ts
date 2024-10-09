import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "dapp_dev",
  tables: {
    TurretWhitelist: {
      schema: {
        smartObjectId: "uint256",
        whitelist: "uint256[]"
      },
      key: ["smartObjectId"],
    },
    TestList: {      
      schema: {
        smartObjectId: "uint256",
        whitelist: "uint256"
      },
      key: ["smartObjectId"],
    }
  },
});
