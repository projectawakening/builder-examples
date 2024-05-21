import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "test",
  systems: {
    ItemSeller: {
      name: "ItemSeller",
      openAccess: true,
    },
  },
  tables: {
    /**********************
     * ITEM SELLER MODULE *
     **********************/
    /**
     * Used to store the transfer details when a item is sold/bought back
     */
    ItemSellerTable: {
      keySchema: {
        smartObjectId: "uint256",
      },
      valueSchema: {
        acceptedItemTypeId: "uint256",
        erc20PurchasePriceWei: "uint256",
        erc20BuybackPriceWei: "uint256",
        erc20Address: "address",
        isPurchaseAllowed: "bool",
        isBuybackAllowed: "bool",
      },
      tableIdArgument: true,
    },
  },
});
