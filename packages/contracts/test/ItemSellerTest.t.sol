// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ItemSeller } from "../src/systems/item_seller/ItemSeller.sol";

contract VendingMachineTest is MudTest {
  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function setup() public {
    ItemSeller itemSeller = new ItemSeller();
    IWorld(worldAddress).registerSystem(address(itemSeller));
  }
}
