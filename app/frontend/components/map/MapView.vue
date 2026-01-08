<template>
  <div ref="mapContainer" class="w-full h-full min-h-[400px]"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import L from 'leaflet'

const props = defineProps({
  center: {
    type: Array,
    required: true
  },
  zoom: {
    type: Number,
    default: 10
  },
  concerts: {
    type: Array,
    default: () => []
  },
  selectedArtistId: {
    type: Number,
    default: null
  }
})

const emit = defineEmits(['concert-click'])

const mapContainer = ref(null)
let map = null
let markers = []
let userMarker = null
let tourPolyline = null

onMounted(async () => {
  await nextTick()
  initMap()
})

onUnmounted(() => {
  if (map) {
    map.off()
    map.remove()
    map = null
  }
})

watch(() => props.center, (newCenter) => {
  if (map && newCenter && newCenter.length === 2) {
    map.setView(newCenter, props.zoom)
    updateUserMarker(newCenter)
  }
})

watch(() => props.concerts, () => {
  updateMarkers()
}, { deep: true })

watch(() => props.selectedArtistId, () => {
  updateMarkers()
})

function initMap() {
  if (!mapContainer.value) {
    console.error('Map container not found')
    return
  }

  try {
    // Initialize map with better options
    map = L.map(mapContainer.value, {
      center: props.center,
      zoom: props.zoom,
      zoomControl: true,
      scrollWheelZoom: true,
      doubleClickZoom: true,
      dragging: true,
      minZoom: 3,
      maxZoom: 18
    })

    // Add OpenStreetMap tiles with better configuration
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19,
      minZoom: 3,
      subdomains: ['a', 'b', 'c'],
      crossOrigin: true
    }).addTo(map)

    // Force map to invalidate size after initialization
    setTimeout(() => {
      if (map) {
        map.invalidateSize()
      }
    }, 100)

    // Add user location marker
    updateUserMarker(props.center)

    // Add concert markers
    updateMarkers()

    // Listen for custom concert-clicked events from popup buttons
    window.addEventListener('concert-clicked', handleConcertClick)
  } catch (error) {
    console.error('Failed to initialize map:', error)
  }
}

function updateUserMarker(center) {
  if (!map) return

  // Remove existing user marker
  if (userMarker) {
    map.removeLayer(userMarker)
  }

  // Create user location marker
  const userIcon = L.divIcon({
    html: '<div style="background: #3b82f6; width: 16px; height: 16px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>',
    className: '',
    iconSize: [22, 22],
    iconAnchor: [11, 11]
  })

  userMarker = L.marker(center, { icon: userIcon })
    .addTo(map)
    .bindPopup('<div style="text-align: center; padding: 4px; font-weight: 600;">Your Location</div>')
}

