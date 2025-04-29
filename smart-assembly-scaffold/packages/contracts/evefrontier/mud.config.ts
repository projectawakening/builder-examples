import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  deploy: {
    customWorld: {
      sourcePath: "src/WorldWithContextProxy.sol",
      name: "WorldWithContextProxy",
    },
  },
  userTypes: {
    ResourceId: { filePath: "@latticexyz/store/src/ResourceId.sol", type: "bytes32" },
  },
  enums: {
    State: ["NULL", "UNANCHORED", "ANCHORED", "ONLINE", "DESTROYED"],
    KillMailLossType: ["SHIP", "POD"],
  },
  codegen: {
    generateSystemLibraries: true,
  },
  namespaces: {
    evefrontier: {
      tables: {
        /**
         * Class Id table
         */
        Initialize: {
          schema: {
            systemId: "ResourceId",
            classId: "uint256",
          },
          key: ["systemId"],
        },
        /***************************
         * OWNERSHIP TABLES *
         ***************************/
        InventoryByItem: {
          schema: {
            itemObjectId: "uint256",
            inventoryObjectId: "uint256",
          },
          key: ["itemObjectId"],
        },
        OwnershipByObject: {
          schema: {
            smartObjectId: "uint256",
            account: "address",
          },
          key: ["smartObjectId"],
        },
        /**********************
         * ENTITY RECORD TABLES *
         **********************/
        /**
         * Used to store the allowed tenantId assignable a smart object being created in this World
         */
        Tenant: {
          schema: {
            tenantId: "bytes32",
          },
          key: [],
        },
        /**
         * Used to create a record which holds important game related data for an entity onchain
         * Singleton entities are treated as objects, OBJECT smartObjectIds are calculated as `objectId = uint256(keccak256(abi.encodePacked(<game-tenantID-as-utf8-string>, <game-itemID-as-uint256>)))`
         * Non-singleton entities are treated as a class, CLASS smartObjectIds as calculated as `classId = uint256(keccak256(abi.encodePacked(<game-typeID-as-uint256>)))`
         */
        EntityRecord: {
          schema: {
            smartObjectId: "uint256",
            exists: "bool",
            tenantId: "bytes32",
            typeId: "uint256",
            itemId: "uint256",
            volume: "uint256",
          },
          key: ["smartObjectId"],
        },
        EntityRecordMetadata: {
          schema: {
            smartObjectId: "uint256",
            name: "string",
            dappURL: "string",
            description: "string",
          },
          key: ["smartObjectId"],
        },
        /***************************
         * SMART ASSEMBLY TABLE *
         ***************************/
        /**
         * Used to store the assembly typeof a smart object
         */
        SmartAssembly: {
          schema: {
            smartObjectId: "uint256",
            assemblyType: "string",
          },
          key: ["smartObjectId"],
        },
        /*************************
         * SMART CHARACTER TABLES *
         *************************/
        Characters: {
          schema: {
            smartObjectId: "uint256",
            exists: "bool",
            tribeId: "uint256",
            createdAt: "uint256",
          },
          key: ["smartObjectId"],
        },
        CharactersByAccount: {
          schema: {
            account: "address",
            smartObjectId: "uint256",
          },
          key: ["account"],
        },
        /*******************
         * LOCATION TABLE *
         *******************/
        /**
         * Used to store the location of a in-game entity in the solar system
         */
        Location: {
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
         * DEPLOYABLE TABLES *
         ***************************/
        /**
         * Used to store the Global state of the Deployable
         */
        GlobalDeployableState: {
          schema: {
            isPaused: "bool",
            updatedBlockNumber: "uint256",
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
        /*******************
         * FUEL TABLE *
         *******************/
        /**
         * Used to store the fuel balance of a Deployable
         */
        Fuel: {
          schema: {
            smartObjectId: "uint256",
            fuelUnitVolume: "uint256",
            fuelConsumptionIntervalInSeconds: "uint256",
            fuelMaxCapacity: "uint256",
            fuelAmount: "uint256",
            lastUpdatedAt: "uint256", // unix time in seconds
          },
          key: ["smartObjectId"],
        },
        /*******************
         * INVENTORY TABLES *
         *******************/
        Inventory: {
          schema: {
            smartObjectId: "uint256",
            capacity: "uint256",
            usedCapacity: "uint256",
            version: "uint256",
            items: "uint256[]",
          },
          key: ["smartObjectId"],
        },
        /**
         * Used to store the inventory item entries of a smart object's inventory
         */
        InventoryItem: {
          schema: {
            smartObjectId: "uint256",
            itemObjectId: "uint256",
            exists: "bool",
            quantity: "uint256",
            index: "uint256",
            version: "uint256",
          },
          key: ["smartObjectId", "itemObjectId"],
        },
        /**
         * Used to signal the transfer details when a item is exchanged between its primary inventory and another smart object's primary inventory
         */
        InventoryItemTransfer: {
          schema: {
            smartObjectId: "uint256",
            itemObjectId: "uint256",
            toObjectId: "uint256",
            previousOwner: "address",
            currentOwner: "address",
            quantity: "uint256",
            updatedAt: "uint256",
          },
          key: ["smartObjectId", "itemObjectId"],
        },
        /*******************
         * EPHEMERAL INVENTORY TABLES *
         *******************/
        /**
         * Used to Store Ephemeral Capacity by smartObjectId
         */
        EphemeralInvCapacity: {
          schema: {
            smartObjectId: "uint256",
            capacity: "uint256",
          },
          key: ["smartObjectId"],
        },
        EphemeralInventory: {
          schema: {
            smartObjectId: "uint256",
            ephemeralOwner: "address",
            capacity: "uint256",
            usedCapacity: "uint256",
            version: "uint256",
            items: "uint256[]",
          },
          key: ["smartObjectId", "ephemeralOwner"],
        },
        EphemeralInvItem: {
          schema: {
            smartObjectId: "uint256",
            ephemeralOwner: "address",
            itemObjectId: "uint256",
            exists: "bool",
            quantity: "uint256",
            index: "uint256",
            version: "uint256",
          },
          key: ["smartObjectId", "ephemeralOwner", "itemObjectId"],
        },
        /**
         * Look up table to find the associated inventory smart object for an ephemeral inventory
         */
        InventoryByEphemeral: {
          schema: {
            ephemeralSmartObjectId: "uint256",
            exists: "bool",
            smartObjectId: "uint256", // parent container ID
            ephemeralOwner: "address", // TODO : ? why is this needed? is this inventory owner?
          },
          key: ["ephemeralSmartObjectId"],
        },
        /**
         * Used to signal the transfer details when a item is exchanged between it's primary inventory and an associated ephemeral inventory or two ehpemeral inventories
         */
        EphemeralItemTransfer: {
          schema: {
            smartObjectId: "uint256",
            itemObjectId: "uint256",
            previousOwner: "address",
            currentOwner: "address",
            quantity: "uint256",
            updatedAt: "uint256",
          },
          key: ["smartObjectId", "itemObjectId"],
        },
        /*************************
         * SMART TURRET TABLE *
         *************************/
        SmartTurretConfig: {
          schema: {
            smartObjectId: "uint256",
            systemId: "ResourceId",
          },
          key: ["smartObjectId"],
        },
        /*************************
         * SMART GATE TABLE *
         *************************/
        SmartGateConfig: {
          schema: {
            smartObjectId: "uint256",
            systemId: "ResourceId",
            maxDistance: "uint256",
          },
          key: ["smartObjectId"],
        },
        SmartGateLink: {
          schema: {
            sourceGateId: "uint256",
            destinationGateId: "uint256",
            isLinked: "bool",
          },
          key: ["sourceGateId"],
        },
        /************************
         * KILL MAIL TABLE *
         ************************/
        KillMail: {
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
    },
  },
});
