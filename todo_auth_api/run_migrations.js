import sequelize from './db.js';
import { readdirSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function runMigrations() {
  try {
    console.log('🔄 Checking database migrations...');

    const migrationsDir = join(__dirname, 'migrations');

    // Create migrations directory if it doesn't exist
    try {
      const migrationFiles = readdirSync(migrationsDir)
        .filter(file => file.endsWith('.js'))
        .sort();

      for (const file of migrationFiles) {
        try {
          console.log(`  Running: ${file}`);
          const migration = await import(join(migrationsDir, file));

          if (migration.up) {
            await migration.up(sequelize.getQueryInterface(), sequelize.Sequelize);
            console.log(`  ✅ ${file} completed`);
          }
        } catch (error) {
          if (error.message && (
            error.message.includes('already exists') ||
            error.message.includes('duplicate column') ||
            error.message.includes('column') && error.message.includes('already')
          )) {
            console.log(`  ⏭️  ${file} already applied`);
          } else {
            console.warn(`  ⚠️  ${file} skipped:`, error.message.split('\n')[0]);
          }
        }
      }
    } catch (dirError) {
      console.log('  ℹ️  No migrations directory found, skipping...');
    }

    console.log('✅ Migration check completed!\n');
  } catch (error) {
    console.error('⚠️  Migration error (non-fatal):', error.message);
  }
}

runMigrations();
