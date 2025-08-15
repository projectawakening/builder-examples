//Import Packages
import { POD, PODEntries, JSONPOD, PODValue, podValueFromJSON } from "@pcd/pod";

//Fetch the POD String
const serializedPOD = '{"entries":{"expiry_date":{"date":"2026-04-10T00:00:00.000Z"},"holder_smart_character_address":"0x6d11ac8f376b6284a7e5d62a340f71869b3063ae","issued_date":{"date":"2025-04-10T00:00:00.000Z"},"pod_type":"corpName.security_badge","security_level":4},"signature":"GfpAbL4XJzSVZUg2XmnPLlIl0Yt1e0JCG+CKNfNQi5FFT3P7L2aCxnmNmSoDGXahvaqhOcXtjGybD1ZH39ZXAQ","signerPublicKey":"3iREOe5OdCEZ0KaF4pOfFc5nMvG6iZbY7GeaMy2P3xw"}'

//Create the POD from the String
const receivedPOD: POD = POD.fromJSON(JSON.parse(serializedPOD));

//Verify the POD
if(!receivedPOD.verifySignature()){
    throw new Error("Invalid POD");
}

console.log("Verified POD")

const officialPublicKey = "3iREOe5OdCEZ0KaF4pOfFc5nMvG6iZbY7GeaMy2P3xw" 

if(receivedPOD.signerPublicKey != officialPublicKey){
    throw new Error("Not the official signer");
}

console.log("Verified Official Signer")

const officialPodType = "corpName.security_badge"

const podType = receivedPOD.content.getValue("pod_type")?.value;

if(podType != officialPodType){
    throw new Error("Not the official pod type");
}

console.log("Verified Official Pod Type")

//Get a value from the POD
const level = receivedPOD.content.getValue("security_level");

console.log("Level:", level?.value)