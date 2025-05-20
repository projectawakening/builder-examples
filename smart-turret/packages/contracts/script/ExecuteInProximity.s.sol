// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { TargetPriority, Turret, SmartTurretTarget } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";
import { DeployableState, DeployableStateData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/DeployableState.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { AccessSystem, accessSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/AccessSystemLib.sol";
import { Turret, SmartTurretTarget } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";
import { TargetPriority } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";

import { SmartTurretSystem } from "../src/systems/SmartTurretSystem.sol";
import { TurretAllowlist } from "../src/codegen/tables/TurretAllowlist.sol";

contract ExecuteInProximity is Script {

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(adminPrivateKey);
    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(adminPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    uint256 smartTurretId = vm.envUint("SMART_TURRET_ID");
    uint256 allowedTribeId = vm.envUint("ALLOWED_TRIBE_ID");

    uint256 adminCharacterId = CharactersByAccount.getSmartObjectId(admin);
    uint256 playerCharacterId = CharactersByAccount.getSmartObjectId(player);

    uint256 allowedTribe = TurretAllowlist.get();

    console.log("-------------------\nTEST SETUP");
    console.log("ALLOWED TRIBE FROM MUD: ", vm.toString(allowedTribe));

    console.log("-------------------\nTESTING CORRECT TRIBE");
    console.log("Tribe ID of character 123:", vm.toString(Characters.getTribeId(adminCharacterId)));
    console.log("Tribe ID of character 77777:", vm.toString(Characters.getTribeId(playerCharacterId)));

    ResourceId systemId = Utils.smartTurretSystemId();

    TargetPriority[] memory inputQueue = new TargetPriority[](1);
    Turret memory turret = Turret({ weaponTypeId: 1, ammoTypeId: 1, chargesLeft: 100 });

    SmartTurretTarget memory turretTarget = SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: adminCharacterId,
      hpRatio: 100,
      shieldRatio: 100,
      armorRatio: 100
    });

    inputQueue[0] = TargetPriority({ target: turretTarget, weight: 100 });
    
    TargetPriority[] memory outputTargetQueue = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          SmartTurretSystem.inProximity,
          (smartTurretId, adminCharacterId, inputQueue, turret, turretTarget)
        )
      ),
      (TargetPriority[])
    );

    console.log("Input Target Queue Length: ", vm.toString(inputQueue.length)); //1
    console.log("Output Target Queue Length: ", vm.toString(outputTargetQueue.length)); //0


    console.log("-------------------\nTESTING INCORRECT TRIBE");
    console.log("Tribe ID of character 123:", vm.toString(Characters.getTribeId(adminCharacterId)));
    console.log("Tribe ID of character 77777:", vm.toString(Characters.getTribeId(playerCharacterId)));

    turretTarget = SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: playerCharacterId,
      hpRatio: 100,
      shieldRatio: 100,
      armorRatio: 100
    });

    inputQueue[0] = TargetPriority({ target: turretTarget, weight: 100 });
    
    outputTargetQueue = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          SmartTurretSystem.inProximity,
          (smartTurretId, playerCharacterId, inputQueue, turret, turretTarget)
        )
      ),
      (TargetPriority[])
    );

    console.log("Input Target Queue Length: ", vm.toString(inputQueue.length)); //1
    console.log("Output Target Queue Length: ", vm.toString(outputTargetQueue.length)); //1

    vm.stopBroadcast();
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return FRONTIER_WORLD_DEPLOYMENT_NAMESPACE;
  }
}
