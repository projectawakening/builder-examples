// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";
import { Utils as SmartGateUtils } from "@eveworld/world/src/modules/smart-gate/Utils.sol";
import { SmartGateLib } from "@eveworld/world/src/modules/smart-gate/SmartGateLib.sol";
import { SmartGateSystem } from "../src/systems/SmartGateSystem.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { AccessListDefinitions, AccessListDefinitionsData } from "../src/codegen/tables/AccessListDefinitions.sol";

contract CustomScript is Script {
  using SmartGateUtils for bytes14;
  using SmartGateLib for SmartGateLib.World;

  SmartGateLib.World smartGate;

  function run(address worldAddress) external {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    smartGate = SmartGateLib.World({ iface: IBaseWorld(worldAddress), namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE });

    uint256 smartGateId = vm.envUint("SOURCE_GATE_ID");
    uint256 destinationSmartGateId = vm.envUint("DESTINATION_GATE_ID");

    ResourceId systemId = Utils.smartGateSystemId();
/*
    // Whitelist
    bytes memory whitelistResult = world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.createAccessList,
        ("test_whitelist", true)
      )
    );
    bytes32 testWhitelistId = abi.decode(whitelistResult, (bytes32));

    console.log("Whitelist ID");
    console.logBytes32(testWhitelistId);

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addCharIdToAccessList,
        (15350231617936866033800429068055185838535504456062486099387944243245585217822, testWhitelistId)
      )
    );

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addCharIdToAccessList,
        (89402346651494321089758371369127499014342777729463889286922264122588247715106, testWhitelistId)
      )
    );

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addAccessListToGate,
        (smartGateId, testWhitelistId)
      )
    );

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addAccessListToGate,
        (destinationSmartGateId, testWhitelistId)
      )
    );*/
/*
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.removeCharIdFromAccessList,
        (89402346651494321089758371369127499014342777729463889286922264122588247715106, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
      )
    );
/*
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addCharIdToAccessList,
        (89402346651494321089758371369127499014342777729463889286922264122588247715106, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
      )
    );
  */  
/*
    world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.addAccessListToGate,
          (32179281776684766558279035710037986083593888863971348835965252474641021232776, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
        )
    );
    world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.addAccessListToGate,
          (6358981912015896955908446534304748195580309633851788354880944165111665942753, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
        )
    );
    world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.addAccessListToGate,
          (107844579556855183876534186559837278792617566574109534592594168375056483199895, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
        )
    );
    world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.addAccessListToGate,
          (77048166476306157565930564203576890306688370305577862844323029921179854589754, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
        )
    );
    world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.addAccessListToGate,
          (2337075224437709090791666583538149241258979859777437752070047185393076541777, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
        )
    );
    world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.addAccessListToGate,
          (58341886992899723008973779086572978934991840070720808210697177330106510330386, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
        )
    );
    world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.addAccessListToGate,
          (1785768646266629660314733355204635267703070393894786587333623113389225666321, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
        )
    );
    world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.addAccessListToGate,
          (57191870601182717127742511331954449487338102626138003794053809838940567174655, 0xb9b13f998f22cc82e4519925f128578d6870155fe163bc4c666964e475773586)
        )
    );



*/
    vm.stopBroadcast();
  }
}
