-- ============================================================================
-- 正念習慣知識庫 (Mindfulness Habit Knowledge Hub)
-- Supabase PostgreSQL Schema & Row Level Security (RLS)
-- 安全原則：前端僅使用公開 anon / publishable key，嚴禁洩露 service_role key
-- 請於 Supabase Dashboard -> SQL Editor 執行，或由管理員透過 migration 套用
-- ============================================================================

-- 1. 個人／團隊正念覺察筆記與 STOP 實戰紀錄表 (mindfulness_team_notes)
CREATE TABLE IF NOT EXISTS public.mindfulness_team_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL DEFAULT '團隊成員',
  book_slug TEXT NOT NULL DEFAULT 'the-mindfulness-habit',
  slide_no INTEGER,
  category TEXT NOT NULL DEFAULT '覺察心得'
    CHECK (category IN ('覺察心得', 'STOP暫停實戰', '職場減壓與心流', '團隊共學討論')),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[] NOT NULL DEFAULT '{}',
  is_shared BOOLEAN NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_mindfulness_team_notes_book_created
  ON public.mindfulness_team_notes (book_slug, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_mindfulness_team_notes_user_id
  ON public.mindfulness_team_notes (user_id);

ALTER TABLE public.mindfulness_team_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "mindfulness_notes_select_shared_or_own" ON public.mindfulness_team_notes;
CREATE POLICY "mindfulness_notes_select_shared_or_own"
  ON public.mindfulness_team_notes
  FOR SELECT
  TO authenticated
  USING (is_shared = true OR (SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "mindfulness_notes_insert_own" ON public.mindfulness_team_notes;
CREATE POLICY "mindfulness_notes_insert_own"
  ON public.mindfulness_team_notes
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "mindfulness_notes_update_own" ON public.mindfulness_team_notes;
CREATE POLICY "mindfulness_notes_update_own"
  ON public.mindfulness_team_notes
  FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "mindfulness_notes_delete_own" ON public.mindfulness_team_notes;
CREATE POLICY "mindfulness_notes_delete_own"
  ON public.mindfulness_team_notes
  FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);


-- 2. 個人／團隊正念習慣行動打卡表 (mindfulness_action_checkins)
CREATE TABLE IF NOT EXISTS public.mindfulness_action_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_slug TEXT NOT NULL,
  action_key TEXT NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT false,
  reflection TEXT DEFAULT '',
  UNIQUE (user_id, book_slug, action_key)
);

CREATE INDEX IF NOT EXISTS idx_mindfulness_action_checkins_user_book
  ON public.mindfulness_action_checkins (user_id, book_slug);

ALTER TABLE public.mindfulness_action_checkins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "mindfulness_checkins_all_own" ON public.mindfulness_action_checkins;
CREATE POLICY "mindfulness_checkins_all_own"
  ON public.mindfulness_action_checkins
  FOR ALL
  TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);


-- 3. 自動更新 updated_at 觸發器
CREATE OR REPLACE FUNCTION public.mindfulness_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_mindfulness_team_notes_updated_at ON public.mindfulness_team_notes;
CREATE TRIGGER trg_mindfulness_team_notes_updated_at
  BEFORE UPDATE ON public.mindfulness_team_notes
  FOR EACH ROW EXECUTE FUNCTION public.mindfulness_set_updated_at();

DROP TRIGGER IF EXISTS trg_mindfulness_action_checkins_updated_at ON public.mindfulness_action_checkins;
CREATE TRIGGER trg_mindfulness_action_checkins_updated_at
  BEFORE UPDATE ON public.mindfulness_action_checkins
  FOR EACH ROW EXECUTE FUNCTION public.mindfulness_set_updated_at();
