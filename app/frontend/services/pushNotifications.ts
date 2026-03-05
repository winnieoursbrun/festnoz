import api from './api.js'

function base64ToUint8Array(base64String: string): Uint8Array {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
  const rawData = window.atob(base64)
  const outputArray: Uint8Array = new Uint8Array(rawData.length)

  for (let i = 0; i < rawData.length; i += 1) {
    outputArray[i] = rawData.charCodeAt(i)
  }

  return outputArray
}

async function getOrCreateServiceWorkerRegistration(): Promise<ServiceWorkerRegistration> {
  if (!('serviceWorker' in navigator)) {
    throw new Error('Service worker is not supported on this device')
  }

  const existing = await navigator.serviceWorker.getRegistration('/')

  if (!existing) {
    await navigator.serviceWorker.register('/service-worker.js', { scope: '/' })
  }

  const readyRegistration = await navigator.serviceWorker.ready
  return readyRegistration
}

function extractSubscriptionKeys(subscription: PushSubscription): { p256dh: string; auth: string } {
  const p256dhBuffer = subscription.getKey('p256dh')
  const authBuffer = subscription.getKey('auth')

  if (!p256dhBuffer || !authBuffer) {
    throw new Error('Missing browser push subscription keys')
  }

  return {
    p256dh: window.btoa(String.fromCharCode(...new Uint8Array(p256dhBuffer))),
    auth: window.btoa(String.fromCharCode(...new Uint8Array(authBuffer)))
  }
}

async function syncSubscriptionToBackend(subscription: PushSubscription): Promise<{ id: number; endpoint: string }> {
  const keys = extractSubscriptionKeys(subscription)

  const response = await api.post('/api/v1/account/push_subscriptions', {
    push_subscription: {
      endpoint: subscription.endpoint,
      expiration_time: subscription.expirationTime,
      keys
    }
  })

  return response.data.push_subscription
}

export function isPushSupported(): boolean {
  return (
    typeof window !== 'undefined' &&
    'serviceWorker' in navigator &&
    'PushManager' in window &&
    'Notification' in window
  )
}

export function getNotificationPermission(): NotificationPermission | 'unsupported' {
  if (!isPushSupported()) return 'unsupported'
  return Notification.permission
}

export async function listPushSubscriptions(): Promise<any[]> {
  const response = await api.get('/api/v1/account/push_subscriptions')
  return response.data.push_subscriptions || []
}

export async function subscribeToPush(): Promise<{ id: number; endpoint: string }> {
  if (!isPushSupported()) {
    throw new Error('Push notifications are not supported on this device')
  }

  if (!window.isSecureContext) {
    throw new Error('Push notifications require HTTPS (or localhost in development)')
  }

  if (Notification.permission === 'default') {
    const permission = await Notification.requestPermission()
    if (permission !== 'granted') {
      throw new Error('Notification permission was not granted')
    }
  } else if (Notification.permission !== 'granted') {
    throw new Error('Notification permission is denied')
  }

  const registration = await getOrCreateServiceWorkerRegistration()
  const existingSubscription = await registration.pushManager.getSubscription()

  if (existingSubscription) {
    return syncSubscriptionToBackend(existingSubscription)
  }

  const keyResponse = await api.get('/api/v1/account/push_subscriptions/public_key')
  const rawApplicationServerKey = base64ToUint8Array(keyResponse.data.public_key)
  const applicationServerKeyBuffer = new ArrayBuffer(rawApplicationServerKey.length)
  new Uint8Array(applicationServerKeyBuffer).set(rawApplicationServerKey)
  const applicationServerKey = new Uint8Array(applicationServerKeyBuffer)

  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey
  })

  return syncSubscriptionToBackend(subscription)
}

export async function unsubscribeFromPush(subscriptionId: number): Promise<void> {
  await api.delete(`/api/v1/account/push_subscriptions/${subscriptionId}`)
}

export async function sendTestPushNotification(): Promise<void> {
  await api.post('/api/v1/account/push_subscriptions/test')
}
