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

import { GateAccess } from "../src/codegen/tables/GateAccess.sol";
import { AccessListDefinitions, AccessListDefinitionsData } from "../src/codegen/tables/AccessListDefinitions.sol";

contract ConfigureSmartGate is Script {
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

  /*
    bytes32 whitelistId = createAccessList("whitelist", true);
    bytes32 blacklistId = createAccessList("blacklist", true);

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addAccessListToGate,
        (smartGateId, whitelistId)
      )
    );

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addAccessListToGate,
        (smartGateId, blacklistId)
      )
    );
  */
    vm.stopBroadcast();
  }

  /*
  function createAccessList(string memory accessListName, bool isWhitelist) public returns (bytes32 listId) {
    // 1) Generate a hash ID from the name
    listId = keccak256(bytes(accessListName));

    // 2) Check if this name already exists (id is always hashed name)
    AccessListDefinitionsData memory existing = AccessListDefinitions.get(listId);
    if (keccak256(bytes(existing.accessListName)) == listId) {
        revert("AccessList with this name already exists");
    }

    // 3) Create the data structure
    AccessListDefinitionsData memory newList = AccessListDefinitionsData({
      isWhitelist: isWhitelist,
      createdBy: msg.sender,
      entryExists: true,
      accessListName: accessListName
    });

    // 4) Store the data structure in the MUD table
    AccessListDefinitions.set(listId, newList);

    return listId;
  }
  */
}
