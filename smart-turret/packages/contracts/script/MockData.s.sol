// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";

import { IBaseWorld } from "@eveworld/world-v2/src/codegen/world/IWorld.sol";
import { smartCharacterSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartCharacterSystemLib.sol";
import { LocationData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Location.sol";
import { DeployableState } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/DeployableState.sol";
import { fuelSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/FuelSystemLib.sol";
import { FuelParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/fuel/types.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { entityRecordSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EntityRecordSystemLib.sol";
import { Tenant, CharactersByAccount } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";
import { smartTurretSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/SmartTurretSystem.sol";

contract MockData is Script {
  IBaseWorld world;
  bytes32 tenantId;

  uint256 SMART_TURRET_ID = 12341;

  uint256 CHARACTER_TYPE_ID = 42000000100;
  uint256 SMART_TURRET_TYPE_ID = 84556;
  uint256 FUEL_TYPE_ID = 84868;

  function safeCreateCharacter(address account, uint256 characterId, uint256 tribeId, string memory name) private {
    uint256 smartObjectId = ObjectIdLib.calculateObjectId(tenantId, characterId);

    if (CharactersByAccount.get(account) != 0) {
      console.log("Character already exists:", name);
      return;
    }
    
    smartCharacterSystem.createCharacter(
      smartObjectId, 
      account, 
      tribeId, 
      EntityRecordParams({ tenantId: tenantId, typeId: CHARACTER_TYPE_ID, itemId: characterId, volume: 100 }), 
      EntityMetadataParams({ name: name, dappURL: "", description: "" })
    );
  }

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);

    world = IBaseWorld(worldAddress);

    tenantId = Tenant.get();
    
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(playerPrivateKey);
    world.registerDelegation(admin, UNLIMITED_DELEGATION, new bytes(0));
    vm.stopBroadcast();

    vm.startBroadcast(deployerPrivateKey);

    uint256 allowedTribeId = vm.envUint("ALLOWED_TRIBE_ID");

    safeCreateCharacter(admin, 1348, allowedTribeId, "adminCharacter");
    safeCreateCharacter(player, 1349, 7777, "playerCharacter");

    uint256 smartTurretId = ObjectIdLib.calculateObjectId(tenantId, SMART_TURRET_ID);

    console.log("Smart Turret ID:", vm.toString(smartTurretId));

    if (DeployableState.getCurrentState(smartTurretId) != State.NULL) {
      console.log("Smart Turret already created");
    } else {
      createAnchorAndOnline(smartTurretId, SMART_TURRET_ID, player);
    }

    vm.stopBroadcast();
  }

  function createAnchorAndOnline(uint256 smartAssemblyId, uint256 itemId, address ownerAddress) private {
    LocationData memory locationParams = LocationData({ solarSystemId: 30000042, x: 1001, y: 1001, z: 1001 });

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

    smartTurretSystem.createAndAnchorTurret(deployableParams, 0);

    console.log("Smart Turret created and anchored");

    entityRecordSystem.createMetadata(smartAssemblyId, EntityMetadataParams({
      name: "Name Here",
      dappURL: "",
      description: "Example Turret for the Smart Turret Example"
    }));

    uint256 fuelSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, FUEL_TYPE_ID);

    fuelSystem.configureFuelParameters(smartAssemblyId, FuelParams({
      fuelMaxCapacity: 100000000,
      fuelBurnRateInSeconds: 100000000
    }));

    fuelSystem.depositFuel(smartAssemblyId, fuelSmartObjectId, 1000);

    deployableSystem.bringOnline(smartAssemblyId);
  }
}
