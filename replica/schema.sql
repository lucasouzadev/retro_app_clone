BEGIN;

CREATE TABLE profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    apple_subject text NOT NULL UNIQUE,
    handle text NOT NULL UNIQUE CHECK (handle ~ '^[a-z0-9_]{3,24}$'),
    display_name text NOT NULL CHECK (char_length(btrim(display_name)) BETWEEN 1 AND 80),
    time_zone text NOT NULL,
    deleted_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE friendships (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    recipient_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CHECK (requester_id <> recipient_id)
);

CREATE UNIQUE INDEX friendships_pair_idx
    ON friendships (least(requester_id, recipient_id), greatest(requester_id, recipient_id));
CREATE INDEX friendships_requester_idx ON friendships (requester_id, status);
CREATE INDEX friendships_recipient_idx ON friendships (recipient_id, status);

CREATE TABLE diary_weeks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    week_start date NOT NULL CHECK (extract(isodow FROM week_start) = 1),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (user_id, week_start),
    UNIQUE (id, user_id)
);

CREATE TABLE media_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    week_id uuid NOT NULL,
    object_key text NOT NULL UNIQUE,
    client_request_id uuid NOT NULL,
    kind text NOT NULL CHECK (kind IN ('photo', 'video')),
    status text NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'published', 'deleted')),
    caption text CHECK (char_length(caption) <= 500),
    captured_at timestamptz,
    published_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (week_id, user_id) REFERENCES diary_weeks(id, user_id) ON DELETE RESTRICT,
    UNIQUE (user_id, client_request_id),
    CHECK (status <> 'published' OR published_at IS NOT NULL)
);

CREATE INDEX media_week_idx ON media_items (week_id, user_id, status, published_at, id);
CREATE INDEX media_feed_idx ON media_items (user_id, published_at DESC, id DESC)
    WHERE status = 'published';
CREATE INDEX media_cleanup_idx ON media_items (status, updated_at)
    WHERE status IN ('pending', 'deleted');

CREATE TABLE reactions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    media_id uuid NOT NULL REFERENCES media_items(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (user_id, media_id)
);

CREATE INDEX reactions_media_idx ON reactions (media_id);

CREATE FUNCTION touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER profiles_touch BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER friendships_touch BEFORE UPDATE ON friendships
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER diary_weeks_touch BEFORE UPDATE ON diary_weeks
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER media_items_touch BEFORE UPDATE ON media_items
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER reactions_touch BEFORE UPDATE ON reactions
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

COMMIT;
