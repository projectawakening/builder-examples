/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_SMARTASSEMBLY_ID: string;
  readonly VITE_GATEWAY_HTTP: string;
  readonly VITE_GATEWAY_WS: string;
  // Add other environment variables here as needed
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
