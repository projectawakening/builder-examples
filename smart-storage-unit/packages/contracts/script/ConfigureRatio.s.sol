// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { Tenant } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { EphemeralInteractSystem, ephemeralInteractSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInteractSystemLib.sol";

import { SmartStorageUnitSystem as CustomSmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { Utils } from "../src/systems/Utils.sol";

/**
 * @title ConfigureRatio
 * @notice This script is used to configure the ratio for the custom SSU contract in systems/SmartStorageUnitSystem.sol
 * @dev It also gives permissions to the custom contract to transfer from and to the SSU (to and from ephemeral inventories)
 */
contract ConfigureRatio is Script {
  
  function run(address worldAddress) external {
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);
    bytes32 tenantId = Tenant.getTenantId();

    //Read from .env
    uint256 itemIn = vm.envUint("ITEM_IN_TYPE_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_TYPE_ID");
    uint64 inRatio = uint64(vm.envUint("IN_RATIO"));
    uint64 outRatio = uint64(vm.envUint("OUT_RATIO"));

    uint256 itemInSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, itemIn);
    uint256 itemOutSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, itemOut);

    //Configure the vending machine
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    console.log("Smart Storage Unit ID: ", vm.toString(smartStorageUnitId));
    console.log("Item In Smart Object ID: ", vm.toString(itemInSmartObjectId));

    ResourceId systemId = Utils.smartStorageUnitSystemId();
    (address contractAddress, ) = Systems.get(systemId);

    vm.startBroadcast(adminPrivateKey);

    ephemeralInteractSystem.setTransferFromEphemeralAccess(smartStorageUnitId, address(contractAddress), true);
    ephemeralInteractSystem.setTransferToEphemeralAccess(smartStorageUnitId, address(contractAddress), true);

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.setRatio,
        (smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, inRatio, outRatio)
      )
    );

    vm.stopBroadcast();
  }
}
