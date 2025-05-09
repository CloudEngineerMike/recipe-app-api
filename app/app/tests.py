"""
Sample tests
"""

from django.test import SimpleTestCase

from app import calc

# Tests for the calc module
class CalcTests(SimpleTestCase):

    # Test the add function
    def test_add_numbers(self):

        res = calc.add(5, 6)

        self.assertEqual(res, 11)