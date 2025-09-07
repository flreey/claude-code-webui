/// <reference types="vitest" />
import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react-swc";
import tailwindcss from "@tailwindcss/vite";
import { dirname, resolve } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, resolve(__dirname, ".."), "");
  const apiPort = env.PORT || "8080";
  const frontendPort = parseInt(env.FRONTEND_PORT || "3000", 10);
  const frontendHost = env.FRONTEND_HOST || "127.0.0.1";

  return {
    plugins: [react(), tailwindcss()],
    resolve: {
      alias: {
        "@shared": resolve(__dirname, "../shared"),
      },
    },
    server: {
      host: frontendHost,
      port: frontendPort,
      proxy: {
        "/api": {
          target: `http://localhost:${apiPort}`,
          changeOrigin: true,
          secure: false,
        },
      },
    },
    test: {
      environment: "jsdom",
      setupFiles: ["./src/test-setup.ts"],
      globals: true,
      exclude: [
        "**/node_modules/**",
        "**/dist/**",
        "**/cypress/**",
        "**/.{idea,git,cache,output,temp}/**",
        "**/{karma,rollup,webpack,vite,vitest,jest,ava,babel,nyc,cypress,tsup,build}.config.*",
        "**/scripts/**", // Exclude Playwright demo recording files
        "**/tests/**", // Exclude Playwright validation tests
      ],
    },
  };
});
