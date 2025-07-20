const { environment } = require('@rails/webpacker')
const webpack = require("webpack")

// Configurar algoritmo de hash compatible con Node.js 20+
environment.config.set('output.hashFunction', 'md4')

environment.plugins.append("Provide", new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        'window.jQuery': 'jquery',
        Popper: ['popper.js', 'default']
    })
)

module.exports = environment