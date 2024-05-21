// SPDX-License-Identifier: MIT
// cherry-picked from staged changes for next-17 release, unavailable in .16
pragma solidity >=0.8.21;

import { AccessManagementSystem } from "@latticexyz/world/src/modules/init/implementations/AccessManagementSystem.sol";
import { BalanceTransferSystem } from "@latticexyz/world/src/modules/init/implementations/BalanceTransferSystem.sol";
import { BatchCallSystem } from "@latticexyz/world/src/modules/init/implementations/BatchCallSystem.sol";

import { InitModule } from "@latticexyz/world/src/modules/init/InitModule.sol";
import { RegistrationSystem } from "@latticexyz/world/src/modules/init/RegistrationSystem.sol";

function createCoreModule() returns (InitModule) {
  return
    new InitModule(
      new AccessManagementSystem(),
      new BalanceTransferSystem(),
      new BatchCallSystem(),
      new RegistrationSystem()
    );
}
