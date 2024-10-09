import React, { CSSProperties } from "react";
import { EveButton, Header } from "@eveworld/ui-components";

const WhitelistEntry = React.memo(
    ({
        id,
    }: {
        id: string | undefined;
    }) => {

        return (            
            <div className="Quantum-Container font-semibold">				
            <div className="grid grid-cols-2 gap-1" id="header">
                Character {id}
                
                <EveButton typeClass="primary"
                className="primary-sm">
                    REMOVE		
                </EveButton>
            </div>
            </div>
        )
    }
)

export default React.memo(WhitelistEntry);