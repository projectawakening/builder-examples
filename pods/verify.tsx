//Import Packages
import { POD, PODEntries, JSONPOD, PODValue, podValueFromJSON } from "@pcd/pod";

//Fetch the POD String
const serializedPOD = '{"entries":{"holder":{"eddsa_pubkey":"ZnU07tyAUiWW2mmY3/z4aa3WxrctfSc0ch23752z6xM"},"issued_data":{"date":"2024-04-10T00:00:00.000Z"},"name":"Fleet Fight #23 Badge","pod_type":"corpName.badge"},"signature":"ajsu8cI/OQxLr0P3LJj6mHi5AkQsZXzgyjXCWjkn+4LFWlg5XwH9hQdI8IEOu7+4HkcY4ZKbsdau3mQWnUb6Aw","signerPublicKey":"xDP3ppa3qjpSJO+zmTuvDM2eku7O4MKaP2yCCKnoHZ4"}'

//Create the POD from the String
const receivedPOD: POD = POD.fromJSON(JSON.parse(serializedPOD));

//Verify the POD
if(!receivedPOD.verifySignature()){
    throw new Error("Invalid POD");
}

console.log("Verified POD")

const officialPublicKey = "xDP3ppa3qjpSJO+zmTuvDM2eku7O4MKaP2yCCKnoHZ4" 

if(receivedPOD.signerPublicKey != officialPublicKey){
    throw new Error("Not the official signer");
}

console.log("Verified Official Signer")

//Get a value from the POD
const name = receivedPOD.content.getValue("name");

console.log("Name:", name?.value)