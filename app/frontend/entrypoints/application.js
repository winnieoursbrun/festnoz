import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { MotionPlugin } from '@vueuse/motion'
import App from '../App.vue'
import router from '../router'
import '../assets/stylesheets/application.css'
import 'leaflet/dist/leaflet.css'

// Sentry imports
import * as Sentry from "@sentry/vue";
import { createSentryPiniaPlugin } from "@sentry/vue";

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

// Initialize Sentry for error tracking and performance monitoring
Sentry.init({
  app,
  dsn: "http://examplePublicKey@sentry.festnoz.link/0",
  // Adds request headers and IP for users, for more info visit:
  // https://docs.sentry.io/platforms/javascript/guides/vue/configuration/options/#sendDefaultPii
  sendDefaultPii: true,
  integrations: [
    Sentry.browserTracingIntegration({ router }),
    Sentry.replayIntegration(),
    Sentry.feedbackIntegration({
      // Additional SDK configuration goes in here, for example:
      colorScheme: "system",
    }),
  ],
  // Enable logs to be sent to Sentry
  enableLogs: true,
  // Set tracesSampleRate to 1.0 to capture 100%
  // of transactions for tracing.
  // We recommend adjusting this value in production
  // Learn more at
  // https://docs.sentry.io/platforms/javascript/configuration/options/#traces-sample-rate
  tracesSampleRate: 1.0,
  // Set `tracePropagationTargets` to control for which URLs trace propagation should be enabled
  tracePropagationTargets: ["localhost", /^https:\/\/yourserver\.io\/api/],
  // Capture Replay for 10% of all sessions,
  // plus for 100% of sessions with an error
  // Learn more at
  // https://docs.sentry.io/platforms/javascript/session-replay/configuration/#general-integration-configuration
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
});
pinia.use(createSentryPiniaPlugin()); // Automatically capture Pinia state and actions in Sentry

app.use(pinia)
app.use(router)

app.mount('#app')
