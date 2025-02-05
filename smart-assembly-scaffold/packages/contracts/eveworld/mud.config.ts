/** This is the same mudconfig file as is exported from the `@eveworld/world` package */

import { defineWorld } from "@latticexyz/world";
import constants from "./constants.json";

export default defineWorld({
  namespace: constants.namespace.FRONTIER_WORLD_DEPLOYMENT,
  deploy: {
    customWorld: {
      sourcePath: "src/WorldWithEntryContext.sol",
      name: "WorldWithEntryContext",
    },
  },
  excludeSystems: ["ERC721System", "AccessModified"],
  systems: {
    AccessSystem: {
      name: constants.systemName.ACCESS,
      openAccess: true,
    },
    SmartCharacterSystem: {
      name: constants.systemName.SMART_CHARACTER,
      openAccess: true,
    },
    SmartStorageUnitSystem: {
      name: constants.systemName.SMART_STORAGE_UNIT,
      openAccess: true,
    },
    StaticDataSystem: {
      name: constants.systemName.STATIC_DATA,
      openAccess: true,
    },
    EntityRecordSystem: {
      name: constants.systemName.ENTITY_RECORD,
      openAccess: true,
    },
    LocationSystem: {
      name: constants.systemName.LOCATION,
      openAccess: true,
    },
    SmartDeployableSystem: {
      name: constants.systemName.SMART_DEPLOYABLE,
      openAccess: true,
    },
    InventorySystem: {
      name: constants.systemName.INVENTORY,
      openAccess: true,
    },
    EphemeralInventorySystem: {
      name: constants.systemName.EPHEMERAL_INVENTORY,
      openAccess: true,
    },
    InventoryInteractSystem: {
      name: constants.systemName.INVENTORY_INTERACT,
      openAccess: true,
    },
    SmartTurretSystem: {
      name: constants.systemName.SMART_TURRET,
      openAccess: true,
    },
    SmartGateSystem: {
      name: constants.systemName.SMART_GATE,
      openAccess: true,
    },
    KillMailSystem: {
      name: constants.systemName.KILL_MAIL,
      openAccess: true,
    },
  },
  enums: {
    State: ["NULL", "UNANCHORED", "ANCHORED", "ONLINE", "DESTROYED"],
    SmartAssemblyType: ["SMART_STORAGE_UNIT", "SMART_TURRET", "SMART_GATE"],
    KillMailLossType: ["SHIP", "POD"],
  },
  userTypes: {
    ResourceId: {
      type: "bytes32",
      filePath: "@latticexyz/store/src/ResourceId.sol",
    },
  },
  tables: {
    /**
     * Simple Access Control - for enforcing the most basic access rules
     */
    AccessEnforcement: {
      schema: {
        target: "bytes32",
        isEnforced: "bool",
      },
      key: ["target"],
    },
    AccessEnforcePerObject: {
      schema: {
        smartObjectId: "uint256",
        target: "bytes32",
        isEnforced: "bool",
      },
      key: ["smartObjectId", "target"],
    },
    AccessRole: {
      schema: {
        roleId: "bytes32",
        accounts: "address[]",
      },
      key: ["roleId"],
    },
    AccessRolePerObject: {
      schema: {
        smartObjectId: "uint256",
        roleId: "bytes32",
        accounts: "address[]",
      },
      key: ["smartObjectId", "roleId"],
    },
    AccessRolePerSys: {
      schema: {
        systemId: "ResourceId",
        roleId: "bytes32",
        accounts: "address[]",
      },
      key: ["systemId", "roleId"],
    },

    /**
     * ClassId Configuration - for setting a list of classIds to tag an object with during creation
     */
    ClassConfig: {
      schema: {
        systemId: "ResourceId",
        classId: "uint256",
      },
      key: ["systemId"],
    },

    /**********************
     * STATIC DATA MODULE *
     **********************/

    /**
     * Used to store the IPFS CID of a smart object
     */
    StaticDataTable: {
      schema: {
        entityId: "uint256",
        cid: "string",
      },
      key: ["entityId"],
    },

    /**
     * Used to store the DNS which serves the IPFS gateway
     */
    StaticDataGlobalTable: {
      schema: {
        systemId: "ResourceId",
        name: "string",
        symbol: "string",
        baseURI: "string",
      },
      key: ["systemId"],
    },

    /**********************
     * STATIC DATA MODULE *
     **********************/

    /**
     * Used to store the metadata of a in-game entity
     */
    EntityRecordTable: {
      schema: {
        entityId: "uint256",
        itemId: "uint256",
        typeId: "uint256",
        volume: "uint256",
        recordExists: "bool",
      },
      key: ["entityId"],
    },
    EntityRecordOffchainTable: {
      schema: {
        entityId: "uint256",
        name: "string",
        dappURL: "string",
        description: "string",
      },
      key: ["entityId"],
    },

    /**************************
     * SMART CHARACTER MODULE *
     **************************/

    /**
     * Maps the in-game character ID to on-chain EOA address
     */
    CharactersTable: {
      schema: {
        characterId: "uint256",
        characterAddress: "address",
        corpId: "uint256",
        createdAt: "uint256",
      },
      key: ["characterId"],
    },
    CharactersByAddressTable: {
      schema: {
        characterAddress: "address",
        characterId: "uint256",
      },
      key: ["characterAddress"],
    },
    CharactersConstantsTable: {
      schema: {
        erc721Address: "address",
      },
      key: [],
    },

    /*******************
     * LOCATION MODULE *
     *******************/

    /**
     * Used to store the location of a in-game entity in the solar system
     */
    LocationTable: {
      schema: {
        smartObjectId: "uint256",
        solarSystemId: "uint256",
        x: "uint256",
        y: "uint256",
        z: "uint256",
      },
      key: ["smartObjectId"],
    },

    /***************************
     * SMART ASSEMBLY MODULE *
     ***************************/
    SmartAssemblyTable: {
      schema: {
        smartObjectId: "uint256",
        smartAssemblyType: "SmartAssemblyType",
      },
      key: ["smartObjectId"],
    },

    /***************************
     * SMART DEPLOYABLE MODULE *
     ***************************/
    GlobalDeployableState: {
      schema: {
        updatedBlockNumber: "uint256",
        isPaused: "bool",
        lastGlobalOffline: "uint256",
        lastGlobalOnline: "uint256",
      },
      key: [],
    },
    /**
     * Used to store the current state of a deployable
     */
    DeployableState: {
      schema: {
        smartObjectId: "uint256",
        createdAt: "uint256",
        previousState: "State",
        currentState: "State",
        isValid: "bool",
        anchoredAt: "uint256",
        updatedBlockNumber: "uint256",
        updatedBlockTime: "uint256",
      },
      key: ["smartObjectId"],
    },
    /**
     * Used to store the fuel balance of a deployable
     */
    DeployableFuelBalance: {
      schema: {
        smartObjectId: "uint256",
        fuelUnitVolume: "uint256",
        fuelConsumptionPerMinute: "uint256",
        fuelMaxCapacity: "uint256",
        fuelAmount: "uint256",
        lastUpdatedAt: "uint256",
      },
      key: ["smartObjectId"],
    },
    /**
     * Used to store the deployable details of a in-game entity
     */
    DeployableTokenTable: {
      schema: {
        erc721Address: "address",
      },
      key: [],
    },

    //INVENTORY MODULE
    /**
     * Used to store the inventory details of a in-game smart storage unit
     */
    // InventoryTable: {
    //   schema: {
    //     smartObjectId: "uint256",
    //     capacity: "uint256",
    //     usedCapacity: "uint256",
    //     items: "uint256[]",
    //   },
    //   key: ["smartObjectId"],
    // },
    /**
     * Used to store the inventory items of a in-game smart storage unit
     */
    InventoryItemTable: {
      schema: {
        smartObjectId: "uint256",
        inventoryItemId: "uint256",
        quantity: "uint256",
        index: "uint256",
        stateUpdate: "uint256",
      },
      key: ["smartObjectId", "inventoryItemId"],
    },
    //EPHEMERAL INVENTORY MODULE
    /**
     * Used to Store Ephemeral Capacity by smartObjectId
     */
    EphemeralInvCapacityTable: {
      schema: {
        smartObjectId: "uint256",
        capacity: "uint256",
      },
      key: ["smartObjectId"],
    },
    /**
     * Used to store the ephemeral inventory details of a in-game smart storage unit
     * Each user has a separate ephemeral inventory capacity
     */
    EphemeralInvTable: {
      schema: {
        smartObjectId: "uint256",
        ephemeralInvOwner: "address",
        usedCapacity: "uint256",
        items: "uint256[]",
      },
      key: ["smartObjectId", "ephemeralInvOwner"],
    },
    /**
     * Used to store the ephemeral inventory items details of a in-game smart storage unit
     */
    EphemeralInvItemTable: {
      schema: {
        smartObjectId: "uint256",
        inventoryItemId: "uint256",
        ephemeralInvOwner: "address",
        quantity: "uint256",
        index: "uint256",
        stateUpdate: "uint256",
      },
      key: ["smartObjectId", "inventoryItemId", "ephemeralInvOwner"],
    },
    /**
     * Used to store the transfer details when a item is exchanged
     */
    ItemTransferOffchainTable: {
      schema: {
        smartObjectId: "uint256",
        inventoryItemId: "uint256",
        previousOwner: "address",
        currentOwner: "address",
        quantity: "uint256",
        updatedAt: "uint256",
      },
      key: ["smartObjectId", "inventoryItemId"],
    },

    /*************************
     * SMART TURRET MODULE *
     *************************/
    SmartTurretConfigTable: {
      schema: {
        smartObjectId: "uint256",
        systemId: "ResourceId",
      },
      key: ["smartObjectId"],
    },

    /*************************
     * SMART GATE MODULE *
     *************************/
    SmartGateConfigTable: {
      schema: {
        smartObjectId: "uint256",
        systemId: "ResourceId",
        maxDistance: "uint256",
      },
      key: ["smartObjectId"],
    },

    SmartGateLinkTable: {
      schema: {
        sourceGateId: "uint256",
        destinationGateId: "uint256",
        isLinked: "bool",
      },
      key: ["sourceGateId"],
    },

    /************************
     * ERC721 PUPPET MODULE *
     ************************/

    Balances: {
      schema: {
        account: "address",
        value: "uint256",
      },
      key: ["account"],
      codegen: {
        tableIdArgument: true,
      },
      deploy: {
        disabled: true,
      },
    },

    TokenURI: {
      schema: {
        tokenId: "uint256",
        tokenURI: "string",
      },
      key: ["tokenId"],
      codegen: {
        tableIdArgument: true,
      },
      deploy: {
        disabled: true,
      },
    },

    Owners: {
      schema: {
        tokenId: "uint256",
        owner: "address",
      },
      key: ["tokenId"],
      codegen: {
        tableIdArgument: true,
      },
      deploy: {
        disabled: true,
      },
    },

    ERC721Registry: {
      schema: {
        namespaceId: "ResourceId",
        tokenAddress: "address",
      },
      key: ["namespaceId"],
      codegen: {
        tableIdArgument: true,
      },
      deploy: {
        disabled: true,
      },
    },
    TokenApproval: {
      schema: {
        tokenId: "uint256",
        account: "address",
      },
      key: ["tokenId"],
      codegen: {
        tableIdArgument: true,
      },
      deploy: {
        disabled: true,
      },
    },

    OperatorApproval: {
      schema: {
        owner: "address",
        operator: "address",
        approved: "bool",
      },
      key: ["owner", "operator"],
      codegen: {
        tableIdArgument: true,
      },
      deploy: {
        disabled: true,
      },
    },

    /************************
     * KillMail module *
     ************************/

    KillMailTable: {
      schema: {
        killMailId: "uint256",
        killerCharacterId: "uint256",
        victimCharacterId: "uint256",
        lossType: "KillMailLossType",
        solarSystemId: "uint256",
        killTimestamp: "uint256",
      },
      key: ["killMailId"],
    },
  },
});
