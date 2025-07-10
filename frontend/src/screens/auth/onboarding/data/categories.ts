export interface SubSubcategory {
  name: string;
  value?: string;
  icon: string;
  price: string;
}

export interface Subcategory {
  name: string;
  value?: string; // What supabase sees (if needed)
  icon: string;
  subSubcategories?: SubSubcategory[];
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
  gradient: string[];
  description: string;
  subcategories: Subcategory[];
  rotation?: string;
}

export const categories: Category[] = [
  {
    id: 'food-drink',
    name: 'Food & Drink',
    icon: '🍱',
    color: '#D7263D',
    rotation: '10deg',
    gradient: ['#D7263D', '#A61B2B'],
    description: 'Discover amazing restaurants and cafes',
    subcategories: [
      {
        name: 'Restaurants',
        icon: '🍽️',
        subSubcategories: [
          { name: 'Steakhouses', value: 'Steakhouses & Grills', icon: '', price: '$' },
          { name: 'Seafood', value: 'Seafood & Fish Cuisine', icon: '🦐', price: '$' },
          { name: 'Indian', value: 'Indian & Curry Houses', icon: '🍛', price: '$' },
          { name: 'Italian', value: 'Italian Cuisine', icon: '🍝', price: '$' },
          { name: 'Mexican', value: 'Taco & Mexican Cuisine', icon: '🌮', price: '$' },
          { name: 'Burgers', value: 'Burger Joint', icon: '🥢', price: '$' },
          { name: 'Pizza', value: 'Pizzerias & Italian Cuisine',icon: '🍕', price: '$' },
          { name: 'Vegetarian', value: 'Vegetarian Cuisine', icon: '🥬', price: '$' },
        ]
      },
      {
        name: 'Street / Food Trucks',
        icon: '🍔',
        subSubcategories: [
          { name: 'Burgers', value: 'Burger Joint', icon: '🥢', price: '$' },
          { name: 'Pizza', value: 'Pizzerias & Italian Cuisine',icon: '🍕', price: '$' },
          { name: 'Sandwiches', value: 'Sandwiches', icon: '🥪', price: '$' },
          { name: 'Hot Dogs', value: 'Hot Dog Joint', icon: '🌭', price: '$' },
        ]
      },
      {
        name: 'Cafes & Coffee',
        value: 'Coffee Shops',
        icon: '☕️',
        subSubcategories: [
          { name: 'Study Cafes', value: 'Study Ca', icon: '☕️', price: '$' },
          { name: 'Espresso', value: 'Espresso Bars', icon: '☕️', price: '$' },
          { name: 'Cafes', value: 'Cafes', icon: '☕️', price: '$' },
        ]
      },
      {
        name: 'Dessert Shops',
        value: 'Coffee Shops',
        icon: '☕️',
        subSubcategories: [
          { name: 'Study Cafes', value: 'Study Ca', icon: '☕️', price: '$' },
          { name: 'Espresso', value: 'Espresso Bars', icon: '☕️', price: '$' },
          { name: 'Cafes', value: 'Cafes', icon: '☕️', price: '$' },
        ]
      },
      {
        name: 'Breakfast & Brunch',
        icon: '🍳',
        subSubcategories: [
          { name: 'Bagels', value: 'Bagel Shops', icon: '🥯', price: '$' },
          { name: 'Pancakes', value: 'Pancake Houses', icon: '🥞', price: '$' },
          { name: 'Waffles', value: 'Waffle / Crepes', icon: '🥪', price: '$' },
          { name: 'Diners', value: 'Diners', icon: '🥪', price: '$' },
        ]
      },
      {
        name: 'Asian Cuisine',
        icon: '🥢',
        subSubcategories: [
          { name: 'Chinese', value: 'Chinese Cuisine', icon: '🥡', price: '$' },
          { name: 'Thai', value: 'Thai & Southeast Asian Cuisine', icon: '🍲', price: '$' },
          { name: 'Japanese', value: 'Sushi & Japanese Cuisine', icon: '🍣', price: '$' },
          { name: 'Korean', value: 'Korean Cuisine', icon: '🍚', price: '$' },
        ]
      },
      {
        name: 'Healthy Options',
        icon: '🥗',
        subSubcategories: [
          { name: 'Vegan', icon: '🥗', price: '$$' },
          { name: 'Vegetarian', icon: '🥬', price: '$$' },
          { name: 'Gluten-Free', icon: '🌾', price: '$$' },
          { name: 'Organic', icon: '🌱', price: '$$' }
        ]
      },
      {
        name: 'Fine Dining',
        icon: '🍷',
        subSubcategories: [
          { name: 'Steakhouses', icon: '🥩', price: '$$$' },
          { name: 'Seafood', icon: '🦐', price: '$$$' },
          { name: 'Italian', icon: '🍝', price: '$$$' },
          { name: 'Wine Bars', icon: '🍷', price: '$$$' }
        ]
      }
    ]
  },
  {
    id: 'recreation-fitness',
    name: 'Recreation & Fitness',
    icon: '🪂',
    color: '#388E3C',
    rotation: '20deg',
    gradient: ['#388E3C', '#1B5E20'],
    description: 'Stay active and healthy',
    subcategories: [
      {
        name: 'Gym & Personal Fitness',
        icon: '🏋️',
        subSubcategories: [
          { name: 'Gyms & Fitness Centers', icon: '🏋️', price: '$$' },
          { name: 'Cross', value: 'CrossFit Boxes', icon: '🤸‍♂️', price: '$$-$$$' },
          { name: 'Dance', value: 'Dance Fitness', icon: '🕺🏼', price: '$$-$$$' },
          { name: 'Pilates & Barre', icon: '🧘‍♀️', price: '$$-$$$' },
          { name: 'HIIT & Bootcamp', icon: '🏃‍♂️', price: '$$-$$$' },
          { name: 'Stretching & Mobility', icon: '🤸', price: '$-$$' }
        ]
      },
      {
        name: 'Team Sports',
        icon: '🏆',
        subSubcategories: [
          { name: 'Basketball', icon: '🏀', price: '$' },
          { name: 'Soccer & Futsal', icon: '⚽', price: '$-$$' },
          { name: 'Tennis & Pickleball', icon: '🎾', price: '$' },
          { name: 'Volleyball', icon: '🏐', price: '$-$$' }
        ]
      },
      {
        name: 'Skill & Combat Sports',
        icon: '🎯',
        subSubcategories: [
          { name: 'Boxing & Kickboxing', icon: '🥊', price: '$$' },
          { name: 'Archery', icon: '🏹', price: '$-$$' },
          { name: 'Indoor Climbing', icon: '🧗', price: '$$-$$$' }
        ]
      },
      {
        name: 'Individual Sports',
        icon: '⛳',
        subSubcategories: [
          { name: 'Golf & Driving Ranges', icon: '⛳', price: '$$-$$$' },
          { name: 'Mini-Golf', icon: '⛳', price: '$-$$' },
          { name: 'Bowling', icon: '🎳', price: '$-$$' }
        ]
      },
      {
        name: 'Health & Wellness',
        icon: '🧖',
        subSubcategories: [
          { name: 'Spas & Saunas', icon: '🧖‍♀️', price: '$$-$$$' },
          { name: 'Massage', icon: '💆', price: '$$-$$$' },
          { name: 'Hydrotherapy & Hot Tubs', icon: '🛁', price: '$-$$' }
        ]
      }
    ]
  },
  {
    id: 'social-nightlife',
    name: 'Social & Nightlife',
    icon: '🍻',
    color: '#8E24AA',
    gradient: ['#8E24AA', '#5E35B1'],
    description: 'Connect and have fun',
    subcategories: [
      {
        name: 'Bars & Lounges',
        icon: '🍸',
        subSubcategories: [
          { name: 'Cocktail Bars & Speakeasies', icon: '🍸', price: '$$-$$$' },
          { name: 'Wine & Tapas Bars', icon: '🍷', price: '$$-$$$' },
          { name: 'Breweries & Beer Bars', icon: '🍺', price: '$-$$' },
          { name: 'Dive Bars', icon: '🍻', price: '$' },
          { name: 'Rooftop Bars', icon: '🏙️', price: '$$-$$$' }
        ]
      },
      {
        name: 'Live Entertainment',
        icon: '🎤',
        subSubcategories: [
          { name: 'Comedy Shows', icon: '🎭', price: '$-$$' },
          { name: 'Karaoke', icon: '🎤', price: '$-$$' },
          { name: 'Jazz & Piano Bars', icon: '🎹', price: '$-$$' },
          { name: 'Live Music Venues', icon: '🎵', price: '$-$$' }
        ]
      },
      {
        name: 'Dance & Nightclubs',
        icon: '💃',
        subSubcategories: [
          { name: 'Nightclubs', icon: '💃', price: '$$-$$$' },
          { name: 'Dance Clubs', icon: '🕺', price: '$$-$$$' },
          { name: 'Latin Dancing', icon: '💃', price: '$$-$$$' },
          { name: 'Silent Discos', icon: '🎧', price: '$-$$' }
        ]
      },
      {
        name: 'Social Games',
        icon: '🎲',
        subSubcategories: [
          { name: 'Pool & Billiards', icon: '🎱', price: '$-$$' },
          { name: 'Arcades & Barcades', icon: '🕹️', price: '$-$$' },
          { name: 'Bowling', icon: '🎳', price: '$-$$' }
        ]
      }
    ]
  },
  {
    id: 'shopping-markets',
    name: 'Shopping',
    icon: '🛍️',
    color: '#1B9AAA',
    gradient: ['#1B9AAA', '#16697A'],
    description: 'Find the best shopping spots',
    subcategories: [
      {
        name: 'Thrift & Vintage',
        icon: '♻️',
        subSubcategories: [
          { name: 'Thrift Stores', icon: '🛍️', price: '$' },
          { name: 'Antique Shops', icon: '🏺', price: '$-$$' },
          { name: 'Flea Markets', icon: '🛒', price: '$' },
          { name: 'Consignment Shops', icon: '🛍️', price: '$$-$$$' }
        ]
      },
      {
        name: 'Fashion & Apparel',
        icon: '👗',
        subSubcategories: [
          { name: 'Jewelry Stores', icon: '💍', price: '$$-$$$' },
          { name: 'Boutiques', icon: '👗', price: '$$-$$' },
          { name: 'Designer Fashion', icon: '👠', price: '$$$' },
          { name: 'Leather Goods', icon: '👞', price: '$$-$$$' }
        ]
      },
      {
        name: 'Home & Specialty',
        icon: '🏠',
        subSubcategories: [
          { name: 'Plant Shops', icon: '🪴', price: '$-$$' },
          { name: 'Crystal & Spiritual Shops', icon: '🔮', price: '$-$$' },
          { name: 'Handmade & Artisan Goods', icon: '🧶', price: '$-$$' },
          { name: 'Pottery & Ceramics Shops', icon: '🏺', price: '$$' }
        ]
      },
      {
        name: 'Hobbies & Collectibles',
        icon: '📚',
        subSubcategories: [
          { name: 'Record Stores', icon: '💿', price: '$-$$' },
          { name: 'Pop-Up Markets & Fairs', icon: '🛍️', price: '$-$$' },
          { name: 'Bookstores', icon: '📚', price: '$-$$' },
          { name: 'Comic & Poster Shops', icon: '📰', price: '$' }
        ]
      }
    ]
  },
  {
    id: 'nature-outdoors',
    name: 'Nature & Outdoors',
    icon: '🌲',
    color: '#6D4C41',
    gradient: ['#6D4C41', '#3E2723'],
    description: 'Explore the great outdoors',
    subcategories: [
      {
        name: 'Scenic & Relaxing',
        icon: '🌄',
        subSubcategories: [
          { name: 'Hiking', icon: '🥾', price: 'N/A - $' },
          { name: 'Lakes & Rivers', icon: '🏞️', price: 'N/A - $' },
          { name: 'Parks & Gardens', icon: '🌺', price: 'N/A - $' },
          { name: 'Scenic Viewpoints', icon: '👁️', price: 'N/A - $' }
        ]
      },
      {
        name: 'Adventure Sports',
        icon: '🎢',
        subSubcategories: [
          { name: 'Paintball', icon: '🔫', price: '$-$$' },
          { name: 'Shooting Ranges', icon: '🎯', price: '$-$$' },
          { name: 'Obstacle Courses & Climbing', icon: '🧗', price: '$$' },
          { name: 'Kayaking & Canoeing', icon: '🛶', price: '$-$$' },
          { name: 'Ziplining', icon: '🪂', price: '$-$$' },
          { name: 'ATV & Off-Roading', icon: '🏍️', price: '$$-$$$' }
        ]
      },
      {
        name: 'Parks & Attractions',
        icon: '🎡',
        subSubcategories: [
          { name: 'Amusement Parks', icon: '🎢', price: '$$-$$$' },
          { name: 'Outdoor Concerts & Festivals', icon: '🎤', price: '$-$$$' },
          { name: 'Carnivals', icon: '🎪', price: '$-$$' }
        ]
      },
      {
        name: 'Animals & Wildlife',
        icon: '🦁',
        subSubcategories: [
          { name: 'Zoos', icon: '🦁', price: '$-$$' },
          { name: 'Aquariums', icon: '🐠', price: '$-$$' },
          { name: 'Petting Zoos & Farms', icon: '🐑', price: '$-$$' }
        ]
      }
    ]
  },
  {
    id: 'indoor-adventure',
    name: 'Indoor Adventure',
    icon: '🧗',
    color: '#F57C00',
    gradient: ['#F57C00', '#E65100'],
    description: 'Fun activities indoors',
    subcategories: [
      {
        name: 'Arcades',
        icon: '🎢',
        subSubcategories: [
          { name: 'VR Arcades', icon: '🕹️', price: '$$-$$$' },
          { name: 'Laser Tag & Nerf', icon: '🔫', price: '$$-$$$' },
          { name: 'Arcades & Barcades', icon: '🕹️', price: '$$' }
        ]
      },
      {
        name: 'Game Challenges',
        icon: '🎯',
        subSubcategories: [
          { name: 'Escape Rooms', icon: '🔐', price: '$$-$$$' },
          { name: 'Indoor Go-Karting', icon: '🏎️', price: '$$' },
          { name: 'Indoor Mini-Golf', icon: '⛳', price: '$-$$' },
          { name: 'Haunted Houses', icon: '👻', price: '$-$$' }
        ]
      },
      {
        name: 'Immersive Experiences',
        icon: '🧙',
        subSubcategories: [
          { name: 'Immersive Theater', icon: '🎭', price: '$$-$$$' },
          { name: 'Fantasy Taverns', icon: '🏰', price: '$$-$$$' },
          { name: 'Sci-Fi & Fantasy Cons', icon: '🤖', price: '$$-$$$' },
          { name: 'Digital Art Exhibits', icon: '🖼️', price: '$' },
          { name: 'Projection Shows', icon: '🎥', price: '$-$$' },
          { name: 'Light & Sound Shows', icon: '💡', price: '$-$$' }
        ]
      },
      {
        name: 'Classic Entertainment',
        icon: '🎳',
        subSubcategories: [
          { name: 'Movie Theaters', icon: '🎬', price: '$$' },
          { name: 'Indie & Art House Cinemas', icon: '🎥', price: '$-$$' },
          { name: 'Bowling', icon: '🎳', price: '$-$$' }
        ]
      }
    ]
  },
  {
    id: 'creative-arts',
    name: 'Creative Arts & Crafts',
    icon: '🎨',
    color: '#3F51B5',
    rotation: '-10deg',
    gradient: ['#3F51B5', '#283593'],
    description: 'Unleash your creativity',
    subcategories: [
      {
        name: 'Studio-Based Arts',
        icon: '🎨',
        subSubcategories: [
          { name: 'Pottery & Ceramics Studios', icon: '🏺', price: '$-$$' },
          { name: 'Sip & Paint Studios', icon: '🎨', price: '$-$$' },
          { name: 'Printmaking Workshops', icon: '🖨️', price: '$-$$' },
          { name: 'Art Studio Classes', icon: '🎨', price: '$-$$' }
        ]
      },
      {
        name: 'Textile, Fiber, & DIY Arts',
        icon: '🧵',
        subSubcategories: [
          { name: 'Candle & Soap Making Workshops', icon: '🕯️', price: '$-$$' },
          { name: 'Jewelry Making Studios', icon: '💍', price: '$-$$' },
          { name: 'Knitting & Sewing Circles/Clubs', icon: '🧶', price: '$' },
          { name: 'Makerspaces & DIY Labs', icon: '🔨', price: '$-$$' }
        ]
      },
      {
        name: 'Creative Writing & Storytelling',
        icon: '📝',
        subSubcategories: [
          { name: 'Poetry Open Mic Nights', icon: '🎤', price: '$-$$' },
          { name: 'Writing Workshops', icon: '📝', price: '$-$$' },
          { name: 'Zine & Bookmaking Events', icon: '📚', price: '$' },
          { name: 'Storytelling Shows or Competitions', icon: '🎭', price: '$' }
        ]
      },
      {
        name: 'Art Appreciation & Exploration',
        icon: '🖼️',
        subSubcategories: [
          { name: 'Gallery Events', icon: '🖼️', price: '$-$$' },
          { name: 'Public Art Tours', icon: '🚶', price: '$-$$$' },
          { name: 'Art-Themed Lectures & Educational Talks', icon: '🎓', price: '$-$$' },
          { name: 'Art Film Screenings or Doc Nights', icon: '🎬', price: '$' }
        ]
      }
    ]
  },
  {
    id: 'sight-seeing',
    name: 'Sight-Seeing',
    icon: '🗺️',
    color: '#1976D2',
    gradient: ['#1976D2', '#0D47A1'],
    description: 'Discover amazing places',
    subcategories: [
      {
        name: 'Historical Sites',
        icon: '🏺',
        subSubcategories: [
          { name: 'Museums', icon: '🏛️', price: '$-$$' },
          { name: 'Historical Sites', icon: '🏺', price: '$-$$' },
          { name: 'Monuments', icon: '🗿', price: '$-$$' },
          { name: 'Statues', icon: '🗽', price: '$-$$' }
        ]
      },
      {
        name: 'Religious Sites',
        icon: '⛪',
        subSubcategories: [
          { name: 'Churches', icon: '⛪', price: '$-$$' },
          { name: 'Temples', icon: '🕍', price: '$-$$' },
          { name: 'Mosques', icon: '🕌', price: '$-$$' },
          { name: 'Synagogues', icon: '🕍', price: '$-$$' }
        ]
      },
      {
        name: 'Architecture',
        icon: '🏛️',
        subSubcategories: [
          { name: 'Landmarks', icon: '🗽', price: '$-$$' },
          { name: 'Castles', icon: '🏰', price: '$-$$' },
          { name: 'Palaces', icon: '👑', price: '$-$$' },
          { name: 'Bridges', icon: '🌉', price: '$-$$' }
        ]
      },
      {
        name: 'Scenic Views',
        icon: '👁️',
        subSubcategories: [
          { name: 'Viewpoints', icon: '👁️', price: '$-$$' },
          { name: 'Observation Decks', icon: '🏙️', price: '$-$$' },
          { name: 'Squares', icon: '⛲', price: '$-$$' },
          { name: 'Gardens', icon: '🌺', price: '$-$$' }
        ]
      }
    ]
  }
]; 