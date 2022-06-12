import commonjs from '@rollup/plugin-commonjs';

export default {
  input: 'out-tsc/entry.js',
  plugins: [commonjs()],
  sourceMap: true,
  output: {
    file: 'docs/entry.js',
    format: 'iife',
  },
};
