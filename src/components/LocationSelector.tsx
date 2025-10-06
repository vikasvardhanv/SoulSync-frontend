import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MapPin, Search, Globe, ChevronDown } from 'lucide-react';

interface LocationSelectorProps {
  value?: {
    city?: string;
    state?: string;
    country?: string;
    latitude?: number;
    longitude?: number;
  };
  onChange: (location: {
    city: string;
    state: string;
    country: string;
    latitude: number;
    longitude: number;
    fullLocation: string;
  }) => void;
  placeholder?: string;
  className?: string;
}

interface City {
  name: string;
  state: string;
  country: string;
  continent: string;
  lat: number;
  lng: number;
  fullLocation: string;
}

const LocationSelector: React.FC<LocationSelectorProps> = ({
  value,
  onChange,
  placeholder = "Search for your city...",
  className = ""
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState<string>(
    value ? `${value.city}, ${value.state}, ${value.country}` : ''
  );
  
  const dropdownRef = useRef<HTMLDivElement>(null);
  const searchTimeout = useRef<NodeJS.Timeout>();

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Search for cities
  useEffect(() => {
    if (searchTerm.length < 2) {
      setCities([]);
      return;
    }

    // Debounce search
    if (searchTimeout.current) {
      clearTimeout(searchTimeout.current);
    }

    searchTimeout.current = setTimeout(async () => {
      setLoading(true);
      try {
        const response = await fetch(`/api/locations/cities?search=${encodeURIComponent(searchTerm)}&limit=10`);
        const data = await response.json();
        
        if (data.success) {
          setCities(data.data.cities);
        }
      } catch (error) {
        console.error('Failed to search cities:', error);
      } finally {
        setLoading(false);
      }
    }, 300);

    return () => {
      if (searchTimeout.current) {
        clearTimeout(searchTimeout.current);
      }
    };
  }, [searchTerm]);

  const handleCitySelect = (city: City) => {
    const locationData = {
      city: city.name,
      state: city.state,
      country: city.country,
      latitude: city.lat,
      longitude: city.lng,
      fullLocation: city.fullLocation
    };

    setSelectedLocation(city.fullLocation);
    setSearchTerm('');
    setIsOpen(false);
    onChange(locationData);
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSearchTerm(value);
    setSelectedLocation(value);
    
    if (value.length >= 2) {
      setIsOpen(true);
    } else {
      setIsOpen(false);
    }
  };

  const getFlagEmoji = (country: string) => {
    const flags: { [key: string]: string } = {
      'United States': '🇺🇸',
      'Canada': '🇨🇦',
      'United Kingdom': '🇬🇧',
      'Germany': '🇩🇪',
      'France': '🇫🇷',
      'Spain': '🇪🇸',
      'Italy': '🇮🇹',
      'Netherlands': '🇳🇱',
      'India': '🇮🇳',
      'China': '🇨🇳',
      'Japan': '🇯🇵',
      'South Korea': '🇰🇷',
      'Singapore': '🇸🇬',
      'Thailand': '🇹🇭',
      'Australia': '🇦🇺',
      'Brazil': '🇧🇷',
      'Argentina': '🇦🇷',
      'Chile': '🇨🇱',
      'South Africa': '🇿🇦',
      'Nigeria': '🇳🇬',
      'Egypt': '🇪🇬',
      'Mexico': '🇲🇽'
    };
    return flags[country] || '🌍';
  };

  return (
    <div className={`relative ${className}`} ref={dropdownRef}>
      <div className="relative">
        <MapPin className="absolute left-3 top-1/2 transform -translate-y-1/2 text-coral-400 w-5 h-5" />
        <input
          type="text"
          value={selectedLocation}
          onChange={handleInputChange}
          onFocus={() => {
            if (searchTerm.length >= 2) setIsOpen(true);
          }}
          placeholder={placeholder}
          className="w-full pl-10 pr-10 py-3 border border-peach-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-coral-400 focus:border-transparent bg-white text-warm-800 placeholder-warm-400"
        />
        <ChevronDown 
          className={`absolute right-3 top-1/2 transform -translate-y-1/2 text-warm-400 w-5 h-5 transition-transform ${
            isOpen ? 'rotate-180' : ''
          }`}
        />
      </div>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            transition={{ duration: 0.2 }}
            className="absolute z-50 w-full mt-2 bg-white rounded-xl shadow-xl border border-peach-200 max-h-80 overflow-y-auto"
          >
            {loading ? (
              <div className="p-4 text-center">
                <div className="inline-flex items-center">
                  <Search className="animate-spin w-4 h-4 mr-2 text-coral-400" />
                  <span className="text-warm-600">Searching cities...</span>
                </div>
              </div>
            ) : cities.length > 0 ? (
              <div className="py-2">
                {cities.map((city, index) => (
                  <motion.button
                    key={`${city.name}-${city.state}-${city.country}`}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.05 }}
                    onClick={() => handleCitySelect(city)}
                    className="w-full px-4 py-3 text-left hover:bg-peach-50 transition-colors flex items-center justify-between group"
                  >
                    <div>
                      <div className="flex items-center">
                        <span className="text-warm-800 font-medium">{city.name}</span>
                        <span className="text-warm-500 ml-2">{getFlagEmoji(city.country)}</span>
                      </div>
                      <div className="text-sm text-warm-500 mt-1">
                        {city.state}, {city.country}
                      </div>
                    </div>
                    <MapPin className="w-4 h-4 text-coral-400 opacity-0 group-hover:opacity-100 transition-opacity" />
                  </motion.button>
                ))}
              </div>
            ) : searchTerm.length >= 2 ? (
              <div className="p-4 text-center text-warm-500">
                <Globe className="w-8 h-8 mx-auto mb-2 text-warm-300" />
                <p>No cities found for "{searchTerm}"</p>
                <p className="text-sm mt-1">Try searching for a major city nearby</p>
              </div>
            ) : (
              <div className="p-4 text-center text-warm-500">
                <Search className="w-8 h-8 mx-auto mb-2 text-warm-300" />
                <p>Type at least 2 characters to search</p>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default LocationSelector;