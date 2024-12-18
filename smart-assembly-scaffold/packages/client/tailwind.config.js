/** @type {import('tailwindcss').Config} */

export default {
  presets: [require("@eveworld/ui-components/eveStyles.config")],
  content: [
    "*",
    "./src/*.{js,ts,jsx,tsx}",
    "./src/*/*.{js,ts,jsx,tsx}",
    "../libs/ui-components/*/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      screens: {
        tablet: { max: "1200px" },
        mobile: { max: "810px" },
        xs: "375px",
        sm: "390px",
        md: "810px",
        lg: "1200px",
      },
      colors: {
        neutral: {
          10: "hsla(60, 100%, 92%, 0.1)",
          30: "hsla(60, 100%, 92%, 0.3)",
        },
        darkquantum: {
          DEFAULT: "hsla(23, 95%, 40%, 1)",
        },
        grayneutral: {
          DEFAULT: "hsla(55, 9%, 51%, 1)",
        },
        crude: {
          30: "hsla(20, 65%, 5%, 0.3)",
          50: "hsla(20, 65%, 5%, 0.5)",
        },
      },
    },
  },
  plugins: [],
};
