import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  ScrollView,
  Image,
  Dimensions,
  Modal,
} from 'react-native';
import MapView, { Marker } from 'react-native-maps';
import Icon from 'react-native-vector-icons/MaterialIcons';

const { width } = Dimensions.get('window');

interface Venue {
  id: string;
  name: string;
  rating: number;
  reviews: number;
  distance: number;
  image: string;
}

interface FilterOptions {
  selectedStars: number[];
  selectedPriceRange: number[];
  isOpenNow: boolean;
}

interface FilterModalProps {
  visible: boolean;
  onClose: () => void;
  onApply: (filters: FilterOptions) => void;
}

interface SortModalProps {
  visible: boolean;
  onClose: () => void;
  onApply: (sortOption: string) => void;
}

const mockVenues: Venue[] = [
  {
    id: '1',
    name: 'Cabo-Bobs',
    rating: 4.8,
    reviews: 500,
    distance: 1.2,
    image: 'https://via.placeholder.com/100x100/FF5733/FFFFFF?text=Cabo-Bobs',
  },
  {
    id: '2',
    name: 'Franklin BBQ',
    rating: 4.9,
    reviews: 1200,
    distance: 2.1,
    image: 'https://via.placeholder.com/100x100/33FF57/FFFFFF?text=Franklin',
  },
  {
    id: '3',
    name: 'Uchi',
    rating: 4.7,
    reviews: 800,
    distance: 1.8,
    image: 'https://via.placeholder.com/100x100/3357FF/FFFFFF?text=Uchi',
  }
];

const mockMapMarkers = [
  { id: '1', rating: 4.9, latitude: 30.2672, longitude: -97.7431 },
  { id: '2', rating: 3.7, latitude: 30.2700, longitude: -97.7400 },
  { id: '3', rating: 1.0, latitude: 30.2650, longitude: -97.7450 },
  { id: '4', rating: 2.0, latitude: 30.2660, longitude: -97.7420 },
  { id: '5', rating: 3.8, latitude: 30.2680, longitude: -97.7440 },
  { id: '6', rating: 4.5, latitude: 30.2690, longitude: -97.7410 },
];

