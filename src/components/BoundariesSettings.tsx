import { FormEvent, useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Plus, Save, ShieldAlert, Sparkles, X } from 'lucide-react';
import toast from 'react-hot-toast';
import { usersAPI } from '../services/api';

type PreferredGender = 'male' | 'female' | 'non-binary' | 'everyone';

const MAX_ITEMS = 25;

const BoundariesSettings = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const [dealBreakers, setDealBreakers] = useState<string[]>([]);
  const [mustHaves, setMustHaves] = useState<string[]>([]);
  const [dealBreakerInput, setDealBreakerInput] = useState('');
  const [mustHaveInput, setMustHaveInput] = useState('');
  const [minAge, setMinAge] = useState('');
  const [maxAge, setMaxAge] = useState('');
  const [maxDistance, setMaxDistance] = useState('');
  const [preferredGender, setPreferredGender] = useState<PreferredGender>('everyone');

  useEffect(() => {
    const loadBoundaries = async () => {
      setLoading(true);
      try {
        const response = await usersAPI.getBoundaries();
        const boundaries = response.data?.data?.boundaries ?? {};

        setDealBreakers(normalizeList(boundaries.dealBreakers));
        setMustHaves(normalizeList(boundaries.mustHaves));
        setMinAge(toInputNumber(boundaries.minAge));
        setMaxAge(toInputNumber(boundaries.maxAge));
        setMaxDistance(toInputNumber(boundaries.maxDistance));

        const backendGender = boundaries.preferredGender;
        setPreferredGender(backendGender ?? 'everyone');
      } catch (error: any) {
        toast.error(error?.response?.data?.message || 'Failed to load boundaries');
      } finally {
        setLoading(false);
      }
    };

    loadBoundaries();
  }, []);

  const addBoundary = (value: string, target: 'deal' | 'must') => {
    const clean = value.trim();
    if (!clean) return;

    if (target === 'deal') {
      if (dealBreakers.length >= MAX_ITEMS) {
        toast.error(`Deal breakers are limited to ${MAX_ITEMS}`);
        return;
      }
      if (dealBreakers.some((item) => item.toLowerCase() === clean.toLowerCase())) {
        toast.error('Deal breaker already exists');
        return;
      }
      setDealBreakers((prev) => [...prev, clean]);
      setDealBreakerInput('');
      return;
    }

    if (mustHaves.length >= MAX_ITEMS) {
      toast.error(`Must-haves are limited to ${MAX_ITEMS}`);
      return;
    }
    if (mustHaves.some((item) => item.toLowerCase() === clean.toLowerCase())) {
      toast.error('Must-have already exists');
      return;
    }
    setMustHaves((prev) => [...prev, clean]);
    setMustHaveInput('');
  };

  const removeBoundary = (index: number, target: 'deal' | 'must') => {
    if (target === 'deal') {
      setDealBreakers((prev) => prev.filter((_, i) => i !== index));
      return;
    }
    setMustHaves((prev) => prev.filter((_, i) => i !== index));
  };

  const saveBoundaries = async (e: FormEvent) => {
    e.preventDefault();

    const parsedMinAge = parseOptionalInt(minAge);
    const parsedMaxAge = parseOptionalInt(maxAge);
    const parsedMaxDistance = parseOptionalInt(maxDistance);

    if (
      (minAge.trim() && parsedMinAge === null) ||
      (maxAge.trim() && parsedMaxAge === null) ||
      (maxDistance.trim() && parsedMaxDistance === null)
    ) {
      toast.error('Use valid numbers for age and distance');
      return;
    }

    if (parsedMinAge !== null && parsedMinAge < 18) {
      toast.error('Minimum age must be at least 18');
      return;
    }

    if (parsedMaxAge !== null && parsedMaxAge > 100) {
      toast.error('Maximum age cannot be greater than 100');
      return;
    }

    if (parsedMinAge !== null && parsedMaxAge !== null && parsedMinAge > parsedMaxAge) {
      toast.error('Minimum age cannot be greater than maximum age');
      return;
    }

    if (parsedMaxDistance !== null && parsedMaxDistance < 1) {
      toast.error('Maximum distance must be at least 1 km');
      return;
    }

    setSaving(true);
    try {
      const response = await usersAPI.updateBoundaries({
        dealBreakers,
        mustHaves,
        minAge: parsedMinAge,
        maxAge: parsedMaxAge,
        maxDistance: parsedMaxDistance,
        preferredGender
      });

      const boundaries = response.data?.data?.boundaries;
      if (boundaries) {
        setDealBreakers(normalizeList(boundaries.dealBreakers));
        setMustHaves(normalizeList(boundaries.mustHaves));
        setMinAge(toInputNumber(boundaries.minAge));
        setMaxAge(toInputNumber(boundaries.maxAge));
        setMaxDistance(toInputNumber(boundaries.maxDistance));
        setPreferredGender(boundaries.preferredGender ?? 'everyone');
      }

      toast.success('Boundary preferences saved');
    } catch (error: any) {
      toast.error(error?.response?.data?.message || 'Failed to save boundaries');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen warm-gradient flex items-center justify-center">
        <div className="w-14 h-14 border-4 border-coral-200 border-t-coral-500 rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen warm-gradient">
      <header className="bg-white/20 backdrop-blur-lg border-b border-white/30 sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <button
                onClick={() => navigate(-1)}
                className="p-2 hover:bg-white/20 rounded-full transition-colors"
              >
                <ArrowLeft className="w-6 h-6 text-warm-700" />
              </button>
              <div>
                <h1 className="text-2xl font-friendly font-bold text-warm-800">Boundaries</h1>
                <p className="text-sm text-warm-600">Data-driven match filters and fit signals</p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 py-8">
        <form onSubmit={saveBoundaries} className="space-y-6">
          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="friendly-card p-6"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-gradient-to-br from-coral-400 to-peach-400 rounded-full flex items-center justify-center">
                <ShieldAlert className="w-5 h-5 text-white" />
              </div>
              <h2 className="text-xl font-bold text-warm-800">Match Filters</h2>
            </div>

            <p className="text-sm text-warm-600 mb-4">
              These values are stored in your profile preference model and used directly by matching.
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <label className="space-y-2">
                <span className="text-sm font-medium text-warm-700">Min Age</span>
                <input
                  value={minAge}
                  onChange={(e) => setMinAge(e.target.value)}
                  placeholder="18"
                  type="number"
                  className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 focus:outline-none focus:ring-2 focus:ring-coral-400"
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-warm-700">Max Age</span>
                <input
                  value={maxAge}
                  onChange={(e) => setMaxAge(e.target.value)}
                  placeholder="35"
                  type="number"
                  className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 focus:outline-none focus:ring-2 focus:ring-coral-400"
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-warm-700">Max Distance (km)</span>
                <input
                  value={maxDistance}
                  onChange={(e) => setMaxDistance(e.target.value)}
                  placeholder="50"
                  type="number"
                  className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 focus:outline-none focus:ring-2 focus:ring-coral-400"
                />
              </label>
            </div>

            <div className="mt-4">
              <p className="text-sm font-medium text-warm-700 mb-2">Preferred Gender</p>
              <div className="flex flex-wrap gap-2">
                {[
                  { value: 'everyone', label: 'Everyone' },
                  { value: 'male', label: 'Men' },
                  { value: 'female', label: 'Women' },
                  { value: 'non-binary', label: 'Non-binary' }
                ].map((item) => (
                  <button
                    key={item.value}
                    type="button"
                    onClick={() => setPreferredGender(item.value as PreferredGender)}
                    className={`px-4 py-2 rounded-full text-sm font-semibold transition-colors ${
                      preferredGender === item.value
                        ? 'bg-coral-200 text-coral-700'
                        : 'bg-white/60 text-warm-700 hover:bg-coral-50'
                    }`}
                  >
                    {item.label}
                  </button>
                ))}
              </div>
            </div>
          </motion.section>

          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="friendly-card p-6"
          >
            <BoundaryListEditor
              title="Deal Breakers"
              subtitle="Hard boundaries that should strongly filter out potential matches."
              icon={<ShieldAlert className="w-4 h-4 text-red-600" />}
              colorClasses="bg-red-50 text-red-700 border-red-200"
              input={dealBreakerInput}
              onInput={setDealBreakerInput}
              onAdd={() => addBoundary(dealBreakerInput, 'deal')}
              items={dealBreakers}
              onRemove={(index) => removeBoundary(index, 'deal')}
            />
          </motion.section>

          <motion.section
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="friendly-card p-6"
          >
            <BoundaryListEditor
              title="Must-Haves"
              subtitle="Positive requirements that boost compatibility scoring."
              icon={<Sparkles className="w-4 h-4 text-mint-500" />}
              colorClasses="bg-mint-50 text-mint-700 border-mint-200"
              input={mustHaveInput}
              onInput={setMustHaveInput}
              onAdd={() => addBoundary(mustHaveInput, 'must')}
              items={mustHaves}
              onRemove={(index) => removeBoundary(index, 'must')}
            />
          </motion.section>

          <motion.button
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            type="submit"
            disabled={saving}
            className="w-full friendly-button py-4 font-semibold flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {saving ? (
              <>
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Save className="w-5 h-5" />
                Save Boundaries
              </>
            )}
          </motion.button>
        </form>
      </main>
    </div>
  );
};

