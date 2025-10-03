/* eslint-env node */
module.exports = {
  root: true,
  ignorePatterns: ["**/dist/**", "**/.next/**", "node_modules", "**/build/**"],
  extends: ["eslint:recommended"],
  parserOptions: {
    ecmaVersion: 2023,
    sourceType: "module"
  },
  env: {
    node: true,
    es2022: true
  },
  overrides: [
    {
      files: ["**/*.ts", "**/*.tsx"],
      parser: "@typescript-eslint/parser",
      plugins: ["@typescript-eslint"],
      extends: ["plugin:@typescript-eslint/recommended"],
      rules: {
        "@typescript-eslint/no-unused-vars": [
          "error,",
          { argsIgnorePattern: "^_", varsIgnorePattern: "^_" }
        ]
      }
    },
    {
      files: ["apps/web/**/*.{ts,tsx}"],
      env: { browser: true, node: false }
    }
  ]
};
