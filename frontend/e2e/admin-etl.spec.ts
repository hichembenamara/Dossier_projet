import { expect, test } from "@playwright/test";
import { loginViaForm } from "./helpers";

test.describe("Administration ETL", () => {
  test("les 5 exécutions ETL sont en succès, un lot mène aux contrôles qualité paginés", async ({ page }) => {
    await loginViaForm(page, "admin");

    await page.goto("/admin/etl/executions");
    const rows = page.locator("table.data-table tbody tr");
    await expect(rows).toHaveCount(5);
    await expect(page.locator("table.data-table tbody .badge").filter({ hasText: "SUCCES" })).toHaveCount(5);

    // Ouvrir la première exécution puis l'un de ses lots
    await rows.first().click();
    await expect(page).toHaveURL(/\/admin\/etl\/executions\/\d+/);
    const lotLink = page.locator("a.row-link").first();
    await expect(lotLink).toBeVisible();
    await lotLink.click();
    await expect(page).toHaveURL(/\/admin\/etl\/lots\/\d+/);

    // Les contrôles qualité rattachés aux lots : lignes + pagination
    await page.goto("/admin/controles-qualite");
    await expect(page.locator("table.data-table tbody tr").first()).toBeVisible();
    expect(await page.locator("table.data-table tbody tr").count()).toBeGreaterThan(0);
    await expect(page.getByText(/Page 1 \/ \d+ - \d+ resultats/)).toBeVisible();
    await expect(page.getByRole("button", { name: "Suivant" })).toBeVisible();
  });
});
