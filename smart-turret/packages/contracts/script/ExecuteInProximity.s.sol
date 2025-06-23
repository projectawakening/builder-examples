// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { TargetPriority, Turret, SmartTurretTarget } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";
import { Tenant, Characters, CharactersByAccount } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";

import { Utils } from "../src/systems/Utils.sol";
import { SmartTurretSystem } from "../src/systems/SmartTurretSystem.sol";
import { TurretAllowlist } from "../src/codegen/tables/TurretAllowlist.sol";

contract ExecuteInProximity is Script {
  IBaseWorld world;
  uint256 smartTurretId;

  function testWithCharacter(uint256 characterId, uint256[] memory health) internal {
    console.log(
      "Tribe ID of character", 
      vm.toString(characterId), 
      ":", 
      vm.toString(Characters.getTribeId(characterId))
    );

    ResourceId systemId = Utils.smartTurretSystemId();

    TargetPriority[] memory inputQueue = new TargetPriority[](1);
    Turret memory turret = Turret({ weaponTypeId: 1, ammoTypeId: 1, chargesLeft: 100 });

    SmartTurretTarget memory turretTarget = SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: characterId,
      hpRatio: health[0],
      armorRatio: health[1],
      shieldRatio: health[2]
    });

    inputQueue[0] = TargetPriority({ target: turretTarget, weight: 100 });
    
    TargetPriority[] memory outputTargetQueue = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          SmartTurretSystem.inProximity,
          (smartTurretId, characterId, inputQueue, turret, turretTarget)
        )
      ),
      (TargetPriority[])
    );

    console.log("Input Target Queue Length: ", vm.toString(inputQueue.length));
    console.log("Output Target Queue Length: ", vm.toString(outputTargetQueue.length));
  }

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(adminPrivateKey);
    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(adminPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    world = IBaseWorld(worldAddress);

    smartTurretId = vm.envUint("SMART_TURRET_ID");

    uint256 adminCharacterId = CharactersByAccount.getSmartObjectId(admin);
    uint256 playerCharacterId = CharactersByAccount.getSmartObjectId(player);

    require(
      adminCharacterId != 0 && playerCharacterId != 0, 
      "Characters do not exist. Run 'pnpm mock-data' to generate them."
    );

    uint256 allowedTribe = TurretAllowlist.get();
    require(allowedTribe != 0, "MUD Data not configured. Run 'pnpm configure' to configure it.");

    console.log("-------------------\nTEST SETUP");
    console.log("ALLOWED TRIBE FROM MUD: ", vm.toString(allowedTribe));

    uint256[] memory health = new uint256[](3);
    (health[0], health[1], health[2]) = (100, 100, 100);

    console.log("-------------------\nTESTING CORRECT TRIBE");
    testWithCharacter(adminCharacterId, health);

    console.log("-------------------\nTESTING INCORRECT TRIBE");
    testWithCharacter(playerCharacterId, health);

    vm.stopBroadcast();
  }
}
