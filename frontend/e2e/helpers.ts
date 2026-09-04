import { expect, type Page } from "@playwright/test";

export const API_URL = process.env.E2E_API_URL ?? "http://localhost:8000";

export const ACCOUNTS = {
  user: { identifiant: "user", mot_de_passe: "user" },
  admin: { identifiant: "admin", mot_de_passe: "admin" },
  superadmin: { identifiant: "superadmin", mot_de_passe: "superadmin" },
} as const;

/** Connexion par le formulaire /login (mêmes sélecteurs que dossier/figures/captures/capture.py). */
export async function loginViaForm(page: Page, account: keyof typeof ACCOUNTS) {
  await page.goto("/login");
  await page.getByLabel("Identifiant").fill(ACCOUNTS[account].identifiant);
  await page.getByLabel("Mot de passe").fill(ACCOUNTS[account].mot_de_passe);
  await page.locator("form button[type=submit]").click();
  await expect(page).not.toHaveURL(/\/login/);
}
