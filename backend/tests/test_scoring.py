"""
I-Fridge — Scoring Service Unit Tests
=======================================
Tests the 6-signal composite scoring functions in isolation.
All tests are pure computation — no database or network calls.

Run: pytest backend/tests/ -v
"""

import pytest
from datetime import date, timedelta

# We need to mock settings before importing scoring
from unittest.mock import patch, MagicMock


@pytest.fixture(autouse=True)
def mock_settings():
    """Mock settings to avoid needing .env file for tests."""
    mock = MagicMock()
    mock.WEIGHT_EXPIRY = 0.25
    mock.WEIGHT_FLAVOR = 0.20
    mock.WEIGHT_FAMILIAR = 0.10
    mock.WEIGHT_DIFFICULTY = 0.10
    mock.WEIGHT_RECENCY = 0.10
    mock.WEIGHT_COVERAGE = 0.25
    with patch("app.services.scoring.get_settings", return_value=mock):
        yield mock


# ── Expiry Urgency ─────────────────────────────────────────────


class TestExpiryUrgency:
    def test_expiring_today_returns_max(self):
        from app.services.scoring import compute_expiry_urgency

        inv = {"ing1": date.today()}
        result = compute_expiry_urgency(["ing1"], inv)
        assert result == 1.0

    def test_expiring_in_7_days_returns_zero(self):
        from app.services.scoring import compute_expiry_urgency

        inv = {"ing1": date.today() + timedelta(days=7)}
        result = compute_expiry_urgency(["ing1"], inv, horizon_days=7)
        assert result == pytest.approx(0.0, abs=0.01)

    def test_expiring_in_3_days(self):
        from app.services.scoring import compute_expiry_urgency

        inv = {"ing1": date.today() + timedelta(days=3)}
        result = compute_expiry_urgency(["ing1"], inv, horizon_days=7)
        assert 0.4 < result < 0.65

    def test_missing_ingredients_ignored(self):
        from app.services.scoring import compute_expiry_urgency

        inv = {"ing1": date.today() + timedelta(days=1)}
        result = compute_expiry_urgency(["ing1", "missing_ing"], inv)
        # Only ing1 contributes, missing_ing is skipped
        assert result > 0.0

    def test_empty_inventory_returns_zero(self):
        from app.services.scoring import compute_expiry_urgency

        result = compute_expiry_urgency(["ing1"], {})
        assert result == 0.0

    def test_multiple_ingredients_averaged(self):
        from app.services.scoring import compute_expiry_urgency

        inv = {
            "ing1": date.today(),  # urgency 1.0
            "ing2": date.today() + timedelta(days=7),  # urgency 0.0
        }
        result = compute_expiry_urgency(["ing1", "ing2"], inv, horizon_days=7)
        assert result == pytest.approx(0.5, abs=0.01)


# ── Flavor Affinity ─────────────────────────────────────────────


class TestFlavorAffinity:
    def test_identical_profiles_return_one(self):
        from app.services.scoring import compute_flavor_affinity

        profile = {"sweet": 0.8, "salty": 0.3, "sour": 0.1, "bitter": 0.2, "umami": 0.9, "spicy": 0.5}
        result = compute_flavor_affinity(profile, profile)
        assert result == pytest.approx(1.0, abs=0.01)

    def test_orthogonal_profiles(self):
        from app.services.scoring import compute_flavor_affinity

        r = {"sweet": 1.0, "salty": 0.0, "sour": 0.0, "bitter": 0.0, "umami": 0.0, "spicy": 0.0}
        u = {"sweet": 0.0, "salty": 1.0, "sour": 0.0, "bitter": 0.0, "umami": 0.0, "spicy": 0.0}
        result = compute_flavor_affinity(r, u)
        assert result == pytest.approx(0.0, abs=0.01)

    def test_neutral_profiles(self):
        from app.services.scoring import compute_flavor_affinity

        result = compute_flavor_affinity({}, {})  # Defaults to 0.5 each
        assert result == pytest.approx(1.0, abs=0.01)


