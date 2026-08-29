const eslint = require('@eslint/js');

module.exports = [
  eslint.configs.recommended,
  {
    files: ['grammar.js'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'commonjs',
      globals: {
        alias: 'readonly',
        choice: 'readonly',
        field: 'readonly',
        grammar: 'readonly',
        optional: 'readonly',
        prec: 'readonly',
        repeat: 'readonly',
        seq: 'readonly',
        token: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      eqeqeq: ['error', 'always'],
      curly: ['error', 'multi-line'],
    },
  },
];
