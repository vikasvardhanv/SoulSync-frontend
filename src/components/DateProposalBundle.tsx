// frontend/src/components/DateProposalBundle.tsx
import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Calendar, Clock, MapPin, DollarSign, Users } from 'lucide-react';

interface DateSuggestion {
  id: string;
  title: string;
  description: string;
  category: string;
  budget: number;
  duration: number;
  location?: string;
  dateTime?: string;
}

interface Match {
  id: string;
  user: {
    id: string;
    name: string;
    age: number;
    bio: string;
    photos: string[];
  };
  compatibility: {
    totalScore: number;
    categories: Record<string, any>;
    recommendations: DateSuggestion[];
  };
  dateSuggestions: DateSuggestion[];
}

interface DateProposalBundleProps {
  match: Match;
  onAcceptDate: (matchId: string, dateSuggestion: DateSuggestion) => void;
  onDeclineMatch: (matchId: string) => void;
}

export const DateProposalBundle: React.FC<DateProposalBundleProps> = ({
  match,
  onAcceptDate,
  onDeclineMatch
}) => {
  const [selectedDate, setSelectedDate] = useState<DateSuggestion | null>(null);

  const getCompatibilityColor = (score: number) => {
    if (score >= 80) return 'bg-green-500';
    if (score >= 60) return 'bg-yellow-500';
    return 'bg-red-500';
  };

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'coffee': return '☕';
      case 'dinner': return '🍽️';
      case 'walk': return '🚶';
      case 'virtual': return '💻';
      case 'activity': return '🎯';
      default: return '📅';
    }
  };

  return (
    <Card className="w-full max-w-2xl mx-auto mb-6">
      <CardHeader>
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="w-16 h-16 rounded-full overflow-hidden">
              <img
                src={match.user.photos[0] || '/default-avatar.png'}
                alt={match.user.name}
                className="w-full h-full object-cover"
              />
            </div>
            <div>
              <CardTitle className="text-xl">{match.user.name}, {match.user.age}</CardTitle>
              <p className="text-gray-600 text-sm">{match.user.bio}</p>
            </div>
          </div>
          <div className="text-right">
            <div className={`inline-flex items-center px-3 py-1 rounded-full text-white text-sm font-medium ${getCompatibilityColor(match.compatibility.totalScore)}`}>
              {match.compatibility.totalScore}% Match
            </div>
          </div>
        </div>
      </CardHeader>

      <CardContent>
        {/* Compatibility Breakdown */}
        <div className="mb-6">
          <h3 className="font-semibold mb-3">Why this match works</h3>
          <div className="grid grid-cols-2 gap-4">
            {Object.entries(match.compatibility.categories).map(([key, value]: [string, any]) => (
              <div key={key} className="flex justify-between items-center">
                <span className="text-sm capitalize">{key.replace(/([A-Z])/g, ' $1').toLowerCase()}</span>
                <Badge variant="secondary">{value.score || 0}/{value.maxScore || 10}</Badge>
              </div>
            ))}
          </div>
        </div>

        {/* Date Suggestions */}
        <div className="mb-6">
          <h3 className="font-semibold mb-3">Suggested Dates</h3>
          <div className="space-y-3">
            {match.dateSuggestions.map((suggestion) => (
              <div
                key={suggestion.id}
                className={`border rounded-lg p-4 cursor-pointer transition-colors ${
                  selectedDate?.id === suggestion.id
                    ? 'border-blue-500 bg-blue-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
                onClick={() => setSelectedDate(suggestion)}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-2">
                      <span className="text-lg">{getCategoryIcon(suggestion.category)}</span>
                      <h4 className="font-medium">{suggestion.title}</h4>
                    </div>
                    <p className="text-sm text-gray-600 mb-3">{suggestion.description}</p>
                    <div className="flex items-center space-x-4 text-sm text-gray-500">
                      <div className="flex items-center space-x-1">
                        <Clock className="w-4 h-4" />
                        <span>{suggestion.duration} min</span>
                      </div>
                      <div className="flex items-center space-x-1">
                        <DollarSign className="w-4 h-4" />
                        <span>${suggestion.budget}</span>
                      </div>
                      {suggestion.location && (
                        <div className="flex items-center space-x-1">
                          <MapPin className="w-4 h-4" />
                          <span>{suggestion.location}</span>
                        </div>
                      )}
                    </div>
                  </div>
                  <div className="ml-4">
                    <input
                      type="radio"
                      checked={selectedDate?.id === suggestion.id}
                      onChange={() => setSelectedDate(suggestion)}
                      className="w-4 h-4 text-blue-600"
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex space-x-3">
          <Button
            variant="outline"
            onClick={() => onDeclineMatch(match.id)}
            className="flex-1"
          >
            Not Interested
          </Button>
          <Button
            onClick={() => selectedDate && onAcceptDate(match.id, selectedDate)}
            disabled={!selectedDate}
            className="flex-1"
          >
            Accept Date
          </Button>
        </div>

        {/* Safety Notice */}
        <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
          <div className="flex items-center space-x-2">
            <Users className="w-4 h-4 text-yellow-600" />
            <span className="text-sm text-yellow-800 font-medium">Safety First</span>
          </div>
          <p className="text-xs text-yellow-700 mt-1">
            All dates include automatic safety check-ins and concierge monitoring.
            You can share your location with emergency contacts if desired.
          </p>
        </div>
      </CardContent>
    </Card>
  );
};