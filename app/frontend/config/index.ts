/**
 * Base URL for the Rails backend API.
 * In production, frontend and backend share the same origin so '/' is correct.
 * Override with VITE_API_URL when the API is on a different origin (e.g. during development
 * against a remote staging server).
 */
export const backendUrl: string = import.meta.env.VITE_API_URL || '/'
