// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

// local autogen interface
import { IPermissionedSystem as IWorldPermissionedSystem } from "../src/codegen/world/IPermissionedSystem.sol";
import { ADMIN } from "../src/constants.sol";

contract ConfigureAdminAccessList is Script {
  function run(address worldAddress) external {
    //Depending on the number of ADMIN addresses you need to allow, you will have to add new variables to the .env, import them, and adjust the array sizes below
    address admin1 = vm.envAddress("ADMIN_ADDRESS_1");
    //  address admin2 = vm.envAddress("ADMIN_ADDRESS_2");
    address[] memory adminAccessList = new address[](1);
    // address[] memory adminAccessList = new address[](2);
    adminAccessList[0] = admin1;
    // adminAccessList[1] = admin2;
  
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    // NOTE: this private key is set to the foundry anvil default, and if you want to deploy live you must replace it with your live network account private key
    // the calling account must have access to the AccessRole table for the following to be successful
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    // The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    IWorldPermissionedSystem(worldAddress).access_control__setAccessListByRole(ADMIN, adminAccessList);

    vm.stopBroadcast();
  }
}