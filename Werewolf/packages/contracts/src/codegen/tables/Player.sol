// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

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
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("Player")));
bytes32 constant PlayerTableId = _tableId;

struct PlayerData {
  address owner;
  string name;
  string color;
}

library Player {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.ADDRESS;
    _schema[1] = SchemaType.STRING;
    _schema[2] = SchemaType.STRING;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](0);

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](3);
    _fieldNames[0] = "owner";
    _fieldNames[1] = "name";
    _fieldNames[2] = "color";
    return ("Player", _fieldNames);
  }

  /** Register the table's schema */
  function registerSchema() internal {
    StoreSwitch.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Register the table's schema (using the specified store) */
  function registerSchema(IStore _store) internal {
    _store.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Set the table's metadata */
  function setMetadata() internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    StoreSwitch.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Set the table's metadata (using the specified store) */
  function setMetadata(IStore _store) internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    _store.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Get owner */
  function getOwner() internal view returns (address owner) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Get owner (using the specified store) */
  function getOwner(IStore _store) internal view returns (address owner) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0);
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Set owner */
  function setOwner(address owner) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((owner)));
  }

  /** Set owner (using the specified store) */
  function setOwner(IStore _store, address owner) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((owner)));
  }

  /** Get name */
  function getName() internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1);
    return (string(_blob));
  }

  /** Get name (using the specified store) */
  function getName(IStore _store) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1);
    return (string(_blob));
  }

  /** Set name */
  function setName(string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 1, bytes((name)));
  }

  /** Set name (using the specified store) */
  function setName(IStore _store, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 1, bytes((name)));
  }

  /** Get the length of name */
  function lengthName() internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 1, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of name (using the specified store) */
  function lengthName(IStore _store) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 1, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of name (unchecked, returns invalid data if index overflows) */
  function getItemName(uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 1, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Get an item of name (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemName(IStore _store, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 1, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Push a slice to name */
  function pushName(string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.pushToField(_tableId, _keyTuple, 1, bytes((_slice)));
  }

  /** Push a slice to name (using the specified store) */
  function pushName(IStore _store, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.pushToField(_tableId, _keyTuple, 1, bytes((_slice)));
  }

  /** Pop a slice from name */
  function popName() internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.popFromField(_tableId, _keyTuple, 1, 1);
  }

  /** Pop a slice from name (using the specified store) */
  function popName(IStore _store) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.popFromField(_tableId, _keyTuple, 1, 1);
  }

  /** Update a slice of name at `_index` */
  function updateName(uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.updateInField(_tableId, _keyTuple, 1, _index * 1, bytes((_slice)));
  }

  /** Update a slice of name (using the specified store) at `_index` */
  function updateName(IStore _store, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.updateInField(_tableId, _keyTuple, 1, _index * 1, bytes((_slice)));
  }

  /** Get color */
  function getColor() internal view returns (string memory color) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2);
    return (string(_blob));
  }

  /** Get color (using the specified store) */
  function getColor(IStore _store) internal view returns (string memory color) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2);
    return (string(_blob));
  }

  /** Set color */
  function setColor(string memory color) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 2, bytes((color)));
  }

  /** Set color (using the specified store) */
  function setColor(IStore _store, string memory color) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 2, bytes((color)));
  }

  /** Get the length of color */
  function lengthColor() internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 2, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of color (using the specified store) */
  function lengthColor(IStore _store) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 2, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of color (unchecked, returns invalid data if index overflows) */
  function getItemColor(uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 2, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Get an item of color (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemColor(IStore _store, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 2, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Push a slice to color */
  function pushColor(string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.pushToField(_tableId, _keyTuple, 2, bytes((_slice)));
  }

  /** Push a slice to color (using the specified store) */
  function pushColor(IStore _store, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.pushToField(_tableId, _keyTuple, 2, bytes((_slice)));
  }

  /** Pop a slice from color */
  function popColor() internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.popFromField(_tableId, _keyTuple, 2, 1);
  }

  /** Pop a slice from color (using the specified store) */
  function popColor(IStore _store) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.popFromField(_tableId, _keyTuple, 2, 1);
  }

  /** Update a slice of color at `_index` */
  function updateColor(uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.updateInField(_tableId, _keyTuple, 2, _index * 1, bytes((_slice)));
  }

  /** Update a slice of color (using the specified store) at `_index` */
  function updateColor(IStore _store, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.updateInField(_tableId, _keyTuple, 2, _index * 1, bytes((_slice)));
  }

  /** Get the full data */
  function get() internal view returns (PlayerData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store) internal view returns (PlayerData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(address owner, string memory name, string memory color) internal {
    bytes memory _data = encode(owner, name, color);

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(IStore _store, address owner, string memory name, string memory color) internal {
    bytes memory _data = encode(owner, name, color);

    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using the data struct */
  function set(PlayerData memory _table) internal {
    set(_table.owner, _table.name, _table.color);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, PlayerData memory _table) internal {
    set(_store, _table.owner, _table.name, _table.color);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal view returns (PlayerData memory _table) {
    // 20 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 20));

    _table.owner = (address(Bytes.slice20(_blob, 0)));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 20) {
      uint256 _start;
      // skip static data length + dynamic lengths word
      uint256 _end = 52;

      _start = _end;
      _end += _encodedLengths.atIndex(0);
      _table.name = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

      _start = _end;
      _end += _encodedLengths.atIndex(1);
      _table.color = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(address owner, string memory name, string memory color) internal view returns (bytes memory) {
    uint40[] memory _counters = new uint40[](2);
    _counters[0] = uint40(bytes(name).length);
    _counters[1] = uint40(bytes(color).length);
    PackedCounter _encodedLengths = PackedCounterLib.pack(_counters);

    return abi.encodePacked(owner, _encodedLengths.unwrap(), bytes((name)), bytes((color)));
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple() internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](0);
  }

  /* Delete all data for given keys */
  function deleteRecord() internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.deleteRecord(_tableId, _keyTuple);
  }
}
