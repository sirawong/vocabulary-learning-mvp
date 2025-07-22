// MongoDB initialization script
print('Starting MongoDB initialization...');

// Switch to vocabulary database
db = db.getSiblingDB('vocabulary_db');

// Create collections with validation
print('Creating collections...');

// Words collection with schema validation
db.createCollection('words', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['word', 'language', 'createdAt'],
      properties: {
        word: {
          bsonType: 'string',
          description: 'The vocabulary word - required'
        },
        language: {
          bsonType: 'string',
          description: 'Language of the word - required'
        },
        definitions: {
          bsonType: 'array',
          description: 'Array of definitions'
        },
        examples: {
          bsonType: 'array',
          description: 'Array of example sentences'
        },
        difficulty: {
          bsonType: 'string',
          enum: ['beginner', 'intermediate', 'advanced'],
          description: 'Difficulty level'
        },
        createdAt: {
          bsonType: 'date',
          description: 'Creation timestamp - required'
        },
        updatedAt: {
          bsonType: 'date',
          description: 'Last update timestamp'
        }
      }
    }
  }
});

// Learning sessions collection
db.createCollection('sessions', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['sessionId', 'status', 'createdAt'],
      properties: {
        sessionId: {
          bsonType: 'string',
          description: 'Unique session identifier - required'
        },
        userId: {
          bsonType: 'string',
          description: 'User identifier'
        },
        words: {
          bsonType: 'array',
          description: 'Array of word IDs in session'
        },
        status: {
          bsonType: 'string',
          enum: ['active', 'completed', 'paused'],
          description: 'Session status - required'
        },
        progress: {
          bsonType: 'object',
          description: 'Learning progress data'
        },
        createdAt: {
          bsonType: 'date',
          description: 'Creation timestamp - required'
        }
      }
    }
  }
});

// Users collection (for future use)
db.createCollection('users');

// Text sources collection
db.createCollection('text_sources', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['url', 'status', 'createdAt'],
      properties: {
        url: {
          bsonType: 'string',
          description: 'Source URL - required'
        },
        title: {
          bsonType: 'string',
          description: 'Page title'
        },
        content: {
          bsonType: 'string',
          description: 'Extracted text content'
        },
        status: {
          bsonType: 'string',
          enum: ['pending', 'processing', 'completed', 'failed'],
          description: 'Processing status - required'
        },
        wordCount: {
          bsonType: 'int',
          description: 'Number of extracted words'
        },
        createdAt: {
          bsonType: 'date',
          description: 'Creation timestamp - required'
        }
      }
    }
  }
});

print('Creating indexes...');

// Words collection indexes
db.words.createIndex({ 'word': 1 }, { unique: true });
db.words.createIndex({ 'language': 1 });
db.words.createIndex({ 'difficulty': 1 });
db.words.createIndex({ 'createdAt': 1 });
db.words.createIndex({ 'word': 'text', 'definitions': 'text' }); // Text search

// Sessions collection indexes
db.sessions.createIndex({ 'sessionId': 1 }, { unique: true });
db.sessions.createIndex({ 'userId': 1 });
db.sessions.createIndex({ 'status': 1 });
db.sessions.createIndex({ 'createdAt': 1 }, { expireAfterSeconds: 86400 }); // 24 hours TTL

// Users collection indexes
db.users.createIndex({ 'email': 1 }, { unique: true, sparse: true });
db.users.createIndex({ 'createdAt': 1 });

// Text sources collection indexes
db.text_sources.createIndex({ 'url': 1 }, { unique: true });
db.text_sources.createIndex({ 'status': 1 });
db.text_sources.createIndex({ 'createdAt': 1 });

print('Inserting sample data...');

// Insert sample words
db.words.insertMany([
  {
    word: 'vocabulary',
    language: 'en',
    definitions: ['A body of words used in a particular language'],
    examples: ['Building vocabulary is essential for language learning'],
    difficulty: 'intermediate',
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    word: 'learning',
    language: 'en',
    definitions: ['The acquisition of knowledge or skills through experience, study, or by being taught'],
    examples: ['Machine learning is a subset of artificial intelligence'],
    difficulty: 'beginner',
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

print('Database initialization completed successfully!');
print('Collections created: words, sessions, users, text_sources');
print('Indexes created and sample data inserted');
