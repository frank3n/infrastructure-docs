# TypeScript Interface Guide

**Target:** Fix 137 `@typescript-eslint/no-explicit-any` errors
**Time Required:** 2-3 hours for 50% reduction
**Difficulty:** Medium - requires understanding type structure

---

## The Problem

**93.8% of all errors** (137 of 146) are using `any` type instead of proper TypeScript types.

```typescript
// Bad - defeats TypeScript's purpose
function process(data: any): any {
    return data.value;
}
```

**Why this is a problem:**
- No type safety
- No autocomplete
- No compile-time error checking
- Defeats the purpose of using TypeScript

---

## Solution Strategy

### 1. Create Common Interfaces
### 2. Replace `any` with Proper Types
### 3. Use Express Types
### 4. Create Domain-Specific Types

---

## Step 1: Create Common Interfaces

### Create: `api/src/types/common.ts`

```typescript
// api/src/types/common.ts

/**
 * Generic API Response
 */
export interface ApiResponse<T = unknown> {
    success: boolean;
    data?: T;
    error?: string;
    message?: string;
}

/**
 * Request Query Parameters
 */
export interface RequestQuery {
    [key: string]: string | string[] | undefined;
}

/**
 * Pagination
 */
export interface PaginationParams {
    page?: number;
    limit?: number;
    offset?: number;
}

export interface PaginatedResponse<T> {
    items: T[];
    total: number;
    page: number;
    limit: number;
    hasMore: boolean;
}

/**
 * Common ID types
 */
export type ID = string | number;

/**
 * Timestamp
 */
export interface Timestamped {
    createdAt: Date;
    updatedAt: Date;
}
```

---

## Step 2: Domain-Specific Types

### Create: `api/src/types/monitoring.ts`

```typescript
// api/src/types/monitoring.ts

export interface MonitoringMetric {
    name: string;
    value: number;
    unit?: string;
    timestamp: number;
    tags?: Record<string, string>;
}

export interface SystemStatus {
    uptime: number;
    memory: MemoryUsage;
    cpu: CPUUsage;
    timestamp: number;
}

export interface MemoryUsage {
    total: number;
    used: number;
    free: number;
    percentage: number;
}

export interface CPUUsage {
    cores: number;
    usage: number;
    loadAverage: number[];
}

export interface HealthCheckResponse {
    status: 'healthy' | 'degraded' | 'unhealthy';
    checks: HealthCheck[];
    timestamp: number;
}

export interface HealthCheck {
    name: string;
    status: 'pass' | 'warn' | 'fail';
    message?: string;
    duration?: number;
}
```

### Create: `api/src/types/proxy.ts`

```typescript
// api/src/types/proxy.ts

export interface ProxyConfig {
    id: string;
    target: string;
    port: number;
    enabled: boolean;
    rateLimit?: RateLimitConfig;
}

export interface RateLimitConfig {
    maxRequests: number;
    windowMs: number;
}

export interface ProxyRequest {
    url: string;
    method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
    headers?: Record<string, string>;
    body?: unknown;
}

export interface ProxyResponse {
    statusCode: number;
    headers: Record<string, string>;
    body: unknown;
    duration: number;
}

export interface ProxyStats {
    totalRequests: number;
    successfulRequests: number;
    failedRequests: number;
    averageDuration: number;
}
```

### Create: `api/src/types/scheduler.ts`

```typescript
// api/src/types/scheduler.ts

export interface ScheduledTask {
    id: string;
    name: string;
    schedule: string;  // cron expression
    enabled: boolean;
    lastRun?: Date;
    nextRun?: Date;
    status: TaskStatus;
}

export type TaskStatus = 'pending' | 'running' | 'completed' | 'failed';

export interface TaskExecution {
    taskId: string;
    startTime: Date;
    endTime?: Date;
    status: TaskStatus;
    result?: unknown;
    error?: string;
}

export interface TaskConfig {
    name: string;
    schedule: string;
    enabled?: boolean;
    timeout?: number;
    retries?: number;
}
```

