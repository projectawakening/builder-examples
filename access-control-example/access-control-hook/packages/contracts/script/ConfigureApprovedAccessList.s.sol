// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

// local autogen interface
import { IAccessControlHook as IWorldAccessControlHook } from "../src/codegen/world/IAccessControlHook.sol";
import { APPROVED } from "../src/constants.sol";


contract ConfigureApprovedAccessList is Script {
  using WorldResourceIdInstance for ResourceId;

  function run(address worldAddress) external {
    StoreSwitch.setStoreAddress(worldAddress);
    // Depending on the number of FORWARDER addresses you need to allow, you will have to add new variables to the .env, import them, and adjust the array sizes below
    bytes32 forwarder1Bytes32 = vm.envBytes32("FORWARDER_SYSTEM_ID_1");
    // bytes32 forwarder2Bytes32 = vm.envBytes32("FORWARDER_SYSTEM_ID_2");
    ResourceId forwarder1ResourceId = ResourceId.wrap(forwarder1Bytes32);
    // ResourceId forwarder2ResourceId = ResourceId.wrap(forwarder2Bytes32);
    address forwarder1 = Systems.getSystem(forwarder1ResourceId);
    // address forwarder2 = Systems.getSystem(forwarder2ResourceId);
    address[] memory approvedAccessList = new address[](1);
    // address[] memory approvedAccessList = new address[](2);
    approvedAccessList[0] = address(forwarder1);
    // approvedAccessList[1] = address(forwarder2);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    // NOTE: this private key is set to the foundry anvil default, and if you want to deploy live you must replace it with your live network account private key
    // the calling account must have access to the AccessRole table for the following to be successful
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    // The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    IWorldAccessControlHook(worldAddress).access_control__setAccessListByRole(APPROVED, approvedAccessList);

    vm.stopBroadcast();
  }
}