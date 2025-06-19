// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";

import { CharactersByAccount } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/CharactersByAccount.sol";
import { Characters } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Characters.sol";

contract CanJump is Script {
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

    uint256 adminCharacterId = CharactersByAccount.getSmartObjectId(admin);
    uint256 playerCharacterId = CharactersByAccount.getSmartObjectId(player);

    uint256 adminCharacterTribeId = Characters.getTribeId(adminCharacterId);
    uint256 playerCharacterTribeId = Characters.getTribeId(playerCharacterId);

    console.log("-------------------\nTESTING CORRECT TRIBE");
    console.log("Admin Character ID:", vm.toString(adminCharacterId));
    console.log("Admin Character Tribe ID:", vm.toString(adminCharacterTribeId));
    console.log("Can Jump:", smartGateSystem.canJump(adminCharacterId, sourceGateId, destinationGateId));

    console.log("-------------------\nTESTING INCORRECT TRIBE");
    console.log("Player Character ID:", vm.toString(playerCharacterId));
    console.log("Player Character Tribe ID:", vm.toString(playerCharacterTribeId));
    console.log("Can Jump:", smartGateSystem.canJump(playerCharacterId, sourceGateId, destinationGateId));

    vm.stopBroadcast();
  }
}
