import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "itemtrade",
  tables: {
    ItemTradeERC20: {
      schema: {
        smartObjectId: "uint256", // SSU ID
        tokenAddress: "address",
        tokenDecimals: "uint256",
        receiver: "address",
      },
      key: ["smartObjectId"],
    },
    ItemTradeTokenSum: {
      schema: {
        smartObjectId: "uint256", // SSU ID
        aggregateTokenAmount: "address"
      },
      key: ["smartObjectId"],
    },
    ItemPriceInToken: { // Looking for better naming 
      schema: {
        smartObjectId: "uint256", // SSU ID
        itemOutId: "uint256",
        isSet: "bool",
        price: "uint256",
      },
      key: ["smartObjectId", "itemOutId"],
    },
    ItemQuantityMultipleForToken: { // Looking for better naming
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