function updateMarkers() {
  if (!map) return

  // Remove existing concert markers
  markers.forEach(marker => map.removeLayer(marker))
  markers = []

  // Remove existing tour polyline
  if (tourPolyline) {
    map.removeLayer(tourPolyline)
    tourPolyline = null
  }

  // Add new markers for each concert
  props.concerts.forEach(concert => {
    if (!concert.latitude || !concert.longitude) {
      console.warn('Concert missing coordinates:', concert)
      return
    }

    // Use artist profile picture if available, otherwise use emoji
    const artistImage = concert.artist?.primary_image_url || concert.artist?.image_url

    const markerHtml = artistImage
      ? `
        <div style="
          width: 40px;
          height: 40px;
          border-radius: 50%;
          border: 3px solid white;
          box-shadow: 0 4px 6px rgba(0,0,0,0.3);
          overflow: hidden;
          cursor: pointer;
          transition: transform 0.2s;
          background: linear-gradient(135deg, #9333ea 0%, #7c3aed 100%);
        " onmouseover="this.style.transform='scale(1.2)'" onmouseout="this.style.transform='scale(1)'">
          <img
            src="${artistImage}"
            alt="${escapeHtml(concert.artist?.name || '')}"
            style="width: 100%; height: 100%; object-fit: cover;"
            onerror="this.parentElement.innerHTML='<div style=&quot;width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; font-size: 20px;&quot;>🎵</div>'"
          />
        </div>
      `
      : `
        <div style="
          background: linear-gradient(135deg, #9333ea 0%, #7c3aed 100%);
          width: 40px;
          height: 40px;
          border-radius: 50%;
          border: 3px solid white;
          box-shadow: 0 4px 6px rgba(0,0,0,0.3);
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 20px;
          cursor: pointer;
          transition: transform 0.2s;
        " onmouseover="this.style.transform='scale(1.2)'" onmouseout="this.style.transform='scale(1)'">
          🎵
        </div>
      `

    const concertIcon = L.divIcon({
      html: markerHtml,
      className: '',
      iconSize: [40, 40],
      iconAnchor: [20, 20],
      popupAnchor: [0, -20]
    })

    const marker = L.marker([concert.latitude, concert.longitude], {
      icon: concertIcon
    }).addTo(map)

    // Create popup content
    const popupContent = `
      <div style="min-width: 200px; padding: 8px;">
        <h3 style="margin: 0 0 8px 0; font-size: 16px; font-weight: bold; color: #1f2937;">
          ${escapeHtml(concert.title)}
        </h3>
        <p style="margin: 0 0 4px 0; font-size: 14px; color: #6b7280;">
          ${escapeHtml(concert.artist?.name || 'Unknown Artist')}
        </p>
        <p style="margin: 0 0 4px 0; font-size: 12px; color: #9ca3af;">
          📍 ${escapeHtml(concert.venue_name)}
        </p>
        <p style="margin: 0 0 8px 0; font-size: 12px; color: #9ca3af;">
          📅 ${new Date(concert.starts_at).toLocaleDateString()}
        </p>
        ${concert.distance ? `<p style="margin: 0 0 8px 0; font-size: 12px; color: #9ca3af;">🗺️ ${Math.round(concert.distance * 10) / 10} km away</p>` : ''}
        <button
          onclick="window.dispatchEvent(new CustomEvent('concert-clicked', { detail: ${JSON.stringify(concert).replace(/"/g, '&quot;')} }))"
          style="
            background: #9333ea;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 500;
            width: 100%;
          "
          onmouseover="this.style.background='#7c3aed'"
          onmouseout="this.style.background='#9333ea'"
        >
          View Details
        </button>
      </div>
    `

    marker.bindPopup(popupContent, {
      maxWidth: 300,
      className: 'concert-popup'
    })

    markers.push(marker)
  })

  // Draw tour polyline when filtering by a single artist
  if (props.selectedArtistId && props.concerts.length > 1) {
    // Sort concerts by date
    const sortedConcerts = [...props.concerts].sort((a, b) =>
      new Date(a.starts_at).getTime() - new Date(b.starts_at).getTime()
    )

    // Create array of coordinates
    const tourPath = sortedConcerts.map(concert => [concert.latitude, concert.longitude])

    // Draw polyline connecting concerts chronologically
    tourPolyline = L.polyline(tourPath, {
      color: '#9333ea',
      weight: 4,
      opacity: 0.8,
      dashArray: '10, 10',
      lineJoin: 'round',
      lineCap: 'round',
      smoothFactor: 1
    }).addTo(map)

    // Add popup to polyline showing it's a tour route
    const artistName = sortedConcerts[0]?.artist?.name || 'Artist'
    tourPolyline.bindPopup(`
      <div style="padding: 8px; text-align: center;">
        <strong style="color: #9333ea;">${escapeHtml(artistName)} Tour Route</strong><br/>
        <span style="font-size: 12px; color: #6b7280;">
          ${sortedConcerts.length} concerts chronologically
        </span>
      </div>
    `)
  }

  // Fit bounds to show all markers if there are concerts
  if (props.concerts.length > 0 && map) {
    try {
      const allPoints = [
        ...props.concerts.map(c => [c.latitude, c.longitude]),
        props.center
      ]

      const bounds = L.latLngBounds(allPoints)
      map.fitBounds(bounds, {
        padding: [50, 50],
        maxZoom: 13,
        animate: true
      })
    } catch (error) {
      console.error('Failed to fit bounds:', error)
    }
  }
}

function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

function handleConcertClick(event) {
  emit('concert-click', event.detail)
}

onUnmounted(() => {
  window.removeEventListener('concert-clicked', handleConcertClick)
})
</script>

<style scoped>
:deep(.concert-popup .leaflet-popup-content-wrapper) {
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  background: white;
}

:deep(.concert-popup .leaflet-popup-tip) {
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

:deep(.leaflet-container) {
  font-family: inherit;
}

:deep(.leaflet-popup-content) {
  margin: 0;
  width: auto !important;
}

:deep(.leaflet-popup-close-button) {
  color: #6b7280;
  font-size: 18px;
}

:deep(.leaflet-popup-close-button:hover) {
  color: #1f2937;
}
</style>
