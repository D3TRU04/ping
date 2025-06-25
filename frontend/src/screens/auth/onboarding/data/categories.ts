export interface Subcategory {
  name: string;
  value?: string; // What supabase sees (if needed)

  icon: string;
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
      { name: 'Fast Food', icon: '🍔' },
      { name: 'Seafood', value: 'Seafood & Fish Cuisine', icon: '🦐' },
      { name: 'Desserts', icon: '🍰' },
      { name: 'Vegan', icon: '🥗' },
      { name: 'Steak & Grill', value: 'Steakhouses & Grills', icon: '🥩' },
      { name: 'Japanese', value: 'Sushi & Japanese Cuisine', icon: '🍣' },
      { name: 'Chinese', value: 'Chinese Cuisine', icon: '🥢' },
      { name: 'Italian', value: 'Pizzerias & Italian', icon: '🍝' },
      { name: 'Korean', value: 'Korean Cuisine', icon: '🍚' },
      { name: 'Mexican', value: 'Taco & Mexican Cuisine', icon: '🌮' },
      { name: 'Healthy', icon: '🥑' },
      { name: 'Coffee', icon: '☕' },
      { name: 'Burgers', value: 'Burger Joints',icon: '🍔' },
      { name: 'Pizza', value: 'Pizzerias & Italian', icon: '🍕' },
      { name: 'Sushi', value: 'Sushi & Japanese Cuisine', icon: '🍣' },
      { name: 'Thai', value: 'Thai & Southeast Asian Cuisine', icon: '🍜' },
      { name: 'Indian', icon: '🍛' },
      { name: 'Mediterranean', value: 'Mediterranean & Middle Eastern Cuisine', icon: '🥙' },
      { name: 'BBQ', icon: '🍖' },
      { name: 'Breakfast', icon: '🥞' },
      { name: 'Brunch', icon: '🍳' },
      { name: 'Fine Dining', icon: '🍷' }
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
      { name: 'Malls', icon: '🏬' },
      { name: 'Boutiques', icon: '👗' },
      { name: 'Farmers Markets', icon: '🥕' },
      { name: 'Thrift', icon: '👕' },
      { name: 'Tech Stores', icon: '💻' },
      { name: 'Bookstores', icon: '📚' },
      { name: 'Jewelry', icon: '💎' },
      { name: 'Shoes', icon: '👠' },
      { name: 'Clothing', icon: '👖' },
      { name: 'Home Decor', icon: '🏠' },
      { name: 'Electronics', icon: '📱' },
      { name: 'Grocery', icon: '🛒' },
      { name: 'Antiques', icon: '🏺' },
      { name: 'Art Galleries', icon: '🎨' },
      { name: 'Flea Markets', icon: '🛍️' },
      { name: 'Department Stores', icon: '🏪' },
      { name: 'Outlet Malls', icon: '🏢' },
      { name: 'Local Shops', icon: '🏪' },
      { name: 'Online Shopping', icon: '🛒' },
      { name: 'Vintage', icon: '👗' }
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
      { name: 'Painting', icon: '🖼️' },
      { name: 'Pottery', icon: '🏺' },
      { name: 'DIY', icon: '🔨' },
      { name: 'Knitting', icon: '🧶' },
      { name: 'Drawing', icon: '✏️' },
      { name: 'Photography', icon: '📸' },
      { name: 'Sculpture', icon: '🗿' },
      { name: 'Digital Art', icon: '💻' },
      { name: 'Calligraphy', icon: '✒️' },
      { name: 'Origami', icon: '🦢' },
      { name: 'Jewelry Making', icon: '💍' },
      { name: 'Woodworking', icon: '🪵' },
      { name: 'Sewing', icon: '🧵' },
      { name: 'Crochet', icon: '🧶' },
      { name: 'Embroidery', icon: '🪡' },
      { name: 'Glass Blowing', icon: '🔥' },
      { name: 'Printmaking', icon: '🖨️' },
      { name: 'Collage', icon: '📄' },
      { name: 'Mixed Media', icon: '🎭' },
      { name: 'Animation', icon: '🎬' }
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
      { name: 'Bars', icon: '🍺' },
      { name: 'Clubs', icon: '💃' },
      { name: 'Karaoke', icon: '🎤' },
      { name: 'Lounges', icon: '🛋️' },
      { name: 'Pubs', icon: '🍻' },
      { name: 'Wine Bars', icon: '🍷' },
      { name: 'Cocktail Bars', icon: '🍹' },
      { name: 'Dance Clubs', icon: '🕺' },
      { name: 'Live Music', icon: '🎵' },
      { name: 'Comedy Clubs', icon: '😄' },
      { name: 'Rooftop Bars', icon: '🏙️' },
      { name: 'Speakeasies', icon: '🥃' },
      { name: 'Sports Bars', icon: '🏈' },
      { name: 'Jazz Clubs', icon: '🎷' },
      { name: 'Beer Gardens', icon: '🌳' },
      { name: 'Hookah Lounges', icon: '💨' },
      { name: 'Night Markets', icon: '🌙' },
      { name: 'Festivals', icon: '🎪' },
      { name: 'Concerts', icon: '🎤' },
      { name: 'Parties', icon: '🎉' }
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
      { name: 'Gym', icon: '🏋️' },
      { name: 'Yoga', icon: '🧘' },
      { name: 'Sports', icon: '⚽' },
      { name: 'Skating', icon: '⛸️' },
      { name: 'Swimming', icon: '🏊' },
      { name: 'Running', icon: '🏃' },
      { name: 'Cycling', icon: '🚴' },
      { name: 'Hiking', icon: '🥾' },
      { name: 'Rock Climbing', icon: '🧗' },
      { name: 'Tennis', icon: '🎾' },
      { name: 'Basketball', icon: '🏀' },
      { name: 'Soccer', icon: '⚽' },
      { name: 'Volleyball', icon: '🏐' },
      { name: 'Golf', icon: '⛳' },
      { name: 'Boxing', icon: '🥊' },
      { name: 'Martial Arts', icon: '🥋' },
      { name: 'Pilates', icon: '🧘' },
      { name: 'CrossFit', icon: '💪' },
      { name: 'Dance', icon: '💃' },
      { name: 'Meditation', icon: '🧘' }
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
      { name: 'Hiking', icon: '🥾' },
      { name: 'Parks', icon: '🌳' },
      { name: 'Lakes', icon: '🏞️' },
      { name: 'Stargazing', icon: '⭐' },
      { name: 'Camping', icon: '⛺' },
      { name: 'Beaches', icon: '🏖️' },
      { name: 'Mountains', icon: '⛰️' },
      { name: 'Forests', icon: '🌲' },
      { name: 'Gardens', icon: '🌺' },
      { name: 'Botanical Gardens', icon: '🌸' },
      { name: 'Wildlife Watching', icon: '🦌' },
      { name: 'Bird Watching', icon: '🦅' },
      { name: 'Fishing', icon: '🎣' },
      { name: 'Kayaking', icon: '🛶' },
      { name: 'Canoeing', icon: '🛶' },
      { name: 'Rock Climbing', icon: '🧗' },
      { name: 'Mountain Biking', icon: '🚵' },
      { name: 'Skiing', icon: '⛷️' },
      { name: 'Snowboarding', icon: '🏂' },
      { name: 'Sunset Viewing', icon: '🌅' }
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
      { name: 'Escape Rooms', icon: '🔐' },
      { name: 'Bowling', icon: '🎳' },
      { name: 'Arcades', icon: '🕹️' },
      { name: 'Laser Tag', icon: '🔫' },
      { name: 'Mini Golf', icon: '⛳' },
      { name: 'Trampoline Parks', icon: '🦘' },
      { name: 'Rock Climbing Gyms', icon: '🧗' },
      { name: 'Virtual Reality', icon: '🥽' },
      { name: 'Board Game Cafes', icon: '🎲' },
      { name: 'Karaoke', icon: '🎤' },
      { name: 'Movie Theaters', icon: '🎬' },
      { name: 'Museums', icon: '🏛️' },
      { name: 'Aquariums', icon: '🐠' },
      { name: 'Zoos', icon: '🦁' },
      { name: 'Science Centers', icon: '🔬' },
      { name: 'Planetariums', icon: '🌌' },
      { name: 'Art Galleries', icon: '🎨' },
      { name: 'Theaters', icon: '🎭' },
      { name: 'Concert Halls', icon: '🎵' },
      { name: 'Comedy Shows', icon: '😄' }
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
      { name: 'Museums', icon: '🏛️' },
      { name: 'Landmarks', icon: '🗽' },
      { name: 'Architecture', icon: '🏛️' },
      { name: 'Historical Sites', icon: '🏺' },
      { name: 'Monuments', icon: '🗿' },
      { name: 'Statues', icon: '🗽' },
      { name: 'Churches', icon: '⛪' },
      { name: 'Temples', icon: '🕍' },
      { name: 'Castles', icon: '🏰' },
      { name: 'Palaces', icon: '👑' },
      { name: 'Bridges', icon: '🌉' },
      { name: 'Towers', icon: '🗼' },
      { name: 'Squares', icon: '⛲' },
      { name: 'Plazas', icon: '🏛️' },
      { name: 'Gardens', icon: '🌺' },
      { name: 'Fountains', icon: '⛲' },
      { name: 'Street Art', icon: '🎨' },
      { name: 'Viewpoints', icon: '👁️' },
      { name: 'Observation Decks', icon: '🏙️' },
      { name: 'City Tours', icon: '🚌' }
    ]
  }
]; 