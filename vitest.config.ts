import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath } from 'node:url'

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'happy-dom',
    setupFiles: ['./app/frontend/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'app/frontend/test/',
        '**/*.config.{js,ts}',
        '**/dist/**'
      ]
    }
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./app/frontend', import.meta.url))
    }
  }
})
