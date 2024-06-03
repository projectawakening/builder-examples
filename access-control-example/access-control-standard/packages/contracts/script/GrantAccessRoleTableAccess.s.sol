// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IAccessManagementSystem } from "@latticexyz/world/src/codegen/interfaces/IAccessManagementSystem.sol";

// table ResourceId import
import { AccessRoleTableId } from "../src/codegen/tables/AccessRole.sol";

contract GrantAccessRoleTableAccess is Script {
  function run(address worldAddress) external {
    address accessRoleTableAccessAccount = vm.envAddress("TABLE_ACCESS_ACCOUNT");
  
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    // NOTE: this private key is set to the foundry anvil default, and if you want to deploy live you must replace it with your live network account private key
    // the calling account must be the namespace owner of the namespace AccessRole was deployed to for the following to be successful
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    // and this transaction need to be run by the AccessRole namespace owner account
    IAccessManagementSystem(worldAddress).grantAccess(AccessRoleTableId, accessRoleTableAccessAccount);

    vm.stopBroadcast();
  }
}