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
import { ItemSellerModule } from "src/item-seller/ItemSellerModule.sol";

import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";

// only needs to be run once
contract InitModules is Script {
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

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);
    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    world.initSOF();
    smartObject = SmartObjectLib.World(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE);
    world.initStaticData();
    world.initEntityRecord();
    world.initLocation();
    world.initSmartCharacter();
    world.initSmartDeployable();
    world.initInventory();
    world.initSSU();

    vm.stopBroadcast();
  }
}
