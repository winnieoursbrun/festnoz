<template>
  <div class="w-full h-full min-h-[400px]">
    <div ref="mapContainer" class="w-full h-full"></div>
    <div ref="popupEl" class="concert-popup-ol">
      <button class="popup-close-btn" @click="closePopup">✕</button>
      <div ref="popupContent"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import Map from 'ol/Map.js'
import View from 'ol/View.js'
import TileLayer from 'ol/layer/Tile.js'
import OSM from 'ol/source/OSM.js'
import VectorLayer from 'ol/layer/Vector.js'
import VectorSource from 'ol/source/Vector.js'
import Feature from 'ol/Feature.js'
import { LineString } from 'ol/geom.js'
import { fromLonLat } from 'ol/proj.js'
import { boundingExtent } from 'ol/extent.js'
import Overlay from 'ol/Overlay.js'
import Style from 'ol/style/Style.js'
import Stroke from 'ol/style/Stroke.js'
import { defaults as defaultInteractions } from 'ol/interaction.js'
import MouseWheelZoom from 'ol/interaction/MouseWheelZoom.js'
import 'ol/ol.css'
import { formatDate } from '@/lib/utils'

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
const popupEl = ref(null)
const popupContent = ref(null)

let map = null
let view = null
let markerOverlays = []
let userMarkerOverlay = null
let tourPolylineLayer = null
let popupOverlay = null

onMounted(async () => {
  await nextTick()
  initMap()
})

onUnmounted(() => {
  window.removeEventListener('concert-clicked', handleConcertClick)
  if (map) {
    map.dispose()
    map = null
  }
})

