import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
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
    }
  },
});
