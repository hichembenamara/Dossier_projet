import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

export default [
  ...nextVitals,
  ...nextTs,
  { ignores: [".next/**", "node_modules/**", "playwright-report/**", "test-results/**"] },
  {
    rules: {
      // Textes français avec apostrophes dans le JSX : règle sans intérêt ici.
      "react/no-unescaped-entities": "off",
      // Dette technique relevée le 2026-09-04 lors du passage à eslint-config-next 16 :
      // à corriger fichier par fichier, remontée en avertissement pour ne pas bloquer la CI.
      "@typescript-eslint/no-explicit-any": "warn",
      "react-hooks/set-state-in-effect": "warn",
      "react-hooks/immutability": "warn",
      "react-hooks/refs": "warn",
    },
  },
];
