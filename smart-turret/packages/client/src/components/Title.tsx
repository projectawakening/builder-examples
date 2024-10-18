import React, { CSSProperties, useState } from "react";

const Title = ({children}) => {
    return(
        <div className="Quantum-Container my-4">
            <header className="w-full items-center py-6 Custom-Title" id="header">
                {children}
            </header>
        </div>
    )
}

export default Title;