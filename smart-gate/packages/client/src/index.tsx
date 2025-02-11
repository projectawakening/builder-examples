import "./App.css";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { App } from "./App";
import { Providers } from "./mud/Providers";
import { getWorldDeploy } from "./mud/getWorldDeploy";
import { chainId } from "./common";

getWorldDeploy(chainId).then((worldDeploy) => {
  createRoot(document.getElementById("react-root")!).render(
    <StrictMode>
      <Providers worldDeploy={worldDeploy}>
        <App />
      </Providers>
    </StrictMode>,
  );
});
