#!/usr/bin/env node
/**
 * svg-to-png.js — render an SVG file to PNG using a headless browser.
 *
 * Cross-platform (Windows, macOS, Linux). Uses Playwright + Chromium.
 *
 * Usage:
 *   node svg-to-png.js <input.svg> [output.png] [--width 1920]
 *
 * If output is omitted, writes <input>.png next to the input file.
 */

const fs = require('fs');
const path = require('path');

async function main() {
    const args = process.argv.slice(2);
    if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
        console.error('Usage: node svg-to-png.js <input.svg> [output.png] [--width 1920]');
        process.exit(1);
    }

    const inputFile = args.find(a => a.endsWith('.svg') || fs.existsSync(a));
    if (!inputFile) {
        console.error('Error: input SVG file not found');
        process.exit(1);
    }

    let outputFile = args.find(a => a.endsWith('.png'));
    if (!outputFile) {
        outputFile = inputFile.replace(/\.svg$/i, '.png');
    }

    const widthArg = args.indexOf('--width');
    const targetWidth = widthArg >= 0 && args[widthArg + 1]
        ? parseInt(args[widthArg + 1], 10)
        : 1920;

    const svg = fs.readFileSync(inputFile, 'utf8');

    // Resolve SVG natural size so we can compute screenshot viewport
    const widthMatch = svg.match(/<svg[^>]*\swidth=["']([\d.]+)/i);
    const heightMatch = svg.match(/<svg[^>]*\sheight=["']([\d.]+)/i);
    const viewBoxMatch = svg.match(/<svg[^>]*\sviewBox=["'][^"']+["']/i);

    let naturalWidth = 800;
    let naturalHeight = 600;

    if (widthMatch && heightMatch) {
        naturalWidth = parseFloat(widthMatch[1]);
        naturalHeight = parseFloat(heightMatch[1]);
    } else if (viewBoxMatch) {
        const parts = viewBoxMatch[0].match(/([\d.]+)/g);
        if (parts && parts.length >= 4) {
            naturalWidth = parseFloat(parts[2]);
            naturalHeight = parseFloat(parts[3]);
        }
    }

    const scale = targetWidth / naturalWidth;
    const viewportWidth = Math.max(1, Math.round(naturalWidth));
    const viewportHeight = Math.max(1, Math.round(naturalHeight));

    let browser;
    try {
        // Try playwright first (self-contained), then puppeteer-core (system Chrome),
        // then puppeteer (bundled Chrome), then sharp (no browser needed)
        const renderers = [
            ['playwright', () => require('playwright').chromium],
            ['puppeteer-core', () => require('puppeteer-core')],
            ['puppeteer', () => require('puppeteer')],
            ['sharp', () => require('sharp')],
        ];

        let rendered = false;
        let lastError = null;

        for (const [name, getMod] of renderers) {
            const mod = getMod();
            if (!mod) continue;

            try {
                if (name === 'sharp') {
                    await mod(inputFile, { density: 96 })
                        .resize({ width: targetWidth })
                        .png()
                        .toFile(outputFile);
                    console.log(`PNG exported via ${name}: ${outputFile}`);
                    rendered = true;
                    break;
                }

                // Browser-based renderers
                let executablePath;
                if (name === 'puppeteer-core') {
                    const chromePaths = [
                        'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
                        'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
                        process.env.LOCALAPPDATA + '\\Google\\Chrome\\Application\\chrome.exe',
                        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
                        '/usr/bin/google-chrome', '/usr/bin/google-chrome-stable',
                        '/usr/bin/chromium-browser', '/usr/bin/chromium',
                    ];
                    executablePath = chromePaths.find(p => fs.existsSync(p));
                    if (!executablePath) throw new Error('No Chrome found');
                }

                const launchOpts = executablePath ? { executablePath, args: ['--no-sandbox'] } : { args: ['--no-sandbox'] };
                browser = await mod.launch(launchOpts);
                const page = await browser.newPage({
                    viewport: { width: viewportWidth, height: viewportHeight }
                });

                await page.setContent(svg, { waitUntil: 'networkidle' });
                await page.waitForTimeout(500); // fonts/styles settle

                const el = await page.$('svg');
                if (!el) throw new Error('SVG element not found after loading');

                await el.screenshot({
                    path: outputFile,
                    type: 'png',
                    omitBackground: false,
                    scale: 'css'
                });

                console.log(`PNG exported via ${name}: ${outputFile}`);
                console.log(`Size: ${targetWidth}px wide (${Math.round(targetWidth / scale)}x${Math.round(viewportHeight * scale)} scaled)`);
                rendered = true;
                break;
            } catch (err) {
                lastError = err;
                if (browser) { try { await browser.close(); } catch {} browser = null; }
            }
        }

        if (!rendered) {
            throw lastError || new Error('No renderer available');
        }
    } catch (err) {
        console.error(`✖ All renderers failed. Last error: ${err.message}`);
        console.error('');
        console.error('Install a renderer:');
        console.error('  npm install playwright     # self-contained (recommended)');
        console.error('  npm install puppeteer      # bundled Chrome');
        console.error('  npm install puppeteer-core # uses system Chrome');
        console.error('  npm install sharp          # lightweight, no browser');
        process.exit(1);
    } finally {
        if (browser) await browser.close();
    }
}

main();
