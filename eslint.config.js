import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import prettier from 'eslint-plugin-prettier';
import security from 'eslint-plugin-security';
import n from 'eslint-plugin-n';
import importPlugin from 'eslint-plugin-import';

export default [
  js.configs.recommended, // Les bonnes règles JS de base
  ...tseslint.configs.recommended, // Les bonnes règles TS de base

  // ⚙️ Settings globaux pour les chemins d'alias "@"
  {
    settings: {
      'import/resolver': {
        typescript: {
          project: './tsconfig.json',
          alwaysTryTypes: true
        },
        node: {
          extensions: ['.ts', '.js']
        }
      }
    }
  },

  {
    files: ['src/**/*.ts'],
    ignores: ['**/__tests__/**'],
    plugins: {
      prettier,
      security,
      n,
      import: importPlugin
    },
    rules: {
      // TypeScript
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/explicit-function-return-type': 'warn',

      // Sécurité
      'security/detect-object-injection': 'error',
      'security/detect-unsafe-regex': 'error',

      // Node.js - DÉSACTIVÉ pour permettre les imports avec alias
      'n/no-missing-import': 'off',

      // Imports - ACTIVÉ pour gérer les alias TypeScript
      'import/no-unresolved': 'error',

      // Qualité de vie
      'no-console': 'warn',
      'prettier/prettier': 'error',
      quotes: ['error', 'single'],
      semi: ['error', 'always']
    },
    languageOptions: {
      parser: tseslint.parser
    }
  },

  {
    files: ['**/__tests__/**/*.test.ts'],
    languageOptions: {
      globals: {
        describe: 'readonly',
        it: 'readonly',
        expect: 'readonly',
        beforeEach: 'readonly',
        afterEach: 'readonly',
        beforeAll: 'readonly',
        afterAll: 'readonly',
        jest: 'readonly'
      }
    },
    rules: {
      'no-console': 'off',
      '@typescript-eslint/no-explicit-any': 'warn'
    }
  }
];