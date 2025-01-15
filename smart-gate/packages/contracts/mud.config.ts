import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  tables: {
    GateAccess: {
      schema: {
        smartObjectId: "uint256",
        accessListIds: "bytes32[]",
      },
      key: ["smartObjectId"], 
    },

    AccessLists: {
      schema: {
        accessListId: "bytes32",
        isWhiteList: "bool", // false = blacklist
        accessListName: "string",
        CorpIds: "uint256[]",
        CharIds: "uint256[]",
      },
      key: ["accessListId"],
    },
  },
});