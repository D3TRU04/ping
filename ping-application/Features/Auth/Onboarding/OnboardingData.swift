//
//  OnboardingData.swift
//  PingNative
//
//  Source: ping/apps/src/screens/auth/onboarding/data.ts (implied)
//  Category and subcategory data structures
//

import Foundation

struct OnboardingData {
    static let categories: [Category] = [
        Category(
            id: "food-drink",
            name: "Food & Drink",
            icon: "🍔",
            color: "#FF6B6B",
            gradient: ["#FF6B6B", "#FF5252"],
            description: "Discover amazing restaurants and cafes",
            subcategories: [
                Subcategory(name: "Asian Noodle Street Trucks", icon: "🍜", value: "Asian Noodle Street Trucks"),
                Subcategory(name: "Bagel Shops", icon: "🥯", value: "Bagel Shops"),
                Subcategory(name: "Bakeries", icon: "🥐", value: "Bakeries"),
                Subcategory(name: "BBQ Street Trucks", icon: "🍖", value: "BBQ Street Trucks"),
                Subcategory(name: "Bubble Tea / Boba", icon: "🧋", value: "Bubble Tea / Boba"),
                Subcategory(name: "Burger Joints", icon: "🍔", value: "Burger Joints"),
                Subcategory(name: "Cafes", icon: "☕", value: "Cafes"),
                Subcategory(name: "Cake Shops", icon: "🎂", value: "Cake Shops"),
                Subcategory(name: "Chinese Cuisine", icon: "🥡", value: "Chinese Cuisine"),
                Subcategory(name: "Coffee Shops", icon: "☕", value: "Coffee Shops"),
                Subcategory(name: "Cupcake Shops", icon: "🧁", value: "Cupcake Shops"),
                Subcategory(name: "Diners", icon: "🍽️", value: "Diners"),
                Subcategory(name: "Donut Shops", icon: "🍩", value: "Donut Shops"),
                Subcategory(name: "Espresso Bars", icon: "☕", value: "Espresso Bars"),
                Subcategory(name: "Fast Casual / Takeout", icon: "🥡", value: "Fast Casual / Takeout"),
                Subcategory(name: "Food Halls", icon: "🏬", value: "Food Halls"),
                Subcategory(name: "Food Markets", icon: "🥕", value: "Food Markets"),
                Subcategory(name: "Frozen Yogurt", icon: "🍦", value: "Frozen Yogurt"),
                Subcategory(name: "Fusion Street Street Trucks", icon: "🚚", value: "Fusion Street Street Trucks"),
                Subcategory(name: "Healthy / Salad Bars", icon: "🥗", value: "Healthy / Salad Bars"),
                Subcategory(name: "Ice Cream Shops", icon: "🍦", value: "Ice Cream Shops"),
                Subcategory(name: "Indian & Curry Houses", icon: "🍛", value: "Indian & Curry Houses"),
                Subcategory(name: "Indian Food Street Trucks", icon: "🍛", value: "Indian Food Street Trucks"),
                Subcategory(name: "Korean Cuisine", icon: "🍲", value: "Korean Cuisine"),
                Subcategory(name: "Local Coffee Roasters", icon: "☕", value: "Local Coffee Roasters"),
                Subcategory(name: "Matcha Cafes", icon: "🍵", value: "Matcha Cafes"),
                Subcategory(name: "Mediterranean & Middle Eastern Cuisine", icon: "🧆", value: "Mediterranean & Middle Eastern Cuisine"),
                Subcategory(name: "Mexican Food Street Trucks", icon: "🌮", value: "Mexican Food Street Trucks"),
                Subcategory(name: "Mochi Shops", icon: "🍡", value: "Mochi Shops"),
                Subcategory(name: "Pancake Houses", icon: "🥞", value: "Pancake Houses"),
                Subcategory(name: "Pizzerias & Italian Cuisine", icon: "🍕", value: "Pizzerias & Italian Cuisine"),
                Subcategory(name: "Ramen & Noodle Shops", icon: "🍜", value: "Ramen & Noodle Shops"),
                Subcategory(name: "Seafood & Fish Cuisine", icon: "🦞", value: "Seafood & Fish Cuisine"),
                Subcategory(name: "Steakhouses & Grills", icon: "🥩", value: "Steakhouses & Grills"),
                Subcategory(name: "Study Cafés / Quiet Spaces", icon: "📚", value: "Study Cafés / Quiet Spaces"),
                Subcategory(name: "Sushi & Japanese Cuisine", icon: "🍣", value: "Sushi & Japanese Cuisine"),
                Subcategory(name: "Taco & Mexican Cuisine", icon: "🌮", value: "Taco & Mexican Cuisine"),
                Subcategory(name: "Tea Houses", icon: "🍵", value: "Tea Houses"),
                Subcategory(name: "Thai & Southeast Asian Cuisine", icon: "🍲", value: "Thai & Southeast Asian Cuisine"),
                Subcategory(name: "Vegan & Vegetarian Specialty", icon: "🥗", value: "Vegan & Vegetarian Specialty"),
                Subcategory(name: "Waffle / Crepes", icon: "🧇", value: "Waffle / Crepes"),
            ]
        ),
        Category(
            id: "shopping-markets",
            name: "Shopping & Markets",
            icon: "🛍️",
            color: "#4ECDC4",
            gradient: ["#4ECDC4", "#44A08D"],
            description: "Find the best shopping spots",
            subcategories: [
                Subcategory(name: "Accessories", icon: "👜", value: "Accessories"),
                Subcategory(name: "Antique Shops", icon: "🏺", value: "Antique Shops"),
                Subcategory(name: "Art Supply Stores", icon: "🎨", value: "Art Supply Stores"),
                Subcategory(name: "Board Game & Puzzle Stores", icon: "🎲", value: "Board Game & Puzzle Stores"),
                Subcategory(name: "Bookstores", icon: "📚", value: "Bookstores"),
                Subcategory(name: "Boutiques", icon: "👗", value: "Boutiques"),
                Subcategory(name: "Bridal Shops", icon: "👰", value: "Bridal Shops"),
                Subcategory(name: "Candle Shops", icon: "🕯️", value: "Candle Shops"),
                Subcategory(name: "Charity Shops", icon: "💝", value: "Charity Shops"),
                Subcategory(name: "Comic & Poster Shops", icon: "📰", value: "Comic & Poster Shops"),
                Subcategory(name: "Consignment Shops", icon: "🏷️", value: "Consignment Shops"),
                Subcategory(name: "Crystal & Spiritual Shops", icon: "🔮", value: "Crystal & Spiritual Shops"),
                Subcategory(name: "Designer Fashion", icon: "👠", value: "Designer Fashion"),
                Subcategory(name: "Estate Sale Warehouses", icon: "🏠", value: "Estate Sale Warehouses"),
                Subcategory(name: "Furniture Stores", icon: "🪑", value: "Furniture Stores"),
                Subcategory(name: "Handmade & Artisan Goods", icon: "🧶", value: "Handmade & Artisan Goods"),
                Subcategory(name: "Home Decor Boutiques", icon: "🏡", value: "Home Decor Boutiques"),
                Subcategory(name: "Jewelry Stores", icon: "💍", value: "Jewelry Stores"),
                Subcategory(name: "Leather Goods", icon: "👜", value: "Leather Goods"),
                Subcategory(name: "Plant Shops", icon: "🪴", value: "Plant Shops"),
                Subcategory(name: "Pop Up Markets & Fairs", icon: "🎪", value: "Pop Up Markets & Fairs"),
                Subcategory(name: "Pottery & Ceramics Shops", icon: "🏺", value: "Pottery & Ceramics Shops"),
                Subcategory(name: "Record Stores", icon: "🎵", value: "Record Stores"),
                Subcategory(name: "Retro Furniture Stores", icon: "🛋️", value: "Retro Furniture Stores"),
                Subcategory(name: "Shoe Stores", icon: "👟", value: "Shoe Stores"),
                Subcategory(name: "Streetwear", icon: "👕", value: "Streetwear"),
                Subcategory(name: "Thrift Stores", icon: "👕", value: "Thrift Stores"),
                Subcategory(name: "Toy & Model Shops", icon: "🧸", value: "Toy & Model Shops"),
                Subcategory(name: "Trading Card Stores", icon: "🃏", value: "Trading Card Stores"),
                Subcategory(name: "Vintage Clothing Shops", icon: "👗", value: "Vintage Clothing Shops"),
            ]
        ),
        Category(
            id: "creative-arts",
            name: "Creative Arts & Crafts",
            icon: "🎨",
            color: "#45B7D1",
            gradient: ["#45B7D1", "#3498DB"],
            description: "Explore your creative side",
            subcategories: [
                Subcategory(name: "Art Film Screenings & Doc Nights", icon: "🎬", value: "Art Film Screenings & Doc Nights"),
                Subcategory(name: "Artist Studio Tours", icon: "🖼️", value: "Artist Studio Tours"),
                Subcategory(name: "Art Lectures & Educational Talks", icon: "🎓", value: "Art Lectures & Educational Talks"),
                Subcategory(name: "Art Studio Classes", icon: "🎨", value: "Art Studio Classes"),
                Subcategory(name: "Candle & Soap Making Workshops", icon: "🕯️", value: "Candle & Soap Making Workshops"),
                Subcategory(name: "Community Art Installations", icon: "🏗️", value: "Community Art Installations"),
                Subcategory(name: "Embroidery or Weaving Studios", icon: "🧵", value: "Embroidery or Weaving Studios"),
                Subcategory(name: "Gallery Events", icon: "🖼️", value: "Gallery Events"),
                Subcategory(name: "Jewelry Making Studios", icon: "💍", value: "Jewelry Making Studios"),
                Subcategory(name: "Knitting & Sewing Circles", icon: "🧶", value: "Knitting & Sewing Circles"),
                Subcategory(name: "Leather Craft Workshops", icon: "👜", value: "Leather Craft Workshops"),
                Subcategory(name: "Makerspaces & DIY Labs", icon: "🔨", value: "Makerspaces & DIY Labs"),
                Subcategory(name: "Mixed Media Collage Classes", icon: "🎨", value: "Mixed Media Collage Classes"),
                Subcategory(name: "Museum Late Nights", icon: "🏛️", value: "Museum Late Nights"),
                Subcategory(name: "Outdoor Art Walks", icon: "🚶", value: "Outdoor Art Walks"),
                Subcategory(name: "Pottery & Ceramics Studios", icon: "🏺", value: "Pottery & Ceramics Studios"),
                Subcategory(name: "Printmaking Workshops", icon: "🖨️", value: "Printmaking Workshops"),
                Subcategory(name: "Public Art Tours", icon: "🗺️", value: "Public Art Tours"),
                Subcategory(name: "Resin Art Studios", icon: "💎", value: "Resin Art Studios"),
                Subcategory(name: "Sculpture Workshops", icon: "🗿", value: "Sculpture Workshops"),
                Subcategory(name: "Sip Paint Studios", icon: "🖌️", value: "Sip Paint Studios"),
                Subcategory(name: "Upcycling & Repurposing Classes", icon: "♻️", value: "Upcycling & Repurposing Classes"),
                Subcategory(name: "Watercolor Drawing Sessions", icon: "🎨", value: "Watercolor Drawing Sessions"),
                Subcategory(name: "Woodworking Studios", icon: "🪵", value: "Woodworking Studios"),
            ]
        ),
        Category(
            id: "social-nightlife",
            name: "Social & Nightlife",
            icon: "🍻",
            color: "#96CEB4",
            gradient: ["#96CEB4", "#7FB3A3"],
            description: "Connect and have fun",
            subcategories: [
                Subcategory(name: "Bars & Lounges", icon: "🍺", value: "Bars & Lounges"),
                Subcategory(name: "Beer Tasting Rooms", icon: "🍻", value: "Beer Tasting Rooms"),
                Subcategory(name: "Billiards Lounges", icon: "🎱", value: "Billiards Lounges"),
                Subcategory(name: "Breweries", icon: "🍺", value: "Breweries"),
                Subcategory(name: "Burlesque Shows", icon: "🎭", value: "Burlesque Shows"),
                Subcategory(name: "Cabaret Bars", icon: "🎭", value: "Cabaret Bars"),
                Subcategory(name: "Cigar Lounges", icon: "💨", value: "Cigar Lounges"),
                Subcategory(name: "Cocktail Bars", icon: "🍸", value: "Cocktail Bars"),
                Subcategory(name: "Comedy Clubs", icon: "😂", value: "Comedy Clubs"),
                Subcategory(name: "Distilleries", icon: "🥃", value: "Distilleries"),
                Subcategory(name: "Drag Show Bars", icon: "💃", value: "Drag Show Bars"),
                Subcategory(name: "Hotel Bars", icon: "🏨", value: "Hotel Bars"),
                Subcategory(name: "Jazz Piano Bars", icon: "🎹", value: "Jazz Piano Bars"),
                Subcategory(name: "Karaoke Bars", icon: "🎤", value: "Karaoke Bars"),
                Subcategory(name: "Live Music Venues", icon: "🎸", value: "Live Music Venues"),
                Subcategory(name: "Open Mic Nights", icon: "🎤", value: "Open Mic Nights"),
                Subcategory(name: "Piano Lounges", icon: "🎹", value: "Piano Lounges"),
                Subcategory(name: "Rooftop Bars", icon: "🌃", value: "Rooftop Bars"),
                Subcategory(name: "Shuffleboard & Bocce Bars", icon: "🎯", value: "Shuffleboard & Bocce Bars"),
                Subcategory(name: "Spoken Word Poetry Bars", icon: "📝", value: "Spoken Word Poetry Bars"),
                Subcategory(name: "Sports Bars", icon: "🏈", value: "Sports Bars"),
                Subcategory(name: "Tiki Bars", icon: "🌴", value: "Tiki Bars"),
                Subcategory(name: "Variety Show Lounges", icon: "🎪", value: "Variety Show Lounges"),
                Subcategory(name: "Wine Bars & Tapas", icon: "🍷", value: "Wine Bars & Tapas"),
                Subcategory(name: "Wineries", icon: "🍇", value: "Wineries"),
            ]
        ),
        Category(
            id: "recreation-fitness",
            name: "Recreation & Fitness",
            icon: "💪",
            color: "#FFEAA7",
            gradient: ["#FFEAA7", "#FDCB6E"],
            description: "Stay active and healthy",
            subcategories: [
                Subcategory(name: "Archery", icon: "🏹", value: "Archery"),
                Subcategory(name: "Basketball Courts", icon: "🏀", value: "Basketball Courts"),
                Subcategory(name: "Boxing & Kickboxing", icon: "🥊", value: "Boxing & Kickboxing"),
                Subcategory(name: "CrossFit Boxes", icon: "🏋️", value: "CrossFit Boxes"),
                Subcategory(name: "Dance Fitness", icon: "💃", value: "Dance Fitness"),
                Subcategory(name: "Golf Courses", icon: "⛳", value: "Golf Courses"),
                Subcategory(name: "Gyms & Fitness Centers", icon: "🏋️", value: "Gyms & Fitness Centers"),
                Subcategory(name: "HIIT & Bootcamp", icon: "🔥", value: "HIIT & Bootcamp"),
                Subcategory(name: "Hydrotherapy & Hot Tubs", icon: "🛁", value: "Hydrotherapy & Hot Tubs"),
                Subcategory(name: "Indoor Climbing", icon: "🧗", value: "Indoor Climbing"),
                Subcategory(name: "Massage", icon: "💆", value: "Massage"),
                Subcategory(name: "Miniature Golf", icon: "⛳", value: "miniature golf"),
                Subcategory(name: "Personal Training Studios", icon: "🏋️", value: "Personal Training Studios"),
                Subcategory(name: "Pickleball Courts", icon: "🏓", value: "Pickleball Courts"),
                Subcategory(name: "Pilates & Barre Studios", icon: "🤸", value: "Pilates & Barre Studios"),
                Subcategory(name: "Skate Parks", icon: "🛹", value: "Skate Parks"),
                Subcategory(name: "Soccer Fields", icon: "⚽", value: "Soccer Fields"),
                Subcategory(name: "Spin & Cycling Studios", icon: "🚴", value: "Spin & Cycling Studios"),
                Subcategory(name: "Tennis Courts", icon: "🎾", value: "Tennis Courts"),
                Subcategory(name: "Volleyball Courts", icon: "🏐", value: "Volleyball Courts"),
                Subcategory(name: "Yoga", icon: "🧘", value: "Yoga"),
            ]
        ),
        Category(
            id: "nature-outdoors",
            name: "Nature & Outdoors",
            icon: "🌲",
            color: "#DDA0DD",
            gradient: ["#DDA0DD", "#C77DFF"],
            description: "Explore the great outdoors",
            subcategories: [
                Subcategory(name: "Amusement Parks", icon: "🎢", value: "Amusement Parks"),
                Subcategory(name: "Animal Sanctuaries", icon: "🐾", value: "Animal Sanctuaries"),
                Subcategory(name: "ATV & Off-Roading", icon: "🏎️", value: "ATV & Off-Roading"),
                Subcategory(name: "Beachfront Parks", icon: "🏖️", value: "Beachfront Parks"),
                Subcategory(name: "Bird Sanctuaries", icon: "🐦", value: "Bird Sanctuaries"),
                Subcategory(name: "Butterfly Gardens", icon: "🦋", value: "Butterfly Gardens"),
                Subcategory(name: "Carnivals", icon: "🎪", value: "Carnivals"),
                Subcategory(name: "Hiking Trails", icon: "🥾", value: "Hiking Trails"),
                Subcategory(name: "Horseback Riding Trails", icon: "🐴", value: "horseback riding trails"),
                Subcategory(name: "Kayaking & Canoeing", icon: "🛶", value: "kayaking & canoeing"),
                Subcategory(name: "Lakes & Rivers", icon: "🏞️", value: "Lakes & Rivers"),
                Subcategory(name: "Mountain Biking Trails", icon: "🚵", value: "mountain biking trails"),
                Subcategory(name: "Nature Preserves & Refuges", icon: "🌿", value: "Nature Preserves & Refuges"),
                Subcategory(name: "Nature-Themed Playgrounds", icon: "🌳", value: "Nature-Themed Playgrounds"),
                Subcategory(name: "Nature Trails", icon: "🌲", value: "Nature Trails"),
                Subcategory(name: "Obstacle Courses & Climbing", icon: "🧗", value: "obstacle courses & climbing"),
                Subcategory(name: "Outdoor Concerts & Festivals", icon: "🎶", value: "Outdoor Concerts & Festivals"),
                Subcategory(name: "Outdoor Markets", icon: "🛒", value: "Outdoor Markets"),
                Subcategory(name: "Outdoor Theaters / Movie Nights", icon: "🎬", value: "Outdoor Theaters / Movie Nights"),
                Subcategory(name: "Paintball", icon: "🎯", value: "paintball"),
                Subcategory(name: "Paragliding / Hang Gliding", icon: "🪂", value: "paragliding / hang gliding"),
                Subcategory(name: "Parks & Gardens", icon: "🌳", value: "Parks & Gardens"),
                Subcategory(name: "Petting Zoos", icon: "🐐", value: "petting zoos"),
                Subcategory(name: "Picnic Areas", icon: "🧺", value: "Picnic Areas"),
                Subcategory(name: "Renaissance Fairs", icon: "🏰", value: "Renaissance Fairs"),
                Subcategory(name: "Reptile Parks", icon: "🦎", value: "reptile parks"),
                Subcategory(name: "Rock Climbing (Outdoor Routes)", icon: "🧗", value: "rock climbing (outdoor routes)"),
                Subcategory(name: "Safari Parks", icon: "🦁", value: "safari parks"),
                Subcategory(name: "Scenic Viewpoints", icon: "🌅", value: "Scenic Viewpoints"),
                Subcategory(name: "Shooting Ranges", icon: "🎯", value: "shooting Ranges"),
                Subcategory(name: "Sunset / Sunrise Spots", icon: "🌇", value: "Sunset / Sunrise Spots"),
                Subcategory(name: "Surfing Spots", icon: "🏄", value: "surfing spots"),
                Subcategory(name: "Walking Paths / Greenbelts", icon: "🚶", value: "Walking Paths / Greenbelts"),
                Subcategory(name: "Water Parks", icon: "🌊", value: "Water Parks"),
                Subcategory(name: "Whitewater Rafting", icon: "🚣", value: "whitewater rafting"),
                Subcategory(name: "Wildlife Reserves", icon: "🦌", value: "wildlife reserves"),
            ]
        ),
        Category(
            id: "indoor-adventure",
            name: "Indoor Adventure",
            icon: "🎯",
            color: "#FFB347",
            gradient: ["#FFB347", "#FF9500"],
            description: "Fun activities indoors",
            subcategories: [
                Subcategory(name: "AR-Enhanced Installations", icon: "📱", value: "AR-Enhanced Installations"),
                Subcategory(name: "Board Game Cafés", icon: "🎲", value: "Board Game Cafés"),
                Subcategory(name: "Bowling Alleys", icon: "🎳", value: "Bowling Alleys"),
                Subcategory(name: "Bumper Cars", icon: "🚗", value: "Bumper Cars"),
                Subcategory(name: "Cosplay Cafes", icon: "🎭", value: "Cosplay Cafes"),
                Subcategory(name: "Digital Art Installations", icon: "🖥️", value: "Digital Art Installations"),
                Subcategory(name: "Escape-Based Theater", icon: "🎭", value: "Escape-Based Theater"),
                Subcategory(name: "Escape Rooms", icon: "🔐", value: "Escape Rooms"),
                Subcategory(name: "Fantasy Taverns", icon: "🏰", value: "Fantasy Taverns"),
                Subcategory(name: "Haunted Houses", icon: "👻", value: "Haunted Houses"),
                Subcategory(name: "Immersive Exhibitions", icon: "🎨", value: "Immersive Exhibitions"),
                Subcategory(name: "Immersive Theater", icon: "🎭", value: "Immersive Theater"),
                Subcategory(name: "Indie Cinemas", icon: "🎬", value: "Indie Cinemas"),
                Subcategory(name: "Indoor Mini Golf", icon: "⛳", value: "Indoor Mini Golf"),
                Subcategory(name: "Indoor Obstacle Courses", icon: "🧗", value: "Indoor Obstacle Courses"),
                Subcategory(name: "Indoor Pool Halls", icon: "🎱", value: "Indoor Pool Halls"),
                Subcategory(name: "Infinity Rooms", icon: "🪞", value: "Infinity Rooms"),
                Subcategory(name: "Interactive Science Centers", icon: "🔬", value: "Interactive Science Centers"),
                Subcategory(name: "Karaoke Rooms", icon: "🎤", value: "Karaoke Rooms"),
                Subcategory(name: "Laser Tag / Nerf", icon: "🔫", value: "Laser Tag / Nerf"),
                Subcategory(name: "Light & Sound Rooms", icon: "💡", value: "Light & Sound Rooms"),
                Subcategory(name: "Mirror Mazes", icon: "🪞", value: "Mirror Mazes"),
                Subcategory(name: "Movie Theaters", icon: "🎬", value: "Movie Theaters"),
                Subcategory(name: "Ping Pong Clubs", icon: "🏓", value: "Ping Pong Clubs"),
                Subcategory(name: "Pop-Up Museums", icon: "🏛️", value: "Pop-Up Museums"),
                Subcategory(name: "Projection Shows", icon: "📽️", value: "Projection Shows"),
                Subcategory(name: "Retro Arcades & Barcades", icon: "🕹️", value: "Retro Arcades & Barcades"),
                Subcategory(name: "Role-Play Game Lounges", icon: "🎲", value: "Role-Play Game Lounges"),
                Subcategory(name: "Sci-Fi / Fantasy Conventions", icon: "🚀", value: "Sci-Fi / Fantasy Conventions"),
                Subcategory(name: "Shuffleboard Lounges", icon: "🎯", value: "Shuffleboard Lounges"),
                Subcategory(name: "Trampoline Parks", icon: "🤸", value: "Trampoline Parks"),
                Subcategory(name: "VR Arcades", icon: "🥽", value: "VR Arcades"),
            ]
        ),
    ]

    /// Static lookup map from subcategory value (lowercased) to its emoji icon
    static let subcategoryIconMap: [String: String] = {
        var map: [String: String] = [:]
        for category in categories {
            for sub in category.subcategories {
                map[sub.value.lowercased()] = sub.icon
            }
        }
        return map
    }()
}

struct Category: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String
    let gradient: [String]
    let description: String
    let subcategories: [Subcategory]
}

struct Subcategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let value: String
    var subSubcategories: [SubSubcategory]? = nil
}

struct SubSubcategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let value: String?
    let price: String?
}