# ── Difficulty Fit ───────────────────────────────────────────────


class TestDifficultyFit:
    def test_perfect_match_beginner(self):
        from app.services.scoring import compute_difficulty_fit

        result = compute_difficulty_fit(recipe_difficulty=1, user_skill_level=1)
        assert result == 1.0

    def test_perfect_match_expert(self):
        from app.services.scoring import compute_difficulty_fit

        result = compute_difficulty_fit(recipe_difficulty=3, user_skill_level=5)
        assert result == 1.0

    def test_mismatch_penalized(self):
        from app.services.scoring import compute_difficulty_fit

        result = compute_difficulty_fit(recipe_difficulty=3, user_skill_level=1)
        assert result < 1.0

    def test_never_below_zero(self):
        from app.services.scoring import compute_difficulty_fit

        result = compute_difficulty_fit(recipe_difficulty=3, user_skill_level=1)
        assert result >= 0.0


# ── Recency Penalty ──────────────────────────────────────────────


class TestRecencyPenalty:
    def test_cooked_today(self):
        from app.services.scoring import compute_recency_penalty

        result = compute_recency_penalty(date.today())
        assert result == 0.0

    def test_cooked_14_days_ago(self):
        from app.services.scoring import compute_recency_penalty

        result = compute_recency_penalty(date.today() - timedelta(days=14))
        assert result == 1.0

    def test_cooked_7_days_ago(self):
        from app.services.scoring import compute_recency_penalty

        result = compute_recency_penalty(date.today() - timedelta(days=7))
        assert result == 0.5

    def test_never_cooked(self):
        from app.services.scoring import compute_recency_penalty

        result = compute_recency_penalty(None)
        assert result == 0.8


# ── Match Coverage ───────────────────────────────────────────────


class TestMatchCoverage:
    def test_full_match(self):
        from app.services.scoring import compute_match_coverage

        assert compute_match_coverage(1.0) == 1.0

    def test_zero_match(self):
        from app.services.scoring import compute_match_coverage

        assert compute_match_coverage(0.0) == 0.0

    def test_high_match_rewarded(self):
        from app.services.scoring import compute_match_coverage

        high = compute_match_coverage(0.9)
        medium = compute_match_coverage(0.5)
        low = compute_match_coverage(0.2)
        assert high > medium > low


# ── Composite Score ──────────────────────────────────────────────


class TestCompositeScore:
    def test_perfect_recipe(self):
        from app.services.scoring import compute_relevance_score

        score = compute_relevance_score(
            expiry_urgency=1.0,
            flavor_affinity=1.0,
            is_comfort=True,
            match_percentage=1.0,
            recipe_difficulty=2,
            user_skill_level=3,
            last_cooked_date=date.today() - timedelta(days=30),
        )
        assert score >= 0.9

    def test_terrible_recipe(self):
        from app.services.scoring import compute_relevance_score

        score = compute_relevance_score(
            expiry_urgency=0.0,
            flavor_affinity=0.0,
            is_comfort=False,
            match_percentage=0.0,
            recipe_difficulty=3,
            user_skill_level=1,
            last_cooked_date=date.today(),
        )
        assert score <= 0.2

    def test_score_bounded_zero_to_one(self):
        from app.services.scoring import compute_relevance_score

        score = compute_relevance_score(
            expiry_urgency=1.5,  # Intentionally over
            flavor_affinity=1.5,
            is_comfort=True,
            match_percentage=1.0,
        )
        assert 0.0 <= score <= 1.0

    def test_familiarity_boost(self):
        from app.services.scoring import compute_relevance_score

        familiar = compute_relevance_score(
            expiry_urgency=0.5, flavor_affinity=0.5,
            is_comfort=True, match_percentage=0.5,
        )
        unfamiliar = compute_relevance_score(
            expiry_urgency=0.5, flavor_affinity=0.5,
            is_comfort=False, match_percentage=0.5,
        )
        assert familiar > unfamiliar
