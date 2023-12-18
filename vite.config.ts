import { defineConfig } from 'vite'
import { resolve } from 'path'
// comment
export default defineConfig({
  build: {
    outDir: 'src/MyAwesomeProject.Web/wwwroot/app/', // inside the Umbraco project
    emptyOutDir: true, // needs to be explicitly set because it’s outside of ./
    rollupOptions: {
      input: {
        main: resolve( 'src/js/main.ts')
      }
    }
  }
})