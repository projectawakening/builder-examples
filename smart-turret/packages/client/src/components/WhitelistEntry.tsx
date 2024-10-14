import React, { CSSProperties, useState } from "react";
import { EveButton, Header } from "@eveworld/ui-components";

const WhitelistEntry = React.memo(
    ({
        id,
        handleClick,
    }: {
        id: string | undefined;
        handleClick: (param: string) => void;
    }) => {

        const [name, setName] = useState("LOADING....");
        const [img, setImg] = useState("");

        if(id != "LOADING...."){
            Promise.resolve(
                fetch(`https://blockchain-gateway-nova.nursery.reitnorf.com/smartcharacters/${id}`)
            )
            .then((res) => res.json())
            .then(x => {
                setName(x.name);
                setImg(x.image);
            });
        }     

        return (            
            <div className="Quantum-Container font-semibold">				
            <div className="grid grid-cols-2 gap-1" id="header">
                <p>
                <img className="character-image" src={img}></img>{name}
                </p>
                <EveButton typeClass="primary"
                className="primary-sm"
                onClick={() => handleClick(id)}
                >
                    
                    REMOVE	
                </EveButton>
            </div>
            </div>
        )
    }
)

export default React.memo(WhitelistEntry);