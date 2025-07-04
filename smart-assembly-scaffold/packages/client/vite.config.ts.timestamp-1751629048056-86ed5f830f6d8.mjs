// vite.config.ts
import react from "file:///Users/thomasw/Documents/GitHub/build/Untitled/smart-assembly-scaffold/node_modules/.pnpm/@vitejs+plugin-react-swc@3.7.2_@swc+helpers@0.5.5_vite@5.4.14_@types+node@20.17.14_terser@5.37.0_/node_modules/@vitejs/plugin-react-swc/index.mjs";
import { defineConfig } from "file:///Users/thomasw/Documents/GitHub/build/Untitled/smart-assembly-scaffold/node_modules/.pnpm/vite@4.5.14_@types+node@22.7.5_terser@5.37.0/node_modules/vite/dist/node/index.js";
import svgr from "file:///Users/thomasw/Documents/GitHub/build/Untitled/smart-assembly-scaffold/node_modules/.pnpm/vite-plugin-svgr@4.3.0_rollup@4.31.0_typescript@5.7.3_vite@5.4.14_@types+node@20.17.14_terser@5.37.0_/node_modules/vite-plugin-svgr/dist/index.js";
var vite_config_default = defineConfig({
  plugins: [
    react(),
    svgr({
      svgrOptions: {
        exportType: "named",
        ref: true,
        svgo: false,
        titleProp: true
      },
      include: "**/*.svg"
    })
  ],
  server: {
    port: parseInt(process.env.VITE_PORT) || 3e3,
    fs: {
      strict: false
    }
  },
  build: {
    target: "es2022",
    minify: true,
    sourcemap: true,
    rollupOptions: {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      onLog(level, log, handler) {
        if (log.cause && log.cause.message === `Can't resolve original location of error.`) {
          return;
        }
        handler(level, log);
      }
    }
  },
  base: "./",
  resolve: {
    alias: {
      "@": "/src"
    }
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCIvVXNlcnMvdGhvbWFzdy9Eb2N1bWVudHMvR2l0SHViL2J1aWxkL1VudGl0bGVkL3NtYXJ0LWFzc2VtYmx5LXNjYWZmb2xkL3BhY2thZ2VzL2NsaWVudFwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiL1VzZXJzL3Rob21hc3cvRG9jdW1lbnRzL0dpdEh1Yi9idWlsZC9VbnRpdGxlZC9zbWFydC1hc3NlbWJseS1zY2FmZm9sZC9wYWNrYWdlcy9jbGllbnQvdml0ZS5jb25maWcudHNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL1VzZXJzL3Rob21hc3cvRG9jdW1lbnRzL0dpdEh1Yi9idWlsZC9VbnRpdGxlZC9zbWFydC1hc3NlbWJseS1zY2FmZm9sZC9wYWNrYWdlcy9jbGllbnQvdml0ZS5jb25maWcudHNcIjtpbXBvcnQgcmVhY3QgZnJvbSBcIkB2aXRlanMvcGx1Z2luLXJlYWN0LXN3Y1wiO1xuaW1wb3J0IHsgZGVmaW5lQ29uZmlnIH0gZnJvbSBcInZpdGVcIjtcbmltcG9ydCBzdmdyIGZyb20gXCJ2aXRlLXBsdWdpbi1zdmdyXCI7XG5cbi8vIGh0dHBzOi8vdml0ZWpzLmRldi9jb25maWcvXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoe1xuICBwbHVnaW5zOiBbXG4gICAgcmVhY3QoKSxcbiAgICBzdmdyKHtcbiAgICAgIHN2Z3JPcHRpb25zOiB7XG4gICAgICAgIGV4cG9ydFR5cGU6ICduYW1lZCcsXG4gICAgICAgIHJlZjogdHJ1ZSxcbiAgICAgICAgc3ZnbzogZmFsc2UsXG4gICAgICAgIHRpdGxlUHJvcDogdHJ1ZSxcbiAgICAgIH0sXG4gICAgICBpbmNsdWRlOiAnKiovKi5zdmcnLFxuICAgIH0pLFxuICBdLFxuICBzZXJ2ZXI6IHtcbiAgICBwb3J0OiBwYXJzZUludChwcm9jZXNzLmVudi5WSVRFX1BPUlQpIHx8IDMwMDAsXG4gICAgZnM6IHtcbiAgICAgIHN0cmljdDogZmFsc2UsXG4gICAgfSxcbiAgfSxcbiAgYnVpbGQ6IHtcbiAgICB0YXJnZXQ6IFwiZXMyMDIyXCIsXG4gICAgbWluaWZ5OiB0cnVlLFxuICAgIHNvdXJjZW1hcDogdHJ1ZSxcbiAgICByb2xsdXBPcHRpb25zOiB7XG4gICAgICAvLyBlc2xpbnQtZGlzYWJsZS1uZXh0LWxpbmUgQHR5cGVzY3JpcHQtZXNsaW50L25vLWV4cGxpY2l0LWFueVxuICAgICAgb25Mb2cobGV2ZWwsIGxvZzogYW55LCBoYW5kbGVyKSB7XG4gICAgICAgIGlmIChcbiAgICAgICAgICBsb2cuY2F1c2UgJiZcbiAgICAgICAgICBsb2cuY2F1c2UubWVzc2FnZSA9PT0gYENhbid0IHJlc29sdmUgb3JpZ2luYWwgbG9jYXRpb24gb2YgZXJyb3IuYFxuICAgICAgICApIHtcbiAgICAgICAgICByZXR1cm47XG4gICAgICAgIH1cbiAgICAgICAgaGFuZGxlcihsZXZlbCwgbG9nKTtcbiAgICAgIH0sXG4gICAgfSxcbiAgfSxcbiAgYmFzZTogXCIuL1wiLFxuICByZXNvbHZlOiB7XG4gICAgYWxpYXM6IHtcbiAgICAgICdAJzogJy9zcmMnLFxuICAgIH0sXG4gIH0sXG59KTtcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBb2IsT0FBTyxXQUFXO0FBQ3RjLFNBQVMsb0JBQW9CO0FBQzdCLE9BQU8sVUFBVTtBQUdqQixJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUMxQixTQUFTO0FBQUEsSUFDUCxNQUFNO0FBQUEsSUFDTixLQUFLO0FBQUEsTUFDSCxhQUFhO0FBQUEsUUFDWCxZQUFZO0FBQUEsUUFDWixLQUFLO0FBQUEsUUFDTCxNQUFNO0FBQUEsUUFDTixXQUFXO0FBQUEsTUFDYjtBQUFBLE1BQ0EsU0FBUztBQUFBLElBQ1gsQ0FBQztBQUFBLEVBQ0g7QUFBQSxFQUNBLFFBQVE7QUFBQSxJQUNOLE1BQU0sU0FBUyxRQUFRLElBQUksU0FBUyxLQUFLO0FBQUEsSUFDekMsSUFBSTtBQUFBLE1BQ0YsUUFBUTtBQUFBLElBQ1Y7QUFBQSxFQUNGO0FBQUEsRUFDQSxPQUFPO0FBQUEsSUFDTCxRQUFRO0FBQUEsSUFDUixRQUFRO0FBQUEsSUFDUixXQUFXO0FBQUEsSUFDWCxlQUFlO0FBQUE7QUFBQSxNQUViLE1BQU0sT0FBTyxLQUFVLFNBQVM7QUFDOUIsWUFDRSxJQUFJLFNBQ0osSUFBSSxNQUFNLFlBQVksNkNBQ3RCO0FBQ0E7QUFBQSxRQUNGO0FBQ0EsZ0JBQVEsT0FBTyxHQUFHO0FBQUEsTUFDcEI7QUFBQSxJQUNGO0FBQUEsRUFDRjtBQUFBLEVBQ0EsTUFBTTtBQUFBLEVBQ04sU0FBUztBQUFBLElBQ1AsT0FBTztBQUFBLE1BQ0wsS0FBSztBQUFBLElBQ1A7QUFBQSxFQUNGO0FBQ0YsQ0FBQzsiLAogICJuYW1lcyI6IFtdCn0K
