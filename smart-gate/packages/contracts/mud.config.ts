import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
    tables: {
      /**
       * Associates a gate (smartObjectId) with an array of access list identifiers.
       * Call GateAccess.get(gateId) to retrieve the array accessListIds (bytes32[])
       * 
       * Example usage:
       * 
       *   bytes32[] memory accesListIdsForThisGate = GateAccess.get(gateId);
       *
       */
      GateAccess: {
        schema: {
          smartObjectId: "uint256",
          accessListIds: "bytes32[]",
        },
        key: ["smartObjectId"],
      },

      /**
       * Defines an access list by providing:
       *   - accessListId(bytes32): a unique identifier for the list
       *   - accessListName(string): a descriptive name (e.g., "MainWhitelist")
       *   - isWhitelist(bool): indicates whether the list is a whitelist (true) or a blacklist (false)
       *   - createdBy: wallet address which created the access list
       * 
       * Retrieve the data for a given listId with:
       *
       *   AccessListDefinitionsData memory listData = AccessListDefinitions.get(listId);
       *   bytes32 listKey = listData.accessListId;
       *   bool isWhite = listData.isWhitelist;
       *   // etc.
       */
      AccessListDefinitions: {
        schema: {
          accessListId: "bytes32",
          isWhitelist: "bool",
          createdBy: "address",
          accessListName: "string",
        },
        key: ["accessListId"],
      },

      /**
       * Holds individual entries for each access list.
       * Each entry is identified by a composite key (accessListId, entryId, entryType):
       *   - accessListId: references the corresponding access list
       *   - entryId:  char or a corporation ID
       *   - entryType: 0 = Char, 1 = Corp
       *   - addedBy: wallet address which added the entry
       *
       * Use AccessListEntries.get([listId, charId, 0]) to check if a char is in a list, for example:
       *
       *   AccessListEntriesData memory entryData = AccessListEntries.get(listId, charId, 0);
       *   bytes32 retrievedListId = entryData.accessListId; 
       *   // If 'retrievedListId' is non-zero, this row exists.
       * 
       * A row's existence implies that (entryId, entryType) belongs to the given access list.
       */
      AccessListEntries: {
        schema: {
          accessListId: "bytes32",
          entryId: "uint256",
          entryType: "uint8", // 0 = Char, 1 = Corp
          addedBy: "address",
          timestamp: "uint256",
        },
        key: ["accessListId", "entryId", "entryType"],
      },
    },
});
