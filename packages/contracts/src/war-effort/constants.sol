// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_NAMESPACE } from "@latticexyz/world/src/worldResourceTypes.sol";

bytes14 constant WAR_EFFORT_DEPLOYMENT_NAMESPACE = "warEffortTest";

bytes16 constant WAR_EFFORT_MODULE_NAME = "WarEffort";
bytes14 constant WAR_EFFORT_MODULE_NAMESPACE = "WarEffort";

bytes16 constant WAR_EFFORT_TABLE_NAME = "WarEffortTable";

uint8 constant OBJECT = 1;
uint8 constant CLASS = 2;

uint256 constant WAR_EFFORT_CLASS_ID = 4567;