//Import the GPC Packages
import {
    GPCProofConfig, gpcVerify,
    boundConfigFromJSON, revealedClaimsFromJSON ,
    GPCBoundConfig
} from "@pcd/gpc";

//Import the GPC Artifacts
const GPC_ARTIFACTS_PATH = "./node_modules/@pcd/proto-pod-gpc-artifacts";

//Import the Proof Config
const expectedProofConfig: GPCProofConfig = {
    pods: {
        badge: {
            entries: {
                level: { 
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
const podStringified = '{"proof":{"pi_a":["1625511905414346867203831556182100487351474796860000531656907947697909189372","19439539238149718270735659927453691996938581370593789286293390410225789761184","1"],"pi_b":[["967949427602219503009661301720924435744926518961999266620375170977628268868","6958917644171950452090860434134184390653414206129615173255426640976687776310"],["12877758429843164412514696187526264533831674474355810594993640699554847477426","16550300249829529009697193970741645195131530902628580246102572129853268664551"],["1","0"]],"pi_c":["3404751921196184359742147465334007603599542867456186061964601622157504061723","4807397883507985424495584158178595912956863775459109557141386827887201647366","1"],"protocol":"groth16","curve":"bn128"},"boundConfig":{"circuitIdentifier":"proto-pod-gpc_1o-12e-5md-4nv-0ei-1x5l-0x0t-0ov3-1ov4","pods":{"badge":{"entries":{"expiry_date":{"isRevealed":false,"inRange":{"min":1746835200000,"max":1902009600000}},"holder_smart_character_address":{"isRevealed":true},"issued_date":{"isRevealed":false,"inRange":{"min":0,"max":1746835200000}},"level":{"isRevealed":false,"inRange":{"min":3,"max":10}},"pod_type":{"isRevealed":true}}}}},"revealedClaims":{"pods":{"badge":{"entries":{"holder_smart_character_address":"0x6d11ac8f376b6284a7e5d62a340f71869b3063ae","pod_type":"corpName.access_badge"},"signerPublicKey":"xDP3ppa3qjpSJO+zmTuvDM2eku7O4MKaP2yCCKnoHZ4"}}}}'

//Parse the Proof Data to JSON
const receivedFromProver = JSON.parse(podStringified);

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
    console.log("Is Valid,", isValid)

    const officialPublicKey = "xDP3ppa3qjpSJO+zmTuvDM2eku7O4MKaP2yCCKnoHZ4"

    if(revealedClaims.pods.badge.signerPublicKey != officialPublicKey){
        throw new Error("Not the official signer");
    }

    //Exit the program
    process.exit(0);
}

//Run the verification
VerifyProof()