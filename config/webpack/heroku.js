process.env.NODE_ENV = process.env.NODE_ENV || 'production'

// Configurar Node.js para usar algoritmos de hash compatibles
process.env.NODE_OPTIONS = process.env.NODE_OPTIONS || '--openssl-legacy-provider'

const environment = require('./environment')

// Configurar algoritmo de hash compatible
environment.config.set('output.hashFunction', 'md4')

module.exports = environment.toWebpackConfig() 