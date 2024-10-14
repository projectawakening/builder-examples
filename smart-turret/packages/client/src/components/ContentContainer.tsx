import React, { CSSProperties, useState } from "react";

const ContentContainer = ({children}) => {
    return(
        <div className="relative">
        <div className="grid border border-brightquantum bg-crude">
        <div className="flex flex-col align-center border border-brightquantum">
            {children}
        </div>
        </div>
        </div>
    )
}

export default ContentContainer;