const BoundaryListEditor = ({
  title,
  subtitle,
  icon,
  colorClasses,
  input,
  onInput,
  onAdd,
  items,
  onRemove
}: {
  title: string;
  subtitle: string;
  icon: JSX.Element;
  colorClasses: string;
  input: string;
  onInput: (value: string) => void;
  onAdd: () => void;
  items: string[];
  onRemove: (index: number) => void;
}) => {
  return (
    <>
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-xl font-bold text-warm-800">{title}</h2>
        <span className="text-xs text-warm-600">{items.length}/{MAX_ITEMS}</span>
      </div>
      <p className="text-sm text-warm-600 mb-4">{subtitle}</p>

      <div className="flex items-center gap-2 mb-3">
        <input
          value={input}
          onChange={(e) => onInput(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              e.preventDefault();
              onAdd();
            }
          }}
          placeholder="Add boundary item"
          className="flex-1 px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 focus:outline-none focus:ring-2 focus:ring-coral-400"
        />
        <button
          type="button"
          onClick={onAdd}
          className="h-[48px] px-4 bg-coral-500 text-white rounded-xl hover:bg-coral-600 transition-colors flex items-center justify-center"
        >
          <Plus className="w-5 h-5" />
        </button>
      </div>

      {items.length === 0 ? (
        <p className="text-sm text-warm-600">No items added yet.</p>
      ) : (
        <div className="flex flex-wrap gap-2">
          {items.map((item, index) => (
            <span
              key={`${item}-${index}`}
              className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full border text-sm ${colorClasses}`}
            >
              {icon}
              {item}
              <button type="button" onClick={() => onRemove(index)} className="hover:opacity-70">
                <X className="w-4 h-4" />
              </button>
            </span>
          ))}
        </div>
      )}
    </>
  );
};

const parseOptionalInt = (value: string): number | null => {
  const normalized = value.trim();
  if (!normalized) return null;
  const parsed = Number.parseInt(normalized, 10);
  return Number.isNaN(parsed) ? null : parsed;
};

const normalizeList = (value: unknown): string[] => {
  if (!Array.isArray(value)) return [];

  const seen = new Set<string>();
  return value
    .filter((item): item is string => typeof item === 'string')
    .map((item) => item.trim())
    .filter((item) => {
      if (!item) return false;
      const key = item.toLowerCase();
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    })
    .slice(0, MAX_ITEMS);
};

const toInputNumber = (value: unknown): string => {
  if (typeof value === 'number' && Number.isFinite(value)) return String(value);
  return '';
};

export default BoundariesSettings;