---

## Step 3: Fix Express.js Routes

### Before (using `any`)

```typescript
// api/src/routes/monitoring.ts
import express from 'express';

const router = express.Router();

router.get('/metrics/:name', async (req: any, res: any) => {
    const data: any = await getMetric(req.params.name);
    res.json(data);
});

router.post('/metrics', async (req: any, res: any) => {
    const metric: any = req.body;
    await saveMetric(metric);
    res.json({ success: true });
});
```

### After (with proper types)

```typescript
// api/src/routes/monitoring.ts
import express, { Request, Response } from 'express';
import { MonitoringMetric } from '../types/monitoring';
import { ApiResponse } from '../types/common';

const router = express.Router();

router.get('/metrics/:name', async (
    req: Request<{ name: string }>,
    res: Response<ApiResponse<MonitoringMetric>>
) => {
    const data: MonitoringMetric = await getMetric(req.params.name);
    res.json({ success: true, data });
});

router.post('/metrics', async (
    req: Request<{}, {}, MonitoringMetric>,
    res: Response<ApiResponse>
) => {
    const metric: MonitoringMetric = req.body;
    await saveMetric(metric);
    res.json({ success: true });
});
```

---

## Step 4: Express Request/Response Types

### Understanding Express Generics

```typescript
Request<Params, ResBody, ReqBody, ReqQuery>
```

- `Params` - URL parameters (e.g., `/users/:id`)
- `ResBody` - Response body type (usually not used)
- `ReqBody` - Request body type
- `ReqQuery` - Query string parameters

### Examples

```typescript
// GET /users/:id
app.get('/users/:id',
    (req: Request<{ id: string }>, res: Response) => {
        const userId = req.params.id;  // TypeScript knows this is a string
    }
);

// POST /users with body
app.post('/users',
    (req: Request<{}, {}, { name: string; email: string }>, res: Response) => {
        const { name, email } = req.body;  // TypeScript knows the types
    }
);

// GET /users?page=1&limit=10
app.get('/users',
    (req: Request<{}, {}, {}, { page?: string; limit?: string }>, res: Response) => {
        const page = parseInt(req.query.page || '1');
    }
);
```

---

## Priority Fix List

### File: `api/src/routes/monitoring.ts` (20+ instances)

**Current errors:** ~20 `any` types

**Steps:**
1. Import Express types
2. Create/import MonitoringMetric interface
3. Replace each `req: any, res: any` with proper types
4. Type all variables using `any`

**Expected time:** 30 minutes

### File: `api/src/routes/proxies.ts` (13+ instances)

**Current errors:** ~13 `any` types

**Steps:**
1. Import Express types
2. Create ProxyConfig and related interfaces
3. Type all route handlers
4. Type helper functions

**Expected time:** 20 minutes

### File: `api/src/routes/scheduler.ts` (6 instances)

**Current errors:** ~6 `any` types

**Steps:**
1. Import Express types
2. Create ScheduledTask interfaces
3. Type all route handlers

**Expected time:** 15 minutes

---

## Step-by-Step Example: Fix One Route

### 1. Identify the Route

```typescript
// Before
router.get('/health', async (req: any, res: any) => {
    const status: any = await checkHealth();
    res.json(status);
});
```

### 2. Create Interface for Response

```typescript
// types/monitoring.ts
export interface HealthStatus {
    healthy: boolean;
    uptime: number;
    timestamp: number;
}
```

### 3. Import Types

```typescript
import { Request, Response } from 'express';
import { HealthStatus } from '../types/monitoring';
import { ApiResponse } from '../types/common';
```

### 4. Apply Types

```typescript
// After
router.get('/health', async (
    req: Request,
    res: Response<ApiResponse<HealthStatus>>
) => {
    const status: HealthStatus = await checkHealth();
    res.json({ success: true, data: status });
});
```

### 5. Verify

```bash
npm run lint
# Should show one less error
```

---

## Common Patterns and Solutions

