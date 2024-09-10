import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "test2",
  systems: {
    ItemSeller: {
      name: "ItemSeller",
      openAccess: true,
    },
  },
  tables: {
    ItemSellerERC20: {
      keySchema: {
        smartObjectId: "uint256", // SSU ID
      },
      valueSchema: {
        tokenAddress: "address",
        tokenDecimals: "uint256",
        receiver: "address",
      },
    },
    ItemPrice: {
      keySchema: {
        smartObjectId: "uint256", // SSU ID
        itemId: "uint256",
      },
      valueSchema: {
        isSet: "bool",
        price: "uint256",
      },
    }
  },
});
