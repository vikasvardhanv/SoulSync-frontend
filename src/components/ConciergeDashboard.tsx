// frontend/src/components/ConciergeDashboard.tsx
import React, { useState, useEffect } from 'react';
import { DateProposalBundle } from './DateProposalBundle';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Heart, Shield, MessageCircle, Calendar } from 'lucide-react';

interface ConciergeDashboardProps {
  userId: string;
}

interface DashboardData {
  concierge?: {
    id: string;
    name: string;
  };
  matches: any[];
  safetyCheckIns: any[];
  matchQuotaRemaining: number;
}

export const ConciergeDashboard: React.FC<ConciergeDashboardProps> = ({ userId }) => {
  const [dashboardData, setDashboardData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardData();
  }, [userId]);

  const loadDashboardData = async () => {
    try {
      const response = await fetch(`/api/concierge/dashboard/${userId}`);
      const data = await response.json();
      setDashboardData(data);
    } catch (error) {
      console.error('Error loading dashboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAcceptDate = async (matchId: string, dateSuggestion: any) => {
    try {
      // Create date commitment with optional deposit
      const response = await fetch('/api/dates/commit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          matchId,
          dateSuggestionId: dateSuggestion.id,
          depositAmount: 10 // Optional $10 deposit
        })
      });

      if (response.ok) {
        // Open communication window
        await openCommunicationWindow(matchId);
        // Refresh dashboard
        loadDashboardData();
      }
    } catch (error) {
      console.error('Error accepting date:', error);
    }
  };

  const handleDeclineMatch = async (matchId: string) => {
    try {
      await fetch(`/api/matches/${matchId}/decline`, { method: 'POST' });
      loadDashboardData();
    } catch (error) {
      console.error('Error declining match:', error);
    }
  };

  const openCommunicationWindow = async (matchId: string) => {
    try {
      await fetch('/api/conversations/open-window', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ matchId })
      });
    } catch (error) {
      console.error('Error opening communication window:', error);
    }
  };

  if (loading) {
    return <div className="flex justify-center p-8">Loading your personalized matches...</div>;
  }

  if (!dashboardData) {
    return <div className="text-center p-8">Unable to load dashboard</div>;
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">Your Dating Concierge</h1>
        <p className="text-gray-600">
          {dashboardData.concierge
            ? `Curated by ${dashboardData.concierge.name}`
            : 'Finding your perfect matches...'}
        </p>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Heart className="w-5 h-5 text-red-500" />
              <div>
                <p className="text-sm text-gray-600">Matches This Week</p>
                <p className="text-2xl font-bold">{dashboardData.matches.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Calendar className="w-5 h-5 text-blue-500" />
              <div>
                <p className="text-sm text-gray-600">Quota Remaining</p>
                <p className="text-2xl font-bold">{dashboardData.matchQuotaRemaining}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Shield className="w-5 h-5 text-green-500" />
              <div>
                <p className="text-sm text-gray-600">Safety Check-ins</p>
                <p className="text-2xl font-bold">{dashboardData.safetyCheckIns.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Active Safety Check-ins */}
      {dashboardData.safetyCheckIns.length > 0 && (
        <Card className="mb-8">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Shield className="w-5 h-5" />
              <span>Upcoming Safety Check-ins</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            {dashboardData.safetyCheckIns.map((checkIn: any) => (
              <div key={checkIn.id} className="flex items-center justify-between p-3 border rounded-lg mb-2">
                <div>
                  <p className="font-medium capitalize">{checkIn.checkInType.replace('_', ' ')}</p>
                  <p className="text-sm text-gray-600">
                    {new Date(checkIn.scheduledFor).toLocaleString()}
                  </p>
                </div>
                <Badge variant={checkIn.status === 'pending' ? 'secondary' : 'default'}>
                  {checkIn.status}
                </Badge>
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* Curated Matches */}
      <div className="mb-8">
        <h2 className="text-2xl font-bold mb-4">Your Curated Matches</h2>

        {dashboardData.matches.length === 0 ? (
          <Card>
            <CardContent className="p-8 text-center">
              <Heart className="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium mb-2">No matches yet</h3>
              <p className="text-gray-600 mb-4">
                We're carefully curating matches based on your preferences and constraints.
                Check back soon for personalized recommendations.
              </p>
              <p className="text-sm text-gray-500">
                Matches are limited to 1-3 per week to ensure quality over quantity.
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-6">
            {dashboardData.matches.map((match: any) => (
              <DateProposalBundle
                key={match.id}
                match={match}
                onAcceptDate={handleAcceptDate}
                onDeclineMatch={handleDeclineMatch}
              />
            ))}
          </div>
        )}
      </div>

      {/* Concierge Contact */}
      {dashboardData.concierge && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <MessageCircle className="w-5 h-5" />
              <span>Need Help?</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="mb-4">
              Have questions about your matches or need advice? Your concierge {dashboardData.concierge.name} is here to help.
            </p>
            <Button variant="outline">
              Contact Concierge
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  );
};