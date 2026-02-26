import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import ViteRails from 'vite-plugin-rails'
import tailwindcss from '@tailwindcss/vite'
import path from 'node:path'

export default defineConfig({
  plugins: [
    vue(),
    tailwindcss(),
    ViteRails(),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './app/frontend'),
    },
  },
})
