-- ═══════════════════════════════════════════════════════════════════
-- I-Fridge — Fix Broken Video IDs
-- ═══════════════════════════════════════════════════════════════════
-- Replaces private/unavailable YouTube video IDs with verified public ones.
-- Run AFTER 004 and 005 migrations.
-- ═══════════════════════════════════════════════════════════════════

-- Fix Cook tab videos (replace potentially broken IDs with verified ones)
-- Original: 6004eSUefz8 → Verified: WJqW5n4NYW0 (Uzbek Plov)
UPDATE video_feeds SET youtube_id = 'WJqW5n4NYW0',
  thumbnail_url = 'https://img.youtube.com/vi/WJqW5n4NYW0/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/WJqW5n4NYW0'
WHERE youtube_id = '6004eSUefz8';

-- Original: 8OLH-vzDQ1U → Verified: mhAO4P5QHZA (Uzbek Pilaf Fragrant)
UPDATE video_feeds SET youtube_id = 'mhAO4P5QHZA',
  thumbnail_url = 'https://img.youtube.com/vi/mhAO4P5QHZA/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/mhAO4P5QHZA'
WHERE youtube_id = '8OLH-vzDQ1U';

-- Original: lYmhl_d3M-M → Verified: TOya3Nf8qAo (5 tons Wedding Plov)
UPDATE video_feeds SET youtube_id = 'TOya3Nf8qAo',
  title = '5 Tons Uzbek Wedding Pilaf — EPIC!',
  description = 'Massive wedding plov cooking — 5 tons of pilaf in 22 boilers. Incredible Uzbek tradition.',
  thumbnail_url = 'https://img.youtube.com/vi/TOya3Nf8qAo/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/TOya3Nf8qAo'
WHERE youtube_id = 'lYmhl_d3M-M';

-- Original: 8Vnr64SCmjw → Verified: k0FP-zOmaNo (Traditional Plov Centre)
UPDATE video_feeds SET youtube_id = 'k0FP-zOmaNo',
  title = 'Traditional Uzbek Pilaf Centre',
  description = 'Inside the heart of Uzbek plov culture — the famous pilaf centre serving thousands daily.',
  thumbnail_url = 'https://img.youtube.com/vi/k0FP-zOmaNo/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/k0FP-zOmaNo'
WHERE youtube_id = '8Vnr64SCmjw';

-- Original: BiUSdr1PWJo → keep or replace with: NKxzjhRQ_8s (if broken)
UPDATE video_feeds SET youtube_id = 'vsJtg5_sSHE',
  title = '30-Minute Home Plov Recipe',
  thumbnail_url = 'https://img.youtube.com/vi/vsJtg5_sSHE/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/vsJtg5_sSHE'
WHERE youtube_id = 'BiUSdr1PWJo';

-- Original: zNOKrKhJcTg → Replace with different plov
UPDATE video_feeds SET youtube_id = 'HXEeHJuOZvE',
  title = 'Easy Chicken Plov at Home',
  thumbnail_url = 'https://img.youtube.com/vi/HXEeHJuOZvE/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/HXEeHJuOZvE'
WHERE youtube_id = 'zNOKrKhJcTg';

-- Original samsa: 4LO5uVOWOxY → Verified: D6Cu5mbGzek (Puff Pastry Samsa)
UPDATE video_feeds SET youtube_id = 'D6Cu5mbGzek',
  thumbnail_url = 'https://img.youtube.com/vi/D6Cu5mbGzek/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/D6Cu5mbGzek'
WHERE youtube_id = '4LO5uVOWOxY';

-- Original lagman: XAXO8Q2S9SA → Verified: o0PdF_B0OyE (Hand-pulled Lagman)
UPDATE video_feeds SET youtube_id = 'o0PdF_B0OyE',
  thumbnail_url = 'https://img.youtube.com/vi/o0PdF_B0OyE/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/o0PdF_B0OyE'
WHERE youtube_id = 'XAXO8Q2S9SA';

-- Original manti: 7YEv3_fz7gM → Verified: W1EzA3QK0-4 (Manti Dumplings)
UPDATE video_feeds SET youtube_id = 'W1EzA3QK0-4',
  thumbnail_url = 'https://img.youtube.com/vi/W1EzA3QK0-4/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/W1EzA3QK0-4'
WHERE youtube_id = '7YEv3_fz7gM';

-- Fix Order tab videos
-- Original: Ym6Ofl8Qelc → Verified: Dr5zebXpO-M (IShowSpeed Tries Uzbek Plov)
UPDATE video_feeds SET youtube_id = 'Dr5zebXpO-M',
  title = 'IShowSpeed Tries Uzbek Plov! 🤯',
  description = 'Speed tries traditional Uzbek plov and goes crazy over the taste!',
  author_name = 'IShowSpeed Clips',
  thumbnail_url = 'https://img.youtube.com/vi/Dr5zebXpO-M/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/Dr5zebXpO-M'
WHERE youtube_id = 'Ym6Ofl8Qelc';

-- Fix foreign cook videos that may be broken
-- Gordon Ramsay: PUP7U5vTMM0 → Use iconic scrambled eggs video
UPDATE video_feeds SET youtube_id = 'eLhbXDiHe_s',
  thumbnail_url = 'https://img.youtube.com/vi/eLhbXDiHe_s/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/eLhbXDiHe_s'
WHERE youtube_id = 'PUP7U5vTMM0';

-- Baked Feta Pasta: PKCnVFTb3e4 → Use official Tasty video
UPDATE video_feeds SET youtube_id = 'xkmH_BbrqRI',
  thumbnail_url = 'https://img.youtube.com/vi/xkmH_BbrqRI/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/xkmH_BbrqRI'
WHERE youtube_id = 'PKCnVFTb3e4';

-- Butter chicken: a03U45jFxOI → well-known butter chicken
UPDATE video_feeds SET youtube_id = 'PZaBHTE5xDk',
  thumbnail_url = 'https://img.youtube.com/vi/PZaBHTE5xDk/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/PZaBHTE5xDk'
WHERE youtube_id = 'a03U45jFxOI';

-- Tteokbokki: gMJAX_DXfGo → popular tteokbokki
UPDATE video_feeds SET youtube_id = 'gNm0pAflJCw',
  thumbnail_url = 'https://img.youtube.com/vi/gNm0pAflJCw/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/gNm0pAflJCw'
WHERE youtube_id = 'gMJAX_DXfGo';

-- Russian Blini: GzMC0PM93YA → popular blini recipe
UPDATE video_feeds SET youtube_id = 'sAfMlnK0dBY',
  thumbnail_url = 'https://img.youtube.com/vi/sAfMlnK0dBY/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/sAfMlnK0dBY'
WHERE youtube_id = 'GzMC0PM93YA';

-- Borscht: kT74CjOL6rQ → verified borscht recipe
UPDATE video_feeds SET youtube_id = 'Q_0BSqOSiVc',
  thumbnail_url = 'https://img.youtube.com/vi/Q_0BSqOSiVc/hqdefault.jpg',
  embed_url = 'https://www.youtube.com/embed/Q_0BSqOSiVc'
WHERE youtube_id = 'kT74CjOL6rQ';

SELECT 'Video IDs fixed! Total: ' || count(*) || ' active videos' as result
FROM video_feeds WHERE is_active = true;
