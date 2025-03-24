import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { readdirSync } from 'fs';
import chalk from 'chalk';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export async function loadPlugins() {
  const pluginsDir = join(__dirname, 'plugins');
  const plugins = {};
  
  try {
    const files = readdirSync(pluginsDir);
    for (const file of files) {
      if (file.endsWith('.mjs')) {
        const plugin = await import(`./plugins/${file}`);
        const name = file.replace('.mjs', '');
        plugins[name] = plugin;
      }
    }
    return plugins;
  } catch (error) {
    console.error(chalk.hex('#ff5f00')('[ERROR]'), 'Failed to load plugins:', error.message);
    process.exit(1);
  }
}