const FilterModal = ({ visible, onClose, onApply }: FilterModalProps) => {
  const [selectedStars, setSelectedStars] = useState<number[]>([]);
  const [selectedPriceRange, setSelectedPriceRange] = useState<number[]>([]);
  const [isOpenNow, setIsOpenNow] = useState(false);

  const toggleStar = (stars: number) => {
    if (selectedStars.includes(stars)) {
      setSelectedStars(selectedStars.filter(s => s !== stars));
    } else {
      setSelectedStars([...selectedStars, stars]);
    }
  };

  const togglePriceRange = (price: number) => {
    if (selectedPriceRange.includes(price)) {
      setSelectedPriceRange(selectedPriceRange.filter(p => p !== price));
    } else {
      setSelectedPriceRange([...selectedPriceRange, price]);
    }
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={onClose}
    >
      <View style={styles.modalContainer}>
        <View style={styles.modalContent}>
          <View style={styles.modalHeader}>
            <Text style={styles.modalTitle}>Filter</Text>
            <TouchableOpacity onPress={onClose}>
              <Icon name="close" size={24} color="#000" />
            </TouchableOpacity>
          </View>

          <Text style={styles.filterSectionTitle}>Star Rating</Text>
          <View style={styles.filterOptions}>
            {[5, 4, 3, 2, 1].map(stars => (
              <TouchableOpacity
                key={stars}
                style={[
                  styles.filterOption,
                  selectedStars.includes(stars) && styles.filterOptionSelected,
                ]}
                onPress={() => toggleStar(stars)}
              >
                <Text style={styles.filterOptionText}>{stars}+ Stars</Text>
              </TouchableOpacity>
            ))}
          </View>

          <Text style={styles.filterSectionTitle}>Price Range</Text>
          <View style={styles.filterOptions}>
            {[1, 2, 3, 4].map(price => (
              <TouchableOpacity
                key={price}
                style={[
                  styles.filterOption,
                  selectedPriceRange.includes(price) && styles.filterOptionSelected,
                ]}
                onPress={() => togglePriceRange(price)}
              >
                <Text style={styles.filterOptionText}>{'$'.repeat(price)}</Text>
              </TouchableOpacity>
            ))}
          </View>

          <Text style={styles.filterSectionTitle}>Opening Hours</Text>
          <TouchableOpacity
            style={[
              styles.filterOption,
              isOpenNow && styles.filterOptionSelected,
              { width: '100%' },
            ]}
            onPress={() => setIsOpenNow(!isOpenNow)}
          >
            <Text style={styles.filterOptionText}>Open Now</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.applyButton}
            onPress={() => {
              onApply({ selectedStars, selectedPriceRange, isOpenNow });
              onClose();
            }}
          >
            <Text style={styles.applyButtonText}>Apply Filters</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const SortModal = ({ visible, onClose, onApply }: SortModalProps) => {
  const [selectedSort, setSelectedSort] = useState('');

  const sortOptions = [
    { id: 'rating', label: 'Rating (High to Low)' },
    { id: 'reviews', label: 'Most Reviewed' },
    { id: 'distance', label: 'Distance' },
    { id: 'price_low', label: 'Price (Low to High)' },
    { id: 'price_high', label: 'Price (High to Low)' },
  ];

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={onClose}
    >
      <View style={styles.modalContainer}>
        <View style={styles.modalContent}>
          <View style={styles.modalHeader}>
            <Text style={styles.modalTitle}>Sort By</Text>
            <TouchableOpacity onPress={onClose}>
              <Icon name="close" size={24} color="#000" />
            </TouchableOpacity>
          </View>

          {sortOptions.map(option => (
            <TouchableOpacity
              key={option.id}
              style={[
                styles.sortOption,
                selectedSort === option.id && styles.sortOptionSelected,
              ]}
              onPress={() => setSelectedSort(option.id)}
            >
              <Text style={[
                styles.sortOptionText,
                selectedSort === option.id && styles.sortOptionTextSelected,
              ]}>
                {option.label}
              </Text>
              {selectedSort === option.id && (
                <Icon name="check" size={24} color="#fff" />
              )}
            </TouchableOpacity>
          ))}

          <TouchableOpacity
            style={styles.applyButton}
            onPress={() => {
              onApply(selectedSort);
              onClose();
            }}
          >
            <Text style={styles.applyButtonText}>Apply Sort</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const DiscoverScreen = () => {
  const [searchQuery, setSearchQuery] = useState('Austin, Texas');
  const [filterModalVisible, setFilterModalVisible] = useState(false);
  const [sortModalVisible, setSortModalVisible] = useState(false);
  const [activeFilters, setActiveFilters] = useState<FilterOptions>({
    selectedStars: [],
    selectedPriceRange: [],
    isOpenNow: false,
  });
  const [activeSort, setActiveSort] = useState('');

  const handleApplyFilters = (filters: FilterOptions) => {
    setActiveFilters(filters);
    // Here you would typically filter your venues based on the selected criteria
    console.log('Applied filters:', filters);
  };

  const handleApplySort = (sortOption: string) => {
    setActiveSort(sortOption);
    // Here you would typically sort your venues based on the selected option
    console.log('Applied sort:', sortOption);
  };

  const renderSearchHeader = () => (
    <View style={styles.searchHeader}>
      <View style={styles.searchBar}>
        <Icon name="search" size={24} color="#000" style={styles.searchIcon} />
        <TextInput
          style={styles.searchInput}
          value={searchQuery}
          onChangeText={setSearchQuery}
          placeholder="Search location"
        />
        <Icon name="edit" size={24} color="#000" style={styles.editIcon} />
      </View>
      {/* <Text style={styles.filterText}># of Stars • Price Stars • Open/Close</Text> */}
      <View style={styles.filterContainer}>
        <TouchableOpacity 
          style={[
            styles.filterButton,
            Object.values(activeFilters).some(f => 
              Array.isArray(f) ? f.length > 0 : f
            ) && styles.filterButtonActive
          ]}
          onPress={() => setFilterModalVisible(true)}
        >
          <Text style={styles.filterButtonText}>Filter</Text>
          <Icon name="keyboard-arrow-down" size={24} color="#000" />
        </TouchableOpacity>
        <TouchableOpacity 
          style={[
            styles.filterButton,
            activeSort && styles.filterButtonActive
          ]}
          onPress={() => setSortModalVisible(true)}
        >
          <Text style={styles.filterButtonText}>Sort</Text>
          <Icon name="keyboard-arrow-down" size={24} color="#000" />
        </TouchableOpacity>
        <Text style={styles.resultsText}>99 results</Text>
      </View>
    </View>
  );

  const renderMapMarker = (marker: typeof mockMapMarkers[0]) => (
    <Marker
      key={marker.id}
      coordinate={{
        latitude: marker.latitude,
        longitude: marker.longitude,
      }}
    >
      <View style={[
        styles.markerContainer,
        marker.rating >= 4.5 && styles.markerContainerHighlighted,
      ]}>
        <Text style={[
          styles.markerText,
          marker.rating >= 4.5 && styles.markerTextHighlighted,
        ]}>
          {marker.rating} Stars
        </Text>
      </View>
    </Marker>
  );

  const renderVenueCard = (venue: Venue) => (
    <View style={styles.venueCard}>
      <Image
        source={{ uri: venue.image }}
        style={styles.venueImage}
        defaultSource={{ uri: 'https://via.placeholder.com/100' }}
      />
      <View style={styles.venueContent}>
        <View style={styles.venueInfo}>
          <Text style={styles.venueName}>{venue.name}</Text>
          <View style={styles.venueDetails}>
            <View style={styles.ratingContainer}>
              <Icon name="star" size={16} color="#000" />
              <Text style={styles.rating}>{venue.rating}</Text>
              <Text style={styles.reviews}>({venue.reviews} reviews)</Text>
            </View>
            <Text style={styles.distance}>{venue.distance} miles</Text>
          </View>
        </View>
        <TouchableOpacity style={styles.selectButton}>
          <Text style={styles.selectButtonText}>Select</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  return (
    <View style={styles.container}>
      {renderSearchHeader()}
      <MapView
        style={styles.map}
        initialRegion={{
          latitude: 30.2672,
          longitude: -97.7431,
          latitudeDelta: 0.0922,
          longitudeDelta: 0.0421,
        }}
      >
        {mockMapMarkers.map(renderMapMarker)}
      </MapView>
      <ScrollView style={styles.venueList}>
        {mockVenues.map(renderVenueCard)}
      </ScrollView>
      
      <FilterModal
        visible={filterModalVisible}
        onClose={() => setFilterModalVisible(false)}
        onApply={handleApplyFilters}
      />
      
      <SortModal
        visible={sortModalVisible}
        onClose={() => setSortModalVisible(false)}
        onApply={handleApplySort}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  searchHeader: {
    padding: 16,
    backgroundColor: '#f5f5f5',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: 8,
    marginBottom: 8,
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
  },
  editIcon: {
    marginLeft: 8,
  },
  filterText: {
    color: '#666',
    marginBottom: 12,
  },
  filterContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  filterButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: 8,
    marginRight: 12,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  filterButtonText: {
    marginRight: 4,
    fontSize: 16,
  },
  resultsText: {
    fontSize: 16,
    color: '#666',
  },
  map: {
    height: 300,
  },
  markerContainer: {
    backgroundColor: '#fff',
    padding: 8,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  markerContainerHighlighted: {
    backgroundColor: '#000',
  },
  markerText: {
    fontSize: 14,
    color: '#000',
  },
  markerTextHighlighted: {
    color: '#fff',
  },
  venueList: {
    flex: 1,
  },
  venueCard: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
    backgroundColor: '#fff',
    gap: 12,
  },
  venueImage: {
    width: 80,
    height: 80,
    borderRadius: 8,
    backgroundColor: '#f3f4f6',
  },
  venueContent: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  venueInfo: {
    flex: 1,
    marginRight: 12,
  },
  venueName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000',
    marginBottom: 4,
  },
  venueDetails: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginTop: 4,
  },
  ratingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  rating: {
    fontSize: 16,
    fontWeight: '500',
  },
  reviews: {
    fontSize: 12,
    color: '#666',
    marginLeft: 4,
  },
  distance: {
    fontSize: 12,
    color: '#666',
  },
  selectButton: {
    backgroundColor: '#000',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 20,
    minWidth: 80,
    alignItems: 'center',
  },
  selectButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '500',
  },
  modalContainer: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    maxHeight: '80%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  modalTitle: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  filterSectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 12,
  },
  filterOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  filterOption: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#f5f5f5',
    marginBottom: 8,
  },
  filterOptionSelected: {
    backgroundColor: '#000',
  },
  filterOptionText: {
    fontSize: 16,
    color: '#000',
  },
  filterButtonActive: {
    backgroundColor: '#000',
  },
  filterButtonActiveText: {
    color: '#fff',
  },
  sortOption: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  sortOptionSelected: {
    backgroundColor: '#000',
  },
  sortOptionText: {
    fontSize: 16,
    color: '#000',
  },
  sortOptionTextSelected: {
    color: '#fff',
  },
  applyButton: {
    backgroundColor: '#000',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
  },
  applyButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default DiscoverScreen; 