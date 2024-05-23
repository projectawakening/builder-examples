import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "test2",
  systems: {
    VendingMachine: {
      name: "VendingMachine",
      openAccess: true,
    },
    ItemSeller: {
      name: "ItemSeller",
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
      },
    },
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
    },
    GateKeeperConfig: {
      keySchema: {
        smartObjectId: "uint256",
      },
      valueSchema: {
        itemIn: "uint256",
        targetItemQuantity: "uint256",
        isGoalReached: "bool",
      }
    }
  },
});
