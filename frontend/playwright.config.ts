import { defineConfig, devices } from "@playwright/test";

// Tests de bout en bout : la pile Docker (front :3000, API :8000) doit tourner,
// avec les données de l'ETL chargées (docker compose --profile etl run --rm etl).
export default defineConfig({
  testDir: "./e2e",
  timeout: 60_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  retries: process.env.CI ? 1 : 0,
  reporter: [["list"], ["html", { open: "never", outputFolder: "playwright-report" }]],
  use: {
    baseURL: process.env.E2E_BASE_URL ?? "http://localhost:3000",
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    locale: "fr-FR",
    viewport: { width: 1440, height: 900 },
  },
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        // En local, E2E_CHROME permet d'utiliser un Chromium système sans `playwright install`.
        launchOptions: process.env.E2E_CHROME ? { executablePath: process.env.E2E_CHROME } : {},
      },
    },
  ],
});
