// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";
import { Utils as SmartGateUtils } from "@eveworld/world/src/modules/smart-gate/Utils.sol";
import { SmartGateLib } from "@eveworld/world/src/modules/smart-gate/SmartGateLib.sol";
import { SmartGateSystem } from "../src/systems/SmartGateSystem.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { AccessListDefinitions, AccessListDefinitionsData } from "../src/codegen/tables/AccessListDefinitions.sol";

contract CreateWhitelist is Script {
  using SmartGateUtils for bytes14;
  using SmartGateLib for SmartGateLib.World;

  SmartGateLib.World smartGate;

  function run(address worldAddress, string memory whitelistName) external {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    smartGate = SmartGateLib.World({ iface: IBaseWorld(worldAddress), namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE });

    uint256 smartGateId = vm.envUint("SOURCE_GATE_ID");
    uint256 destinationSmartGateId = vm.envUint("DESTINATION_GATE_ID");

    ResourceId systemId = Utils.smartGateSystemId();

    bytes memory whitelistResult = world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.createAccessList,
        (whitelistName, true)
      )
    );
    bytes32 whitelistId = abi.decode(whitelistResult, (bytes32));

    console.log("Whitelist created whith name", whitelistName);
    console.log("AccessListId");
    console.logBytes32(whitelistId);

    vm.stopBroadcast();
  }
}
