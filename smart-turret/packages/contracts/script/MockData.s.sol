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
import { Turret, SmartTurretTarget } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";
import { SmartTurretSystem, smartTurretSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/SmartTurretSystem.sol";

import { InventorySystem, inventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventorySystemLib.sol";
import { EphemeralInventorySystem, ephemeralInventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInventorySystemLib.sol";
import { CreateInventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";

contract MockData is Script {
IBaseWorld world;
  bytes32 tenantId;

  uint256 SMART_TURRET_ID = 12341;

  uint256 CHARACTER_TYPE_ID = 42000000100;
  uint256 SMART_TURRET_TYPE_ID = 84556;
  uint256 FUEL_TYPE_ID = 78437;

  function safeCreateCharacter(address account, uint256 characterId, uint256 tribeId, string memory name) private {
    uint256 smartObjectId = ObjectIdLib.calculateSingletonId(tenantId, characterId);
    
    if (CharactersByAccount.get(account) == 0) {
      smartCharacterSystem.createCharacter(
        smartObjectId, 
        account, 
        tribeId, 
        EntityRecordParams({ tenantId: tenantId, typeId: CHARACTER_TYPE_ID, itemId: characterId, volume: 100 }), 
        EntityMetadataParams({ name: name, dappURL: "", description: "" })
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

    console.log("Tenant ID:");

    uint256 allowedTribeId = vm.envUint("ALLOWED_TRIBE_ID");

    safeCreateCharacter(admin, 1348, allowedTribeId, "adminCharacter");
    safeCreateCharacter(player, 1349, 7777, "playerCharacter");

    vm.stopBroadcast();

    vm.startBroadcast(playerPrivateKey);
    world.registerDelegation(admin, UNLIMITED_DELEGATION, new bytes(0));
    vm.stopBroadcast();

    vm.startBroadcast(deployerPrivateKey);

    uint256 smartTurretId = ObjectIdLib.calculateSingletonId(tenantId, SMART_TURRET_ID);

    if(DeployableState.getCurrentState(smartTurretId) != State.NULL){
      console.log("Smart Turret already created");
    } else{
      console.log("Creating Smart Turret");
      createAnchorAndOnline(smartTurretId, SMART_TURRET_ID, player);
    }

    vm.stopBroadcast();
  }

  function createAnchorAndOnline(uint256 smartAssemblyId, uint256 itemId, address ownerAddress) private {
    LocationData memory locationParams = LocationData({ solarSystemId: 1, x: 1001, y: 1001, z: 1001 });

    EntityRecordParams memory entityRecordParams = EntityRecordParams({
      tenantId: tenantId,
      typeId: SMART_TURRET_TYPE_ID,
      itemId: itemId,
      volume: 1000
    });

    CreateAndAnchorParams memory deployableParams = CreateAndAnchorParams({
      smartObjectId: smartAssemblyId,
      assemblyType: "ST",
      entityRecordParams: entityRecordParams,
      owner: ownerAddress,
      locationData: locationParams
    });

    world.callFrom(
      ownerAddress,
      smartTurretSystem.toResourceId(),
      abi.encodeCall(
        SmartTurretSystem.createAndAnchorTurret,
        (deployableParams, 0)
      )
    );

    entityRecordSystem.createMetadata(smartAssemblyId, EntityMetadataParams({
      name: "Name Here",
      dappURL: "",
      description: "Example SSU for the Smart Assembly Scaffold"
    }));

    console.log("Smart Gate created and anchored successfully");

    uint256 fuelSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, FUEL_TYPE_ID);

    fuelSystem.configureFuelParameters(smartAssemblyId, FuelParams({
      fuelMaxCapacity: 100000000,
      fuelBurnRateInSeconds: 100000000
    }));

    fuelSystem.depositFuel(smartAssemblyId, fuelSmartObjectId, 1000);

    deployableSystem.bringOnline(smartAssemblyId);

    console.log("Smart Gate fueled and online");
  }
}