watch(() => props.center, (newCenter) => {
  if (view && newCenter?.length === 2) {
    view.animate({
      center: fromLonLat([newCenter[1], newCenter[0]]),
      zoom: props.zoom,
      duration: 500
    })
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
    view = new View({
      center: fromLonLat([props.center[1], props.center[0]]),
      zoom: props.zoom,
      minZoom: 3,
      maxZoom: 18,
      constrainResolution: false
    })

    popupOverlay = new Overlay({
      element: popupEl.value,
      autoPan: { animation: { duration: 250 } },
      positioning: 'bottom-center',
      offset: [0, -10]
    })

    map = new Map({
      target: mapContainer.value,
      layers: [
        new TileLayer({
          preload: 4,
          source: new OSM()
        })
      ],
      view,
      overlays: [popupOverlay],
      interactions: defaultInteractions({ mouseWheelZoom: false }).extend([
        new MouseWheelZoom({
          useAnchor: true,
          duration: 300,
          timeout: 80
        })
      ])
    })

    updateUserMarker(props.center)
    updateMarkers()
    window.addEventListener('concert-clicked', handleConcertClick)
  } catch (error) {
    console.error('Failed to initialize map:', error)
  }
}

function updateUserMarker(center) {
  if (!map) return

  if (userMarkerOverlay) {
    map.removeOverlay(userMarkerOverlay)
    userMarkerOverlay = null
  }

  const el = document.createElement('div')
  el.innerHTML = `
    <div style="
      background: #3b82f6;
      width: 16px;
      height: 16px;
      border-radius: 50%;
      border: 3px solid white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.3);
      cursor: pointer;
    "></div>
  `

  userMarkerOverlay = new Overlay({
    element: el,
    positioning: 'center-center',
    stopEvent: false
  })
  userMarkerOverlay.setPosition(fromLonLat([center[1], center[0]]))
  map.addOverlay(userMarkerOverlay)
}

function updateMarkers() {
  if (!map) return

  markerOverlays.forEach(o => map.removeOverlay(o))
  markerOverlays = []

  if (tourPolylineLayer) {
    map.removeLayer(tourPolylineLayer)
    tourPolylineLayer = null
  }

  props.concerts.forEach(concert => {
    if (!concert.latitude || !concert.longitude) {
      console.warn('Concert missing coordinates:', concert)
      return
    }

    const artistImage = concert.artist?.primary_image_url || concert.artist?.image_url

    const el = document.createElement('div')
    el.style.cursor = 'pointer'

    if (artistImage) {
      el.innerHTML = `
        <div style="
          width: 40px;
          height: 40px;
          border-radius: 50%;
          border: 3px solid white;
          box-shadow: 0 4px 6px rgba(0,0,0,0.3);
          overflow: hidden;
          transition: transform 0.2s;
          background: linear-gradient(135deg, #9333ea 0%, #7c3aed 100%);
        ">
          <img
            src="${artistImage}"
            alt="${escapeHtml(concert.artist?.name || '')}"
            style="width:100%;height:100%;object-fit:cover;"
            onerror="this.parentElement.innerHTML='<div style=&quot;width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:20px;&quot;>🎵</div>'"
          />
        </div>
      `
    } else {
      el.innerHTML = `
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
          transition: transform 0.2s;
        ">🎵</div>
      `
    }

    const markerDiv = el.firstElementChild
    markerDiv.addEventListener('mouseover', () => { markerDiv.style.transform = 'scale(1.2)' })
    markerDiv.addEventListener('mouseout', () => { markerDiv.style.transform = 'scale(1)' })
    el.addEventListener('click', (e) => {
      e.stopPropagation()
      showPopup(concert)
    })

    const overlay = new Overlay({
      element: el,
      positioning: 'center-center',
      stopEvent: true
    })
    overlay.setPosition(fromLonLat([concert.longitude, concert.latitude]))
    map.addOverlay(overlay)
    markerOverlays.push(overlay)
  })

  // Draw tour polyline when filtering by a single artist
  if (props.selectedArtistId && props.concerts.length > 1) {
    const sortedConcerts = [...props.concerts].sort((a, b) =>
      new Date(a.starts_at).getTime() - new Date(b.starts_at).getTime()
    )

    const coordinates = sortedConcerts.map(c =>
      fromLonLat([c.longitude, c.latitude])
    )

    const feature = new Feature({ geometry: new LineString(coordinates) })
    feature.setStyle(new Style({
      stroke: new Stroke({
        color: '#9333ea',
        width: 4,
        lineDash: [10, 10]
      })
    }))

    tourPolylineLayer = new VectorLayer({
      source: new VectorSource({ features: [feature] }),
      opacity: 0.8
    })
    map.addLayer(tourPolylineLayer)
  }

  // Fit extent to show all markers
  if (props.concerts.length > 0 && view) {
    try {
      const points = [
        ...props.concerts.map(c => fromLonLat([c.longitude, c.latitude])),
        fromLonLat([props.center[1], props.center[0]])
      ]
      const extent = boundingExtent(points)
      view.fit(extent, {
        padding: [50, 50],
        maxZoom: 13,
        duration: 500
      })
    } catch (error) {
      console.error('Failed to fit extent:', error)
    }
  }
}

function showPopup(concert) {
  if (!popupContent.value || !popupOverlay) return

  popupContent.value.innerHTML = `
    <div style="min-width:200px;padding:8px;">
      <h3 style="margin:0 0 8px;font-size:16px;font-weight:bold;color:#1f2937;">${escapeHtml(concert.title)}</h3>
      <p style="margin:0 0 4px;font-size:14px;color:#6b7280;">${escapeHtml(concert.artist?.name || 'Unknown Artist')}</p>
      <p style="margin:0 0 4px;font-size:12px;color:#9ca3af;">📍 ${escapeHtml(concert.venue_name)}</p>
      <p style="margin:0 0 8px;font-size:12px;color:#9ca3af;">📅 ${formatDate(concert.starts_at)}</p>
      ${concert.distance ? `<p style="margin:0 0 8px;font-size:12px;color:#9ca3af;">🗺️ ${Math.round(concert.distance * 10) / 10} km away</p>` : ''}
      <button
        onclick="window.dispatchEvent(new CustomEvent('concert-clicked', { detail: ${JSON.stringify(concert).replace(/"/g, '&quot;')} }))"
        style="background:#9333ea;color:white;border:none;padding:6px 12px;border-radius:6px;cursor:pointer;font-size:12px;font-weight:500;width:100%;"
        onmouseover="this.style.background='#7c3aed'"
        onmouseout="this.style.background='#9333ea'"
      >View Details</button>
    </div>
  `

  popupEl.value.style.display = 'block'
  popupOverlay.setPosition(fromLonLat([concert.longitude, concert.latitude]))
}

function closePopup() {
  if (popupOverlay) popupOverlay.setPosition(undefined)
  if (popupEl.value) popupEl.value.style.display = 'none'
}

function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text || ''
  return div.innerHTML
}

function handleConcertClick(event) {
  emit('concert-click', event.detail)
}
</script>

<style scoped>
.concert-popup-ol {
  display: none;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  min-width: 220px;
  position: relative;
}

.popup-close-btn {
  position: absolute;
  top: 6px;
  right: 8px;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  color: #6b7280;
  line-height: 1;
  padding: 2px;
  z-index: 1;
}

.popup-close-btn:hover {
  color: #1f2937;
}

/* OL zoom controls */
:deep(.ol-zoom) {
  top: 10px;
  left: 10px;
}

:deep(.ol-zoom button) {
  background: rgba(0, 0, 0, 0.6);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
  font-size: 18px;
}

:deep(.ol-zoom button:hover) {
  background: rgba(147, 51, 234, 0.8);
}

:deep(.ol-attribution) {
  font-family: inherit;
  font-size: 10px;
}
</style>
