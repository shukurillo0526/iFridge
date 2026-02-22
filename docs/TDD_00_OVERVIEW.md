# I-Fridge — Technical Design Document

> **"Zero-Waste, Maximum Taste."**

## Document Metadata

| Field | Value |
|-------|-------|
| **Project** | I-Fridge: The Intelligent Fridge Ecosystem |
| **Version** | 1.0.0 |
| **Date** | 2026-02-20 |
| **Status** | Draft — Architecture Phase |
| **Stack** | Flutter · FastAPI · Supabase · Clarifai |

---

## Executive Summary

I-Fridge is a **Digital Twin** of the user's kitchen — a living, breathing inventory system that knows what you have, when it expires, and exactly what you can cook with it. The architecture is designed from day one to be **robot-ready**: every data structure, every recipe instruction, every action is machine-parseable so that the same backend powering a mobile app today can drive a robotic arm tomorrow.

---

## Document Structure

| File | Section |
|------|---------|
| `TDD_00_OVERVIEW.md` | This file — Overview, Risks, Architecture Diagram |
| `TDD_01_DATA_SCHEMA.md` | Section 1 — Supabase SQL Schema |
| `TDD_02_ALGORITHM.md` | Section 2 — 5-Tier Recommendation Engine |
| `TDD_03_UI_ARCHITECTURE.md` | Section 3 — Flutter Digital Twin UI |
| `TDD_04_VISION_PIPELINE.md` | Section 4 — Clarifai Vision Pipeline |
| `TDD_05_ROBOT_PROTOCOL.md` | Section 5 — Robot-Ready Protocol |

---

## Top 3 Technical Risks & Mitigations

### Risk 1: Vision Model Data Drift & Misclassification

**Problem:** Clarifai's food recognition models are trained on idealized images. Real-world kitchen photos contain partial packaging, mixed items, poor lighting, and region-specific produce (e.g., Korean 배 pear vs. Western Bartlett pear). Over time, model accuracy can degrade as user demographics shift.

**Mitigation:**
- **Correction Feedback Loop:** Every vision result passes through a mandatory "Confirm & Correct" UI step. User corrections are logged in a `vision_corrections` table, creating a gold-standard dataset for fine-tuning.
- **Confidence Gating:** Items identified with <70% confidence are flagged for manual review rather than auto-added. Items >90% are auto-confirmed with a lightweight undo toast.
- **Fallback Hierarchy:** Camera → Barcode Scan → Manual Search. No single point of failure.

### Risk 2: Inventory Staleness & State Inconsistency

**Problem:** A fridge's contents change constantly. Users forget to log consumption. An opened bottle of milk expires in 3 days, not 14. The "Digital Twin" becomes a "Digital Ghost" — a stale, unreliable snapshot.

**Mitigation:**
- **Dynamic Expiry Model:** Each item has both a `sealed_shelf_life` and an `opened_shelf_life`. A state transition (`sealed → opened`) recalculates the expiry. See Section 1 schema.
- **Gentle Nudges:** A daily push notification at a user-configured time: *"Quick check: Do you still have Milk, Eggs, Spinach?"* with one-tap confirm/remove.
- **Consumption Inference:** When a user marks a Tier 1 recipe as "Cooked," the system auto-deducts the recipe's ingredients from inventory with an "Undo" option.

### Risk 3: Recipe Instruction Granularity for Robotics

**Problem:** Human recipe instructions are ambiguous ("add a pinch of salt," "cook until golden brown"). A robot needs exact actions, targets, parameters, durations, and sensor-based completion criteria. Bridging this gap at scale is enormously difficult.

**Mitigation:**
- **Structured Instruction Schema:** Recipes are stored as JSONB arrays of `RobotAction` objects (see Section 1), not prose. Each step has an `action`, `target`, `parameters`, and optional `sensor_check`.
- **Human & Machine Views:** The Flutter app renders human-friendly text from the structured data. The robot API consumes the raw JSONB directly. One source of truth, two renderers.
- **Progressive Enrichment:** V1 launches with human-authored structured recipes. V2 introduces an LLM pipeline that parses free-text recipes into structured format, validated by human reviewers.

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      FLUTTER CLIENT                         │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌───────────┐  │
│  │ Living   │  │ Recipe   │  │  Camera   │  │ Gamific.  │  │
│  │ Shelf UI │  │ Browser  │  │  Scanner  │  │ Dashboard │  │
│  └────┬─────┘  └────┬─────┘  └─────┬─────┘  └─────┬─────┘  │
│       └──────────────┴──────────────┴──────────────┘        │
│                          │  Supabase Realtime                │
└──────────────────────────┼──────────────────────────────────┘
                           │
              ┌────────────▼────────────┐
              │    SUPABASE (Postgres)   │
              │  • Auth   • Realtime    │
              │  • Tables • Storage     │
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │   FASTAPI on Railway     │
              │  ┌────────────────────┐  │
              │  │ 5-Tier Engine      │  │
              │  │ Vision Orchestrator│  │
              │  │ Robot Protocol API │  │
              │  └────────────────────┘  │
              └─────┬──────────┬────────┘
                    │          │
          ┌─────────▼┐   ┌────▼──────┐
          │ Clarifai │   │ Robot ARM │
          │   API    │   │ (Future)  │
          └──────────┘   └───────────┘
```

---

*Continue to [Section 1: Data Schema →](./TDD_01_DATA_SCHEMA.md)*
