import { categories } from '../../auth/onboarding/data/categories';

// CategoryMapper.ts
export const getCategoryFromSubtopic = (subtopic: string): string => {
  if (!subtopic) return 'food-drink'; // Default to food-drink
  const subtopicLower = subtopic.toLowerCase();
  // Food & Drink category
  if (subtopicLower.includes('restaurant') || 
      subtopicLower.includes('cafe') || 
      subtopicLower.includes('coffee') || 
      subtopicLower.includes('food') || 
      subtopicLower.includes('cuisine') || 
      subtopicLower.includes('pizza') || 
      subtopicLower.includes('burger') || 
      subtopicLower.includes('steak') || 
      subtopicLower.includes('seafood') || 
      subtopicLower.includes('italian') || 
      subtopicLower.includes('mexican') || 
      subtopicLower.includes('chinese') || 
      subtopicLower.includes('japanese') || 
      subtopicLower.includes('thai') || 
      subtopicLower.includes('korean') || 
      subtopicLower.includes('indian') || 
      subtopicLower.includes('vegetarian') || 
      subtopicLower.includes('vegan') || 
      subtopicLower.includes('breakfast') || 
      subtopicLower.includes('brunch') || 
      subtopicLower.includes('diner') || 
      subtopicLower.includes('sandwich') || 
      subtopicLower.includes('hot dog') || 
      subtopicLower.includes('bagel') || 
      subtopicLower.includes('pancake') || 
      subtopicLower.includes('waffle') || 
      subtopicLower.includes('dessert') || 
      subtopicLower.includes('bar') || 
      subtopicLower.includes('brewery') || 
      subtopicLower.includes('wine')) {
    return 'food-drink';
  }
  // Recreation & Fitness category
  if (subtopicLower.includes('gym') || 
      subtopicLower.includes('fitness') || 
      subtopicLower.includes('workout') || 
      subtopicLower.includes('crossfit') || 
      subtopicLower.includes('dance') || 
      subtopicLower.includes('pilates') || 
      subtopicLower.includes('yoga') || 
      subtopicLower.includes('hiit') || 
      subtopicLower.includes('bootcamp') || 
      subtopicLower.includes('basketball') || 
      subtopicLower.includes('soccer') || 
      subtopicLower.includes('tennis') || 
      subtopicLower.includes('volleyball') || 
      subtopicLower.includes('boxing') || 
      subtopicLower.includes('kickboxing') || 
      subtopicLower.includes('archery') || 
      subtopicLower.includes('climbing') || 
      subtopicLower.includes('golf') || 
      subtopicLower.includes('bowling') || 
      subtopicLower.includes('spa') || 
      subtopicLower.includes('massage') || 
      subtopicLower.includes('sauna')) {
    return 'recreation-fitness';
  }
  // Social & Nightlife category
  if (subtopicLower.includes('nightclub') || 
      subtopicLower.includes('club') || 
      subtopicLower.includes('lounge') || 
      subtopicLower.includes('speakeasy') || 
      subtopicLower.includes('cocktail') || 
      subtopicLower.includes('tapas') || 
      subtopicLower.includes('dive bar') || 
      subtopicLower.includes('rooftop') || 
      subtopicLower.includes('comedy') || 
      subtopicLower.includes('karaoke') || 
      subtopicLower.includes('jazz') || 
      subtopicLower.includes('piano') || 
      subtopicLower.includes('live music') || 
      subtopicLower.includes('dancing') || 
      subtopicLower.includes('latin') || 
      subtopicLower.includes('silent disco') || 
      subtopicLower.includes('pool') || 
      subtopicLower.includes('billiards') || 
      subtopicLower.includes('arcade') || 
      subtopicLower.includes('barcade')) {
    return 'social-nightlife';
  }
  // Shopping category
  if (subtopicLower.includes('thrift') || 
      subtopicLower.includes('vintage') || 
      subtopicLower.includes('antique') || 
      subtopicLower.includes('flea market') || 
      subtopicLower.includes('consignment') || 
      subtopicLower.includes('jewelry') || 
      subtopicLower.includes('boutique') || 
      subtopicLower.includes('designer') || 
      subtopicLower.includes('fashion') || 
      subtopicLower.includes('leather') || 
      subtopicLower.includes('plant') || 
      subtopicLower.includes('crystal') || 
      subtopicLower.includes('spiritual') || 
      subtopicLower.includes('handmade') || 
      subtopicLower.includes('artisan') || 
      subtopicLower.includes('pottery') || 
      subtopicLower.includes('ceramics') || 
      subtopicLower.includes('record') || 
      subtopicLower.includes('bookstore') || 
      subtopicLower.includes('comic') || 
      subtopicLower.includes('poster') || 
      subtopicLower.includes('pop-up') || 
      subtopicLower.includes('market') || 
      subtopicLower.includes('fair')) {
    return 'shopping-markets';
  }
  // Nature & Outdoors category
  if (subtopicLower.includes('hiking') || 
      subtopicLower.includes('lake') || 
      subtopicLower.includes('river') || 
      subtopicLower.includes('park') || 
      subtopicLower.includes('garden') || 
      subtopicLower.includes('scenic') || 
      subtopicLower.includes('viewpoint') || 
      subtopicLower.includes('paintball') || 
      subtopicLower.includes('shooting') || 
      subtopicLower.includes('obstacle') || 
      subtopicLower.includes('kayaking') || 
      subtopicLower.includes('canoeing') || 
      subtopicLower.includes('ziplining') || 
      subtopicLower.includes('atv') || 
      subtopicLower.includes('off-road') || 
      subtopicLower.includes('amusement') || 
      subtopicLower.includes('concert') || 
      subtopicLower.includes('festival') || 
      subtopicLower.includes('carnival') || 
      subtopicLower.includes('zoo') || 
      subtopicLower.includes('aquarium') || 
      subtopicLower.includes('petting zoo') || 
      subtopicLower.includes('farm')) {
    return 'nature-outdoors';
  }
  // Indoor Adventure category
  if (subtopicLower.includes('vr arcade') || 
      subtopicLower.includes('laser tag') || 
      subtopicLower.includes('nerf') || 
      subtopicLower.includes('escape room') || 
      subtopicLower.includes('go-kart') || 
      subtopicLower.includes('mini-golf') || 
      subtopicLower.includes('haunted house') || 
      subtopicLower.includes('immersive') || 
      subtopicLower.includes('theater') || 
      subtopicLower.includes('fantasy') || 
      subtopicLower.includes('tavern') || 
      subtopicLower.includes('convention') || 
      subtopicLower.includes('digital art') || 
      subtopicLower.includes('exhibit') || 
      subtopicLower.includes('projection') || 
      subtopicLower.includes('light show') || 
      subtopicLower.includes('sound show') || 
      subtopicLower.includes('movie theater') || 
      subtopicLower.includes('cinema')) {
    return 'indoor-adventure';
  }
  // Creative Arts category
  if (subtopicLower.includes('pottery') || 
      subtopicLower.includes('ceramics') || 
      subtopicLower.includes('sip and paint') || 
      subtopicLower.includes('printmaking') || 
      subtopicLower.includes('art studio') || 
      subtopicLower.includes('candle') || 
      subtopicLower.includes('soap') || 
      subtopicLower.includes('jewelry making') || 
      subtopicLower.includes('knitting') || 
      subtopicLower.includes('sewing') || 
      subtopicLower.includes('makerspace') || 
      subtopicLower.includes('diy') || 
      subtopicLower.includes('woodworking') || 
      subtopicLower.includes('leather craft') || 
      subtopicLower.includes('upcycling') || 
      subtopicLower.includes('embroidery') || 
      subtopicLower.includes('weaving') || 
      subtopicLower.includes('poetry') || 
      subtopicLower.includes('writing') || 
      subtopicLower.includes('storytelling') || 
      subtopicLower.includes('gallery') || 
      subtopicLower.includes('art tour') || 
      subtopicLower.includes('art lecture') || 
      subtopicLower.includes('art film') || 
      subtopicLower.includes('museum')) {
    return 'creative-arts';
  }
  // Sight-Seeing category
  if (subtopicLower.includes('museum') || 
      subtopicLower.includes('historical') || 
      subtopicLower.includes('monument') || 
      subtopicLower.includes('statue') || 
      subtopicLower.includes('church') || 
      subtopicLower.includes('temple') || 
      subtopicLower.includes('mosque') || 
      subtopicLower.includes('synagogue') || 
      subtopicLower.includes('landmark') || 
      subtopicLower.includes('castle') || 
      subtopicLower.includes('palace') || 
      subtopicLower.includes('bridge') || 
      subtopicLower.includes('observation') || 
      subtopicLower.includes('deck') || 
      subtopicLower.includes('square')) {
    return 'sight-seeing';
  }
  // Default to food-drink if no match found
  return 'food-drink';
};

export const getCategoryColor = (categoryId: string): string => {
  const category = categories.find(cat => cat.id === categoryId);
  return category?.color || '#D7263D'; // Default to food-drink color
}; 