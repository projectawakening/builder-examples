// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
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

import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { RatioConfig, RatioConfigData } from "../../codegen/tables/RatioConfig.sol";
import { TransferItem } from "@eveworld/world/src/modules/inventory/types.sol";

/**
 * @dev This contract is an example for extending Inventory functionality from game.
 * This contract implements vending machine as a feature to the existing inventoryIn logic
 */
contract VendingMachineSystem is System {
  using InventoryLib for InventoryLib.World;
  using EntityRecordUtils for bytes14;
  using InventoryUtils for bytes14;
  using SmartDeployableUtils for bytes14;

  /**
   * @dev Define what goes in and out and set the exchange ratio for a vending machine
   * @param smartObjectId The smart object id of the vending machine
   * @param inventoryItemIdIn The inventory item id of the item that goes in
   * @param inventoryItemIdOut The inventory item id of the item that goes out
   * @param quantityIn The ratio of the item that goes in
   * @param quantityOut The ratio of the item that goes out
   * The ratios are whole numbers as an item cannot exist as float in game
   */
  function setVendingMachineRatio(
    uint256 smartObjectId,
    uint256 inventoryItemIdIn,
    uint256 inventoryItemIdOut,
    uint256 quantityIn,
    uint256 quantityOut
  ) public {
    require(quantityIn > 0 && quantityOut > 0, "ratio cannot be set to 0");
    //make sure the inventoryItem out item exists
    //Revert if the items to deposit is not created on-chain
    EntityRecordTableData memory entityInRecord = EntityRecordTable.get(inventoryItemIdIn);

    EntityRecordTableData memory entityOutRecord = EntityRecordTable.get(inventoryItemIdOut);

    if (entityInRecord.recordExists == false || entityOutRecord.recordExists == false) {
      revert IInventoryErrors.Inventory_InvalidItem("VendingMachine: item is not created on-chain", inventoryItemIdIn);
    }
    RatioConfig.set(smartObjectId, inventoryItemIdIn, inventoryItemIdOut, quantityIn, quantityOut);
  }

  /**
   * @notice Handle the interaction flow for vending machine to exchange 2x:10y items between two players
   * @dev Ideally the ration can be configured in a seperate function and stored on-chain
   * //TODO this function needs to be authorized by the builder to access inventory functions through RBAC
   * @param smartObjectId The smart object id of the smart storage unit
   * @param quantity The quantity of the item to be exchanged
   * @param inventoryItemIdIn The inventory item id of the item that goes in
   */
  function executeVendingMachine(uint256 smartObjectId, uint256 quantity, uint256 inventoryItemIdIn) public {
    RatioConfigData memory ratioConfigData = RatioConfig.get(smartObjectId, inventoryItemIdIn);
    if (ratioConfigData.ratioIn == 0 || ratioConfigData.ratioOut == 0) {
      return;
    }
    address ssuOwner = IERC721(DeployableTokenTable.getErc721Address()).ownerOf(smartObjectId);

    // Make sure there are enough items
    (uint256 quantityOutputItem, uint256 quantityInputItemLeftOver) = calculateOutput(
      ratioConfigData.ratioIn,
      ratioConfigData.ratioOut,
      quantity
    );

    uint256 itemObjectIdOut = RatioConfig.getItemOut(smartObjectId, inventoryItemIdIn);

    TransferItem[] memory inItems = new TransferItem[](1);
    inItems[0] = TransferItem(inventoryItemIdIn, ssuOwner, quantity);

    TransferItem[] memory ephTransferItems = new TransferItem[](1);
    ephTransferItems[0] = TransferItem(itemObjectIdOut, ssuOwner, quantityInputItemLeftOver);

    _inventoryLib().inventoryToEphemeralTransfer(smartObjectId, _msgSender(), ephTransferItems);

    ephTransferItems = new TransferItem[](1);
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
    uint256 inputRatio,
    uint256 outputRatio,
    uint256 inputAmount
  ) public pure returns (uint256 outputAmount, uint256 remainingInput) {
    require(inputRatio != 0, "Input ratio cannot be zero");
    require(outputRatio != 0, "Output ratio cannot be zero");

    (inputRatio, outputRatio) = _simplifyRatio(inputRatio, outputRatio);
    remainingInput = inputAmount % inputRatio;
    uint256 usedInput = inputAmount - remainingInput;
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
  function _simplifyRatio(uint256 num, uint256 denom) internal pure returns (uint256 simpleNum, uint256 simpleDenom) {
    uint256 gcdValue = _gcd(num, denom);
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
  function _gcd(uint256 a, uint256 b) internal pure returns (uint256) {
    while (b != 0) {
      uint256 temp = b;
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
