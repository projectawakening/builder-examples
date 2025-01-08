import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "example",
  tables: {
    RatioConfig: {
      schema: {
        smartObjectId: "uint256",
        itemIn: "uint256",
        itemOut: "uint256",
        ratioIn: "uint64",
        ratioOut: "uint64",
      },
      key: ["smartObjectId", "itemIn"],
    },
    DAppConfig: {
      schema: {
        smartObjectId: "uint256",
        promotedItem: "uint256"
      },
      key: ["smartObjectId"]
    }
  },
});
