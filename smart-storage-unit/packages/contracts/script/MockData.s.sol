// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";

import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";

import { SmartAssemblySystem, smartAssemblySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartAssemblySystemLib.sol";
import { EntityRecordSystem, entityRecordSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EntityRecordSystemLib.sol";
import { SmartCharacterSystem, smartCharacterSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartCharacterSystemLib.sol";
import { DeployableSystem, deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { InventorySystem, inventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventorySystemLib.sol";
import { EphemeralInventorySystem, ephemeralInventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInventorySystemLib.sol";
import { SmartStorageUnitSystem, smartStorageUnitSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartStorageUnitSystemLib.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord, Location, LocationData, DeployableState } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { CreateInventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { InventoryItem, InventoryItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/InventoryItem.sol";
import { EphemeralInvItem, EphemeralInvItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/EphemeralInvItem.sol";

/**
 * @title MockData
 * @dev This script creates smart characters, a Smart Storage Unit and deposits items into the SSU. 
 * @notice This can only be run on your local world.
 */
contract MockData is Script {
  IWorldWithContext world;

  address admin;

  uint256 CHARACTER_TYPE_ID = 42000000100;
  uint256 SSU_TYPE_ID = 77917;
  uint256 FUEL_TYPE_ID = 78437;

  uint256 aliceCharacterItemId = 1348;
  uint256 bobCharacterItemId = 1349;

  uint256 tribeId = 100;

  uint256 ssuItemId = 565656565;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    world = IWorldWithContext(worldAddress);

    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(adminPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    bytes32 tenantId = Tenant.getTenantId();

    // Create characters
    vm.startBroadcast(adminPrivateKey);
    _safeCreateCharacter(tenantId, admin, aliceCharacterItemId, "adminCharacter");
    _safeCreateCharacter(tenantId, player, bobCharacterItemId, "playerCharacter");
    vm.stopBroadcast();

    // Register delegation
    vm.startBroadcast(playerPrivateKey);
    world.registerDelegation(admin, UNLIMITED_DELEGATION, new bytes(0));
    vm.stopBroadcast();

    // Create SSU
    uint256 smartStorageUnitId = ObjectIdLib.calculateSingletonId(tenantId, ssuItemId);

    vm.startBroadcast(adminPrivateKey);
    if (DeployableState.getCurrentState(smartStorageUnitId) != State.NULL) {
      console.log("SSU already created ID:", vm.toString(smartStorageUnitId));
    } else {
      console.log("Creating SSU");
      _createAnchorAndOnline(smartStorageUnitId, tenantId, admin);
    }

    // Create and deposit inventory items
    _depositToInventory(smartStorageUnitId, tenantId, admin);
    _depositToEphemeralInventory(smartStorageUnitId, tenantId, player);
    console.log("Depositing to inventory and ephemeral inventory complete");

    vm.stopBroadcast();
  }

  function _safeCreateCharacter(bytes32 tenantId, address account, uint256 characterId, string memory name) private {
    uint256 smartObjectId = ObjectIdLib.calculateSingletonId(tenantId, characterId);

    if (CharactersByAccount.get(account) == 0) {
      smartCharacterSystem.createCharacter(
        smartObjectId,
        account,
        tribeId,
        EntityRecordParams({ tenantId: tenantId, typeId: CHARACTER_TYPE_ID, itemId: characterId, volume: 100 }),
        EntityMetadataParams({ name: name, dappURL: "noURL", description: "." })
      );

      console.log("Character created successfully:", name);
    } else {
      console.log("Character already exists:", name);
    }
  }

  function _createAnchorAndOnline(uint256 smartStorageUnitId, bytes32 tenantId, address ownerAddress) private {
    LocationData memory locationParams = LocationData({ solarSystemId: 30000042, x: 1001, y: 1001, z: 1001 });

    EntityRecordParams memory entityRecordParams = EntityRecordParams({
      tenantId: tenantId,
      typeId: SSU_TYPE_ID,
      itemId: ssuItemId,
      volume: 1000
    });

    CreateAndAnchorParams memory deployableParams = CreateAndAnchorParams({
      smartObjectId: smartStorageUnitId,
      assemblyType: "SSU",
      entityRecordParams: entityRecordParams,
      owner: ownerAddress,
      locationData: locationParams
    });

    bytes memory result = world.callFrom(
      ownerAddress,
      smartStorageUnitSystem.toResourceId(),
      abi.encodeCall(SmartStorageUnitSystem.createAndAnchorStorageUnit, (deployableParams, 100000000, 100000000, 0))
    );
    
    deployableSystem.bringOnline(smartStorageUnitId);
    console.log("SSU created anchored and brought online");
  }

  function _depositToInventory(uint256 smartStorageUnitId, bytes32 tenantId, address player) private {
    uint256 itemOutTypeID = vm.envUint("ITEM_OUT_TYPE_ID");

    uint256 itemOutSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, itemOutTypeID);

    CreateInventoryItemParams[] memory items = new CreateInventoryItemParams[](1);

    items[0] = CreateInventoryItemParams({
      smartObjectId: itemOutSmartObjectId,
      tenantId: tenantId,
      typeId: itemOutTypeID,
      itemId: 0, // For non-singleton items, itemId is zero
      quantity: 10, // Non-singleton can have any quantity
      volume: 1
    });

    world.callFrom(
      player,
      inventorySystem.toResourceId(),
      abi.encodeCall(InventorySystem.createAndDepositInventory, (smartStorageUnitId, items))
    );
  }

  function _depositToEphemeralInventory(uint256 smartStorageUnitId, bytes32 tenantId, address player) private {
    uint256 itemInTypeID = vm.envUint("ITEM_IN_TYPE_ID");
    uint256 itemInSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, itemInTypeID);
    CreateInventoryItemParams[] memory ephemeralItems = new CreateInventoryItemParams[](1);

    ephemeralItems[0] = CreateInventoryItemParams({
      smartObjectId: itemInSmartObjectId,
      tenantId: tenantId,
      typeId: itemInTypeID,
      itemId: 0, // For non-singleton items, itemId is zero
      quantity: 15, // Non-singleton can have any quantity
      volume: 10
    });

    world.callFrom(
      player,
      ephemeralInventorySystem.toResourceId(),
      abi.encodeCall(EphemeralInventorySystem.createAndDepositEphemeral, (smartStorageUnitId, player, ephemeralItems))
    );
  }
}
