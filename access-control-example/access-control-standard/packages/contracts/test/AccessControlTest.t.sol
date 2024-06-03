// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";

// MUD World and world helpers imports
import { World } from "@latticexyz/world/src/World.sol";
import { IWorldErrors } from "@latticexyz/world/src/IWorldErrors.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import { IModule } from "@latticexyz/world/src/IModule.sol";
import { RESOURCE_NAMESPACE, RESOURCE_SYSTEM, RESOURCE_TABLE } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceAccess } from "@latticexyz/world/src/codegen/tables/ResourceAccess.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import { PuppetModule } from "@latticexyz/world-modules/src/modules/puppet/PuppetModule.sol";

import { createCoreModule } from "./CreateCoreModule.sol";

// SOF imports
import { SmartObjectFrameworkModule } from "@eveworld/smart-object-framework/src/SmartObjectFrameworkModule.sol";
import { EntityCore } from "@eveworld/smart-object-framework/src/systems/core/EntityCore.sol";
import { ModuleCore } from "@eveworld/smart-object-framework/src/systems/core/ModuleCore.sol";
import { HookCore } from "@eveworld/smart-object-framework/src/systems/core/HookCore.sol";
import { HookType } from "@eveworld/smart-object-framework/src/types.sol";
import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";

// EVE World imports
// SD & dependency imports
import { registerERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/registerERC721.sol";
import { IERC721Mintable } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721Mintable.sol";
import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";
import { StaticDataGlobalTableData } from "@eveworld/world/src/codegen/tables/StaticDataGlobalTable.sol";
import { EntityRecordModule } from "@eveworld/world/src/modules/entity-record/EntityRecordModule.sol";
import { StaticDataModule } from "@eveworld/world/src/modules/static-data/StaticDataModule.sol";
import { LocationModule } from "@eveworld/world/src/modules/location/LocationModule.sol";
import { SmartDeployable } from "@eveworld/world/src/modules/smart-deployable/systems/SmartDeployable.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";

//SSU & dependency imports
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";
import { InventoryModule } from "@eveworld/world/src/modules/inventory/InventoryModule.sol";
import { Inventory } from "@eveworld/world/src/modules/inventory/systems/Inventory.sol";
import { EphemeralInventory } from "@eveworld/world/src/modules/inventory/systems/EphemeralInventory.sol";
import { InventoryInteract } from "@eveworld/world/src/modules/inventory/systems/InventoryInteract.sol";
import { SmartStorageUnitModule } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitModule.sol";
import { EntityRecordData, SmartObjectData, WorldPosition, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";

import { GlobalDeployableState, DeployableState, DeployableTokenTable, DeployableFuelBalance } from "@eveworld/world/src/codegen/index.sol";

// AccessControl and test dependency imports
import { IAccessControlErrors } from "../src/interfaces/IAccessControlErrors.sol";
import { IAccessControl } from "../src/interfaces/IAccessControl.sol";
import { IForwarderSystem } from "../src/interfaces/IForwarderSystem.sol";
import { IPermissionedSystem } from "../src/interfaces/IPermissionedSystem.sol";
// import { AccessControl } from "../src/systems/AccessControl.sol";
import { ForwarderSystem } from "../src/systems/ForwarderSystem.sol";
import { PermissionedSystem } from "../src/systems/PermissionedSystem.sol";

import { AccessRole, AccessRoleTableId } from "../src/codegen/index.sol";

import { ADMIN, APPROVED, EVE_WORLD_NAMESPACE, NAMESPACE, ACCESS_ROLE_TABLE_NAME, ACCESS_CONTROL_SYSTEM_NAME } from "../src/constants.sol";


contract AccessControlTest is Test {
  using WorldResourceIdInstance for ResourceId;
  using SmartObjectLib for SmartObjectLib.World;
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartDeployableUtils for bytes14;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  
  // account variables
  string mnemonic = "test test test test test test test test test test test junk"; // default anvil mnemonic
  uint256 deployerPK = vm.deriveKey(mnemonic, 0);
  uint256 alicePK = vm.deriveKey(mnemonic, 1);
  uint256 bobPK = vm.deriveKey(mnemonic, 2);

  address deployer = vm.addr(deployerPK);
  address alice = vm.addr(alicePK);
  address bob = vm.addr(bobPK);
  
  // World variables
  IBaseWorld world;

  // SOF variables
  SmartObjectLib.World SOFInterface;
  uint8 constant OBJECT = 1;
  string constant OBJECT_STRING = "OBJECT";
  uint8 constant CLASS = 2;
  string constant CLASS_STRING = "CLASS";
  uint256 sdClassId = uint256(keccak256("SD_CLASS"));
  uint256 ssuClassId = uint256(keccak256("SSU_CLASS"));

  // Deployable variables
  SmartDeployableLib.World SDInterface;
  bytes14 constant ERC721_DEPLOYABLE_NAMESPACE = "SDERC721Token";
  IERC721Mintable erc721DeployableToken;

  // SSU variables
  SmartStorageUnitLib.World SSUInterface;
  ResourceId SMART_STORAGE_UNIT_SYSTEM_ID = WorldResourceIdLib.encode({
    typeId: RESOURCE_SYSTEM,
    namespace: EVE_WORLD_NAMESPACE,
    name: bytes16("SmartStorageUnit")
  });
  uint256 ssuId = uint256(keccak256("SSU_DUMMY"));

  // custom module variables
  ResourceId NAMESPACE_ID = ResourceId.wrap(bytes32(abi.encodePacked(RESOURCE_NAMESPACE, NAMESPACE)));
  ResourceId FORWARDER_SYSTEM_ID = WorldResourceIdLib.encode({
    typeId: RESOURCE_SYSTEM,
    namespace: NAMESPACE,
    name: bytes16("ForwarderSystem")
  });
  ResourceId PERMISSIONED_SYSTEM_ID = WorldResourceIdLib.encode({
    typeId: RESOURCE_SYSTEM,
    namespace: NAMESPACE,
    name: bytes16("PermissionedSyst")
  });
  ResourceId ACCESS_CONTROL_SYSTEM_ID = WorldResourceIdLib.encode({
    typeId: RESOURCE_SYSTEM,
    namespace: NAMESPACE,
    name: ACCESS_CONTROL_SYSTEM_NAME
  });
  ForwarderSystem forwarder;

  function setUp() public {
    // START: EVE World deployment and module registration

    // World init
    world = IBaseWorld(address(new World()));
    world.initialize(createCoreModule());
    StoreSwitch.setStoreAddress(address(world));

    // SOF deployment
    world.installModule(
      new SmartObjectFrameworkModule(),
      abi.encode(EVE_WORLD_NAMESPACE, address(new EntityCore()), address(new HookCore()), address(new ModuleCore()))
    );

    // SD dependencies deployment
    _sdDependenciesDeploy(world);
  
    // SD Table and System registry and deployment
    GlobalDeployableState.register(EVE_WORLD_NAMESPACE.globalStateTableId());
    DeployableState.register(EVE_WORLD_NAMESPACE.deployableStateTableId());
    DeployableTokenTable.register(EVE_WORLD_NAMESPACE.deployableTokenTableId());
    DeployableFuelBalance.register(EVE_WORLD_NAMESPACE.deployableFuelBalanceTableId());
    SmartDeployable deployable = new SmartDeployable();
    world.registerSystem(EVE_WORLD_NAMESPACE.smartDeployableSystemId(), System(deployable), true);
 
    // SSU dependencies deployment
    _ssuDependenciesDeploy(world);

    // SSU deployment
    SmartStorageUnitModule SSUMod = new SmartStorageUnitModule();
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE)) == address(this))
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE), address(SSUMod));
    world.installModule(SSUMod, abi.encode(EVE_WORLD_NAMESPACE));
    
    // END: EVE World deployment and registration
    // START: our custom module deployment and registration

    // REGISTER our namespace into the EVE World
    world.registerNamespace(NAMESPACE_ID);

    // Forwarder deploy, then System and functions EVE World register
    forwarder = new ForwarderSystem();
    world.registerSystem(FORWARDER_SYSTEM_ID, System(forwarder), true);
    world.registerFunctionSelector(FORWARDER_SYSTEM_ID, "callOnlyApprovedForwarderPermissioned(uint256)");

    // REGISTER AccessRole Table before inherited AccessControl (because AccessControl uses it) 
    AccessRole.register();

    // Permissioned deploy, then System and functions EVE World register
    PermissionedSystem permissioned = new PermissionedSystem();
    world.registerSystem(PERMISSIONED_SYSTEM_ID, System(permissioned), true);
    world.registerFunctionSelector(PERMISSIONED_SYSTEM_ID, "onlyAdminPermissioned(uint256)");
    world.registerFunctionSelector(PERMISSIONED_SYSTEM_ID, "onlyOwnerPermissioned(uint256)");
    world.registerFunctionSelector(PERMISSIONED_SYSTEM_ID, "onlyApprovedForwarderPermissioned(uint256)");
    world.registerFunctionSelector(PERMISSIONED_SYSTEM_ID, "setAccessListByRole(bytes32,address[])");

    // grant the deployer MUD resource access to AccessRole Table, this allows them to set access lists for roles
    world.grantAccess(AccessRoleTableId, deployer);

    // END: custom module deployment and registration
    // START: EVE World module configuration

    // initialize EVE World module interfaces
    SOFInterface = SmartObjectLib.World(world, EVE_WORLD_NAMESPACE);
    SDInterface = SmartDeployableLib.World(world, EVE_WORLD_NAMESPACE);
    SSUInterface = SmartStorageUnitLib.World(world, EVE_WORLD_NAMESPACE);

    // SOF setup
    // create class and object types
    SOFInterface.registerEntityType(CLASS, bytes32(bytes(CLASS_STRING)));
    SOFInterface.registerEntityType(OBJECT, bytes32(bytes(OBJECT_STRING)));
    // allow object to class tagging
    SOFInterface.registerEntityTypeAssociation(OBJECT, CLASS);

    // register the SD CLASS ID as a CLASS entity
    SOFInterface.registerEntity(sdClassId, CLASS);
    // register the SSU CLASS ID as a CLASS entity
    SOFInterface.registerEntity(ssuClassId, CLASS);

    // SD setup
    // register an ERC721 for SDs
    SDInterface.registerDeployableToken(address(erc721DeployableToken));
    // active SDs
    SDInterface.globalResume();

    // SSU setup
    // set ssu classId in the config
    SSUInterface.setSSUClassId(ssuClassId);

    // create a test SSU Object (internally registers SSU ID as Object and tags it to SSU CLASS ID)
    SSUInterface.createAndAnchorSmartStorageUnit(
      ssuId,
      EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 }),
      SmartObjectData({ owner: alice, tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionPerMinute,
      1000000 * 1e18, //fuelMaxCapacity,
      100000000, // storageCapacity,
      100000000000 // ephemeralStorageCapacity
    );

    // END: EVE World module configuration
  }

  function testRoleSetPass() public {
    address[] memory adminAccessList = new address[](1);
    adminAccessList[0] = bob;
    address[] memory approvedAccessList = new address[](1);
    approvedAccessList[0] = address(forwarder);

    vm.startPrank(deployer);
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IAccessControl.setAccessListByRole, (ADMIN, adminAccessList)));
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IAccessControl.setAccessListByRole, (APPROVED, approvedAccessList)));
    vm.stopPrank();
    address[] memory storedAdminAccessList = AccessRole.get(ADMIN);
    assertEq(storedAdminAccessList[0], bob);
    address[] memory storedApprovedAccessList = AccessRole.get(APPROVED);
    assertEq(storedApprovedAccessList[0], address(forwarder));
  }

  function testRoleSetFailByCaller() public {
    address[] memory adminAccessList = new address[](1);
    adminAccessList[0] = alice;

    vm.prank(alice);
    vm.expectRevert();
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IAccessControl.setAccessListByRole, (ADMIN, adminAccessList)));
  }

  function testRoleSetFailByRoleId() public {
    address[] memory ownerAccessList = new address[](1);
    ownerAccessList[0] = alice;
    vm.prank(deployer);
    vm.expectRevert();
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IAccessControl.setAccessListByRole, (bytes32("OWNER"), ownerAccessList)));
  }

  function testOnlyAdminPass() public {
    address[] memory adminAccessList = new address[](1);
    adminAccessList[0] = bob;
    vm.startPrank(deployer, bob);
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IAccessControl.setAccessListByRole, (ADMIN, adminAccessList)));
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IPermissionedSystem.onlyAdminPermissioned, (ssuId)));
    vm.stopPrank();
  }

  function testOnlyAdminRejection() public {
    address[] memory adminAccessList = new address[](1);
    adminAccessList[0] = bob;
    vm.startPrank(deployer, alice);
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IAccessControl.setAccessListByRole, (ADMIN, adminAccessList)));
    vm.expectRevert(
      abi.encodeWithSelector(IAccessControlErrors.AccessControl_NoPermission.selector, alice, bytes32(ADMIN))
    );
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IPermissionedSystem.onlyAdminPermissioned, (ssuId)));
    vm.stopPrank();
  }

  function testOnlyOwnerPass() public {
    vm.startPrank(alice, deployer);
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IPermissionedSystem.onlyOwnerPermissioned, (ssuId)));
    vm.stopPrank();
  }

  function testOnlyOwnerRejection() public {
    vm.startPrank(bob, deployer);
        vm.expectRevert(
      abi.encodeWithSelector(IAccessControlErrors.AccessControl_NoPermission.selector, bob, bytes32("OWNER"))
    );
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IPermissionedSystem.onlyOwnerPermissioned, (ssuId)));
    vm.stopPrank();
  }

  function testOnlyApprovedForwarderPass() public {
    address[] memory approvedAccessList = new address[](1);
    approvedAccessList[0] = address(forwarder);
    vm.startPrank(deployer);
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IAccessControl.setAccessListByRole, (APPROVED, approvedAccessList)));
    world.call(FORWARDER_SYSTEM_ID, abi.encodeCall(IForwarderSystem.callOnlyApprovedForwarderPermissioned, (ssuId)));
    vm.stopPrank();
  }

  function testOnlyApprovedForwarderRejection() public {
    address[] memory approvedAccessList = new address[](1);
    approvedAccessList[0] = address(forwarder);
    vm.startPrank(deployer);
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IAccessControl.setAccessListByRole, (APPROVED, approvedAccessList)));
    vm.expectRevert(
      abi.encodeWithSelector(IAccessControlErrors.AccessControl_NoPermission.selector, deployer, APPROVED)
    );
    world.call(PERMISSIONED_SYSTEM_ID, abi.encodeCall(IPermissionedSystem.onlyApprovedForwarderPermissioned, (ssuId)));
    vm.stopPrank();
  }

  function _sdDependenciesDeploy(IBaseWorld world_) internal {
    // SD StaticData Module deployment
    StaticDataModule StaticDataMod = new StaticDataModule();
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE)) == address(this))
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE), address(StaticDataMod));
    world_.installModule(
      StaticDataMod,
      abi.encode(EVE_WORLD_NAMESPACE)
    );

    // SD EntityRecord Module deployment
    EntityRecordModule EntityRecordMod = new EntityRecordModule();
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE)) == address(this))
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE), address(EntityRecordMod));
    world_.installModule(
      EntityRecordMod,
      abi.encode(EVE_WORLD_NAMESPACE)
    );

    // SD Location module deployment
    LocationModule LocMod = new LocationModule();
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE)) == address(this))
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE), address(LocMod));
    world_.installModule(
      LocMod,
      abi.encode(EVE_WORLD_NAMESPACE)
    );

    // SD ERC721 deployment
    PuppetModule Erc721Mod = new PuppetModule();
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(ERC721_DEPLOYABLE_NAMESPACE)) == address(this))
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(ERC721_DEPLOYABLE_NAMESPACE), address(Erc721Mod));
    world_.installModule(
      Erc721Mod,
      abi.encode(ERC721_DEPLOYABLE_NAMESPACE)
    );

    erc721DeployableToken = registerERC721(
      world_,
      ERC721_DEPLOYABLE_NAMESPACE,
      StaticDataGlobalTableData({ name: "SmartDeployable", symbol: "SD", baseURI: "" })
    );
  }

  function _ssuDependenciesDeploy(IBaseWorld world_) internal {
    // SSU Inventory deployment
    InventoryModule InvMod = new InventoryModule();
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE)) == address(this))
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(EVE_WORLD_NAMESPACE), address(InvMod));
    world_.installModule(
      InvMod,
      abi.encode(
        EVE_WORLD_NAMESPACE,
        address(new Inventory()),
        address(new EphemeralInventory()),
        address(new InventoryInteract())
      )
    );
  }
}