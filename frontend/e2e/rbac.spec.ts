import { expect, test } from "@playwright/test";
import { ACCOUNTS, API_URL, loginViaForm } from "./helpers";

test.describe("Contrôle d'accès par rôle", () => {
  test("un utilisateur qui tape /admin/dashboard est renvoyé vers /me/dashboard", async ({ page }) => {
    await loginViaForm(page, "user");
    await page.goto("/admin/dashboard");
    await expect(page).toHaveURL(/\/me\/dashboard/);
    await expect(page.locator(".health-kpi-card").first()).toBeVisible();
  });

  test("l'API répond 403 à GET /api/admin/utilisateurs avec le jeton d'un utilisateur", async ({ request }) => {
    const login = await request.post(`${API_URL}/api/auth/login`, { data: ACCOUNTS.user });
    expect(login.ok()).toBeTruthy();
    const token = (await login.json()).data.access_token as string;

    const response = await request.get(`${API_URL}/api/admin/utilisateurs`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    expect(response.status()).toBe(403);
    const body = await response.json();
    expect(body.error.code).toBe("forbidden");
  });
});
