//Import Packages
import { POD, PODEntries, JSONPOD, PODValue, podValueFromJSON, deriveSignerPublicKey } from "@pcd/pod";

//POD Data
const myEntries: PODEntries = {
    security_level: {
        type: "int",
        value: 4n
    },
    holder_smart_character_address: {
        type: "string",
        value: "0x6d11ac8f376b6284a7e5d62a340f71869b3063ae"
    },
    issued_date: {
        type: "date",
        value: new Date("2025-04-10T00:00:00.000Z")
    },
    expiry_date: {
        type: "date",
        value: new Date("2026-04-10T00:00:00.000Z")
    },
    pod_type: { type: "string", value: "corpName.security_badge" },
};

//Your PRIVATE signing key
const privateSigningKey = "2851153af6e862439ff91253684f85a6357ec7a3edcec4324de1eb7db4431ea5";

//Output Signer Public Key
const publicSigningKey = deriveSignerPublicKey(privateSigningKey);
console.log("\nSigner Public Key")
console.log(publicSigningKey + "\n")

//Create the POD
const myPOD = POD.sign(myEntries, privateSigningKey);

//Convert POD to JSON then String
const jsonPOD: JSONPOD = myPOD.toJSON();
const serializedPOD: string = JSON.stringify(jsonPOD);

//Output POD
console.log(jsonPOD)
console.log("\nStringified\n")
console.log(serializedPOD)