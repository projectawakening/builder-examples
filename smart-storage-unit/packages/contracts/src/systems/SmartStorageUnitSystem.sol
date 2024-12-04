// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { console } from "forge-std/console.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";
import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { IInventoryErrors } from "@eveworld/world/src/modules/inventory/IInventoryErrors.sol";

import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";
import { InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { EphemeralInvTable } from "@eveworld/world/src/codegen/tables/EphemeralInvTable.sol";
import { EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";
import { EntityRecordTable, EntityRecordTableData } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";
import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";
import { InventoryItemTableData, InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";

import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { RatioConfig, RatioConfigData } from "../codegen/tables/RatioConfig.sol";
import { TransferItem } from "@eveworld/world/src/modules/inventory/types.sol";

/**
 * @dev This contract is an example for extending Inventory functionality from game.
 * This contract implements item trade as a feature to the existing inventoryIn logic
 */
contract SmartStorageUnitSystem is System {
  using InventoryLib for InventoryLib.World;
  using EntityRecordUtils for bytes14;
  using InventoryUtils for bytes14;
  using SmartDeployableUtils for bytes14;

  error InvalidRatio(string message);

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
    require(ratioIn > 0 && ratioOut > 0, "ratio cannot be lower than 1");    
    
    //Check for overflow issues
    require(ratioIn * ratioOut >= ratioIn, "Overflow with ratios. The ratios are too large.");

    //make sure the inventoryItem out item exists
    //Revert if the items to deposit is not created on-chain
    EntityRecordTableData memory entityInRecord = EntityRecordTable.get(inventoryItemIdIn);
    EntityRecordTableData memory entityOutRecord = EntityRecordTable.get(inventoryItemIdOut);

    if (entityInRecord.recordExists == false || entityOutRecord.recordExists == false) {
      revert IInventoryErrors.Inventory_InvalidItem("Item is not created on-chain", inventoryItemIdIn);
    }

    RatioConfig.set(smartObjectId, inventoryItemIdIn, inventoryItemIdOut, ratioIn, ratioOut);
  }

  /**
   * @notice Handle the interaction flow for item trade to exchange x:y items between two players
   * @dev Ideally the ration can be configured in a seperate function and stored on-chain
   * //TODO this function needs to be authorized by the builder to access inventory functions through RBAC
   * @param smartObjectId The smart object id of the smart storage unit
   * @param quantity The quantity of the item to be exchanged
   * @param inventoryItemIdIn The inventory item id of the item that goes in
   */
  function execute(uint256 smartObjectId, uint64 quantity, uint256 inventoryItemIdIn) public {
    RatioConfigData memory ratioConfigData = RatioConfig.get(smartObjectId, inventoryItemIdIn);
    require(ratioConfigData.ratioIn > 0 && ratioConfigData.ratioOut > 0, "Invalid ratio");
    require(quantity > 0, "Quantity cannot be 0");

    address ssuOwner = IERC721(DeployableTokenTable.getErc721Address()).ownerOf(smartObjectId);

    // Make sure there are enough items
    (uint64 quantityOutputItem, uint64 quantityInputItemLeftOver) = calculateOutput(
      ratioConfigData.ratioIn,
      ratioConfigData.ratioOut,
      quantity
    );    

    uint64 calculatedInput = quantity-quantityInputItemLeftOver;

    require(quantityOutputItem > 0, "Output quantity cannot be 0");
    require(quantityOutputItem > 0, "Calculated input quantity cannot be 0");

    uint256 itemObjectIdOut = RatioConfig.getItemOut(smartObjectId, inventoryItemIdIn);    

    TransferItem[] memory inItems = new TransferItem[](1);
    inItems[0] = TransferItem(inventoryItemIdIn, ssuOwner, calculatedInput);

    TransferItem[] memory ephTransferItems = new TransferItem[](1);
    ephTransferItems[0] = TransferItem(itemObjectIdOut, _msgSender(), quantityOutputItem);

    _inventoryLib().inventoryToEphemeralTransfer(smartObjectId, _msgSender(), ephTransferItems);
    _inventoryLib().ephemeralToInventoryTransfer(smartObjectId, inItems);
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

  function _inventoryLib() internal view returns (InventoryLib.World memory) {
    if (!ResourceIds.getExists(WorldResourceIdLib.encodeNamespace(DEPLOYMENT_NAMESPACE))) {
      return InventoryLib.World({ iface: IBaseWorld(_world()), namespace: DEPLOYMENT_NAMESPACE });
    } else return InventoryLib.World({ iface: IBaseWorld(_world()), namespace: DEPLOYMENT_NAMESPACE });
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return DEPLOYMENT_NAMESPACE;
  }
}
