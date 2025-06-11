# CoachHub API Documentation

## Base URL

All API endpoints are served from:
```
https://coachhub-production.up.railway.app
```

## Authentication

Most endpoints require authentication using a Bearer token in the Authorization header:
```
Authorization: Bearer <access_token>
```

## API Endpoints

### 🔐 Authentication

#### Register User
- **Endpoint**: `POST /api/auth/register`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  username: string;
  password: string;
  email: string;
}
```

#### Verify OTP
- **Endpoint**: `POST /api/auth/verify`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  otp: string;
}
```

#### Complete Profile Information
- **Endpoint**: `POST /api/auth/complete-info`
- **Auth**: Required
- **Body**: `multipart/form-data`
```typescript
{
  full_name: string;
  gender: "male" | "female";
  type: "trainee" | "coach";
  image: File;
  bio: string;

  // Coach-specific fields
  experience_IDs?: string[];  // e.g. ["1", "2", "3"]

  // Trainee-specific fields
  goals_IDs?: string[];      // e.g. ["1", "2", "3"]
  age?: number;
  height?: number;
  weight?: number;
  body_fat?: number;
  body_muscle?: number;
}
```

#### Sign In
- **Endpoint**: `POST /api/auth/sign-in`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  username: string;
  password: string;
}
```

#### Request Password Reset
- **Endpoint**: `POST /api/auth/request-password-reset`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  email: string;
}
```

#### Reset Password
- **Endpoint**: `POST /api/auth/reset-password`
- **Auth**: Required
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  password: string;
}
```

### 📝 Coach Posts

#### Create Post
- **Endpoint**: `POST /api/post/create`
- **Auth**: Required
- **Body**: `multipart/form-data`
```typescript
{
  content: string;
  media: File[];  // Multiple files supported
}
```

#### Get Coach Posts
- **Endpoint**: `GET /api/post/`
- **Auth**: Required
- **Query Parameters**: `coach_id`
- **Example**: `/api/post/?coach_id=2`

#### Update Post
- **Endpoint**: `PUT /api/post/{post_id}`
- **Auth**: Required
- **Body**: `multipart/form-data`
```typescript
{
  content: string;
  media: File;
}
```

#### Get Post by ID
- **Endpoint**: `GET /api/post/{post_id}`
- **Auth**: Required

#### Delete Post
- **Endpoint**: `DELETE /api/post/{post_id}`
- **Auth**: Required

### 🤝 Subscription Management

All subscription endpoints require authentication.

#### Request Subscription
- **Endpoint**: `POST /api/subscription/request/{coach_id}`

#### Delete Request
- **Endpoint**: `DELETE /api/subscription/request/{request_id}`

#### Handle Request
- **Endpoint**: `POST /api/subscription/handle/{request_id}`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  status: "accepted" | "rejected";
}
```

#### Get Clients
- **Endpoint**: `GET /api/subscription/clients`

#### Get Requests
- **Endpoint**: `GET /api/subscription/requests`

#### Unsubscribe
- **Endpoint**: `PATCH /api/subscription/unsubscribe/{coach_id}`

#### Terminate Subscription
- **Endpoint**: `PATCH /api/subscription/end/{client_id}`

### 🏋️ Workout Plans

All workout plan endpoints require authentication and are under the base path `/api/plans/workout`.

#### Create Workout Plan
- **Endpoint**: `POST /api/plans/workout/`
- **Body**: `application/json`
```typescript
{
  title: string;
  duration: number;
  days: {
    day_number: number;
    exercises: {
      exercise_id: number;
      sets: number;
      reps: number;
      rest_time: number;
      notes: string;
      video_url: string;
    }[];
  }[];
}
```

#### Get Coach Plans
- **Endpoint**: `GET /api/plans/workout/my-plans`

#### Get Plan by ID
- **Endpoint**: `GET /api/plans/workout/{id}`

#### Update Plan
- **Endpoint**: `PUT /api/plans/workout/{id}`
- **Body**: `application/json`
```typescript
{
  title: string;
  days: {
    day_number: number;
    add_exercises: {
      exercise_id: number;
      sets: number;
      reps: number;
      rest_time: number;
      notes: string;
      video_url: string;
    }[];
    remove_exercise_ids: number[];
    update_exercises: {
      id: number;
      sets: number;
      reps: number;
      rest_time: number;
      notes: string;
      video_url: string;
    }[];
  }[];
}
```

#### Assign Plan
- **Endpoint**: `POST /api/plans/workout/assign/{plan_id}`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  trainee_id: string;
}
```

#### Get Assigned Plan
- **Endpoint**: `GET /api/plans/workout/assigned`

#### Unassign Plan
- **Endpoint**: `DELETE /api/plans/workout/unassign`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  trainee_id: string;
}
```

#### List Muscles
- **Endpoint**: `GET /api/plans/workout/muscles`

#### List Exercises
- **Endpoint**: `GET /api/plans/workout/exercises`
- **Query Parameters**: `muscle` (optional)
- **Example**: `/api/plans/workout/exercises?muscle=Arms`

### 🥗 Nutrition Plans

All nutrition plan endpoints require authentication and are under the base path `/api/plans/nutrition`.

#### Create Nutrition Plan
- **Endpoint**: `POST /api/plans/nutrition/`
- **Body**: `application/json`
```typescript
{
  title: string;
  duration: number;
  days: {
    day_number: number;
    breakfast: string;
    lunch: string;
    dinner: string;
    snack: string;
    notes: string;
  }[];
}
```

#### Get Coach Plans
- **Endpoint**: `GET /api/plans/nutrition/my-plans`

#### Get Plan by ID
- **Endpoint**: `GET /api/plans/nutrition/{id}`

#### Update Plan
- **Endpoint**: `PUT /api/plans/nutrition/{id}`
- **Body**: Same as Create Nutrition Plan

#### Assign Plan
- **Endpoint**: `POST /api/plans/nutrition/assign/{plan_id}`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  trainee_id: string;
}
```

#### Get Assigned Plan
- **Endpoint**: `GET /api/plans/nutrition/assigned`

#### Unassign Plan
- **Endpoint**: `DELETE /api/plans/nutrition/unassign`
- **Body**: `application/x-www-form-urlencoded`
```typescript
{
  trainee_id: string;
}
```

## Response Formats

All endpoints return JSON responses with the following general structure:
```typescript
{
  success: boolean;
  message?: string;
  data?: any;
  error?: string;
}
```

## Error Handling

The API uses standard HTTP status codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

## Rate Limiting

Please note that API endpoints may be subject to rate limiting. Implement appropriate error handling in your client applications. 