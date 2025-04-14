//Import the GPC Packages
import {
    GPCProofConfig, gpcVerify,
    boundConfigFromJSON, revealedClaimsFromJSON ,
    GPCBoundConfig
} from "@pcd/gpc";

//Import the GPC Artifacts
const GPC_ARTIFACTS_PATH = "./node_modules/@pcd/proto-pod-gpc-artifacts";

//Import the Proof Config
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

//Import the POD
const podStringified = '{"proof":{"pi_a":["17165088015773470364499468775353569245513718166758215366465242181421748854063","11148108789216055924461405365503298820090583290996909056123174499767403985968","1"],"pi_b":[["17277554839286596354606131497461334920216927039400576197885077482669454733526","1332204512618193457235218493224183277081493608305773708015616231185733559629"],["13282263274750810810341544137900732555984574987537922349190090231138668002594","16024416837250075995007866729921038804446706791368997786341967492806050558950"],["1","0"]],"pi_c":["4479855606828081979153306989501836473184464251034202690864318452243418543656","16741222571863185932507790023556335231152352653892794665535458592697177982585","1"],"protocol":"groth16","curve":"bn128"},"boundConfig":{"circuitIdentifier":"proto-pod-gpc_1o-5e-6md-2nv-0ei-0x0l-0x0t-1ov3-1ov4","pods":{"badge":{"entries":{"holder":{"isRevealed":true},"issued_data":{"isRevealed":false,"inRange":{"min":0,"max":1767225600000}},"name":{"isRevealed":true}}}}},"revealedClaims":{"pods":{"badge":{"entries":{"holder":{"eddsa_pubkey":"ZnU07tyAUiWW2mmY3/z4aa3WxrctfSc0ch23752z6xM"},"name":"Fleet Fight #23 Badge"},"signerPublicKey":"xDP3ppa3qjpSJO+zmTuvDM2eku7O4MKaP2yCCKnoHZ4"}}}}'

//Parse the POD to JSON
const receivedFromProver = JSON.parse(podStringified);

//Get the Proof, Bound Config, and Revealed Claims
const proof = receivedFromProver.proof;
const boundConfig = boundConfigFromJSON(receivedFromProver.boundConfig);
const revealedClaims = revealedClaimsFromJSON(receivedFromProver.revealedClaims);

//Verify the GPC POD
async function VerifyPOD(){
    const verifyConfig: GPCBoundConfig = {
        ...proofConfig,
        circuitIdentifier: boundConfig.circuitIdentifier
    }

    //Verify the POD
    const isValid = await gpcVerify(
        proof,
        verifyConfig,
        revealedClaims,
        GPC_ARTIFACTS_PATH
    );

    //Print the result
    console.log("Is Valid,", isValid)

    //Exit the program
    process.exit(0);
}

//Run the verification
VerifyPOD()