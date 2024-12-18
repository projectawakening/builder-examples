/** @type {import('tailwindcss').Config} */
export default {
  presets: [require("@eveworld/ui-components/eveStyles.config")],
  content: [
    "*",
    "./src/*.{js,ts,jsx,tsx}",
    "./src/*/*.{js,ts,jsx,tsx}",
    "../libs/ui-components/*/*.{js,ts,jsx,tsx}",
    "./node_modules/@eveworld/ui-components/*/*.{js,ts,jsx,tsx}",
  ],
};
