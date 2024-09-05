pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { DeployableFuelBalance, DeployableFuelBalanceData } from "@eveworld/world/src/codegen/tables/DeployableFuelBalance.sol";
import { GlobalDeployableState } from "@eveworld/world/src/codegen/tables/GlobalDeployableState.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

contract BringOnline is Script {
  // assumes CreateAndAnchor.s.sol has been run
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartDeployableUtils for bytes14;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    SmartDeployableLib.World memory smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    uint256 smartObjectId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-2345")));

    // check global state and resume if needed
    if (GlobalDeployableState.getIsPaused(FRONTIER_WORLD_DEPLOYMENT_NAMESPACE.globalStateTableId()) == false) {
      smartDeployable.globalResume();
    }

    // check fuel and add fuel if needed
    DeployableFuelBalanceData memory data = DeployableFuelBalance.get(
      FRONTIER_WORLD_DEPLOYMENT_NAMESPACE.deployableFuelBalanceTableId(),
      smartObjectId
    );
    uint256 FUEL_DECIMALS = 18;
    if (data.fuelAmount < 10 ** FUEL_DECIMALS) {
      smartDeployable.depositFuel(smartObjectId, 200000);
    }

    smartDeployable.bringOnline(smartObjectId); // needs to have some fuel in it to work, else it will just let the state to offline

    vm.stopBroadcast();
  }
}
