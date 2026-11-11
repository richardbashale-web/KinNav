CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_type VARCHAR(20) NOT NULL CHECK (auth_type IN ('anonymous', 'phone', 'email', 'google', 'apple')),
  phone VARCHAR(20) UNIQUE,
  email VARCHAR(255) UNIQUE,
  display_name VARCHAR(100),
  avatar_url TEXT,
  tier VARCHAR(20) NOT NULL DEFAULT 'anonymous' CHECK (tier IN ('anonymous', 'free', 'premium', 'enterprise')),
  daily_route_count INT NOT NULL DEFAULT 0 CHECK (daily_route_count >= 0),
  daily_route_limit INT NOT NULL DEFAULT 3 CHECK (daily_route_limit >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  origin_lat DECIMAL(10,8) NOT NULL,
  origin_lng DECIMAL(11,8) NOT NULL,
  dest_lat DECIMAL(10,8) NOT NULL,
  dest_lng DECIMAL(11,8) NOT NULL,
  waypoints JSONB NOT NULL DEFAULT '[]'::jsonb,
  estimated_duration INT CHECK (estimated_duration IS NULL OR estimated_duration >= 0),
  actual_duration INT CHECK (actual_duration IS NULL OR actual_duration >= 0),
  distance_meters INT CHECK (distance_meters IS NULL OR distance_meters >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS routes_user_created_idx ON routes(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  lat DECIMAL(10,8) NOT NULL,
  lng DECIMAL(11,8) NOT NULL,
  address TEXT,
  type VARCHAR(20) NOT NULL CHECK (type IN ('home', 'work', 'other')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS favorites_user_idx ON favorites(user_id);
