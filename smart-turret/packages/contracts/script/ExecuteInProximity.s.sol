// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";
import { Utils as SmartTurretUtils } from "@eveworld/world/src/modules/smart-turret/Utils.sol";
import { SmartTurretLib } from "@eveworld/world/src/modules/smart-turret/SmartTurretLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { TargetPriority, Turret, SmartTurretTarget } from "@eveworld/world/src/modules/smart-turret/types.sol";
import { DeployableState, DeployableStateData } from "@eveworld/world/src/codegen/tables/DeployableState.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { Utils as SmartCharacterUtils } from "@eveworld/world/src/modules/smart-character/Utils.sol";
import { SmartTurretConfigTable } from "@eveworld/world/src/codegen/tables/SmartTurretConfigTable.sol";
import { CharactersTableData, CharactersTable } from "@eveworld/world/src/codegen/tables/CharactersTable.sol";

/*
  This script will test the whitelisting functionality of the Smart Turret example.
  The first test tests the functionality of a character that is not whitelisted:
    Queue:
      1. Not whitelisted - 33333
      2. Not whitelisted - 11112
    Target:
       Not whitelisted - 11112

  The second test tests the functionality of a character that is whitelisted:
    Queue:
      1. Not whitelisted - 33333
      2. Whitelisted - 200
    Target:
       Whitelisted - 200
*/

contract ExecuteInProximity is Script {
  using SmartTurretUtils for bytes14;
  using SmartTurretLib for SmartTurretLib.World;
  using SmartDeployableUtils for bytes14;
  using SmartCharacterUtils for bytes14;

  SmartTurretLib.World smartTurret;

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    uint256 smartTurretId = vm.envUint("SMART_TURRET_ID");

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    smartTurret = SmartTurretLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    console.log("-------------------");
    console.log("Deployable State:", uint8(DeployableState.getCurrentState(smartTurretId)));
    console.log("-------------------");
    console.log("TESTING NOT WHITELISTED");

    ResourceId systemId = Utils.smartTurretSystemId();

    TargetPriority[] memory priorityQueue = new TargetPriority[](2);

    Turret memory turret = Turret({ weaponTypeId: 1, ammoTypeId: 1, chargesLeft: 100 });

    SmartTurretTarget memory spareTarget = SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: 33333,
      hpRatio: 100,
      shieldRatio: 100,
      armorRatio: 100
    });

    priorityQueue[0] = TargetPriority({ target: spareTarget, weight: 100 });

    SmartTurretTarget memory turretTarget = SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: 11112,
      hpRatio: 100,
      shieldRatio: 100,
      armorRatio: 100
    });
    priorityQueue[1] = TargetPriority({ target: turretTarget, weight: 100 });

    TargetPriority[] memory returnTargetQueue = smartTurret.inProximity(
      smartTurretId, //Smart Turret ID
      11111, //Owner Character ID
      priorityQueue, //Current target queue
      turret, //Turret Data
      turretTarget //Target Data
    );

    console.log("Queue Length:", returnTargetQueue.length); //2
    
    console.log("-------------------");
    console.log("TESTING WHITELISTED");

    SmartTurretTarget memory turretTargetWhitelisted = SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: 200,
      hpRatio: 100,
      shieldRatio: 100,
      armorRatio: 100
    });
    
    priorityQueue[1] = TargetPriority({ target: turretTargetWhitelisted, weight: 100 });

    TargetPriority[] memory returnTargetQueueWhitelisted = smartTurret.inProximity(
      smartTurretId, //Smart Turret ID
      11111, //Owner Character ID
      priorityQueue, //Current target queue
      turret, //Turret Data
      turretTargetWhitelisted //Target Data
    );
    
    console.log("Queue Length:", returnTargetQueueWhitelisted.length); //2

    vm.stopBroadcast();
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return FRONTIER_WORLD_DEPLOYMENT_NAMESPACE;
  }
}
