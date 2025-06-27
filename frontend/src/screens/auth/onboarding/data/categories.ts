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
    icon: '🍕',
    color: '#D7263D',
    rotation: '10deg',
    gradient: ['#D7263D', '#A61B2B'],
    description: 'Discover amazing restaurants and cafes',
    subcategories: [
      {
        name: 'Fast Food',
        icon: '🍔',
        subSubcategories: [
          { name: 'Burgers', icon: '🍔', price: '$' },
          { name: 'Pizza', icon: '🍕', price: '$' },
          { name: 'Hot Dogs', icon: '🌭', price: '$' },
          { name: 'Fried Chicken', icon: '🍗', price: '$' }
        ]
      },
      {
        name: 'Asian Cuisine',
        icon: '🥢',
        subSubcategories: [
          { name: 'Japanese', icon: '🍣', price: '$$' },
          { name: 'Chinese', icon: '🥢', price: '$$' },
          { name: 'Korean', icon: '🍚', price: '$$' },
          { name: 'Thai', icon: '🍜', price: '$$' }
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
    icon: '💪',
    color: '#388E3C',
    rotation: '20deg',
    gradient: ['#388E3C', '#1B5E20'],
    description: 'Stay active and healthy',
    subcategories: [
      {
        name: 'Train & Sweat',
        icon: '💪',
        subSubcategories: [
          { name: 'Gyms & Fitness Centers', icon: '🏋️', price: '$$' },
          { name: 'Yoga Studios', icon: '🧘', price: '$$' },
          { name: 'Pilates & Barre Studios', icon: '🧘‍♀️', price: '$$-$$$' },
          { name: 'HIIT / Bootcamp Studios', icon: '🏃‍♂️', price: '$$-$$$' },
          { name: 'Boxing & Kickboxing Gyms', icon: '🥊', price: '$$' }
        ]
      },
      {
        name: 'Play & Compete',
        icon: '🏆',
        subSubcategories: [
          { name: 'Basketball Courts', icon: '🏀', price: '$' },
          { name: 'Soccer / Futsal Fields', icon: '⚽', price: '$-$$' },
          { name: 'Tennis & Pickleball Courts', icon: '🎾', price: '$' },
          { name: 'Volleyball Courts (Indoor / Beach)', icon: '🏐', price: '$-$$' }
        ]
      },
      {
        name: 'Skill & Precision Sports',
        icon: '🎯',
        subSubcategories: [
          { name: 'Golf Courses & Driving Ranges', icon: '⛳', price: '$$-$$$' },
          { name: 'Archery Ranges', icon: '🏹', price: '$-$$' },
          { name: 'Mini-Golf', icon: '⛳', price: '$-$$' },
          { name: 'Climbing Gyms', icon: '🧗', price: '$$-$$$' }
        ]
      },
      {
        name: 'Recover & Recharge',
        icon: '🧖',
        subSubcategories: [
          { name: 'Golf Courses & Driving Ranges', icon: '⛳', price: '$$-$$$' },
          { name: 'Spas & Saunas', icon: '🧖‍♀️', price: '$$-$$$' },
          { name: 'Massage Studios', icon: '💆', price: '$$-$$$' },
          { name: 'Hydrotherapy & Hot Tubs', icon: '🛁', price: '$-$$' },
          { name: 'Stretch & Mobility Studios', icon: '🤸', price: '$-$$' }
        ]
      }
    ]
  },
  {
    id: 'indoor-adventure',
    name: 'Indoor Adventure',
    icon: '🎯',
    color: '#F57C00',
    gradient: ['#F57C00', '#E65100'],
    description: 'Fun activities indoors',
    subcategories: [
      {
        name: 'Thrill Zones',
        icon: '🎢',
        subSubcategories: [
          { name: 'VR Arcades', icon: '🕹️', price: '$$-$$$' },
          { name: 'Laser Tag and Nerf Arenas', icon: '🔫', price: '$$-$$$' },
          { name: 'Escape Rooms', icon: '🔐', price: '$$-$$$' },
          { name: 'Go-Karting', icon: '🏎️', price: '$$' },
          { name: 'Indoor Mini-Golf', icon: '⛳', price: '$-$$' }
        ]
      },
      {
        name: 'Fantasy & Immersive Worlds',
        icon: '🧙',
        subSubcategories: [
          { name: 'Haunted Houses', icon: '👻', price: '$-$$' },
          { name: 'Immersive Theater Performances', icon: '🎭', price: '$$-$$$' },
          { name: 'Fantasy Taverns or Medieval Inns', icon: '🏰', price: '$$-$$$' },
          { name: 'Sci-fi/Fantasy Conventions', icon: '🤖', price: '$$-$$$' }
        ]
      },
      {
        name: 'Experiential Exhibits',
        icon: '🖼️',
        subSubcategories: [
          { name: 'Digital Art Installations', icon: '🖼️', price: '$' },
          { name: 'Projection Shows', icon: '🎥', price: '$-$$' },
          { name: 'Immersive Exhibitions', icon: '🖼️', price: '$$' },
          { name: 'Light & Sound Rooms', icon: '💡', price: '$-$$' }
        ]
      },
      {
        name: 'Timeless Fun',
        icon: '🎳',
        subSubcategories: [
          { name: 'Movie Theaters', icon: '🎬', price: '$$' },
          { name: 'Indie Cinemas', icon: '🎥', price: '$-$$' },
          { name: 'Bowling Alleys', icon: '🎳', price: '$-$$' },
          { name: 'Retro Arcades/Barcades', icon: '🕹️', price: '$$' }
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
    id: 'nature-outdoors',
    name: 'Nature & Outdoors',
    icon: '🌲',
    color: '#6D4C41',
    gradient: ['#6D4C41', '#3E2723'],
    description: 'Explore the great outdoors',
    subcategories: [
      {
        name: 'Nature & Scenic Exploration',
        icon: '🌄',
        subSubcategories: [
          { name: 'Hiking Trails', icon: '🥾', price: 'N/A - $' },
          { name: 'Lakes & Rivers', icon: '🏞️', price: 'N/A - $' },
          { name: 'Parks & Botanical Gardens', icon: '🌺', price: 'N/A - $' },
          { name: 'Scenic Viewpoints', icon: '👁️', price: 'N/A - $' }
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
      },
      {
        name: 'Outdoor Thrills',
        icon: '🎢',
        subSubcategories: [
          { name: 'Paintball Fields', icon: '🔫', price: '$-$$' },
          { name: 'Shooting Ranges', icon: '🎯', price: '$-$$' },
          { name: 'Obstacle Courses & Rock Climbing', icon: '🧗', price: '$$' },
          { name: 'Kayaking and Canoeing', icon: '🛶', price: '$-$$' },
          { name: 'Ziplining', icon: '🪂', price: '$-$$' },
          { name: 'ATV/Off-Roading', icon: '🏍️', price: '$$-$$$' }
        ]
      },
      {
        name: 'Outdoor Attractions',
        icon: '🎡',
        subSubcategories: [
          { name: 'Amusement Parks', icon: '🎢', price: '$$-$$$' },
          { name: 'Outdoor Concerts & Festivals', icon: '🎤', price: '$-$$$' },
          { name: 'Carnivals', icon: '🎪', price: '$-$$' }
        ]
      }
    ]
  },
  {
    id: 'social-nightlife',
    name: 'Social & Nightlife',
    icon: '🍸',
    color: '#8E24AA',
    gradient: ['#8E24AA', '#5E35B1'],
    description: 'Connect and have fun',
    subcategories: [
      {
        name: 'Bars & Lounges',
        icon: '🍸',
        subSubcategories: [
          { name: 'Cocktail Lounges & Speakeasies', icon: '🍸', price: '$$-$$$' },
          { name: 'Wine Bars & Tapas', icon: '🍷', price: '$$-$$$' },
          { name: 'Brewpubs & Craft Beer Bars', icon: '🍺', price: '$-$$' },
          { name: 'Dive Bars', icon: '🍻', price: '$-$' },
          { name: 'Rooftop Bars & Lounges', icon: '🏙️', price: '$$-$$$' }
        ]
      },
      {
        name: 'Live Entertainment Venues',
        icon: '🎤',
        subSubcategories: [
          { name: 'Comedy Clubs', icon: '🎭', price: '$-$$' },
          { name: 'Karaoke Bars', icon: '🎤', price: '$-$$' },
          { name: 'Jazz & Piano Bars', icon: '🎹', price: '$-$$' },
          { name: 'Live Music Bars', icon: '🎵', price: '$-$$' }
        ]
      },
      {
        name: 'Dance & Nightclubs',
        icon: '💃',
        subSubcategories: [
          { name: 'Nightclubs', icon: '💃', price: '$$-$$$' },
          { name: 'Dance Clubs', icon: '🕺', price: '$$-$$$' },
          { name: 'Latin Dance Clubs', icon: '💃', price: '$$-$$$' },
          { name: 'Silent Discos', icon: '🎧', price: '$-$$' }
        ]
      },
      {
        name: 'Social Games',
        icon: '🎲',
        subSubcategories: [
          { name: 'Pool Halls & Billiards Lounges', icon: '🎱', price: '$-$$' },
          { name: 'Arcade Bars (Barcades)', icon: '🕹️', price: '$-$$' },
          { name: 'Bowling Lounges', icon: '🎳', price: '$-$$' }
        ]
      }
    ]
  },
  {
    id: 'shopping-markets',
    name: 'Shopping & Markets',
    icon: '🛍️',
    color: '#1B9AAA',
    gradient: ['#1B9AAA', '#16697A'],
    description: 'Find the best shopping spots',
    subcategories: [
      {
        name: 'Secondhand',
        icon: '♻️',
        subSubcategories: [
          { name: 'Thrift Stores', icon: '🛍️', price: '$' },
          { name: 'Antique Stores', icon: '🏺', price: '$-$$' },
          { name: 'Flea Markets', icon: '🛒', price: '$' },
          { name: 'Curated Stores', icon: '🛍️', price: '$$-$$$' }
        ]
      },
      {
        name: 'Clothing & Fashion',
        icon: '👗',
        subSubcategories: [
          { name: 'Jewelry Shops', icon: '💍', price: '$$-$$$' },
          { name: 'Local Fashion Boutiques', icon: '👗', price: '$$-$$' },
          { name: 'Designer Stores', icon: '👠', price: '$$$' },
          { name: 'Leather Stores', icon: '👞', price: '$$-$$$' }
        ]
      },
      {
        name: 'Home & Lifestyle',
        icon: '🏠',
        subSubcategories: [
          { name: 'Plant Shops', icon: '🪴', price: '$-$$' },
          { name: 'Crystal/Spiritual Stores', icon: '🔮', price: '$-$$' },
          { name: 'Handmade Goods Stores', icon: '🧶', price: '$-$$' },
          { name: 'Pottery Studios', icon: '🏺', price: '$$' }
        ]
      },
      {
        name: 'Hobbies & Collectibles',
        icon: '📚',
        subSubcategories: [
          { name: 'Record & CD Stores', icon: '💿', price: '$-$$' },
          { name: 'Pop-up Markets and Vendor Fair Events', icon: '🛍️', price: '$-$$' },
          { name: 'Bookstores', icon: '📚', price: '$-$$' },
          { name: 'Magazine/Comic/Poster Stores', icon: '📰', price: '$' }
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