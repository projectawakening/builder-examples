import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  tables: {
    RatioConfig: {
      schema: {
        smartObjectId: "uint256",
        itemIn: "uint256",
        itemOut: "uint256",
        ratioIn: "uint256",
        ratioOut: "uint256",
      },
      key: ["smartObjectId", "itemIn"],
    }
  },
});
