import { defineConfig } from 'vite'

export default defineConfig({
  base: './',
  build: {
    license: { fileName: 'third-party-licenses.txt' },
  },
})
