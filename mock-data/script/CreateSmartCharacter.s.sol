pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { SmartObjectData, EntityRecordData } from "@eveworld/world/src/modules/smart-character/types.sol";
import { SmartCharacterLib } from "@eveworld/world/src/modules/smart-character/SmartCharacterLib.sol";
import { EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

contract CreateSmartCharacter is Script {
  using SmartCharacterLib for SmartCharacterLib.World;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Test values for creating the smart character
    // TODO accept as parameters to the run method for test reproducability
    uint256 characterId = 1250081923;
    uint256 corpId = 22662;
    // The token of this character will be minted to
    address characterAddress = vm.addr(deployerPrivateKey);

    uint256 typeId = 123;
    uint256 itemId = 234;
    uint256 volume = 100;
    string memory cid = "azert";
    string memory characterName = "awesome character";

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    SmartCharacterLib.World memory smartCharacter = SmartCharacterLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartCharacter.createCharacter(
      characterId,
      0x14dC79964da2C08b23698B3D3cc7Ca32193d9955,
      corpId,
      EntityRecordData({ typeId: typeId, itemId: itemId, volume: volume }),
      EntityRecordOffchainTableData({ name: characterName, dappURL: "noURL", description: "." }),
      cid
    );
    vm.stopBroadcast();
  }
}
