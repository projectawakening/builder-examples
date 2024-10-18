import React, { CSSProperties, useState } from "react";

const Section = ({children}) => {
    return(
        <div className="Quantum-Container font-semibold">
            {children}
        </div>
    )
}

export default Section;