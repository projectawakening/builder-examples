pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";

import { IBaseWorld } from "@eveworld/world-v2/src/codegen/world/IWorld.sol";
import { SmartCharacterSystem, smartCharacterSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartCharacterSystemLib.sol";
import { Location, LocationData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Location.sol";
import { DeployableState } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/DeployableState.sol";
import { FuelSystem, fuelSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/FuelSystemLib.sol";
import { FuelParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/fuel/types.sol";
import { SmartAssemblySystem, smartAssemblySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartAssemblySystemLib.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { EntityRecordSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/EntityRecordSystem.sol";
import { entityRecordSystem} from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EntityRecordSystemLib.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { SmartStorageUnitSystem, smartStorageUnitSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartStorageUnitSystemLib.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { DeployableSystem, deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";

import { InventorySystem, inventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventorySystemLib.sol";
import { EphemeralInventorySystem, ephemeralInventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInventorySystemLib.sol";
import { CreateInventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";

contract MockData is Script {
  IBaseWorld world;

  bytes32 tenantId;

  uint256 CHARACTER_TYPE_ID = 42000000100;
  uint256 SSU_TYPE_ID = 77917;
  uint256 FUEL_TYPE_ID = 78437;

  function safeCreateCharacter(address account, uint256 characterId, uint256 tribeId, string memory name) private {
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
    } else{
      console.log("Character already exists:", name);
    }
  }

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(deployerPrivateKey);

    world = IBaseWorld(worldAddress);

    tenantId = Tenant.getTenantId();

    safeCreateCharacter(admin, 1348, 7777, "adminCharacter");
    safeCreateCharacter(player, 1349, 7777, "playerCharacter");

    vm.stopBroadcast();

    vm.startBroadcast(playerPrivateKey);
    world.registerDelegation(admin, UNLIMITED_DELEGATION, new bytes(0));
    vm.stopBroadcast();

    vm.startBroadcast(deployerPrivateKey);

    uint256 smartStorageUnitId = ObjectIdLib.calculateSingletonId(tenantId, 1245);

    if(DeployableState.getCurrentState(smartStorageUnitId) != State.NULL){
      console.log("SSU already created");
    } else{
      console.log("Creating SSU");
      createAnchorAndOnline(smartStorageUnitId, admin);
    }

    //Create and deposit inventory items
    uint256 itemOutTypeID = vm.envUint("ITEM_OUT_TYPE_ID");

    uint256 itemOutSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, itemOutTypeID);

    CreateInventoryItemParams[] memory items = new CreateInventoryItemParams[](1);
    
    items[0] = CreateInventoryItemParams({
      smartObjectId: itemOutSmartObjectId,
      tenantId: tenantId,
      typeId: itemOutTypeID,
      itemId: 0, // For non-singleton items, itemId is zero
      quantity: 20, // Non-singleton can have any quantity
      volume: 10
    });

    inventorySystem.createAndDepositInventory(smartStorageUnitId, items);

    uint256 itemInTypeID = vm.envUint("ITEM_IN_TYPE_ID");

    uint256 itemInSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, itemInTypeID);

    CreateInventoryItemParams[] memory ephemeralItems = new CreateInventoryItemParams[](1);

    ephemeralItems[0] = CreateInventoryItemParams({
      smartObjectId: itemInSmartObjectId,
      tenantId: tenantId,
      typeId: itemInTypeID,
      itemId: 0, // For non-singleton items, itemId is zero
      quantity: 10, // Non-singleton can have any quantity
      volume: 10
    });

    vm.stopBroadcast();

    vm.startBroadcast(playerPrivateKey);
    ephemeralInventorySystem.createAndDepositEphemeral(smartStorageUnitId, player, ephemeralItems);

    vm.stopBroadcast();
  }

  function createAnchorAndOnline(uint256 smartStorageUnitId, address ownerAddress) private {
    LocationData memory locationParams = LocationData({ solarSystemId: 1, x: 1001, y: 1001, z: 1001 });

    EntityRecordParams memory entityRecordParams = EntityRecordParams({
      tenantId: tenantId,
      typeId: SSU_TYPE_ID,
      itemId: 1245,
      volume: 1000
    });

    CreateAndAnchorParams memory deployableParams = CreateAndAnchorParams({
      smartObjectId: smartStorageUnitId,
      assemblyType: "SSU",
      entityRecordParams: entityRecordParams,
      owner: ownerAddress,
      locationData: locationParams
    });

    world.callFrom(
      ownerAddress,
      smartStorageUnitSystem.toResourceId(),
      abi.encodeCall(
        SmartStorageUnitSystem.createAndAnchorStorageUnit,
        (deployableParams, 100000000, 100000000, 100000000)
      )
    );

    entityRecordSystem.createMetadata(smartStorageUnitId, EntityMetadataParams({
      name: "Name Here",
      dappURL: "",
      description: "Example SSU for the Smart Assembly Scaffold"
    }));

    console.log("SSU created and anchored successfully");

    uint256 fuelSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, FUEL_TYPE_ID);

    fuelSystem.configureFuelParameters(smartStorageUnitId, FuelParams({
      fuelMaxCapacity: 100000000,
      fuelBurnRateInSeconds: 100000000
    }));

    fuelSystem.depositFuel(smartStorageUnitId, fuelSmartObjectId, 1000);

    deployableSystem.bringOnline(smartStorageUnitId);

    console.log("SSU fueled and online");
  }
}
