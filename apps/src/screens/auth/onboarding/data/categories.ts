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
    id: 'food_drink',
    // value: 'Food Places',
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
          { name: 'Steakhouses', value: 'Steakhouses & Grills', icon: '🥩', price: '$$-$$$' },
          { name: 'Seafood', value: 'Seafood & Fish Cuisine', icon: '🦐', price: '$$-$$$' },
          { name: 'Indian', value: 'Indian & Curry Houses', icon: '🍛', price: '$$' },
          { name: 'Italian', value: 'Italian Cuisine', icon: '🍝', price: '$$' },
          { name: 'Mexican', value: 'Taco & Mexican Cuisine', icon: '🌮', price: '$' },
          { name: 'Burgers', value: 'Burger Joint', icon: '🍔', price: '$' },
          { name: 'Pizza', value: 'Pizzerias & Italian Cuisine', icon: '🍕', price: '$' },
          { name: 'Vegetarian', value: 'Vegetarian Cuisine', icon: '🥬', price: '$' },
          { name: 'Mediterranean', value: 'Mediterranean & Middle Eastern Cuisine', icon: '🌯', price: '$' }

        ]
      },
      {
        name: 'Street / Food Trucks',
        icon: '🚚',
        subSubcategories: [
          { name: 'Burgers', value: 'Burger Joints', icon: '🍔', price: '$' },
          { name: 'Pizza', value: 'Pizzerias & Italian Cuisine', icon: '🍕', price: '$' },
          // { name: 'Sandwiches', value: 'Sandwiches', icon: '🥪', price: '$' },
          { name: 'Hot Dogs', value: 'Hot Dog Joint', icon: '🌭', price: '$' },
          { name: 'BBQ Street Trucks', value: 'BBQ Street Trucks', icon: '🌭', price: '$' },
          { name: 'Mexican', value: 'Mexican Food Street Trucks', icon: '🌭', price: '$' }


        ]
      },
      {
        name: 'Cafes & Coffee',
        icon: '☕️',
        subSubcategories: [
          { name: 'Study Cafes', value: 'Study Cafés / Quiet Spaces', icon: '📖', price: '$' },
          { name: 'Matcha Cafes', value: 'Matcha Cafes', icon: '☕️', price: '$' },
          { name: 'Coffee Roasters', value: 'Coffee Roasters', icon: '☕️', price: '$' },
          { name: 'Espresso Bars', value: 'Espresso Bars', icon: '☕️', price: '$' },
          { name: 'Coffee Shops', value: 'Coffee Shops', icon: '☕️', price: '$' }


        ]
      },
      {
        name: 'Breakfast & Brunch',
        icon: '🍳',
        subSubcategories: [
          { name: 'Bagels', value: 'Bagel Shops', icon: '🥯', price: '$' },
          { name: 'Pancakes', value: 'Pancake Houses', icon: '🥞', price: '$' },
          { name: 'Waffles & Crepes', value: 'Waffle / Crepes', icon: '🧇', price: '$' },
          { name: 'Diners', value: 'Diners', icon: '🍽️', price: '$' }
        ]
      },
      {
        name: 'Asian Cuisine',
        icon: '🥢',
        subSubcategories: [
          { name: 'Chinese', value: 'Chinese Cuisine', icon: '🥡', price: '$' },
          { name: 'Thai', value: 'Thai & Southeast Asian Cuisine', icon: '🍲', price: '$' },
          { name: 'Japanese', value: 'Sushi & Japanese Cuisine', icon: '🍣', price: '$$' },
          { name: 'Korean', value: 'Korean Cuisine', icon: '🍚', price: '$$' },
          { name: 'Ramen & Noodles', value: 'Ramen & Noodles Shops', icon: '🍜', price: '$$' }

        ]
      },
      {
        name: 'Healthy Options',
        icon: '🥗',
        subSubcategories: [
          { name: 'Vegan / Vegetarian', value: 'Vegan / Vegetarian Speciality', icon: '🥬', price: '$$' },
          { name: 'Tea Houses', value: 'Tea Houses', icon: '🍵', price: '$$' },
          { name: 'Salad Bars', value: 'Salad Bars', icon: '🥗', price: '$$' }
        ]
      },
      {
        name: 'Fine Dining',
        icon: '🍷',
        subSubcategories: [
          { name: 'Steakhouses', value: 'Steakhouses & Grills', icon: '🥩', price: '$$$' },
          { name: 'Seafood', value: 'Seafood & Fish Cuisine', icon: '🦐', price: '$$$' },
          { name: 'Italian', value: 'Italian Cuisine', icon: '🍝', price: '$$$' },
          { name: 'Wine Bars', value: 'Wine Bars', icon: '🍷', price: '$$$' }
        ]
      },
      {
        name: 'Dessert Cafes',
        icon: '🍨',
        subSubcategories: [
          { name: 'Donut Shops', value: 'Donut Shops & Specialty Bakeries', icon: '🍩', price: '$' },
          { name: 'Cupcake Boutiques', value: 'Cupcake Shops', icon: '🧁', price: '$' },
          { name: 'Bakeries', value: 'Bakeries', icon: '🧁', price: '$' },
          { name: 'Cake Shops', value: 'Cake Shops', icon: '🍫', price: '$' },
          { name: 'Ice Cream Parlors', value: 'Ice Cream Shops', icon: '🍦', price: '$' },
          { name: 'Boba Tea', value: 'Bubble Tea / Boba', icon: '🧋', price: '$' },
          { name: 'Mochi Shops', value: 'Mochi Shops', icon: '🍡', price: '$' },
          { name: 'Froyo', value: 'Frozen Yogurt', icon: '🍡', price: '$' },
        ]
      }
    ]
  },
{
  id: 'recreation_fitness',
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
        { name: 'Gyms & Fitness Centers', value: 'Gyms & Fitness Centers', icon: '🏋️', price: '$$' },
        { name: 'Yoga', value: 'Yoga', icon: '🧘', price: '$$-$$$' },
        { name: 'Pilates & Barre Studios', value: 'Pilates & Barre Studios', icon: '🧘‍♀️', price: '$$-$$$' },
        { name: 'HIIT & Bootcamp', value: 'HIIT & Bootcamp', icon: '🏃‍♂️', price: '$$-$$$' },
        // { name: 'Stretch & Mobility Studios', value: 'Stretching & Mobility', icon: '🤸', price: '$-$$' },
        { name: 'Personal Training Studios', value: 'Personal Training Studios', icon: '💪', price: '$$-$$$' },
        { name: 'Spin & Cycling Studios', value: 'Spin & Cycling Studios', icon: '🚴‍♂️', price: '$$' },
        { name: 'CrossFit Boxes', value: 'CrossFit Boxes', icon: '🤸‍♂️', price: '$$-$$$' },
        { name: 'Dance Fitness', value: 'Dance Fitness', icon: '🕺🏼', price: '$$-$$$' }
      ]
    },
    {
      name: 'Team Sports',
      icon: '🏆',
      subSubcategories: [
        { name: 'Basketball Courts', value: 'Basketball Courts', icon: '🏀', price: '$' },
        { name: 'Soccer Fields', value: 'Soccer Fields', icon: '⚽', price: '$-$$' },
        { name: 'Tennis Courts', value: 'Tennis Courts', icon: '🎾', price: '$' },
        { name: 'Pickleball Courts', value: 'Pickleball Courts', icon: '🏓', price: '$' },
        { name: 'Volleyball Courts', value: 'Volleyball Courts', icon: '🏐', price: '$-$$' },
        { name: 'Skate Parks', value: 'Skate Parks', icon: '🛹', price: '$' }
      ]
    },
    {
      name: 'Skill & Combat Sports',
      icon: '🎯',
      subSubcategories: [
        { name: 'Boxing & Kickboxing', value: 'Boxing & Kickboxing', icon: '🥊', price: '$$' },
        { name: 'Archery', value: 'Archery', icon: '🏹', price: '$-$$' },
        { name: 'Indoor Climbing', value: 'Indoor Climbing', icon: '🧗', price: '$$-$$$' }
      ]
    },
    {
      name: 'Basketball Courts',
      icon: '⛳',
      subSubcategories: [
        { name: 'Golf Courses', value: 'Golf Courses', icon: '⛳', price: '$$-$$$' },
        { name: 'Miniature Golf', value: 'miniature golf', icon: '⛳', price: '$-$$' },
        { name: 'Bowling Alleys', value: 'bowling alleys', icon: '🎳', price: '$-$$' }
      ]
    },
    {
      name: 'Health & Wellness',
      icon: '🧖',
      subSubcategories: [
        // { name: 'Spas & Saunas', value: 'Spas & Saunas', icon: '🧖‍♀️', price: '$$-$$$' },
        { name: 'Massage', value: 'Massage', icon: '💆', price: '$$-$$$' },
        { name: 'Hydrotherapy & Hot Tubs', value: 'Hydrotherapy & Hot Tubs', icon: '🛁', price: '$-$$' }
      ]
    }
  ]
},
  {
    id: 'social_nightlife',
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
          { name: 'Bars & Lounges', value: 'Bars & Lounges', icon: '🍸', price: '$$-$$$' },
          { name: 'Cocktail Bars', value: 'Cocktail Bars', icon: '🍸', price: '$$-$$$' },
          { name: 'Wine & Tapas Bars', value: 'Wine Bars & Tapas', icon: '🍷', price: '$$-$$$' },
          { name: 'Breweries & Beer Bars', value: 'Breweries', icon: '🍺', price: '$-$$' },
          // { name: 'Dive Bars', value: 'Dive Bars', icon: '🍻', price: '$' },
          { name: 'Rooftop Bars', value: 'Rooftop Bars', icon: '🏙️', price: '$$-$$$' },
          { name: 'Distilleries', value: 'Distilleries', icon: '🥃', price: '$$' },
          { name: 'Wineries', value: 'Wineries', icon: '🍇', price: '$$-$$$' },
          { name: 'Beer Tasting Rooms', value: 'Beer Tasting Rooms', icon: '🍻', price: '$-$$' },
          { name: 'Billiards Lounges', value: 'Billiards Lounges', icon: '🎱', price: '$-$$' },
          { name: 'Shuffleboard & Bocce Bars', value: 'Shuffleboard & Bocce Bars', icon: '🏓', price: '$' },
          { name: 'Hotel Bars', value: 'Hotel Bars', icon: '🏨', price: '$$' },
          { name: 'Cigar Lounges', value: 'Cigar Lounges', icon: '🚬', price: '$$-$$$' },
          { name: 'Tiki Bars', value: 'Tiki Bars', icon: '🌺', price: '$$' },
          { name: 'Sports Bars', value: 'Sports Bars', icon: '🏈', price: '$-$$' },
          { name: 'Piano Lounges', value: 'Piano Lounges', icon: '🎹', price: '$$' }
        ]
      },
      {
        name: 'Live Entertainment',
        icon: '🎤',
        subSubcategories: [
          { name: 'Comedy Shows', value: 'Comedy Clubs', icon: '🎭', price: '$-$$' },
          { name: 'Karaoke Bars', value: 'Karaoke Bars', icon: '🎤', price: '$-$$' },
          { name: 'Jazz & Piano Bars', value: 'Jazz Piano Bars', icon: '🎹', price: '$-$$' },
          { name: 'Live Music Venues', value: 'Live Music Venues', icon: '🎵', price: '$-$$' },
          { name: 'Open Mic Nights', value: 'Open Mic Nights', icon: '🎤', price: '$' },
          { name: 'Spoken Word Poetry Bars', value: 'Spoken Word Poetry Bars', icon: '📖', price: '$-$$' },
          { name: 'Drag Show Bars', value: 'Drag Show Bars', icon: '👑', price: '$$' },
          { name: 'Variety Show Lounges', value: 'Variety Show Lounges', icon: '🎭', price: '$$' },
          { name: 'Cabaret Bars', value: 'Cabaret Bars', icon: '🎩', price: '$$-$$$' },
          { name: 'Burlesque Shows', value: 'Burlesque Shows', icon: '💃', price: '$$-$$$' }
        ]
      },
      // {
      //   name: 'Dance & Nightclubs',
      //   icon: '💃',
      //   subSubcategories: [
      //     { name: 'Nightclubs', value: 'Nightclubs', icon: '💃', price: '$$-$$$' },
      //     { name: 'Dance Clubs', value: 'Dance Clubs', icon: '🕺', price: '$$-$$$' },
      //     { name: 'Latin Dancing', value: 'Latin Dancing', icon: '💃', price: '$$-$$$' },
      //     { name: 'Silent Discos', value: 'Silent Discos', icon: '🎧', price: '$-$$' }
      //   ]
      // },
      // {
      //   name: 'Games & Hangouts',
      //   icon: '🎲',
      //   subSubcategories: [
      //     { name: 'Pool & Billiards', value: 'Pool & Billiards', icon: '🎱', price: '$-$$' },
      //     { name: 'Arcades & Barcades', value: 'Arcades & Barcades', icon: '🕹️', price: '$-$$' },
      //     { name: 'Bowling', value: 'Bowling', icon: '🎳', price: '$-$$' }
      //   ]
      // }
    ]
  },
  {
    id: 'shopping',
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
          { name: 'Thrift Stores', value: 'Thrift Stores', icon: '🛍️', price: '$' },
          { name: 'Antique Shops', value: 'Antique Shops', icon: '🏺', price: '$-$$' },
          { name: 'Flea Markets', value: 'Flea Markets', icon: '🛒', price: '$' },
          { name: 'Consignment Shops', value: 'Consignment Shops', icon: '🛍️', price: '$$-$$$' },
          { name: 'Vintage Clothing Shops', value: 'Vintage Clothing Shops', icon: '👗', price: '$-$$' },
          { name: 'Estate Sale Warehouses', value: 'Estate Sale Warehouses', icon: '🏠', price: '$$' },
          { name: 'Retro Furniture Stores', value: 'Retro Furniture Stores', icon: '🛋️', price: '$$-$$$' },
          { name: 'Charity Shops', value: 'Charity Shops', icon: '💖', price: '$' }
        ]
      },
      {
        name: 'Fashion & Apparel',
        icon: '👗',
        subSubcategories: [
          { name: 'Boutiques', value: 'Boutiques', icon: '👗', price: '$$-$$' },
          { name: 'Jewelry Stores', value: 'Jewelry Stores', icon: '💍', price: '$$-$$$' },
          { name: 'Designer Fashion', value: 'Designer Fashion', icon: '👠', price: '$$$' },
          { name: 'Leather Goods', value: 'Leather Goods', icon: '👞', price: '$$-$$$' },
          { name: 'Shoe Stores', value: 'Shoe Stores', icon: '👟', price: '$$' },
          { name: 'Streetwear Shops', value: 'Streetwear', icon: '🧢', price: '$$' },
          { name: 'Accessories Shops', value: 'Accessories', icon: '👜', price: '$-$$' },
          { name: 'Bridal Shops', value: 'Bridal Shops', icon: '👰', price: '$$$' }
        ]
      },
      {
        name: 'Home & Specialty',
        icon: '🏠',
        subSubcategories: [
          { name: 'Plant Shops', value: 'Plant Shops', icon: '🪴', price: '$-$$' },
          { name: 'Crystal & Spiritual Shops', value: 'Crystal & Spiritual Shops', icon: '🔮', price: '$-$$' },
          { name: 'Handmade & Artisan Goods', value: 'Handmade & Artisan Goods', icon: '🧶', price: '$-$$' },
          { name: 'Pottery & Ceramics Shops', value: 'Pottery & Ceramics Studios', icon: '🏺', price: '$$' },
          { name: 'Home Decor Boutiques', value: 'Home Decor Boutiques', icon: '🪞', price: '$$' },
          { name: 'Furniture Stores', value: 'Furniture Stores', icon: '🛋️', price: '$$-$$$' },
          { name: 'Candle Shops', value: 'Candle Shops', icon: '🕯️', price: '$-$$' },
          { name: 'Kitchen & Cookware Stores', value: 'kitchen_cookware_stores', icon: '🍳', price: '$-$$' }
        ]
      },
      {
        name: 'Hobbies & Collectibles',
        icon: '📚',
        subSubcategories: [
          { name: 'Record Stores', value: 'Record Stores', icon: '💿', price: '$-$$' },
          { name: 'Pop-Up Markets & Fairs', value: 'Pop-Up Markets & Fairs', icon: '🛍️', price: '$-$$' },
          { name: 'Bookstores', value: 'Bookstores', icon: '📚', price: '$-$$' },
          { name: 'Comic & Poster Shops', value: 'Comic & Poster Shops', icon: '📰', price: '$' },
          { name: 'Toy & Model Shops', value: 'Toy & Model Shops', icon: '🧸', price: '$$' },
          { name: 'Board Game & Puzzle Stores', value: 'Board Game & Puzzle Stores', icon: '🧩', price: '$$' },
          { name: 'Trading Card Stores', value: 'Trading Card Stores', icon: '🃏', price: '$$' },
          { name: 'Art Supply Stores', value: 'Art Supply Stores', icon: '🎨', price: '$$' }
        ]
      }
    ]
  },
  {
    id: 'nature_outdoors',
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
          { name: "Hiking", value: "Hiking Trails", icon: "🥾", price: "N/A - $" },
          { name: "Lakes & Rivers", value: "Lakes & Rivers", icon: "🏞️", price: "N/A - $" },
          { name: "Parks & Gardens", value: "Parks & Gardens", icon: "🌺", price: "N/A - $" },
          { name: "Scenic Viewpoints", value: "Scenic Viewpoints", icon: "👁️", price: "N/A - $" },
          { name: "Nature Trails", value: "Nature Trails", icon: "🌳", price: "N/A - $" },
          { name: "Picnic Areas", value: "Picnic Areas", icon: "🧺", price: "N/A - $" },
          { name: "Sunset / Sunrise Spots", value: "Sunset / Sunrise Spots", icon: "🌅", price: "N/A - $" },
          // { name: "Walking Paths / Greenbelts", value: "Walking Paths / Greenbelts", icon: "🌳", price: "N/A - $" },
          // { name: "Nature Preserves & Refuges", value: "Nature Preserves & Refuges", icon: "🦋", price: "N/A - $" },
          { name: "Beachfront Parks", value: "Beachfront Parks", icon: "🏖️", price: "N/A - $" }
        ]
      },
      {
        name: 'Adventure Sports',
        icon: '🎢',
        subSubcategories: [
          { name: "Paintball", value: "paintball", icon: "🔫", price: "$-$$" },
          { name: "Shooting Ranges", value: "shooting Ranges", icon: "🎯", price: "$-$$" },
          { name: "Obstacle Courses & Climbing", value: "obstacle courses & climbing", icon: "🧱", price: "$$" },
          { name: "Kayaking & Canoeing", value: "kayaking & canoeing", icon: "🛶", price: "$-$$" },
          // { name: "Ziplining", value: "Ziplining", icon: "🪂", price: "$-$$" },
          { name: "ATV & Off-Roading", value: "ATV & Off-Roading", icon: "🏍️", price: "$$-$$$" },
          { name: "Mountain Biking Trails", value: "mountain biking trails", icon: "🚵", price: "$-$$" },
          { name: "Whitewater Rafting", value: "whitewater rafting", icon: "🌊", price: "$$-$$$" },
          { name: "Surfing Spots", value: "surfing spots", icon: "🏄", price: "$-$$$" },
          { name: "Paragliding / Hang Gliding", value: "paragliding / hang gliding", icon: "🪁", price: "$$-$$$" },
          { name: "Rock Climbing (Outdoor Routes)", value: "rock climbing (outdoor routes)", icon: "🧗‍♂️", price: "$$" },
          { name: "Horseback Riding Trails", value: "horseback riding trails", icon: "🐎", price: "$$" },
          // { name: "Snow Sports", value: "Snow Sports", icon: "🎿", price: "$$-$$$" }
        ]
      },
      {
        name: 'Parks & Attractions',
        icon: '🎡',
        subSubcategories: [
          { name: "Amusement Parks", value: "Amusement Parks", icon: "🎢", price: "$$-$$$" },
          { name: "Outdoor Concerts & Festivals", value: "Outdoor Concerts & Festivals", icon: "🎤", price: "$-$$$" },
          { name: "Carnivals", value: "Carnivals", icon: "🎪", price: "$-$$" },
          { name: "Outdoor Theaters / Movie Nights", value: "Outdoor Theaters / Movie Nights", icon: "🎬", price: "$-$$" },
          { name: "Renaissance Fairs", value: "Renaissance Fairs", icon: "🛡️", price: "$-$$$" },
          { name: "Nature-Themed Playgrounds", value: "Nature-Themed Playgrounds", icon: "🛝", price: "Free - $" },
          { name: "Outdoor Markets", value: "Outdoor Markets", icon: "🧺", price: "$-$$" },
          { name: "Water Parks", value: "Water Parks", icon: "🏊", price: "$$-$$$" },
          // { name: "Botanical Light Shows", value: "Botanical Light Shows", icon: "💡", price: "$-$$" },
          // { name: "Outdoor Mazes / Corn Mazes", value: "Outdoor Mazes / Corn Mazes", icon: "🌽", price: "$-$$" }
        ]
      },
      {
        name: 'Animals & Wildlife',
        icon: '🦁',
        subSubcategories: [
          // { name: "Zoos", value: "Zoos", icon: "🦁", price: "$-$$" },
          // { name: "Aquariums", value: "Aquariums", icon: "🐠", price: "$-$$" },
          { name: "Petting Zoos", value: "petting zoos", icon: "🐑", price: "$-$$" },
          { name: "Wildlife Reserves", value: "Wildlife Reserves", icon: "🦓", price: "$-$$$" },
          { name: "Bird Watching Spots", value: "Bird Sanctuaries", icon: "🐦", price: "Free - $" },
          { name: "Butterfly Gardens", value: "Butterfly Gardens", icon: "🦋", price: "$-$$" },
          { name: "Reptile Parks", value: "reptile parks", icon: "🦎", price: "$-$$" },
          { name: "Animal Sanctuaries", value: "Animal Sanctuaries", icon: "🛐", price: "Free - $$" },
          { name: "Safari Parks", value: "safari parks", icon: "🦒", price: "$$-$$$" },
          // { name: "Sealife Touch Tanks", value: "Sealife Touch Tanks", icon: "🐙", price: "$-$$" }
        ]
      }
    ]
  },
  {
    id: 'indoor-activities',
    name: 'Indoor Activities',
    icon: '🧗',
    color: '#F57C00',
    gradient: ['#F57C00', '#E65100'],
    description: 'Fun activities indoors',
    subcategories: [
      {
        name: 'Thrill Zones',
        icon: '🎢',
        subSubcategories: [
          { name: 'VR Arcades', value: 'VR Arcades', icon: '🕹️', price: '$$-$$$' },
          { name: 'Laser Tag', value: 'Laser Tag / Nerf', icon: '🔫', price: '$$-$$$' },
          { name: 'Escape Rooms', value: 'Escape Rooms', icon: '🔐', price: '$$-$$$' },
          // { name: 'Go-Kart Tracks', value: 'Go-Kart Tracks', icon: '🏎️', price: '$$' },
          { name: 'Indoor Mini-Golf', value: 'Indoor Mini Golf', icon: '⛳', price: '$-$$' },
          { name: 'Trampoline Parks', value: 'Trampoline Parks', icon: '🤸', price: '$-$$' },
          { name: 'Indoor Obstacle Courses', value: 'Indoor Obstacle Courses', icon: '🧗', price: '$-$$' },
          { name: 'Bumper Cars', value: 'Bumper Cars', icon: '🚗', price: '$-$$' },
          // { name: 'Indoor Skydiving', value: 'Indoor Skydiving', icon: '🪂', price: '$$$' }
        ]
      },
      {
        name: 'Fantasy & Immersive Worlds',
        icon: '🧙',
        subSubcategories: [
          { name: 'Haunted Houses', value: 'Haunted Houses', icon: '👻', price: '$-$$' },
          { name: 'Immersive Theater', value: 'Immersive Theater', icon: '🎭', price: '$$-$$$' },
          { name: 'Fantasy Taverns', value: 'Fantasy Taverns', icon: '🏰', price: '$$-$$$' },
          { name: 'Sci-Fi & Fantasy Conventions', value: 'Sci-Fi / Fantasy Conventions', icon: '🤖', price: '$$-$$$' },
          { name: 'Escape-Based Theater', value: 'Escape-Based Theater', icon: '🎭', price: '$$' },
          { name: 'Role-Play Game Lounges', value: 'Role-Play Game Lounges', icon: '🧝', price: '$-$$' },
          { name: 'Cosplay Cafés', value: 'Cosplay Cafes', icon: '🎎', price: '$-$$' }
        ]
      },
      {
        name: 'Experiential Exhibits',
        icon: '🌌',
        subSubcategories: [
          { name: 'Digital Art Installations', value: 'Digital Art Installations', icon: '🖼️', price: '$' },
          { name: 'Projection Shows', value: 'Projection Shows', icon: '🎥', price: '$-$$' },
          { name: 'Immersive Exhibitions', value: 'Immersive Exhibitions', icon: '🌀', price: '$$-$$$' },
          { name: 'Light & Sound Rooms', value: 'Light & Sound Rooms', icon: '💡', price: '$-$$' },
          { name: 'Mirror Mazes', value: 'Mirror Mazes', icon: '🪞', price: '$-$$' },
          { name: 'Infinity Rooms', value: 'Infinity Rooms', icon: '♾️', price: '$-$$' },
          { name: 'AR-Enhanced Installations', value: 'AR-Enhanced Installations', icon: '📱', price: '$-$$' },
          { name: 'Interactive Science Centers', value: 'Interactive Science Centers', icon: '🔬', price: '$-$$' },
          { name: 'Pop-Up Museums', value: 'Pop-Up Museums', icon: '🍦', price: '$$' }
      ]
      },
      {
        name: 'Timeless Fun',
        icon: '🎳',
        subSubcategories: [
          { name: 'Movie Theaters', value: 'Movie Theaters', icon: '🎬', price: '$$' },
          { name: 'Indie Cinemas', value: 'Indie Cinemas', icon: '🎥', price: '$-$$' },
          { name: 'Bowling', value: 'Bowling Alleys', icon: '🎳', price: '$-$$' },
          { name: 'Retro Arcades & Barcades', value: 'Retro Arcades & Barcades', icon: '🕹️', price: '$$' },
          { name: 'Board Game Cafés', value: 'Board Game Cafés', icon: '🎲', price: '$-$$' },
          { name: 'Karaoke Rooms', value: 'Karaoke Rooms', icon: '🎤', price: '$-$$' },
          { name: 'Indoor Pool Halls', value: 'Indoor Pool Halls', icon: '🎱', price: '$-$$' },
          { name: 'Shuffleboard Lounges', value: 'Shuffleboard Lounges', icon: '🧂', price: '$-$$' },
          { name: 'Ping Pong Clubs', value: 'Ping Pong Clubs', icon: '🏓', price: '$-$$' }
        ]
      }
    ]
  },
    {
    id: 'creative_arts',
    name: 'Creative Arts & Crafts',
    icon: '🎨',
    color: '#3F51B5',
    rotation: '-10deg',
    gradient: ['#3F51B5', '#283593'],
    description: 'Unleash your creativity',
    subcategories: [
      {
        name: 'Hands-On Art Studios',
        icon: '🎨',
        subSubcategories: [
          { name: 'Pottery & Ceramics Studios', value: 'Pottery & Ceramics Studios', icon: '🏺', price: '$-$$' },
          { name: 'Sip & Paint Studios', value: 'Sip Paint Studios', icon: '🎨', price: '$-$$' },
          { name: 'Printmaking Workshops', value: 'Printmaking Workshops', icon: '🖨️', price: '$-$$' },
          { name: 'Art Studio Classes', value: 'Art Studio Classes', icon: '🎨', price: '$-$$' },
          { name: 'Sculpture Workshops', value: 'Sculpture Workshops', icon: '🗿', price: '$-$$' },
          { name: 'Watercolor & Drawing Sessions', value: 'Watercolor Drawing Sessions', icon: '🖌️', price: '$' },
          { name: 'Resin Art Studios', value: 'Resin Art Studios', icon: '🧫', price: '$-$$' },
          { name: 'Mixed Media & Collage Classes', value: 'Mixed Media Collage Classes', icon: '🧵', price: '$' },
          { name: 'Outdoor Art Walks', value: 'Outdoor Art Walks', icon: '🧵', price: '$' }

        ]
      },
      {
        name: 'Crafts & Maker Spaces',
        icon: '🧵',
        subSubcategories: [
          { name: 'Candle & Soap Making Workshops', value: 'Candle & Soap Making Workshops', icon: '🕯️', price: '$-$$' },
          { name: 'Jewelry Making Studios', value: 'Jewelry Making Studios', icon: '💍', price: '$-$$' },
          { name: 'Knitting & Sewing Circles', value: 'Knitting & Sewing Circles', icon: '🧶', price: '$' },
          { name: 'Makerspaces & DIY Labs', value: 'Makerspaces & DIY Labs', icon: '🔨', price: '$-$$' },
          { name: 'Woodworking Studios', value: 'Woodworking Studios', icon: '🪵', price: '$-$$' },
          { name: 'Leather Craft Workshops', value: 'Leather Craft Workshops', icon: '👞', price: '$-$$' },
          { name: 'Upcycling', value: 'Upcycling & Repurposing Classes', icon: '♻️', price: '$' },
          { name: 'Embroidery or Weaving Studios', value: 'Embroidery or Weaving Studios', icon: '🧵', price: '$' },
          { name: 'Community Art Installations', value: 'Community Art Installations', icon: '🧵', price: '$' },
          { name: 'Museum Late Nights', value: 'Museum Late Nights', icon: '🧵', price: '$' },
          { name: 'Public Art Tours', value: 'Public Art Tours', icon: '🧵', price: '$' },
          { name: 'Art Film Screenings & Doc Nights', value: 'Art Film Screenings & Doc Nights', icon: '🧵', price: '$' },
          { name: 'Artist Studio Tours', value: 'Artist Studio Tours', icon: '🧵', price: '$' },
          { name: 'Art Lectures & Educational Talks', value: 'Art Lectures & Educational Talks', icon: '🧵', price: '$' },

        ]
      },
      // {
      //   name: 'Creative Writing & Storytelling',
      //   icon: '📝',
      //   subSubcategories: [
      //     { name: 'Poetry Open Mic Nights', value: 'poetry_open_mic', icon: '🎤', price: '$-$$' },
      //     { name: 'Writing Workshops', value: 'writing_workshops', icon: '📝', price: '$-$$' },
      //     { name: 'Zine & Bookmaking Events', value: 'zine_bookmaking', icon: '📚', price: '$' },
      //     { name: 'Storytelling Shows or Competitions', value: 'storytelling_shows', icon: '🎭', price: '$' }
      //   ]
      // },
      // {
      //   name: 'Art Appreciation & Exploration',
      //   icon: '🖼️',
      //   subSubcategories: [
      //     { name: 'Gallery Events', value: 'gallery_events', icon: '🖼️', price: '$-$$' }, ✅
      //     { name: 'Public Art Tours', value: 'public_art_tours', icon: '🚶', price: '$-$$$' },
      //     { name: 'Art-Themed Lectures & Educational Talks', value: 'art_lectures', icon: '🎓', price: '$-$$' }, ✅
      //     { name: 'Art Film Screenings or Doc Nights', value: 'art_film_screenings', icon: '🎬', price: '$' }
      //   ]
      // }
    ]
  },
]; 