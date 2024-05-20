// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout, FieldLayoutLib } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

// Hex below is the result of `WorldResourceIdLib.encode({ namespace: "test", name: "ItemPrice", typeId: RESOURCE_TABLE });`
ResourceId constant _tableId = ResourceId.wrap(0x746274657374000000000000000000004974656d507269636500000000000000);
ResourceId constant ItemPriceTableId = _tableId;

FieldLayout constant _fieldLayout = FieldLayout.wrap(
  0x0021020001200000000000000000000000000000000000000000000000000000
);

struct ItemPriceData {
  bool isSet;
  uint256 price;
}

library ItemPrice {
  /**
   * @notice Get the table values' field layout.
   * @return _fieldLayout The field layout for the table.
   */
  function getFieldLayout() internal pure returns (FieldLayout) {
    return _fieldLayout;
  }

  /**
   * @notice Get the table's key schema.
   * @return _keySchema The key schema for the table.
   */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _keySchema = new SchemaType[](2);
    _keySchema[0] = SchemaType.UINT256;
    _keySchema[1] = SchemaType.UINT256;

    return SchemaLib.encode(_keySchema);
  }

  /**
   * @notice Get the table's value schema.
   * @return _valueSchema The value schema for the table.
   */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _valueSchema = new SchemaType[](2);
    _valueSchema[0] = SchemaType.BOOL;
    _valueSchema[1] = SchemaType.UINT256;

    return SchemaLib.encode(_valueSchema);
  }

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](2);
    keyNames[0] = "smartObjectId";
    keyNames[1] = "itemId";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](2);
    fieldNames[0] = "isSet";
    fieldNames[1] = "price";
  }

  /**
   * @notice Register the table with its config.
   */
  function register() internal {
    StoreSwitch.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config.
   */
  function _register() internal {
    StoreCore.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Get isSet.
   */
  function getIsSet(uint256 smartObjectId, uint256 itemId) internal view returns (bool isSet) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Get isSet.
   */
  function _getIsSet(uint256 smartObjectId, uint256 itemId) internal view returns (bool isSet) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Set isSet.
   */
  function setIsSet(uint256 smartObjectId, uint256 itemId, bool isSet) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((isSet)), _fieldLayout);
  }

  /**
   * @notice Set isSet.
   */
  function _setIsSet(uint256 smartObjectId, uint256 itemId, bool isSet) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((isSet)), _fieldLayout);
  }

  /**
   * @notice Get price.
   */
  function getPrice(uint256 smartObjectId, uint256 itemId) internal view returns (uint256 price) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get price.
   */
  function _getPrice(uint256 smartObjectId, uint256 itemId) internal view returns (uint256 price) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set price.
   */
  function setPrice(uint256 smartObjectId, uint256 itemId, uint256 price) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((price)), _fieldLayout);
  }

  /**
   * @notice Set price.
   */
  function _setPrice(uint256 smartObjectId, uint256 itemId, uint256 price) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((price)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get(uint256 smartObjectId, uint256 itemId) internal view returns (ItemPriceData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    (bytes memory _staticData, PackedCounter _encodedLengths, bytes memory _dynamicData) = StoreSwitch.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data.
   */
  function _get(uint256 smartObjectId, uint256 itemId) internal view returns (ItemPriceData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    (bytes memory _staticData, PackedCounter _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function set(uint256 smartObjectId, uint256 itemId, bool isSet, uint256 price) internal {
    bytes memory _staticData = encodeStatic(isSet, price);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(uint256 smartObjectId, uint256 itemId, bool isSet, uint256 price) internal {
    bytes memory _staticData = encodeStatic(isSet, price);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(uint256 smartObjectId, uint256 itemId, ItemPriceData memory _table) internal {
    bytes memory _staticData = encodeStatic(_table.isSet, _table.price);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(uint256 smartObjectId, uint256 itemId, ItemPriceData memory _table) internal {
    bytes memory _staticData = encodeStatic(_table.isSet, _table.price);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of static data using this table's field layout.
   */
  function decodeStatic(bytes memory _blob) internal pure returns (bool isSet, uint256 price) {
    isSet = (_toBool(uint8(Bytes.slice1(_blob, 0))));

    price = (uint256(Bytes.slice32(_blob, 1)));
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   * @param _staticData Tightly packed static fields.
   *
   *
   */
  function decode(
    bytes memory _staticData,
    PackedCounter,
    bytes memory
  ) internal pure returns (ItemPriceData memory _table) {
    (_table.isSet, _table.price) = decodeStatic(_staticData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(uint256 smartObjectId, uint256 itemId) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(uint256 smartObjectId, uint256 itemId) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(bool isSet, uint256 price) internal pure returns (bytes memory) {
    return abi.encodePacked(isSet, price);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(bool isSet, uint256 price) internal pure returns (bytes memory, PackedCounter, bytes memory) {
    bytes memory _staticData = encodeStatic(isSet, price);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(uint256 smartObjectId, uint256 itemId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(smartObjectId));
    _keyTuple[1] = bytes32(uint256(itemId));

    return _keyTuple;
  }
}

/**
 * @notice Cast a value to a bool.
 * @dev Boolean values are encoded as uint8 (1 = true, 0 = false), but Solidity doesn't allow casting between uint8 and bool.
 * @param value The uint8 value to convert.
 * @return result The boolean value.
 */
function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
