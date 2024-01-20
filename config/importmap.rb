# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'

# Plugins
pin 'popper', to: 'popper.js', preload: true
pin 'bootstrap', to: 'bootstrap.min.js', preload: true
pin 'mapbox-gl', to: 'https://ga.jspm.io/npm:mapbox-gl@3.0.1/dist/mapbox-gl.js'
pin 'process', to: 'https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/process-production.js' # what is that? Is it needed?

pin 'swiper', to: 'https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.mjs'

# Components
pin_all_from 'app/javascript/components', under: 'components'
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
