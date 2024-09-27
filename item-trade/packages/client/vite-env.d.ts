/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_SMARTASSEMBLY_ID: string;
  readonly VITE_PRIVATE_KEY: string;
  readonly VITE_CHAIN_ID: string;
  readonly VITE_ERC20_TOKEN: string;
  // Add other environment variables here as needed
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}