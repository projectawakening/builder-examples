// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

// World imports
import { World } from "@latticexyz/world/src/World.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IModule } from "@latticexyz/world/src/IModule.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";

import "@eveworld/common-constants/src/constants.sol";
import { CLASS, ITEM_SELLER_CLASS_ID, ITEM_SELLER_DEPLOYMENT_NAMESPACE } from "../src/item-seller/constants.sol";
import { SmartObjectFrameworkModule } from "@eveworld/smart-object-framework/src/SmartObjectFrameworkModule.sol";
import { HookType } from "@eveworld/smart-object-framework/src/types.sol";

import { ModulesInitializationLibrary } from "../src/utils/ModulesInitializationLibrary.sol";
import { SOFInitializationLibrary } from "../src/utils/SOFInitializationLibrary.sol";
import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";
import { IInventory } from "@eveworld/world/src/modules/inventory/interfaces/IInventory.sol";
import { IInventoryInteract } from "@eveworld/world/src/modules/inventory/interfaces/IInventoryInteract.sol";

import { Utils as ItemSellerUtils } from "../src/item-seller/Utils.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";

import { IItemSeller } from "../src/item-seller/interfaces/IItemSeller.sol";
import { ItemSellerModule } from "../src/item-seller/ItemSellerModule.sol";
import { ItemSeller } from "../src/item-seller/systems/ItemSeller.sol";

import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";

// this is more robust to install just a module once there's already a healthy world out there
contract InitItemSeller is Script {
  using ModulesInitializationLibrary for IBaseWorld;
  using SOFInitializationLibrary for IBaseWorld;
  using SmartObjectLib for SmartObjectLib.World;

  using ItemSellerUtils for bytes14;
  using InventoryUtils for bytes14;

  IBaseWorld world;
  SmartObjectLib.World smartObject;
  function run(address worldAddress) external {
    
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);
    world = IBaseWorld(worldAddress);
    smartObject = SmartObjectLib.World(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);
    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    address itemSellerAddress = address(new ItemSeller());
    _installModule(deployer, new ItemSellerModule(), ITEM_SELLER_DEPLOYMENT_NAMESPACE, itemSellerAddress);
    world.initItemSeller();

    smartObject.registerEntity(ITEM_SELLER_CLASS_ID, CLASS);
    world.associateClassIdToItemSeller(ITEM_SELLER_CLASS_ID);

    // will add the direct deposit/withdraw functions by default, but registers the InventoryInteract hooks just in case also
    _registerClassLevelHookItemSeller();

    vm.stopBroadcast();
  }

  function _installModule(
    address deployer,
    IModule module,
    bytes14 namespace,
    address system
  ) internal {
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(namespace)) == deployer)
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(namespace), address(module));
    world.installModule(module, abi.encode(namespace, system));
  }

  function _registerClassLevelHookItemSeller() internal {
    ResourceId itemSellerSystemId = ITEM_SELLER_DEPLOYMENT_NAMESPACE.itemSellerSystemId();
    ResourceId inventoryInteractSystemId = INVENTORY_DEPLOYMENT_NAMESPACE.inventoryInteractSystemId();
    ResourceId inventorySystemId = INVENTORY_DEPLOYMENT_NAMESPACE.inventorySystemId();

    uint256 depositHookId = _registerHook(itemSellerSystemId, IItemSeller.itemSellerDepositToInventoryHook.selector);
    uint256 withdrawHookId = _registerHook(
      itemSellerSystemId,
      IItemSeller.itemSellerWithdrawFromInventoryHook.selector
    );
    uint256 transferToInvHookId = _registerHook(
      itemSellerSystemId,
      IItemSeller.itemSellerEphemeralToInventoryTransferHook.selector
    );
    uint256 transferToEphHookId = _registerHook(
      itemSellerSystemId,
      IItemSeller.itemSellerInventoryToEphemeralTransferHook.selector
    );

    smartObject.associateHook(ITEM_SELLER_CLASS_ID, depositHookId);
    smartObject.associateHook(ITEM_SELLER_CLASS_ID, withdrawHookId);
    smartObject.associateHook(ITEM_SELLER_CLASS_ID, transferToInvHookId);
    smartObject.associateHook(ITEM_SELLER_CLASS_ID, transferToEphHookId);

    smartObject.addHook(depositHookId, HookType.AFTER, inventorySystemId, IInventory.depositToInventory.selector);

    smartObject.addHook(withdrawHookId, HookType.AFTER, inventorySystemId, IInventory.withdrawFromInventory.selector);
  }

  function _registerHook(ResourceId systemId, bytes4 functionSelector) internal returns (uint256 hookId) {
    smartObject.registerHook(systemId, functionSelector);
    hookId = uint256(keccak256(abi.encodePacked(systemId, functionSelector)));
  }
}
