-- I-Fridge Phase 3: pgvector configuration

-- 1. Enable the pgvector extension to work with embedding vectors
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Add embedding vector column to recipes table
-- (Using 768 dimensions common for sentence-transformers or text-embedding-ada-002)
ALTER TABLE public.recipes 
ADD COLUMN IF NOT EXISTS embedding vector(768);

-- 3. Create a vector similarity search RPC
-- This allows matching user preference vectors to recipe vectors
CREATE OR REPLACE FUNCTION match_recipes(
  query_embedding vector(768),
  match_threshold float,
  match_count int
)
RETURNS TABLE (
  id uuid,
  title text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    recipes.id,
    recipes.title,
    1 - (recipes.embedding <=> query_embedding) AS similarity
  FROM recipes
  WHERE 1 - (recipes.embedding <=> query_embedding) > match_threshold
  ORDER BY recipes.embedding <=> query_embedding
  LIMIT match_count;
$$;
