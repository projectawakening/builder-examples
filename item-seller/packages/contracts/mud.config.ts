import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  systems: {
    ItemSellerSystem: {
      name: "ItemSellerSystem",
      openAccess: true,
    },
  },
  tables: {
    ItemSellerERC20: {
      schema: {
        smartObjectId: "uint256", // SSU ID
        tokenAddress: "address",
        tokenDecimals: "uint256",
        receiver: "address",
      },
      key: ["smartObjectId"],
    },
    ItemPrice: {
      schema: {
        smartObjectId: "uint256", // SSU ID
        itemId: "uint256",
        isSet: "bool",
        price: "uint256",
      },
      key: ["smartObjectId", "itemId"],
    }
  },
});
