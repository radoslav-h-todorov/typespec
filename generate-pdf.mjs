import puppeteer from 'puppeteer';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const presentationPath = join(__dirname, 'presentation.html').replace(/\\/g, '/');
const outputPath = join(__dirname, 'presentation.pdf');

const browser = await puppeteer.launch({
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
});

try {
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 720 });
  await page.goto(`file:///${presentationPath}`, { waitUntil: 'networkidle0' });

  const total = await page.evaluate(() => document.querySelectorAll('.slide').length);
  console.log(`Found ${total} slides`);

  // Transform layout: stack all slides vertically, one per PDF page
  await page.evaluate(() => {
    // Hide navigation controls
    document.querySelectorAll('body > div:not(#deck)').forEach(el => el.style.display = 'none');

    const deck = document.getElementById('deck');
    deck.style.cssText = 'position:static;width:100%;height:auto;overflow:visible;';

    document.body.style.cssText = 'overflow:visible;height:auto;padding:0;margin:0;display:block;background:#07080e;';

    document.querySelectorAll('.slide').forEach(slide => {
      slide.style.position = 'static';
      slide.style.display = 'flex';
      slide.style.width = '1280px';
      slide.style.height = '720px';
      slide.style.pageBreakAfter = 'always';
      slide.style.breakAfter = 'page';
      slide.style.transform = 'none';
      slide.style.opacity = '1';
      slide.classList.add('active');
    });
  });

  await page.pdf({
    path: outputPath,
    width: '1280px',
    height: '720px',
    printBackground: true,
    margin: { top: '0', right: '0', bottom: '0', left: '0' },
  });

  console.log(`PDF saved to: ${outputPath}`);
} finally {
  await browser.close();
}