### Pattern 1: Generic Data Object

```typescript
// Bad
function processData(data: any) {
    return data.id;
}

// Good - use generic
function processData<T extends { id: string }>(data: T) {
    return data.id;
}

// Or - create interface
interface DataWithId {
    id: string;
    [key: string]: unknown;
}
function processData(data: DataWithId) {
    return data.id;
}
```

### Pattern 2: Unknown Structure

```typescript
// Bad
const config: any = JSON.parse(configString);

// Good - use unknown, then validate
const config: unknown = JSON.parse(configString);

// Type guard
if (isValidConfig(config)) {
    // config is now properly typed
    useConfig(config);
}

function isValidConfig(obj: unknown): obj is ConfigType {
    return (
        typeof obj === 'object' &&
        obj !== null &&
        'setting' in obj
    );
}
```

### Pattern 3: Third-party Library Types

```typescript
// Bad
const result: any = await someLibrary.call();

// Good - check if library has types
import { LibraryResult } from 'some-library';
const result: LibraryResult = await someLibrary.call();

// If no types exist, create minimal interface
interface LibraryResult {
    success: boolean;
    data: unknown;
}
```

---

## Batch Replace Strategy

### Use Search and Replace

```typescript
// Search for pattern:
async (req: any, res: any)

// Replace with:
async (req: Request, res: Response)
```

**Then:**
1. Add specific generics where needed
2. Run `npm run lint`
3. Fix any new TypeScript errors
4. Repeat

---

## Verification Process

### After Each File Fix

```powershell
# 1. Save the file
# 2. Run lint
npm run lint

# 3. Check error reduction
# Should see fewer @typescript-eslint/no-explicit-any errors

# 4. Run TypeScript compiler
npm run build

# 5. If successful, commit
git add .
git commit -m "fix(types): Replace any with proper types in [filename]"
```

---

## Progress Tracking Template

### Create: `fix-logs/manual-fixes/typescript-any-fixes-log.md`

```markdown
# TypeScript `any` Type Fixes Log

## Session: [Date/Time]

### Starting State
- Total `any` errors: 137

### Files Fixed

#### 1. api/src/routes/monitoring.ts
- **Before:** 20 `any` instances
- **After:** 0 `any` instances
- **Time:** 30 minutes
- **Commit:** [hash]
- **Notes:** Created MonitoringMetric interface

#### 2. api/src/routes/proxies.ts
- **Before:** 13 `any` instances
- **After:** 0 `any` instances
- **Time:** 20 minutes
- **Commit:** [hash]
- **Notes:** Created ProxyConfig and ProxyResponse types

### Current State
- Total `any` errors: 104 (33 fixed)
- Progress: 24%

### Next Steps
- [ ] Fix api/src/routes/scheduler.ts (6 instances)
- [ ] Fix api/src/routes/sessions.ts (2 instances)
```

---

## Success Metrics

### Goal: 50% Reduction
- Starting: 137 errors
- Target: < 69 errors
- Need to fix: 68+ instances

### Recommended Focus
1. **api/src/routes/monitoring.ts** (20 instances) - 15%
2. **api/src/routes/proxies.ts** (13 instances) - 9%
3. **api/src/routes/scheduler.ts** (6 instances) - 4%
4. **api/src/routes/sessions.ts** (2 instances) - 1%
5. **api/src/routes/test.ts** (4 instances) - 3%

**Total from these 5 files:** 45 instances (33% of total)

---

## Tips for Success

1. **Start with one file**
   Don't try to fix everything at once

2. **Create interfaces first**
   Define types before using them

3. **Use existing types**
   Check if Express/Node provides types

4. **Test incrementally**
   Run lint after each file

5. **Document patterns**
   Save common solutions for reuse

6. **Take breaks**
   This is mentally demanding work

---

**Estimated Impact:** 50-70% error reduction (68-96 of 137 errors)
**Time Required:** 2-3 hours
**Difficulty:** Medium - requires TypeScript knowledge
