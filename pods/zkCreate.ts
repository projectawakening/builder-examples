//Import Packages
import { POD, PODEntries, JSONPOD, PODValue, podValueFromJSON, deriveSignerPublicKey } from "@pcd/pod";

import {
    gpcArtifactDownloadURL,
    GPCProofConfig, gpcProve,
    gpcVerify,
    boundConfigToJSON, revealedClaimsToJSON 
  } from "@pcd/gpc";

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

//Create the POD
const myPOD = POD.sign(myEntries, privateSigningKey);

//Output Signer Public Key
const publicSigningKey = deriveSignerPublicKey(privateSigningKey);
console.log("\nSigner Public Key")
console.log(publicSigningKey + "\n")

//Import the GPC Artifacts
const GPC_ARTIFACTS_PATH = "./node_modules/@pcd/proto-pod-gpc-artifacts";

//Create the Proof Config
const proofConfig: GPCProofConfig = {
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

const proofInputs = {
    pods: {
        security_badge: myPOD
    }
}

async function CreateProof(){
    //Create the proof
    const { proof, boundConfig, revealedClaims } = await gpcProve(
        proofConfig,
        proofInputs,
        GPC_ARTIFACTS_PATH
    );

    //Convert proof information to JSON
    const proofMessage = JSON.stringify({
        proof: proof,
        boundConfig: boundConfigToJSON(boundConfig),
        revealedClaims: revealedClaimsToJSON(revealedClaims)
    });

    //Output the proof
    console.log(proofMessage)

    process.exit(0);
}

CreateProof()