// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { SmartCharacterSystem, smartCharacterSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartCharacterSystemLib.sol";
import { FuelSystem, fuelSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/FuelSystemLib.sol";
import { FuelParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/fuel/types.sol";
import { SmartAssemblySystem, smartAssemblySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartAssemblySystemLib.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { EntityRecordSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/EntityRecordSystem.sol";
import { entityRecordSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EntityRecordSystemLib.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord, EntityRecordData, Location, LocationData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { smartStorageUnitSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartStorageUnitSystemLib.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { DeployableSystem, deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";
import { OwnershipSystem, ownershipSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/OwnershipSystemLib.sol";
import { OwnershipByObject } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/OwnershipByObject.sol";

import { InventorySystem, inventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventorySystemLib.sol";
import { EphemeralInventorySystem, ephemeralInventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInventorySystemLib.sol";
import { CreateInventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";
import { EphemeralInteractSystem, ephemeralInteractSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInteractSystemLib.sol";
import { InventoryInteractSystem, inventoryInteractSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventoryInteractSystemLib.sol";
import { InventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";

import { RatioConfig, RatioConfigData } from "../codegen/tables/RatioConfig.sol";

/**
 * @dev This contract is an example for extending Inventory functionality from game.
 * This contract implements item trade as a feature to the existing inventoryIn logic
 */
contract SmartStorageUnitSystem is System {
  /**
   * @dev Define what goes in and out and set the exchange ratio for a item trade
   * @param smartObjectId The smart object id of the item trade
   * @param inventoryItemIdIn The inventory item id of the item that goes in
   * @param inventoryItemIdOut The inventory item id of the item that goes out
   * @param ratioIn The ratio of the item that goes in
   * @param ratioOut The ratio of the item that goes out
   * The ratios are whole numbers as an item cannot exist as float in game
   */
  function setRatio(
    uint256 smartObjectId,
    uint256 inventoryItemIdIn,
    uint256 inventoryItemIdOut,
    uint64 ratioIn,
    uint64 ratioOut
  ) public {
    //Ensure the caller is the owner of the SSU
    address ssuOwner = OwnershipByObject.get(smartObjectId);
    require(ssuOwner == _msgSender(), "Access Denied. You are not the owner of this SSU.");

    // Check for invalid ratios
    require(ratioIn > 0 && ratioOut > 0, "Ratio cannot be less than 1");

    // Check for overflow issues
    require(ratioIn * ratioOut >= ratioIn, "Overflow with ratios. The ratios are too large");

    // Fetch the item entity data
    EntityRecordData memory entityInRecordData = EntityRecord.get(inventoryItemIdIn);
    EntityRecordData memory entityOutRecordData = EntityRecord.get(inventoryItemIdOut);

    // Revert if the items are not created on-chain
    if (entityInRecordData.exists == false || entityOutRecordData.exists == false) {
      revert InventorySystem.Inventory_InvalidItemObjectId(inventoryItemIdIn);
    }

    // Set the Ratio Config MUD Table for this SSU
    RatioConfig.set(smartObjectId, inventoryItemIdIn, inventoryItemIdOut, ratioIn, ratioOut);
  }

  /**
   * @notice Handle the interaction flow for item trade to exchange x:y items between two players
   * @dev The ratio is set in the setRatio function and stored through the RatioConfig table
   * @param smartObjectId The smart object id of the smart storage unit
   * @param quantity The quantity of the item to be exchanged
   * @param inventoryItemIdIn The inventory item id of the item that goes in
   */
  function execute(uint256 smartObjectId, uint64 quantity, uint256 inventoryItemIdIn) public {
    RatioConfigData memory ratioConfigData = RatioConfig.get(smartObjectId, inventoryItemIdIn);

    require(ratioConfigData.ratioIn > 0 && ratioConfigData.ratioOut > 0, "Invalid ratio");
    require(quantity > 0, "Quantity cannot be 0 or less");

    // Ensure there are enough items
    (uint64 quantityOutputItem, uint64 quantityInputItemLeftOver) = calculateOutput(
      ratioConfigData.ratioIn,
      ratioConfigData.ratioOut,
      quantity
    );

    uint64 calculatedInput = quantity - quantityInputItemLeftOver;

    require(quantityOutputItem > 0, "Output quantity cannot be 0 or less");
    require(calculatedInput > 0, "Calculated input quantity cannot be 0 or less");

    uint256 itemObjectIdOut = RatioConfig.getItemOut(smartObjectId, inventoryItemIdIn);

    InventoryItemParams[] memory ephToInvItems = new InventoryItemParams[](1);
    ephToInvItems[0] = InventoryItemParams(inventoryItemIdIn, calculatedInput);

    ephemeralInteractSystem.transferFromEphemeral(smartObjectId, _msgSender(), ephToInvItems);

    InventoryItemParams[] memory invToEphItems = new InventoryItemParams[](1);
    invToEphItems[0] = InventoryItemParams(itemObjectIdOut, quantityOutputItem);

    ephemeralInteractSystem.transferToEphemeral(smartObjectId, _msgSender(), invToEphItems);
  }

  /**
   * @dev Calculate output and remaining input based on input and output ratios
   * @param inputRatio Numerator of the input-output ratio
   * @param outputRatio Denominator of the input-output ratio
   * @param inputAmount Amount of input
   * @return outputAmount Output amount based on the input-output ratio
   * @return remainingInput Remaining input after calculation
   */
  function calculateOutput(
    uint64 inputRatio,
    uint64 outputRatio,
    uint64 inputAmount
  ) public pure returns (uint64 outputAmount, uint64 remainingInput) {
    (inputRatio, outputRatio) = _simplifyRatio(inputRatio, outputRatio);

    remainingInput = inputAmount % inputRatio;
    uint64 usedInput = inputAmount - remainingInput;
    outputAmount = (usedInput * outputRatio) / inputRatio;

    return (outputAmount, remainingInput);
  }

  /**
   * @dev Simplify the ratio by dividing with the greatest common divisor
   * @param num Numerator of the ratio
   * @param denom Denominator of the ratio
   * @return simpleNum Simplified numerator after dividing by GCD
   * @return simpleDenom Simplified denominator after dividing by GCD
   */
  function _simplifyRatio(uint64 num, uint64 denom) internal pure returns (uint64 simpleNum, uint64 simpleDenom) {
    uint64 gcdValue = _gcd(num, denom);
    simpleNum = num / gcdValue;
    simpleDenom = denom / gcdValue;
    return (simpleNum, simpleDenom);
  }

  /**
   * @dev Iterative function to calculate the greatest common divisor
   * @param a First number
   * @param b Second number
   * @return The greatest common divisor of a and b
   */
  function _gcd(uint64 a, uint64 b) internal pure returns (uint64) {
    while (b != 0) {
      uint64 temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }
}
