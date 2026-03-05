import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useUsersStore } from '../users'
import api from '../../services/api'

vi.mock('../../services/api', () => ({
  default: { get: vi.fn(), post: vi.fn(), put: vi.fn(), delete: vi.fn() }
}))

describe('Users Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  describe('Initial State', () => {
    it('initializes with empty users array', () => {
      const store = useUsersStore()
      expect(store.users).toEqual([])
    })

    it('initializes with null currentUser', () => {
      const store = useUsersStore()
      expect(store.currentUser).toBeNull()
    })

    it('initializes with loading false', () => {
      const store = useUsersStore()
      expect(store.loading).toBe(false)
    })

    it('initializes with null error', () => {
      const store = useUsersStore()
      expect(store.error).toBeNull()
    })
  })

  describe('Getters', () => {
    it('userCount reflects users array length', () => {
      const store = useUsersStore()
      expect(store.userCount).toBe(0)
      store.users = [{ id: 1 }, { id: 2 }, { id: 3 }] as any
      expect(store.userCount).toBe(3)
    })

    it('adminCount counts only users with admin=true', () => {
      const store = useUsersStore()
      store.users = [
        { id: 1, admin: true },
        { id: 2, admin: false },
        { id: 3, admin: true },
        { id: 4, admin: false },
      ] as any
      expect(store.adminCount).toBe(2)
    })

    it('adminCount returns 0 when no admins', () => {
      const store = useUsersStore()
      store.users = [{ id: 1, admin: false }, { id: 2, admin: false }] as any
      expect(store.adminCount).toBe(0)
    })

    it('adminCount returns 0 for empty array', () => {
      const store = useUsersStore()
      expect(store.adminCount).toBe(0)
    })
  })

  describe('fetchUsers', () => {
    it('populates users array with response data', async () => {
      const mockUsers = [{ id: 1, email: 'a@example.com' }, { id: 2, email: 'b@example.com' }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: mockUsers } as any)

      const store = useUsersStore()
      await store.fetchUsers()

      expect(store.users).toEqual(mockUsers)
      expect(api.get).toHaveBeenCalledWith('/api/v1/users')
    })

    it('returns the fetched users', async () => {
      const mockUsers = [{ id: 1 }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: mockUsers } as any)

      const store = useUsersStore()
      const result = await store.fetchUsers()

      expect(result).toEqual(mockUsers)
    })

    it('sets loading to false after fetch', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: [] } as any)

      const store = useUsersStore()
      await store.fetchUsers()

      expect(store.loading).toBe(false)
    })

    it('sets error and throws on failure', async () => {
      const error = { response: { data: { error: 'Unauthorized' } } }
      vi.mocked(api.get).mockRejectedValueOnce(error)

      const store = useUsersStore()
      await expect(store.fetchUsers()).rejects.toEqual(error)
      expect(store.error).toBe('Unauthorized')
    })
  })

  describe('fetchUser', () => {
    it('sets currentUser with fetched user', async () => {
      const mockUser = { id: 1, email: 'test@example.com', admin: false }
      vi.mocked(api.get).mockResolvedValueOnce({ data: mockUser } as any)

      const store = useUsersStore()
      await store.fetchUser(1)

      expect(store.currentUser).toEqual(mockUser)
      expect(api.get).toHaveBeenCalledWith('/api/v1/users/1')
    })

    it('returns the fetched user', async () => {
      const mockUser = { id: 2, email: 'user@example.com' }
      vi.mocked(api.get).mockResolvedValueOnce({ data: mockUser } as any)

      const store = useUsersStore()
      const result = await store.fetchUser(2)

      expect(result).toEqual(mockUser)
    })
  })

  describe('createUser', () => {
    it('adds new user to users array', async () => {
      const newUser = { id: 10, email: 'new@example.com' }
      vi.mocked(api.post).mockResolvedValueOnce({ data: newUser } as any)

      const store = useUsersStore()
      await store.createUser({ email: 'new@example.com', password: 'password' })

      expect(store.users).toContainEqual(newUser)
    })

    it('calls correct API endpoint with user data', async () => {
      const userData = { email: 'new@example.com', password: 'password' }
      vi.mocked(api.post).mockResolvedValueOnce({ data: { id: 1, ...userData } } as any)

      const store = useUsersStore()
      await store.createUser(userData)

      expect(api.post).toHaveBeenCalledWith('/api/v1/users', userData)
    })

    it('sets error and throws on validation failure', async () => {
      const error = { response: { data: { errors: ['Email is invalid'] } } }
      vi.mocked(api.post).mockRejectedValueOnce(error)

      const store = useUsersStore()
      await expect(store.createUser({})).rejects.toEqual(error)
      expect(store.error).toBe('Email is invalid')
    })
  })

  describe('updateUser', () => {
    it('updates existing user in users array', async () => {
      const updatedUser = { id: 1, email: 'updated@example.com', admin: false }
      vi.mocked(api.put).mockResolvedValueOnce({ data: updatedUser } as any)

      const store = useUsersStore()
      store.users = [{ id: 1, email: 'old@example.com' }, { id: 2, email: 'other@example.com' }] as any
      await store.updateUser(1, { email: 'updated@example.com' })

      expect(store.users[0]).toEqual(updatedUser)
    })

    it('updates currentUser if it matches the updated id', async () => {
      const updatedUser = { id: 1, email: 'updated@example.com' }
      vi.mocked(api.put).mockResolvedValueOnce({ data: updatedUser } as any)

      const store = useUsersStore()
      store.users = [{ id: 1, email: 'old@example.com' }] as any
      store.currentUser = { id: 1, email: 'old@example.com' } as any
      await store.updateUser(1, { email: 'updated@example.com' })

      expect(store.currentUser).toEqual(updatedUser)
    })

    it('does not update currentUser if id does not match', async () => {
      const updatedUser = { id: 2, email: 'updated@example.com' }
      vi.mocked(api.put).mockResolvedValueOnce({ data: updatedUser } as any)

      const store = useUsersStore()
      store.users = [{ id: 2, email: 'other@example.com' }] as any
      store.currentUser = { id: 1, email: 'current@example.com' } as any
      await store.updateUser(2, { email: 'updated@example.com' })

      expect(store.currentUser).toEqual({ id: 1, email: 'current@example.com' })
    })
  })

  describe('deleteUser', () => {
    it('removes user from users array', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useUsersStore()
      store.users = [{ id: 1 }, { id: 2 }] as any
      await store.deleteUser(1)

      expect(store.users).toHaveLength(1)
      expect(store.users.find((u: any) => u.id === 1)).toBeUndefined()
    })

    it('clears currentUser if it matches deleted id', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useUsersStore()
      store.users = [{ id: 1 }] as any
      store.currentUser = { id: 1, email: 'test@example.com' } as any
      await store.deleteUser(1)

      expect(store.currentUser).toBeNull()
    })

    it('does not clear currentUser if id does not match', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useUsersStore()
      store.users = [{ id: 2 }] as any
      store.currentUser = { id: 1, email: 'current@example.com' } as any
      await store.deleteUser(2)

      expect(store.currentUser).toEqual({ id: 1, email: 'current@example.com' })
    })

    it('calls correct API endpoint', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useUsersStore()
      store.users = [{ id: 5 }] as any
      await store.deleteUser(5)

      expect(api.delete).toHaveBeenCalledWith('/api/v1/users/5')
    })
  })
})
