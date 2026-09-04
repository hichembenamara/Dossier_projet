import { expect, test } from "@playwright/test";
import { loginViaForm } from "./helpers";

test.describe("Authentification", () => {
  test("connexion user/user → /me/dashboard avec indicateurs, puis déconnexion", async ({ page }) => {
    await loginViaForm(page, "user");

    await expect(page).toHaveURL(/\/me\/dashboard/);
    // Synthèse santé + rangée d'indicateurs (HealthKpiCard) rendues à partir de GET /api/me/dashboard
    await expect(page.locator(".circular-score-card").first()).toBeVisible();
    await expect(page.locator(".health-kpi-card").first()).toBeVisible();
    expect(await page.locator(".health-kpi-card").count()).toBeGreaterThanOrEqual(4);

    await page.getByRole("button", { name: /D[ée]connexion/ }).click();
    await expect(page).toHaveURL(/\/login/);

    // La session est bien close : l'espace personnel redirige vers /login
    await page.goto("/me/dashboard");
    await expect(page).toHaveURL(/\/login/);
  });
});
