#!/usr/bin/env node

/**
 * Build script for esbuild bundling
 *
 * This script bundles the Node.js CLI application using esbuild.
 * Version information is handled via the auto-generated version.ts file.
 */

import { build } from "esbuild";

// Build with esbuild
await build({
  entryPoints: ["cli/node.ts"],
  bundle: true,
  platform: "node",
  target: "node18",
  format: "esm",
  outfile: "dist/cli/node.js",
  external: [
    // Keep node built-ins as external
    "node:*",
  ],
  banner: {
    js: `
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const __filename = new URL(import.meta.url).pathname;
const __dirname = new URL('.', import.meta.url).pathname;
    `.trim()
  },
  sourcemap: true,
});

console.log("✅ Bundle created successfully");
