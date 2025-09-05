import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

// https://vitejs.dev/config/
export default defineConfig(({ command, mode }) => {
  // Load env file based on `mode` in the current working directory.
  const env = loadEnv(mode, process.cwd(), '');
  
  return {
    plugins: [react()],
    base: mode === 'production' ? '/' : './', // Use absolute paths in production
    optimizeDeps: {
      exclude: ['lucide-react'],
      include: ['react', 'react-dom', 'axios', 'zustand']
    },
    resolve: {
      alias: {
        '@': resolve(__dirname, './src'),
        '@components': resolve(__dirname, './src/components'),
        '@services': resolve(__dirname, './src/services'),
        '@utils': resolve(__dirname, './src/utils'),
        '@stores': resolve(__dirname, './src/stores'),
        '@context': resolve(__dirname, './src/context'),
        '@assets': resolve(__dirname, './src/assets')
      }
    },
    build: {
      outDir: 'dist',
      sourcemap: mode === 'production' ? false : true,
      minify: mode === 'production' ? 'esbuild' : false,
      cssCodeSplit: true,
      chunkSizeWarningLimit: 1000,
      rollupOptions: {
        output: {
          manualChunks: {
            'vendor-react': ['react', 'react-dom'],
            'vendor-router': ['react-router-dom'],
            'vendor-ui': ['framer-motion', 'lucide-react', 'react-hot-toast'],
            'vendor-forms': ['react-hook-form', '@hookform/resolvers', 'zod'],
            'vendor-http': ['axios'],
            'vendor-state': ['zustand', 'immer'],
            'vendor-paypal': ['@paypal/react-paypal-js']
          },
          entryFileNames: 'assets/[name]-[hash].js',
          chunkFileNames: 'assets/[name]-[hash].js',
          assetFileNames: 'assets/[name]-[hash].[ext]'
        }
      },
      target: 'esnext',
      assetsInlineLimit: 4096
    },
    server: {
      port: 5173,
      host: true,
      open: true,
      cors: true
    },
    preview: {
      port: 4173,
      host: true,
      cors: true
    },
    define: {
      __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
      __BUILD_DATE__: JSON.stringify(new Date().toISOString())
    },
    esbuild: {
      drop: mode === 'production' ? ['console', 'debugger'] : []
    }
  };
});
