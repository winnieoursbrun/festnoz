import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { MotionPlugin } from '@vueuse/motion'
import App from '../App.vue'
import router from '../router'
import '../assets/stylesheets/application.css'
import 'leaflet/dist/leaflet.css'

const app = createApp(App)
const pinia = createPinia()

// Motion plugin with global presets
app.use(MotionPlugin, {
  directives: {
    // Fade in from below
    'fade-up': {
      initial: { opacity: 0, y: 20 },
      enter: {
        opacity: 1,
        y: 0,
        transition: { type: 'spring', stiffness: 250, damping: 25 }
      }
    },
    // Fade in from above
    'fade-down': {
      initial: { opacity: 0, y: -20 },
      enter: {
        opacity: 1,
        y: 0,
        transition: { type: 'spring', stiffness: 250, damping: 25 }
      }
    },
    // Simple fade
    'fade': {
      initial: { opacity: 0 },
      enter: {
        opacity: 1,
        transition: { duration: 300 }
      }
    },
    // Scale in
    'scale': {
      initial: { opacity: 0, scale: 0.9 },
      enter: {
        opacity: 1,
        scale: 1,
        transition: { type: 'spring', stiffness: 300, damping: 20 }
      }
    },
    // Slide in from left
    'slide-left': {
      initial: { opacity: 0, x: -30 },
      enter: {
        opacity: 1,
        x: 0,
        transition: { type: 'spring', stiffness: 250, damping: 25 }
      }
    },
    // Slide in from right
    'slide-right': {
      initial: { opacity: 0, x: 30 },
      enter: {
        opacity: 1,
        x: 0,
        transition: { type: 'spring', stiffness: 250, damping: 25 }
      }
    },
    // Pop effect (for buttons, cards on hover)
    'pop': {
      initial: { scale: 1 },
      hovered: { scale: 1.05 },
      tapped: { scale: 0.95 }
    },
    // Lift effect (for cards)
    'lift': {
      initial: { y: 0 },
      hovered: {
        y: -8,
        transition: { type: 'spring', stiffness: 400, damping: 25 }
      }
    }
  }
})

app.use(pinia)
app.use(router)

app.mount('#app')
