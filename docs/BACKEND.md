# CoachHub Backend Architecture

## Technology Stack

### Core Technologies
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MySQL
- **ORM**: Sequelize
- **Real-time**: Socket.IO
- **Cache**: Redis
- **Search**: Elasticsearch
- **AI Engine**: Python/Node.js

## Project Structure

```
src/
├── config/
│   ├── database.js
│   ├── redis.js
│   └── elasticsearch.js
├── models/
│   ├── user.js
│   ├── coach.js
│   ├── trainee.js
│   └── plan.js
├── controllers/
│   ├── auth/
│   ├── coach/
│   ├── trainee/
│   └── plan/
├── services/
│   ├── matching/
│   ├── notification/
│   └── analytics/
├── middleware/
│   ├── auth.js
│   ├── validation.js
│   └── error.js
├── routes/
│   ├── auth.js
│   ├── coach.js
│   └── plan.js
└── utils/
    ├── logger.js
    └── helpers.js
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('coach', 'trainee') NOT NULL,
    name VARCHAR(255) NOT NULL,
    age INT,
    gender ENUM('male', 'female', 'other'),
    city VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Coaches Table
```sql
CREATE TABLE coaches (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    specialties JSON,
    certifications JSON,
    pricing DECIMAL(10,2),
    bio TEXT,
    rating_avg DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Trainees Table
```sql
CREATE TABLE trainees (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    goal VARCHAR(255),
    fitness_level ENUM('beginner', 'intermediate', 'advanced'),
    matched_coach_id UUID REFERENCES coaches(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## API Endpoints

### Authentication
```javascript
// POST /api/auth/register
router.post('/register', async (req, res) => {
    // Implementation
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
    // Implementation
});
```

### Coach Management
```javascript
// GET /api/coaches
router.get('/', async (req, res) => {
    // Implementation
});

// POST /api/coaches/match
router.post('/match', async (req, res) => {
    // Implementation
});
```

### Plan Management
```javascript
// POST /api/plans
router.post('/', async (req, res) => {
    // Implementation
});

// GET /api/plans/:id
router.get('/:id', async (req, res) => {
    // Implementation
});
```

## Real-time Communication

### Socket.IO Implementation
```javascript
const io = require('socket.io')(server);

io.on('connection', (socket) => {
    socket.on('join_chat', (data) => {
        // Implementation
    });

    socket.on('send_message', (data) => {
        // Implementation
    });
});
```

## AI Matching Engine

### Matching Algorithm
```python
class CoachMatcher:
    def __init__(self):
        self.model = self._load_model()

    def find_matches(self, trainee_profile):
        # Implementation
        pass

    def _load_model(self):
        # Implementation
        pass
```

## Security Implementation

### JWT Authentication
```javascript
const jwt = require('jsonwebtoken');

const generateToken = (user) => {
    return jwt.sign(
        { id: user.id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '24h' }
    );
};
```

### Password Hashing
```javascript
const bcrypt = require('bcrypt');

const hashPassword = async (password) => {
    return await bcrypt.hash(password, 10);
};
```

## Caching Strategy

### Redis Implementation
```javascript
const redis = require('redis');
const client = redis.createClient();

const cacheCoach = async (coachId, data) => {
    await client.set(`coach:${coachId}`, JSON.stringify(data));
};

const getCachedCoach = async (coachId) => {
    return await client.get(`coach:${coachId}`);
};
```

## Search Implementation

### Elasticsearch Setup
```javascript
const { Client } = require('@elastic/elasticsearch');
const client = new Client({ node: 'http://localhost:9200' });

const indexCoach = async (coach) => {
    await client.index({
        index: 'coaches',
        body: coach
    });
};
```

## Error Handling

### Global Error Handler
```javascript
const errorHandler = (err, req, res, next) => {
    logger.error(err.stack);
    res.status(err.status || 500).json({
        error: {
            message: err.message,
            code: err.code
        }
    });
};
```

## Logging

### Winston Logger
```javascript
const winston = require('winston');

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.json(),
    transports: [
        new winston.transports.File({ filename: 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'combined.log' })
    ]
});
```

## Testing

### Unit Tests
```javascript
describe('Auth Service', () => {
    test('should register new user', async () => {
        // Implementation
    });

    test('should login existing user', async () => {
        // Implementation
    });
});
```

### Integration Tests
```javascript
describe('Coach API', () => {
    test('should create new coach profile', async () => {
        // Implementation
    });

    test('should match coach with trainee', async () => {
        // Implementation
    });
});
```

## Performance Optimization

### Database Indexing
```sql
CREATE INDEX idx_coaches_specialty ON coaches(specialties);
CREATE INDEX idx_trainees_goal ON trainees(goal);
```

### Query Optimization
```javascript
const getCoaches = async (filters) => {
    return await Coach.findAll({
        include: [{
            model: User,
            attributes: ['name', 'city']
        }],
        where: filters,
        limit: 20,
        offset: 0
    });
};
```

## Monitoring

### Health Checks
```javascript
router.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date(),
        services: {
            database: checkDatabase(),
            redis: checkRedis(),
            elasticsearch: checkElasticsearch()
        }
    });
});
```

## Deployment

### Docker Configuration
```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### Environment Configuration
```javascript
module.exports = {
    development: {
        database: {
            host: process.env.DB_HOST,
            port: process.env.DB_PORT,
            name: process.env.DB_NAME
        },
        redis: {
            host: process.env.REDIS_HOST,
            port: process.env.REDIS_PORT
        }
    },
    production: {
        // Production configuration
    }
};
```

## Scaling Strategy

### Horizontal Scaling
- Implement load balancing
- Use database replication
- Implement caching layers

### Vertical Scaling
- Optimize database queries
- Implement connection pooling
- Use efficient data structures

## Backup Strategy

### Database Backups
```javascript
const backupDatabase = async () => {
    // Implementation
};
```

### File Backups
```javascript
const backupFiles = async () => {
    // Implementation
};
```

## Conclusion

This backend architecture provides a robust foundation for the CoachHub application. It includes all necessary components for authentication, real-time communication, data management, and scalability. The architecture is designed to be maintainable, secure, and performant. 