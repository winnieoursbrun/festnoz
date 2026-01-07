# Frontend Testing Guide

This document describes the frontend testing setup and how to run tests for the FestNoz application.

## Testing Stack

- **Framework**: Vitest (fast unit test framework for Vite)
- **Component Testing**: @vue/test-utils (official Vue testing library)
- **DOM Environment**: happy-dom (lightweight DOM implementation)
- **Mocking**: Vitest's built-in mocking capabilities

## Test Structure

```
app/frontend/
├── stores/
│   └── __tests__/
│       └── auth.spec.ts          # Auth store tests (22 tests)
├── services/
│   └── __tests__/
│       └── api.spec.ts            # API service tests (12 tests)
├── views/
│   └── __tests__/
│       └── AuthSuccess.spec.ts   # AuthSuccess component tests (9 tests)
└── test/
    └── setup.ts                   # Global test setup
```

## Running Tests

```bash
# Run tests in watch mode (interactive)
npm test

# Run all tests once
npm run test:run

# Run tests with UI
npm run test:ui

# Generate coverage report
npm run test:coverage
```

## Test Coverage

### Auth Store Tests (`stores/__tests__/auth.spec.ts`)

Tests the authentication state management:

- **Initial State** (4 tests)
  - ✓ Initializes with null user
  - ✓ Loads token from localStorage
  - ✓ Authentication state based on token presence

- **Login** (6 tests)
  - ✓ Successful login with credentials
  - ✓ Handles missing token in response
  - ✓ Error handling with messages
  - ✓ Network error handling
  - ✓ Loading state management

- **Signup** (2 tests)
  - ✓ Successful signup
  - ✓ Validation error handling

- **Logout** (2 tests)
  - ✓ Clears state on logout
  - ✓ Handles API errors gracefully

- **Fetch Current User** (4 tests)
  - ✓ Fetches user when authenticated
  - ✓ Skips when no token
  - ✓ Handles 401 errors
  - ✓ Error message handling

- **Computed Properties** (4 tests)
  - ✓ isAuthenticated computed
  - ✓ isAdmin computed

### API Service Tests (`services/__tests__/api.spec.ts`)

Tests the Axios instance configuration and interceptors:

- **Initialization** (3 tests)
  - ✓ Creates axios instance with correct config
  - ✓ Registers request interceptor
  - ✓ Registers response interceptor

- **Request Interceptor** (3 tests)
  - ✓ Adds Authorization header with token
  - ✓ No header when no token
  - ✓ Error handling

- **Response Interceptor** (4 tests)
  - ✓ Returns response unchanged on success
  - ✓ Clears token and redirects on 401
  - ✓ No redirect on other errors
  - ✓ Handles errors without response object

- **API Base URL** (2 tests)
  - ✓ Uses VITE_API_URL from environment
  - ✓ Defaults to 127.0.0.1:3000

### AuthSuccess Component Tests (`views/__tests__/AuthSuccess.spec.ts`)

Tests the authentication success redirect component:

- **Rendering** (1 test)
  - ✓ Displays success message and loading animation

- **Token Handling** (3 tests)
  - ✓ Redirects to login when no token
  - ✓ Saves token to localStorage
  - ✓ Fetches current user after saving token

- **Navigation** (2 tests)
  - ✓ Redirects to dashboard after authentication
  - ✓ Redirects to login on error

- **OAuth Support** (2 tests)
  - ✓ Handles OAuth provider parameter
  - ✓ Handles error parameter

- **UI** (1 test)
  - ✓ Displays loading animation

## Writing New Tests

### Testing a Pinia Store

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useMyStore } from '../myStore'

describe('MyStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('does something', () => {
    const store = useMyStore()
    // Test your store
  })
})
```

### Testing a Vue Component

```typescript
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import MyComponent from '../MyComponent.vue'

describe('MyComponent', () => {
  it('renders correctly', () => {
    const wrapper = mount(MyComponent, {
      props: { /* your props */ }
    })
    expect(wrapper.text()).toContain('Expected text')
  })
})
```

### Mocking API Calls

```typescript
import { vi } from 'vitest'
import api from '../../services/api'

vi.mock('../../services/api', () => ({
  default: {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    delete: vi.fn(),
  }
}))

// In your test
vi.mocked(api.get).mockResolvedValue({ data: { /* mock data */ } })
```

## Best Practices

1. **Isolation**: Each test should be independent and not rely on other tests
2. **Clear Mocks**: Always clear mocks in `beforeEach` to avoid test pollution
3. **Descriptive Names**: Use clear, descriptive test names that explain what is being tested
4. **Arrange-Act-Assert**: Structure tests with clear setup, execution, and assertion phases
5. **Mock External Dependencies**: Mock API calls, localStorage, and other external dependencies
6. **Test Behavior, Not Implementation**: Focus on what the code does, not how it does it

## Continuous Integration

Tests run automatically on:
- Every commit (via git hooks if configured)
- Pull request creation
- Before deployment

## Debugging Tests

```bash
# Run a specific test file
npx vitest run app/frontend/stores/__tests__/auth.spec.ts

# Run tests matching a pattern
npx vitest run -t "login"

# Debug mode with Node inspector
npx vitest --inspect-brk --no-file-parallelism
```

## Common Issues

### Tests Timing Out

Increase timeout in test:
```typescript
it('slow test', async () => {
  // test code
}, { timeout: 10000 }) // 10 seconds
```

### Mock Not Working

Ensure mock is defined before import:
```typescript
vi.mock('../../services/api', () => ({
  default: { /* mock */ }
}))

// Then import
import api from '../../services/api'
```

### localStorage Errors

The test setup mocks localStorage automatically. If you need custom behavior:
```typescript
beforeEach(() => {
  localStorage.getItem = vi.fn(() => 'custom-value')
})
```

## Resources

- [Vitest Documentation](https://vitest.dev/)
- [Vue Test Utils](https://test-utils.vuejs.org/)
- [Testing Pinia](https://pinia.vuejs.org/cookbook/testing.html)
