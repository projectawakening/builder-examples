import React, { CSSProperties, useState } from "react";

const AppContainer = ({children}) => {
    return(
    <div className="bg-crude-5 w-screen min-h-screen">
        <div className="flex flex-col align-center max-w-[560px] mx-auto pb-6 min-h-screen h-full">
            {children}
        </div>
    </div>
    )
}

export default AppContainer;