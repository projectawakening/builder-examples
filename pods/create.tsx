//Import Packages
import { POD, PODEntries, JSONPOD, PODValue, podValueFromJSON } from "@pcd/pod";

//POD Data
const myEntries: PODEntries = {
    name: {
        type: "string",
        value: "Fleet Fight #23 Badge"
    },
    holder: {
        type: "eddsa_pubkey",
        value: "ZnU07tyAUiWW2mmY3/z4aa3WxrctfSc0ch23752z6xM"
    },
    issued_data: {
        type: "date",
        value: new Date("2024-04-10T00:00:00.000Z")
    },
    pod_type: { type: "string", value: "corpName.badge" },
};

//Your PRIVATE signing key
const signingKey = "AAECAwQFBgcICQABAgMEBQYHCAkAAQIDBAUGBwgJAAE";

//Create the POD
const myPOD = POD.sign(myEntries, signingKey);

//Check if the POD is invalid
if (!myPOD.verifySignature()) {
    throw new Error("Bad POD!");
}

//Convert POD to JSON then String
const jsonPOD: JSONPOD = myPOD.toJSON();
const serializedPOD: string = JSON.stringify(jsonPOD);

//Output POD
console.log(jsonPOD)
console.log("\nStringified\n")
console.log(serializedPOD)

//Output Signer Public Key
console.log("\nSigner Public Key\n")
console.log(myPOD.signerPublicKey)