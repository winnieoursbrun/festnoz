import { sentryVitePlugin } from "@sentry/vite-plugin";
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import ViteRails from 'vite-plugin-rails'
import tailwindcss from '@tailwindcss/vite'
import path from 'node:path'

export default defineConfig({
  plugins: [vue(), tailwindcss(), ViteRails(), sentryVitePlugin({
    org: "winnietech",
    project: "festnoz-frontend"
  })],

  resolve: {
    alias: {
      '@': path.resolve(__dirname, './app/frontend'),
    },
  },

  build: {
    sourcemap: true
  }
})
