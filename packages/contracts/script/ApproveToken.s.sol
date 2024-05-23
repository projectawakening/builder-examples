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

import { IItemSeller } from "../src/codegen/world/IItemSeller.sol";

contract ApproveToken is Script {
  function run(address worldAddress) external {
    // Private key for the ERC20 Contract owner/deployer loaded from ENV
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    address tokenAddress = vm.envAddress("ERC20_TOKEN_ADDRESS");
    address owner = vm.addr(playerPrivateKey);

    console.log(owner);

    // Test parameters hardcoded
    // TODO accept as parameters to the run method for test reproducability
    // Contract address for the deployed token to be minted
    address erc20Address = address(tokenAddress);

    // The address of the recipient
    uint256 amount = 1;

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    vm.startBroadcast(playerPrivateKey);
    address itemSellerAddress = IItemSeller(worldAddress).test2__getContractAddress();
    console.log(itemSellerAddress);

    // StoreSwitch.setStoreAddress(address(world));
    IERC20Mintable erc20 = IERC20Mintable(erc20Address);
    console.log(erc20.balanceOf(owner));
    erc20.approve(itemSellerAddress, amount * 1 ether);

    console.log(erc20.allowance(owner, itemSellerAddress));
    console.log(erc20.balanceOf(owner));

    vm.stopBroadcast();
  }
}
