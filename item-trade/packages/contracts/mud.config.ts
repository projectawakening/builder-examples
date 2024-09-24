import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test1",
  tables: {
    ItemTradeERC20: {
      schema: {
        smartObjectId: "uint256", // SSU ID
        tokenAddress: "address",
        tokenDecimals: "uint256",
        receiver: "address",
        totalTokensCollected: "uint256",
      },
      key: ["smartObjectId"],
    },
    ItemPriceInToken: {
      schema: {
        smartObjectId: "uint256", // SSU ID
        itemOutId: "uint256",
        isSet: "bool",
        price: "uint256",
      },
      key: ["smartObjectId", "itemOutId"],
    },
    ItemQuantityMultipleForToken: {
      schema: {
        smartObjectId: "uint256", // SSU ID
        itemInId: "uint256",
        isSet: "bool",
        enforcedItemMultiple: "uint256",
        tokenAmount: "uint256",
      },
      key: ["smartObjectId", "itemInId"],
    }
  }
});
