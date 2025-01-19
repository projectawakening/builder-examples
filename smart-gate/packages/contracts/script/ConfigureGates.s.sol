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
import { SMART_GATE_SYSTEM_NAME } from "../src/systems/constants.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";



import { AccessListDefinitions, AccessListDefinitionsData } from "../src/codegen/tables/AccessListDefinitions.sol";

contract ConfigureGates is Script {
  using SmartGateUtils for bytes14;
  using SmartGateLib for SmartGateLib.World;

  SmartGateLib.World smartGate;

  function run(address worldAddress) external {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    smartGate = SmartGateLib.World({ iface: IBaseWorld(worldAddress), namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE });

    uint256 smartGateId = vm.envUint("SOURCE_GATE_ID");
    uint256 destinationSmartGateId = vm.envUint("DESTINATION_GATE_ID");

    ResourceId systemId = Utils.smartGateSystemId();

    //This function binds the gates to the smart contract
    smartGate.configureSmartGate(smartGateId, systemId);
    smartGate.configureSmartGate(destinationSmartGateId, systemId);
    
    vm.stopBroadcast();
    bytes16 systemName = SMART_GATE_SYSTEM_NAME;
    string memory systemNameString = bytes16ToString(systemName);
    console.log("Configured System with name", systemNameString);
    //console.log(systemNameString);
    console.log("for source gate with ID", smartGateId);
    console.log("and destination gate with ID", destinationSmartGateId);
  }

  function bytes16ToString(bytes16 input) private pure returns (string memory) {
        // Erstelle einen neuen Speicherbereich für den String
        bytes memory result = new bytes(16);
        
        // Kopiere die Bytes von `input` in den Speicherbereich
        for (uint256 i = 0; i < 16; i++) {
            result[i] = input[i];
        }
        
        // Wandelt die Bytes in einen String um
        return string(result);
    }
}
