pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { EntityRecordData, SmartObjectData, WorldPosition } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { IWarEffort } from "./interfaces/IWarEffort.sol";
import { Utils } from "./Utils.sol";

/**
 * @title WarEffort Library (makes interacting with the underlying Systems cleaner)
 * Works similarly to direct calls to world, without having to deal with dynamic method's function selectors due to namespacing.
 * @dev To preserve _msgSender() and other context-dependant properties, Library methods like those MUST be `internal`.
 * That way, the compiler is forced to inline the method's implementation in the contract they're imported into.
 */
library WarEffortLib {
  using Utils for bytes14;

  struct World {
    IBaseWorld iface;
    bytes14 namespace;
  }

  function createAndAnchorWarEffort(
    World memory world,
    uint256 smartObjectId,
    EntityRecordData memory entityRecordData,
    SmartObjectData memory smartObjectData,
    WorldPosition memory worldPosition,
    uint256 fuelUnitVolume,
    uint256 fuelConsumptionPerMinute,
    uint256 fuelMaxCapacity,
    uint256 storageCapacity,
    uint256 ephemeralStorageCapacity
  ) internal {
    world.iface.call(
      world.namespace.warEffortSystemId(),
      abi.encodeCall(
        IWarEffort.createAndAnchorWarEffort,
        (
          smartObjectId,
          entityRecordData,
          smartObjectData,
          worldPosition,
          fuelUnitVolume,
          fuelConsumptionPerMinute,
          fuelMaxCapacity,
          storageCapacity,
          ephemeralStorageCapacity
        )
      )
    );
  }

  function associateSSUToWarEffort(World memory world, uint256 smartObjectId) internal {
    world.iface.call(
      world.namespace.warEffortSystemId(),
      abi.encodeCall(IWarEffort.associateSSUToWarEffort, (smartObjectId))
    );
  }

  function setAcceptedItemTypeId(World memory world, uint256 smartObjectId, uint256 entityTypeId) internal {
    world.iface.call(
      world.namespace.warEffortSystemId(),
      abi.encodeCall(IWarEffort.setAcceptedItemTypeId, (smartObjectId, entityTypeId))
    );
  }

  function setTargetQuantity(World memory world, uint256 smartObjectId, uint256 targetItemQuantity) internal {
    world.iface.call(
      world.namespace.warEffortSystemId(),
      abi.encodeCall(IWarEffort.setTargetQuantity, (smartObjectId, targetItemQuantity))
    );
  }
}
