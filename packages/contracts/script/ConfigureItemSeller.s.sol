// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { EntityMap } from "@eveworld/smart-object-framework/src/codegen/tables/EntityMap.sol";
import { SMART_OBJECT_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { Utils as CoreUtils } from "@eveworld/smart-object-framework/src/utils.sol";
import { ItemSellerLib } from "../src/item-seller/ItemSellerLib.sol";
import { ITEM_SELLER_DEPLOYMENT_NAMESPACE, ITEM_SELLER_CLASS_ID } from "../src/item-seller/constants.sol";

contract ConfigureItemSeller is Script {
  using CoreUtils for bytes14;
  using ItemSellerLib for ItemSellerLib.World;

  IBaseWorld world;
  ItemSellerLib.World itemSeller;

  function run(address worldAddress) external {

    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);
    world = IBaseWorld(worldAddress);
    itemSeller = ItemSellerLib.World({iface: world, namespace: ITEM_SELLER_DEPLOYMENT_NAMESPACE});

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Read from .env
    uint256 ssuId = vm.envUint("SSU_ID");
    bool isPurchaseAllowed = vm.envBool("IS_PURCHASE_ALLOWED");
    bool isBuybackAllowed = vm.envBool("IS_BUYBACK_ALLOWED");
    uint256 acceptedItemTypeId = vm.envUint("TYPE_ID");
    uint256 erc20PurchasePriceWei = vm.envUint("PURCHASE_PRICE");
    uint256 erc20BuybackPriceWei = vm.envUint("BUYBACK_PRICE");
    address erc20Address = vm.envAddress("ERC20_PAYMENT_ADDRESS");

    vm.startBroadcast(playerPrivateKey);

    // if the SSU is not already, tag it as an Item Seller
    uint256[] memory classArray = EntityMap.getTaggedEntityIds(SMART_OBJECT_DEPLOYMENT_NAMESPACE.entityMapTableId(), ssuId);
    bool found = false;
    for(uint i=0; i < classArray.length; i++){
      if(classArray[i] == ITEM_SELLER_CLASS_ID) {
        found = true;
        break;
      }
    }
    if(!found) itemSeller.associateSSUToItemSeller(ssuId);

    // set up SSU
    itemSeller.setAllowPurchase(ssuId, isPurchaseAllowed);
    itemSeller.setAllowBuyback(ssuId, isBuybackAllowed);
    itemSeller.setItemSellerAcceptedItemTypeId(ssuId, acceptedItemTypeId);
    itemSeller.setERC20Currency(ssuId, erc20Address);
    itemSeller.setERC20PurchasePrice(ssuId, erc20PurchasePriceWei);
    itemSeller.setERC20BuybackPrice(ssuId, erc20BuybackPriceWei);

    vm.stopBroadcast();
  }
}
