/**
 * Base URL for the Rails backend API.
 * In production, frontend and backend share the same origin so '' (empty string) is correct.
 * Override with VITE_API_URL when the API is on a different origin (e.g. during development
 * against a remote staging server).
 *
 * NOTE: Do NOT use '/' as the default — `${backendUrl}/api/auth/login` would produce
 * the protocol-relative URL `//api/auth/login`, which the browser resolves as
 * http://api/auth/login (treating "api" as a hostname).
 */
export const backendUrl: string = import.meta.env.VITE_API_URL || ''
