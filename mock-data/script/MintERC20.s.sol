// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { PuppetModule } from "@latticexyz/world-modules/src/modules/puppet/PuppetModule.sol";
import { IERC20Mintable } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Mintable.sol";
import { ERC20Module } from "@latticexyz/world-modules/src/modules/erc20-puppet/ERC20Module.sol";
import { registerERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/registerERC20.sol";

import { ERC20MetadataData } from "@latticexyz/world-modules/src/modules/erc20-puppet/tables/ERC20Metadata.sol";

contract MintERC20 is Script {
  function run(address worldAddress) external {
    // Private key for the ERC20 Contract owner/deployer loaded from ENV
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    // Test parameters hardcoded
    // TODO accept as parameters to the run method for test reproducability
    // Contract address for the deployed token to be minted
    address erc20Address = address(0x0670500CBCD4010A801E803dC0b6c0806838b43C);

    // The address of the recipient
    address destinationAddress = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    uint256 amount = 1000000000000;

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    vm.startBroadcast(deployerPrivateKey);
    // TODO: Need to make a ERC20 Factory that feeds into the static data module
    StoreSwitch.setStoreAddress(address(world));
    IERC20Mintable erc20 = IERC20Mintable(erc20Address);
    erc20.mint(destinationAddress, amount * 1 ether);

    console.log("minting to: ", address(destinationAddress));
    console.log("amount: ", amount * 1 ether);
    vm.stopBroadcast();
  }
}
