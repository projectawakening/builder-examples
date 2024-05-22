//SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Module } from "@latticexyz/world/src/Module.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { WAR_EFFORT_MODULE_NAME as MODULE_NAME, WAR_EFFORT_MODULE_NAMESPACE as MODULE_NAMESPACE } from "./constants.sol";
import { Utils } from "./Utils.sol";

import { WarEffortTable } from "../codegen/tables/WarEffortTable.sol";

import { WarEffort } from "./systems/WarEffort.sol";

contract WarEffortModule is Module {
  error WarEffortModule_InvalidNamespace(bytes14 namespace);

  address immutable registrationLibrary = address(new WarEffortModuleRegistrationLibrary());

  function getName() public pure returns (bytes16) {
    return MODULE_NAME;
  }

  function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function _requireDependencies() internal view {}

  function install(bytes memory encodeArgs) public {
    requireNotInstalled(__self, encodeArgs);

    bytes14 namespace = abi.decode(encodeArgs, (bytes14));

    if (namespace == MODULE_NAMESPACE) {
      revert WarEffortModule_InvalidNamespace(namespace);
    }

    _requireDependencies();

    IBaseWorld world = IBaseWorld(_world());
    (bool success, bytes memory returnData) = registrationLibrary.delegatecall(
      abi.encodeCall(WarEffortModuleRegistrationLibrary.register, (world, namespace))
    );
    require(success, string(returnData));

    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    world.transferOwnership(namespaceId, _msgSender());
  }

  function installRoot(bytes memory) public pure {
    revert Module_RootInstallNotSupported();
  }
}

contract WarEffortModuleRegistrationLibrary {
  using Utils for bytes14;

  /**
   * Register systems and tables for a new smart storage unit in a given namespace
   */
  function register(IBaseWorld world, bytes14 namespace) external {
    //Register the namespace
    if (!ResourceIds.getExists(WorldResourceIdLib.encodeNamespace(namespace)))
      world.registerNamespace(WorldResourceIdLib.encodeNamespace(namespace));

    // Register the tables
    if (!ResourceIds.getExists(namespace.warEffortTableId())) WarEffortTable.register(namespace.warEffortTableId());

    //Register the systems
    if (!ResourceIds.getExists(namespace.warEffortSystemId()))
      world.registerSystem(namespace.warEffortSystemId(), new WarEffort(), true);
  }
}
