import "./App.css";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter as Router } from "react-router-dom";
import { App } from "./App";
import { Providers } from "./mud/Providers";
import { getWorldDeploy } from "./mud/getWorldDeploy";
import { chainId } from "./common";

// Supress console warnings that are not relevant to the project
const originalConsoleError = console.error;

console.warn = (...args) => {
  // (This warning is not relevant and does not affect the functionality of the project)
  if (args[0]?.includes("Failed to fetch remote project configuration")) {
    return;
  }
  originalConsoleError(...args);
};

getWorldDeploy(chainId).then((worldDeploy) => {
  createRoot(document.getElementById("react-root")!).render(
    <StrictMode>
      <Router>
        <Providers worldDeploy={worldDeploy}>
          <App />
        </Providers>
      </Router>
    </StrictMode>,
  );
});