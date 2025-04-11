import { test, expect} from '@playwright/test';

test.beforeEach(async ({ page }) => {
    await page.goto('https://localhost:9292/');
})

test.afterEach(async ({ page }) => {
    await sleep(1000);
})

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

test('Kan läsa ingredienser på ett recept', async ({ page }) => {
    await page.goto('https://localhost:9292/recipes');
    await sleep(1000);

    await page.locator('.card .img-wrapper a').first().click();
    await sleep(1000);

    // Get first ingredient
    const firstIngredient = await page.locator('.recipe-ingredients-container li').first();
    const ingredientText = await firstIngredient.textContent();
    expect(ingredientText).not.toBeNull();
    expect(ingredientText?.trim().length).toBeGreaterThan(0);
});
