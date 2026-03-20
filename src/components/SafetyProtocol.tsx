// frontend/src/components/SafetyProtocol.tsx
import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Badge } from './ui/badge';
import { Shield, MapPin, Phone, User, Clock, CheckCircle } from 'lucide-react';

interface SafetyCheckIn {
  id: string;
  checkInType: 'pre_date' | 'during_date' | 'post_date';
  scheduledFor: string;
  status: 'pending' | 'completed' | 'missed';
  completedAt?: string;
  locationShared: boolean;
  emergencyContactsNotified: boolean;
}

interface EmergencyContact {
  id: string;
  name: string;
  phoneNumber: string;
  email?: string;
  relationship?: string;
  isPrimary: boolean;
}

interface SafetyProtocolProps {
  matchId: string;
  userId: string;
}

export const SafetyProtocol: React.FC<SafetyProtocolProps> = ({ matchId, userId }) => {
  const [checkIns, setCheckIns] = useState<SafetyCheckIn[]>([]);
  const [emergencyContacts, setEmergencyContacts] = useState<EmergencyContact[]>([]);
  const [showAddContact, setShowAddContact] = useState(false);
  const [newContact, setNewContact] = useState({
    name: '',
    phoneNumber: '',
    email: '',
    relationship: ''
  });

  useEffect(() => {
    loadSafetyData();
  }, [matchId, userId]);

  const loadSafetyData = async () => {
    try {
      const [checkInsRes, contactsRes] = await Promise.all([
        fetch(`/api/safety/checkins/${matchId}`),
        fetch(`/api/safety/emergency-contacts/${userId}`)
      ]);

      const checkInsData = await checkInsRes.json();
      const contactsData = await contactsRes.json();

      setCheckIns(checkInsData);
      setEmergencyContacts(contactsData);
    } catch (error) {
      console.error('Error loading safety data:', error);
    }
  };

  const handleCheckIn = async (checkInId: string, shareLocation: boolean = false) => {
    try {
      const response = await fetch(`/api/safety/checkin/${checkInId}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ shareLocation })
      });

      if (response.ok) {
        loadSafetyData(); // Refresh data
      }
    } catch (error) {
      console.error('Error completing check-in:', error);
    }
  };

  const addEmergencyContact = async () => {
    try {
      const response = await fetch('/api/safety/emergency-contacts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId,
          ...newContact,
          isPrimary: emergencyContacts.length === 0 // First contact is primary
        })
      });

      if (response.ok) {
        setNewContact({ name: '', phoneNumber: '', email: '', relationship: '' });
        setShowAddContact(false);
        loadSafetyData();
      }
    } catch (error) {
      console.error('Error adding emergency contact:', error);
    }
  };

  const getCheckInTypeLabel = (type: string) => {
    switch (type) {
      case 'pre_date': return 'Pre-Date Check-in';
      case 'during_date': return 'During Date Check-in';
      case 'post_date': return 'Post-Date Check-in';
      default: return type;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'bg-green-500';
      case 'pending': return 'bg-yellow-500';
      case 'missed': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <div className="mb-6">
        <h2 className="text-2xl font-bold flex items-center space-x-2">
          <Shield className="w-6 h-6 text-blue-600" />
          <span>Safety Protocol</span>
        </h2>
        <p className="text-gray-600 mt-1">
          Your safety is our top priority. These automated check-ins help ensure a positive experience.
        </p>
      </div>

      {/* Safety Check-ins */}
      <Card className="mb-6">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Clock className="w-5 h-5" />
            <span>Scheduled Check-ins</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          {checkIns.length === 0 ? (
            <p className="text-gray-600">No check-ins scheduled yet.</p>
          ) : (
            <div className="space-y-4">
              {checkIns.map((checkIn) => (
                <div key={checkIn.id} className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <h3 className="font-medium">{getCheckInTypeLabel(checkIn.checkInType)}</h3>
                      <p className="text-sm text-gray-600">
                        Scheduled: {new Date(checkIn.scheduledFor).toLocaleString()}
                      </p>
                      {checkIn.completedAt && (
                        <p className="text-sm text-green-600">
                          Completed: {new Date(checkIn.completedAt).toLocaleString()}
                        </p>
                      )}
                    </div>
                    <Badge className={`${getStatusColor(checkIn.status)} text-white`}>
                      {checkIn.status}
                    </Badge>
                  </div>

                  {checkIn.status === 'pending' && (
                    <div className="space-y-2">
                      <p className="text-sm text-gray-700">
                        {checkIn.checkInType === 'pre_date' && "Confirm you're ready for your date and feeling safe."}
                        {checkIn.checkInType === 'during_date' && "Let us know how your date is going."}
                        {checkIn.checkInType === 'post_date' && "Confirm you've returned home safely."}
                      </p>

                      <div className="flex space-x-2">
                        <Button
                          onClick={() => handleCheckIn(checkIn.id, false)}
                          size="sm"
                        >
                          Check In
                        </Button>
                        <Button
                          onClick={() => handleCheckIn(checkIn.id, true)}
                          variant="outline"
                          size="sm"
                        >
                          <MapPin className="w-4 h-4 mr-1" />
                          Share Location
                        </Button>
                      </div>
                    </div>
                  )}

                  {checkIn.status === 'completed' && (
                    <div className="flex items-center space-x-2 text-green-600">
                      <CheckCircle className="w-4 h-4" />
                      <span className="text-sm">Check-in completed</span>
                      {checkIn.locationShared && <MapPin className="w-4 h-4" />}
                      {checkIn.emergencyContactsNotified && <Phone className="w-4 h-4" />}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Emergency Contacts */}
      <Card className="mb-6">
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <User className="w-5 h-5" />
              <span>Emergency Contacts</span>
            </div>
            <Button
              onClick={() => setShowAddContact(!showAddContact)}
              size="sm"
              variant="outline"
            >
              {showAddContact ? 'Cancel' : 'Add Contact'}
            </Button>
          </CardTitle>
        </CardHeader>
        <CardContent>
          {emergencyContacts.length === 0 && !showAddContact && (
            <p className="text-gray-600 mb-4">
              Add emergency contacts who can be notified if needed during your date.
            </p>
          )}

          {/* Existing Contacts */}
          <div className="space-y-3 mb-4">
            {emergencyContacts.map((contact) => (
              <div key={contact.id} className="flex items-center justify-between p-3 border rounded-lg">
                <div>
                  <div className="flex items-center space-x-2">
                    <span className="font-medium">{contact.name}</span>
                    {contact.isPrimary && <Badge variant="secondary">Primary</Badge>}
                  </div>
                  <p className="text-sm text-gray-600">{contact.phoneNumber}</p>
                  {contact.relationship && (
                    <p className="text-xs text-gray-500">{contact.relationship}</p>
                  )}
                </div>
                <Button variant="ghost" size="sm">
                  <Phone className="w-4 h-4" />
                </Button>
              </div>
            ))}
          </div>

          {/* Add New Contact Form */}
          {showAddContact && (
            <div className="border rounded-lg p-4 bg-gray-50">
              <h3 className="font-medium mb-3">Add Emergency Contact</h3>
              <div className="space-y-3">
                <div>
                  <Label htmlFor="name">Name *</Label>
                  <Input
                    id="name"
                    value={newContact.name}
                    onChange={(e) => setNewContact({...newContact, name: e.target.value})}
                    placeholder="Contact name"
                  />
                </div>
                <div>
                  <Label htmlFor="phone">Phone Number *</Label>
                  <Input
                    id="phone"
                    value={newContact.phoneNumber}
                    onChange={(e) => setNewContact({...newContact, phoneNumber: e.target.value})}
                    placeholder="+1 (555) 123-4567"
                  />
                </div>
                <div>
                  <Label htmlFor="email">Email (optional)</Label>
                  <Input
                    id="email"
                    type="email"
                    value={newContact.email}
                    onChange={(e) => setNewContact({...newContact, email: e.target.value})}
                    placeholder="contact@example.com"
                  />
                </div>
                <div>
                  <Label htmlFor="relationship">Relationship (optional)</Label>
                  <Input
                    id="relationship"
                    value={newContact.relationship}
                    onChange={(e) => setNewContact({...newContact, relationship: e.target.value})}
                    placeholder="Friend, family, colleague"
                  />
                </div>
                <div className="flex space-x-2">
                  <Button onClick={addEmergencyContact} disabled={!newContact.name || !newContact.phoneNumber}>
                    Add Contact
                  </Button>
                  <Button variant="outline" onClick={() => setShowAddContact(false)}>
                    Cancel
                  </Button>
                </div>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Safety Tips */}
      <Card>
        <CardHeader>
          <CardTitle>Safety Tips</CardTitle>
        </CardHeader>
        <CardContent>
          <ul className="space-y-2 text-sm text-gray-700">
            <li>• Meet in public places for first dates</li>
            <li>• Keep your own transportation arranged</li>
            <li>• Let someone know your plans and location</li>
            <li>• Trust your instincts - it's okay to leave early</li>
            <li>• Our concierge team monitors all dates and is available 24/7</li>
          </ul>
        </CardContent>
      </Card>
    </div>
  );
};