import axios from 'axios'

const nominatim = axios.create({
  baseURL: 'https://nominatim.openstreetmap.org',
  headers: {
    'Accept': 'application/json'
  }
})

/**
 * Search for a location by query string
 * @param {string} query - Search query (e.g., "Quimper, France")
 * @returns {Promise<Array>} Array of location results
 */
export async function searchLocation(query) {
  try {
    const response = await nominatim.get('/search', {
      params: {
        q: query,
        format: 'json',
        limit: 5,
        addressdetails: 1
      }
    })
    return response.data
  } catch (error) {
    console.error('Geocoding error:', error)
    throw error
  }
}

/**
 * Reverse geocode coordinates to address
 * @param {number} lat - Latitude
 * @param {number} lng - Longitude
 * @returns {Promise<Object>} Location details
 */
export async function reverseGeocode(lat, lng) {
  try {
    const response = await nominatim.get('/reverse', {
      params: {
        lat,
        lon: lng,
        format: 'json',
        addressdetails: 1
      }
    })
    return response.data
  } catch (error) {
    console.error('Reverse geocoding error:', error)
    throw error
  }
}

/**
 * Get user's current location
 * @returns {Promise<Object>} {lat, lng}
 */
export function getCurrentLocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation is not supported by your browser'))
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          lat: position.coords.latitude,
          lng: position.coords.longitude
        })
      },
      (error) => {
        reject(error)
      }
    )
  })
}
