const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import routes
const { DiscoverRoutes } = require('./routes/discoverRoutes');

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Compression middleware
app.use(compression());

// Logging middleware
app.use(morgan('combined'));

// Health check endpoint
app.get('/health', (req: any, res: any) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Discover routes
app.get('/api/discover/places', DiscoverRoutes.getPlaces);
app.get('/api/discover/search', DiscoverRoutes.searchPlaces);
app.post('/api/discover/filter', DiscoverRoutes.filterPlacesBySubtopic);
app.get('/api/discover/subtopics', DiscoverRoutes.getAvailableSubtopics);
app.get('/api/discover/places/:placeId', DiscoverRoutes.getPlaceById);
app.post('/api/discover/filtered', DiscoverRoutes.getFilteredPlaces);

// 404 handler
app.use('*', (req: any, res: any) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handling middleware
app.use((error: any, req: any, res: any, next: any) => {
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🗺️ Discover API: http://localhost:${PORT}/api/discover`);
});

module.exports = app; 