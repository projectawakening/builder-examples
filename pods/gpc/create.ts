//Import Packages
import { POD, PODEntries, JSONPOD, PODValue, podValueFromJSON } from "@pcd/pod";

import {
    gpcArtifactDownloadURL,
    GPCProofConfig, gpcProve,
    gpcVerify,
    boundConfigToJSON, revealedClaimsToJSON 
  } from "@pcd/gpc";

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

//Output Signer Public Key
console.log("\nSigner Public Key")
console.log(myPOD.signerPublicKey + "\n")

//Import the GPC Artifacts
const GPC_ARTIFACTS_PATH = "./node_modules/@pcd/proto-pod-gpc-artifacts";

//Create the Proof Config
const proofConfig: GPCProofConfig = {
    pods: {
        badge: {
            entries: {
                name: { isRevealed: true },
                holder: { isRevealed: true },
                issued_data: {
                    isRevealed: false,
                    inRange: {
                        min: 0n,
                        max: BigInt(new Date("2026-01-01T00:00:00.000Z").getTime())
                    }
                }
            }
        }
    }
};

const proofInputs = {
    pods: {
        badge: myPOD
    }
}

async function ProveAndVerify(){
    const { proof, boundConfig, revealedClaims } = await gpcProve(
        proofConfig,
        proofInputs,
        GPC_ARTIFACTS_PATH
    );

    const proofMessage = JSON.stringify({
        proof: proof,
        boundConfig: boundConfigToJSON(boundConfig),
        revealedClaims: revealedClaimsToJSON(revealedClaims)
    });

    console.log(proofMessage)
}

ProveAndVerify()