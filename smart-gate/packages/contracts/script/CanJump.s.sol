// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";

import { CharactersByAccount } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/CharactersByAccount.sol";
import { Characters } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Characters.sol";

/**
 * @notice This script tests if characters can jump between two configured smart gates
 * @dev This script can only be called by the owner of the smart gate
 */
contract CanJump is Script {
  uint256 sourceGateId;
  uint256 destinationGateId;

  function testCharacterCanJump(address character, string memory name) internal {
    uint256 characterId = CharactersByAccount.getSmartObjectId(character);

    require(characterId != 0, "Character does not exist");

    uint256 tribeId = Characters.getTribeId(characterId);

    console.log(name, "Character ID:", vm.toString(characterId));
    console.log(name, "Character Tribe ID:", vm.toString(tribeId));
    console.log(name, "Can Jump:", smartGateSystem.canJump(characterId, sourceGateId, destinationGateId));
  }

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(adminPrivateKey);
    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(adminPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);

    sourceGateId = vm.envUint("SOURCE_GATE_ID");
    destinationGateId = vm.envUint("DESTINATION_GATE_ID");

    console.log("-------------------\nTESTING CORRECT TRIBE");
    testCharacterCanJump(admin, "Admin");

    console.log("-------------------\nTESTING INCORRECT TRIBE");
    testCharacterCanJump(player, "Player");

    vm.stopBroadcast();
  }
}
