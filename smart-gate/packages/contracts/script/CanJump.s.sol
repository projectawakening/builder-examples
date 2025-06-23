// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";
import { CharactersByAccount } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/CharactersByAccount.sol";
import { Characters } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Characters.sol";

/**
 * @notice This script is used to test if the custom Smart Gate Behavior limits Smart Gate Usage
 */
contract CanJump is Script {
  function displayPlayerCanJumpFromAddress(address playerAddress, string memory testName, uint256 sourceGateId, uint256 destinationGateId) internal returns (bool) {
    uint256 playerCharacterId = CharactersByAccount.getSmartObjectId(playerAddress);
    uint256 playerCharacterTribeId = Characters.getTribeId(playerCharacterId);

    console.log("-------------------\n", testName);
    console.log("Player Character ID:", vm.toString(playerCharacterId));
    console.log("Player Character Tribe ID:", vm.toString(playerCharacterTribeId));

    bool canJump = smartGateSystem.canJump(playerCharacterId, sourceGateId, destinationGateId);

    console.log("Can Jump:", canJump);

    return canJump;
  }

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(adminPrivateKey);
    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(adminPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);

    uint256 sourceGateId = vm.envUint("SOURCE_GATE_ID");
    uint256 destinationGateId = vm.envUint("DESTINATION_GATE_ID");

    displayPlayerCanJumpFromAddress(admin, "TESTING CORRECT TRIBE", sourceGateId, destinationGateId);
    displayPlayerCanJumpFromAddress(player, "TESTING INCORRECT TRIBE", sourceGateId, destinationGateId);

    vm.stopBroadcast();
  }
}
