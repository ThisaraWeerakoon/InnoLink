import daisyui from "daisyui";
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html","./src/**/*.{ts,js,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [daisyui],
}
