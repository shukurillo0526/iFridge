"""
I-Fridge — Test Configuration
================================
Shared fixtures for the backend test suite.
"""

import pytest
import sys
import os

# Ensure the backend directory is on the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
