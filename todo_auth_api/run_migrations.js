import sequelize from './db.js';
import { readdirSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function runMigrations() {
  try {
    console.log('Checking migrations...');

    const migrationsDir = join(__dirname, 'migrations');
    const migrationFiles = readdirSync(migrationsDir)
      .filter(file => file.endsWith('.js'))
      .sort();

    for (const file of migrationFiles) {
      try {
        console.log(`Running migration: ${file}`);
        const migration = await import(join(migrationsDir, file));

        if (migration.up) {
          await migration.up(sequelize.getQueryInterface(), sequelize.Sequelize);
          console.log(`✓ ${file} completed`);
        }
      } catch (error) {
        // If migration fails because column already exists, skip it
        if (error.message && (
          error.message.includes('already exists') ||
          error.message.includes('duplicate column')
        )) {
          console.log(`⊘ ${file} already applied, skipping`);
        } else {
          // For other errors, log but continue
          console.warn(`⚠ ${file} failed:`, error.message);
        }
      }
    }

    console.log('Migration check completed!');
  } catch (error) {
    console.error('Migration process failed:', error);
    // Don't exit with error code - let the app start anyway
  }
}

runMigrations();
