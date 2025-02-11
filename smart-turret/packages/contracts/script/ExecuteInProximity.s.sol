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

import { SmartTurretSystem } from "../src/systems/SmartTurretSystem.sol";
import { TurretAllowlist } from "../src/codegen/tables/TurretAllowlist.sol";

contract ExecuteInProximity is Script {
  using SmartTurretUtils for bytes14;
  using SmartTurretLib for SmartTurretLib.World;
  using SmartDeployableUtils for bytes14;
  using SmartCharacterUtils for bytes14;

  SmartTurretLib.World smartTurret;

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    smartTurret = SmartTurretLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    uint256 smartTurretId = vm.envUint("SMART_TURRET_ID");
    uint256 allowedCorpId = vm.envUint("ALLOWED_CORP_ID");

    console.log("Corp ID of character 123:", CharactersTable.getCorpId(123));
    console.log("Corp ID of character 77777:", CharactersTable.getCorpId(77777));

    uint256 allowedCorp = TurretAllowlist.get();

    console.log("\n");
    console.log("ALLOWED CORP FROM MUD: ", allowedCorp);
    console.log("\n");

    ResourceId systemId = Utils.smartTurretSystemId();

    TargetPriority[] memory inputQueue = new TargetPriority[](1);
    Turret memory turret = Turret({ weaponTypeId: 1, ammoTypeId: 1, chargesLeft: 100 });

    SmartTurretTarget memory turretTarget = SmartTurretTarget({
      shipId: 1,
      shipTypeId: 1,
      characterId: 123,
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
          (smartTurretId, 11111, inputQueue, turret, turretTarget)
        )
      ),
      (TargetPriority[])
    );

    console.log("Input Target Queue Length: ", inputQueue.length); //1
    console.log("Output Target Queue Length: ", outputTargetQueue.length); //1

    vm.stopBroadcast();
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return FRONTIER_WORLD_DEPLOYMENT_NAMESPACE;
  }
}
