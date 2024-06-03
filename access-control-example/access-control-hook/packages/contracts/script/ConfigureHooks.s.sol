// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { ResourceId, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
// @eveworld/smart-object-framework autogen interfaces
import { IHookCore } from "@eveworld/smart-object-framework/src/codegen/world/IHookCore.sol";
import { HookType } from "@eveworld/smart-object-framework/src/types.sol";
// @eveworld/world autogen interface
import { ISmartStorageUnit } from "@eveworld/world/src/codegen/world/ISmartStorageUnit.sol";
// @eveworld/world types
import { EntityRecordData, WorldPosition, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { SmartObjectData } from "@eveworld/world/src/modules/smart-deployable/types.sol";
// local autogen interface (includes all interface from this deployed example and Word basic interface)
import { IWorld } from "../src/codegen/world/IWorld.sol";
// standard interfaces
import { IAccessControlHook } from "../src/interfaces/IAccessControlHook.sol";
import { IForwarderSystem } from "../src/interfaces/IForwarderSystem.sol";
import { IPermissionedSystem } from "../src/interfaces/IPermissionedSystem.sol";
// import { IExtraForwarderSystem } from "../src/interfaces/IExtraForwarderSystem.sol";
// import { IExtraPermissionedSystem } from "../src/interfaces/IExtraPermissionedSystem.sol";


contract ConfigureHooks is Script {
  
  using WorldResourceIdInstance for ResourceId;
  function run(address worldAddress) external {
    StoreSwitch.setStoreAddress(worldAddress);
    bytes32 accessControlBytes32 = vm.envBytes32("ACCESS_CONTROL_SYSTEM_ID");
    bytes32 permissionedBytes32 = vm.envBytes32("PERMISSIONED_SYSTEM_ID");
    bytes32 forwarderBytes32 = vm.envBytes32("FORWARDER_SYSTEM_ID");
    // bytes32 extraPermissionedBytes32 = vm.envBytes32("EXTRA_PERMISSIONED_SYSTEM_ID");
    // bytes32 extraForwarderBytes32 = vm.envBytes32("EXTRA_FORWARDER_SYSTEM_ID");
    ResourceId accessControlSystemId = ResourceId.wrap(accessControlBytes32);
    ResourceId permissionedSystemId = ResourceId.wrap(permissionedBytes32);
    ResourceId forwarderSystemId = ResourceId.wrap(forwarderBytes32);
    // ResourceId extraPermissionedSystemId = ResourceId.wrap(extraPermissionedBytes32);
    // ResourceId extraForwarderSystemId = ResourceId.wrap(extraForwarderBytes32);

    uint256 ssuId = vm.envUint("SSU_ID");
    // NOTE: this private key is set to the foundry anvil default, and if you want to deploy live you must replace it with your live network account private key
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);
    {
      // Load the private key from the `PRIVATE_KEY` environment variable (in .env)

      string memory mnemonic = "test test test test test test test test test test test junk"; // default anvil mnemonic
      uint256 alicePK = vm.deriveKey(mnemonic, 1);
      address alice = vm.addr(alicePK);

      EntityRecordData memory entityRecord = EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 });
      SmartObjectData memory soData = SmartObjectData({ owner: alice, tokenURI: "test" });
      Coord memory coords = Coord({ x: 1, y: 1, z: 1 });
      WorldPosition memory position = WorldPosition({ solarSystemId: 1, position: coords });

      // create SSU (alice is SSU owner)
      ISmartStorageUnit(worldAddress).eveworld__createAndAnchorSmartStorageUnit(
        ssuId,
        entityRecord,
        soData,
        position,
        1e18, // fuelUnitVolume,
        1, // fuelConsumptionPerMinute,
        1000000 * 1e18, //fuelMaxCapacity,
        100000000, // storageCapacity,
        100000000000 // ephemeralStorageCapacity
      );
    }
    // REGISTER HOOKS in the SOF
    // hookIds are deterministically generated, uint256 hookId = uint256(keccak256(abi.encodePacked(systemId, functionId)));
    IHookCore(worldAddress).eveworld__registerHook(accessControlSystemId, IAccessControlHook.onlyAdminRoleTxOrigin.selector);
    uint256 onlyAdminHookId = uint256(keccak256(abi.encodePacked(accessControlSystemId, IAccessControlHook.onlyAdminRoleTxOrigin.selector)));
    
    IHookCore(worldAddress).eveworld__registerHook(accessControlSystemId, IAccessControlHook.onlyOwnerInitialMsgSender.selector);
    uint256 onlyOwnerHookId = uint256(keccak256(abi.encodePacked(accessControlSystemId, IAccessControlHook.onlyOwnerInitialMsgSender.selector)));
    
    IHookCore(worldAddress).eveworld__registerHook(accessControlSystemId, IAccessControlHook.onlyApprovedRoleForwardedMsgSender.selector);
    uint256 onlyApprovedHookId = uint256(keccak256(abi.encodePacked(accessControlSystemId, IAccessControlHook.onlyApprovedRoleForwardedMsgSender.selector)));

    IHookCore(worldAddress).eveworld__registerHook(accessControlSystemId, IAccessControlHook.storeSystemAddress.selector);
    uint256 storeSystemHookId = uint256(keccak256(abi.encodePacked(accessControlSystemId, IAccessControlHook.storeSystemAddress.selector)));

    // CONFIGURE HOOKS in the SOF
    IHookCore(worldAddress).eveworld__addHook(storeSystemHookId, HookType.BEFORE, forwarderSystemId, IForwarderSystem.callOnlyApprovedForwarderPermissioned.selector);
    // IHookCore(worldAddress).eveworld__addHook(storeSystemHookId, HookType.BEFORE, extraForwarderSystemId, IExtraForwarderSystem.callOnlyApprovedForwarderPermissioned.selector);
    IHookCore(worldAddress).eveworld__addHook(onlyAdminHookId, HookType.BEFORE, permissionedSystemId, IPermissionedSystem.onlyAdminPermissioned.selector);
    IHookCore(worldAddress).eveworld__addHook(onlyOwnerHookId, HookType.BEFORE, permissionedSystemId, IPermissionedSystem.onlyOwnerPermissioned.selector);
    IHookCore(worldAddress).eveworld__addHook(onlyApprovedHookId, HookType.BEFORE, permissionedSystemId, IPermissionedSystem.onlyApprovedForwarderPermissioned.selector);
    // IHookCore(worldAddress).eveworld__addHook(onlyAdminHookId, HookType.BEFORE, extraPermissionedSystemId, IExtraPermissionedSystem.onlyAdminPermissioned.selector);
    // IHookCore(worldAddress).eveworld__addHook(onlyOwnerHookId, HookType.BEFORE, extraPermissionedSystemId, IExtraPermissionedSystem.onlyOwnerPermissioned.selector);
    // IHookCore(worldAddress).eveworld__addHook(onlyApprovedHookId, HookType.BEFORE, extraPermissionedSystemId, IExtraPermissionedSystem.onlyApprovedForwarderPermissioned.selector);

    // ASSOCIATE HOOKS with our dummy SSU ID in SOF
    IHookCore(worldAddress).eveworld__associateHook(ssuId, storeSystemHookId);
    IHookCore(worldAddress).eveworld__associateHook(ssuId, onlyAdminHookId);
    IHookCore(worldAddress).eveworld__associateHook(ssuId, onlyOwnerHookId);
    IHookCore(worldAddress).eveworld__associateHook(ssuId, onlyApprovedHookId);

    vm.stopBroadcast();
  }
}