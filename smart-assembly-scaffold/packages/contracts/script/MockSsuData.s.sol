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
import { SmartAssemblySystem, smartAssemblySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartAssemblySystemLib.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { SmartStorageUnitSystem, smartStorageUnitSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartStorageUnitSystemLib.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { DeployableSystem, deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";

contract MockSsuData is Script {
  IBaseWorld world;

  bytes32 tenantId;

  uint256 CHARACTER_TYPE_ID = 42000000100;
  uint256 SSU_TYPE_ID = 77917;

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
    address owner = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(deployerPrivateKey);

    world = IBaseWorld(worldAddress);

    tenantId = Tenant.getTenantId();

    safeCreateCharacter(owner, 1348, 7777, "adminCharacter");
    safeCreateCharacter(player, 1349, 7777, "playerCharacter");

    vm.stopBroadcast();

    vm.startBroadcast(playerPrivateKey);
    world.registerDelegation(owner, UNLIMITED_DELEGATION, new bytes(0));
    vm.stopBroadcast();

    vm.startBroadcast(deployerPrivateKey);

    uint256 smartStorageUnitId = ObjectIdLib.calculateSingletonId(tenantId, 1245);

    if(DeployableState.getCurrentState(smartStorageUnitId) != State.NULL){
      console.log("SSU already created");
    } else{
      console.log("Creating SSU");
      createAnchorAndOnline(smartStorageUnitId, player);
    }

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
        (deployableParams, 100000000, 100000000, 0)
      )
    );

    console.log("SSU created and anchored successfully");
  }
}