pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";

import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { EntityRecordData, WorldPosition, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { SmartObjectData } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { SmartTurretLib } from "@eveworld/world/src/modules/smart-turret/SmartTurretLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { GlobalDeployableState } from "@eveworld/world/src/codegen/tables/GlobalDeployableState.sol";
import { TargetPriority, Turret, SmartTurretTarget } from "@eveworld/world/src/modules/smart-turret/types.sol";

contract ConfigureSmartTurret is Script {
  using SmartTurretLib for SmartTurretLib.World;
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartDeployableUtils for bytes14;
  using WorldResourceIdInstance for ResourceId;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address player = vm.addr(deployerPrivateKey);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    SmartDeployableLib.World memory smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    SmartTurretLib.World memory smartTurret = SmartTurretLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    uint256 smartObjectId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-0001")));

    //Create, anchor the smart turret and bring online
    smartTurret.createAndAnchorSmartTurret(
      smartObjectId,
      EntityRecordData({ typeId: 12345, itemId: 45, volume: 10 }),
      SmartObjectData({ owner:  vm.addr(deployerPrivateKey), tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionIntervalInSeconds,
      1000100 * 1e18 // fuelMaxCapacity,
    );

    // check global state and resume if needed
    if (GlobalDeployableState.getIsPaused() == false) {
      smartDeployable.globalResume();
    }

    smartDeployable.depositFuel(smartObjectId, 200010);
    smartDeployable.bringOnline(smartObjectId);

    //Derploy the Mock contract and configure the smart turret to use it
    IBaseWorld world = IBaseWorld(worldAddress);
    SmartTurretTestSystem smartTurretTestSystem = new SmartTurretTestSystem();
    ResourceId smartTurretTestSystemId = WorldResourceIdLib.encode({
      typeId: RESOURCE_SYSTEM,
      namespace: "testnamespace",
      name: "SmartTurretTestS"
    });

    // register the smart turret system
    world.registerNamespace(smartTurretTestSystemId.getNamespaceId());
    world.registerSystem(smartTurretTestSystemId, smartTurretTestSystem, true);
    //register the function selector
    world.registerFunctionSelector(
      smartTurretTestSystemId,
      "inProximity(uint256,uint256,((uint256,uint256,uint256,uint256,uint256,uint256),uint256)[],(uint256,uint256,uint256),(uint256,uint256,uint256,uint256,uint256,uint256))"
    );
    smartTurret.configureSmartTurret(smartObjectId, smartTurretTestSystemId);

    //Execute inProximity view function and see what is returns
    TargetPriority[] memory priorityQueue = new TargetPriority[](1);
    Turret memory turret = Turret({ weaponTypeId: 1, ammoTypeId: 1, chargesLeft: 100 });
    uint256 characterId = 11111;

    SmartTurretTarget memory turretTarget = SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: characterId,
      hpRatio: 100,
      shieldRatio: 100,
      armorRatio: 100
    });
    priorityQueue[0] = TargetPriority({ target: turretTarget, weight: 100 });

    TargetPriority[] memory returnTargetQueue = smartTurret.inProximity(
      smartObjectId,
      characterId,
      priorityQueue,
      turret,
      turretTarget
    );

    console.log(returnTargetQueue.length);

    vm.stopBroadcast();
  }
}

//Mock Contract for testing
contract SmartTurretTestSystem is System {
  function inProximity(
    uint256 smartTurretId,
    uint256 turretOwnerCharacterId,
    TargetPriority[] memory priorityQueue,
    Turret memory turret,
    SmartTurretTarget memory turretTarget
  ) public returns (TargetPriority[] memory returnTargetQueue) {
    //TODO: Implement the logic for the system
    return priorityQueue;
  }

  function aggression(
    uint256 smartTurretId,
    uint256 turretOwnerCharacterId,
    TargetPriority[] memory priorityQueue,
    Turret memory turret,
    SmartTurretTarget memory aggressor,
    SmartTurretTarget memory victim
  ) public returns (TargetPriority[] memory returnTargetQueue) {
    return returnTargetQueue;
  }
}
