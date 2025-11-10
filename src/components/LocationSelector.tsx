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

interface Suggestion {
  city: string | null;
  state: string | null;
  country: string | null;
  latitude: number;
  longitude: number;
  formattedAddress: string;
}

const LocationSelector: React.FC<LocationSelectorProps> = ({
  value,
  onChange,
  placeholder = "Search for your city...",
  className = ""
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
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

  // Autocomplete suggestions from backend
  useEffect(() => {
    if (searchTerm.length < 2) {
      setSuggestions([]);
      return;
    }

    // Debounce search
    if (searchTimeout.current) {
      clearTimeout(searchTimeout.current);
    }

    searchTimeout.current = setTimeout(async () => {
      setLoading(true);
      try {
        const response = await fetch(`/api/locations/autocomplete?query=${encodeURIComponent(searchTerm)}`);
        const data = await response.json();
        if (data.success && Array.isArray(data.candidates)) {
          const mapped: Suggestion[] = data.candidates.map((c: any) => ({
            city: c.city || null,
            state: c.state || null,
            country: c.country || null,
            latitude: c.latitude,
            longitude: c.longitude,
            formattedAddress: c.formattedAddress
          }));
          setSuggestions(mapped);
        } else {
          setSuggestions([]);
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

  const handleSuggestionSelect = (s: Suggestion) => {
    const resolvedCity = s.city || '';
    const resolvedState = s.state || '';
    const resolvedCountry = s.country || '';
    const locationData = {
      city: resolvedCity,
      state: resolvedState,
      country: resolvedCountry,
      latitude: s.latitude,
      longitude: s.longitude,
      fullLocation: s.formattedAddress
    };

    setSelectedLocation(s.formattedAddress);
    setSearchTerm('');
    setIsOpen(false);
    onChange(locationData);
  };

  const useMyLocation = async () => {
    try {
      setLoading(true);
      await new Promise<void>((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(async (pos) => {
          try {
            const { latitude, longitude } = pos.coords;
            const resp = await fetch(`/api/locations/reverse?lat=${latitude}&lng=${longitude}`);
            const data = await resp.json();
            if (data.success && data.best) {
              const best = data.best;
              const s: Suggestion = {
                city: best.city || null,
                state: best.state || null,
                country: best.country || null,
                latitude: best.latitude,
                longitude: best.longitude,
                formattedAddress: best.formattedAddress
              };
              handleSuggestionSelect(s);
              resolve();
            } else {
              reject(new Error('Failed to resolve current location'));
            }
          } catch (e) {
            reject(e);
          }
        }, reject, { enableHighAccuracy: true, timeout: 10000 });
      });
    } catch (e) {
      console.error('Geolocation error:', e);
    } finally {
      setLoading(false);
    }
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
            ) : suggestions.length > 0 ? (
              <div>
                <div className="px-3 pt-3">
                  <button onClick={useMyLocation} className="w-full text-left px-3 py-2 mb-2 text-sm rounded-lg bg-peach-50 hover:bg-peach-100 text-coral-600">
                    Use my current location
                  </button>
                </div>
                <div className="py-2">
                {suggestions.map((s, index) => (
                  <motion.button
                    key={`${s.formattedAddress}-${index}`}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.05 }}
                    onClick={() => handleSuggestionSelect(s)}
                    className="w-full px-4 py-3 text-left hover:bg-peach-50 transition-colors flex items-center justify-between group"
                  >
                    <div>
                      <div className="flex items-center">
                        <span className="text-warm-800 font-medium">{s.city || s.formattedAddress}</span>
                        <span className="text-warm-500 ml-2">{getFlagEmoji(s.country || '')}</span>
                      </div>
                      <div className="text-sm text-warm-500 mt-1">
                        {s.state || ''}{s.state && s.country ? ', ' : ''}{s.country || ''}
                      </div>
                    </div>
                    <MapPin className="w-4 h-4 text-coral-400 opacity-0 group-hover:opacity-100 transition-opacity" />
                  </motion.button>
                ))}
                </div>
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