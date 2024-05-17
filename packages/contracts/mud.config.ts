import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "playtest",
  systems: {
    VendingMachine: {
      name: "VendingMachine",
      openAccess: true,
    },
  },
  tables: {
    RatioConfig: {
      keySchema: { smartObjectId: "uint256", itemIn: "uint256" },
      valueSchema: {
        itemOut: "uint256",
        ratioIn: "uint256",
        ratioOut: "uint256",
      }
    }
  },
});
