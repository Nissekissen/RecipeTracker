import { test, expect} from '@playwright/test';

test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:9292/');
})

test.afterEach(async ({ page }) => {
    await sleep(1000);
})

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

test('Kan läsa ingredienser på ett recept', async ({ page }) => {
    await page.goto('http://localhost:9292/recipes');
    await sleep(1000);

    await page.locator('.card .img-wrapper a').first().click();
    await sleep(1000);

    // Get first ingredient
    const firstIngredient = await page.locator('.recipe-ingredients-container li').first();
    const ingredientText = await firstIngredient.textContent();
    expect(ingredientText).not.toBeNull();
    expect(ingredientText?.trim().length).toBeGreaterThan(0);
});

test('Kan logga in', async ({ page }) => {
    await page.goto('http://localhost:9292/auth/sign-in');
    await sleep(1000);

    await page.locator('a.google-log-in').click();
    await sleep(1000);

    // fill out email field with 'kontotest716@gmail.com'
    await page.locator('input[name=identifier]').fill('kontotest716@gmail.com');
    
    // click button with text 'Next'
    await page.locator('button:has-text("Next")').click();
    await sleep(1000);

    // fill out password field with 'secure-password'
    await page.locator('input[name=Passwd]').fill('super-secure');
    await sleep(1000);

    // click button with text 'Next'
    await page.locator('button:has-text("Next")').click();
    await sleep(1000);

    // click button next again
    await page.locator('button:has-text("Fortsätt")').click();
    await sleep(1000);

})