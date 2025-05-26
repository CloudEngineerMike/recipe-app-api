"""
Test custom Django management commands.
"""

from unittest.mock import patch
from psycopg2 import OperationalError as Psycopg2Error
from django.core.management import call_command
from django.test import SimpleTestCase
from django.db.utils import OperationalError


# Test the wait_for_db command.
class CommandTests(SimpleTestCase):
    """Test custom Django management commands."""

    # Patch the check method in the wait_for_db command.
    @patch('core.management.commands.wait_for_db.Command.check')
    def test_wait_for_db_ready(self, patched_check):  # Test waiting for DB when DB is unavailable.
        """Test waiting for database when database is available."""

        # Simulate the database being ready
        patched_check.return_value = True

        # Call the command
        call_command('wait_for_db')

        # Check that the check method was called once with the correct arguments
        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    @patch('core.management.commands.wait_for_db.Command.check')
    def test_wait_for_db_delay(self, patched_check, patched_sleep):
        """
        Test waiting for database when getting OperationalError:

        - For the first 2 calls, check() will raise Psycopg2Error
        - For the next 3 calls, it will raise OperationalError
        - On the 6th call, it will return True

        This simulates:
        - The DB being unreachable (e.g. network error)
        - Then reachable but not ready (e.g. migrations not applied)
        - Then finally being ready
        """
        patched_check.side_effect = [Psycopg2Error] * 2 + [OperationalError] * 3 + [True]

        # Call the command
        call_command('wait_for_db')

        # Check that the check method was called 6 times
        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])
