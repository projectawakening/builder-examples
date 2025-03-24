import { input } from '@inquirer/prompts';
import chalk from 'chalk';
import fs from 'fs';

const errorColor = chalk.hex('#ff5f00');

export async function validateInput(prompt, minLength, maxLength) {
  while (true) {
    const answer = await input({ 
      message: prompt
    });

    if (!answer) {
      console.log(errorColor('[ERROR]'), 'You did not enter anything.');
      continue;
    }

    if (answer.length < minLength) {
      console.log(errorColor('[ERROR]'), `Input was too short. Minimum length is ${minLength}.`);
      continue;
    }

    if (answer.length > maxLength) {
      console.log(errorColor('[ERROR]'), `Input was too long. Maximum length is ${maxLength}.`);
      continue;
    }

    return answer;
  }
}

export function updateFile(filePath, pattern, replacement, message = "") {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    content = content.replace(pattern, replacement);

    fs.writeFileSync(filePath, content);

    if(message != "") {
      console.log(chalk.green('[SUCCESS]'), `Updated ${chalk.yellow(message)} in ${filePath}`);
    } else {
      console.log(chalk.green('[SUCCESS]'), `Updated ${filePath}`);
    }
  } catch (error) {
    console.error(errorColor('[ERROR]'), `Failed to update ${filePath}:`, error.message);
    process.exit(1);
  }
}

export function updateFiles(updates) {
  updates.forEach(({ path, pattern, replacement, message }) => {
    if(message) {
      updateFile(path, pattern, replacement, message);
    } else {
      updateFile(path, pattern, replacement);
    }
  });
} 