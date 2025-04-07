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

test('Har titeln "Receptbasen"', async ({ page }) => {
    await page.goto('https://localhost:9292/');
    await sleep(1000);

    
});
