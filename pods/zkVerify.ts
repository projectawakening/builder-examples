//Import the GPC Packages
import {
    GPCProofConfig, gpcVerify,
    boundConfigFromJSON, revealedClaimsFromJSON,
    GPCBoundConfig
} from "@pcd/gpc";

//Import the GPC Artifacts
const GPC_ARTIFACTS_PATH = "./node_modules/@pcd/proto-pod-gpc-artifacts";

//Import the Proof Config
const expectedProofConfig: GPCProofConfig = {
    pods: {
        security_badge: {
            entries: {
                security_level: { 
                    isRevealed: false,
                    inRange: {
                        min: 3n,
                        max: 10n
                    }
                },
                holder_smart_character_address: { isRevealed: true },
                issued_date: {
                    isRevealed: false,
                    inRange: {
                        min: 0n,
                        max: BigInt(new Date("2025-05-10T00:00:00.000Z").getTime())
                    }
                },
                expiry_date: {
                    isRevealed: false,
                    inRange: {
                        min: BigInt(new Date("2025-05-10T00:00:00.000Z").getTime()),
                        max: BigInt(new Date("2030-04-10T00:00:00.000Z").getTime())
                    }
                },
                pod_type: { isRevealed: true }
            }
        }
    }
};

//Import the Proof Data
const proofMessage = '{"proof":{"pi_a":["18382096760714031908670127575213136578083295521215433334251317660564033378720","21030477399437073370476149069090721170053337449725832469428119547769133404031","1"],"pi_b":[["3441945812976152446306624803438621070022957041244859610613891371824225138447","13484259047285811435888513023900289692797242279920846387677844428076348775051"],["5980242761206523890540011436691111069270009222756334744394997945384381875367","15263548166808880668931526071918599213486304986568041225530763198080863123460"],["1","0"]],"pi_c":["19436657118428907159797452603147484224001485778247802421550746896397384983856","3196080941424733966474612046643629155603406339625206953551307106366932306579","1"],"protocol":"groth16","curve":"bn128"},"boundConfig":{"circuitIdentifier":"proto-pod-gpc_1o-12e-5md-4nv-0ei-1x5l-0x0t-0ov3-1ov4","pods":{"security_badge":{"entries":{"expiry_date":{"isRevealed":false,"inRange":{"min":1746835200000,"max":1902009600000}},"holder_smart_character_address":{"isRevealed":true},"issued_date":{"isRevealed":false,"inRange":{"min":0,"max":1746835200000}},"pod_type":{"isRevealed":true},"security_level":{"isRevealed":false,"inRange":{"min":3,"max":10}}}}}},"revealedClaims":{"pods":{"security_badge":{"entries":{"holder_smart_character_address":"0x6d11ac8f376b6284a7e5d62a340f71869b3063ae","pod_type":"corpName.security_badge"},"signerPublicKey":"3iREOe5OdCEZ0KaF4pOfFc5nMvG6iZbY7GeaMy2P3xw"}}}}'

//Parse the Proof Data to JSON
const receivedFromProver = JSON.parse(proofMessage);

//Get the Proof, Bound Config, and Revealed Claims
const proof = receivedFromProver.proof;
const boundConfig = boundConfigFromJSON(receivedFromProver.boundConfig);
const revealedClaims = revealedClaimsFromJSON(receivedFromProver.revealedClaims);

//Verify the Proof
async function VerifyProof(){
    const verifyConfig: GPCBoundConfig = {
        ...expectedProofConfig,
        circuitIdentifier: boundConfig.circuitIdentifier
    }

    //Verify the Proof
    const isValid = await gpcVerify(
        proof,
        verifyConfig,
        revealedClaims,
        GPC_ARTIFACTS_PATH
    );

    //Print the result
    if(!isValid){
        throw new Error("Proof is invalid");   
    }

    console.log("Proof is valid");

    const officialPublicKey = "3iREOe5OdCEZ0KaF4pOfFc5nMvG6iZbY7GeaMy2P3xw"

    if(revealedClaims.pods.security_badge.signerPublicKey != officialPublicKey){
        throw new Error("Not the official signer");
    }

    const badgeEntries = revealedClaims.pods.security_badge.entries;

    const officialPodType = "corpName.security_badge"

    if(badgeEntries.pod_type.value !== officialPodType){
        throw new Error("Not the right type of POD");
    }

    console.log("Correct POD Type")
		
    console.log("Verified security badge for character", badgeEntries.holder_smart_character_address.value);

    //Exit the program
    process.exit(0);
}

//Run the verification
VerifyProof()