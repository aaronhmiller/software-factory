import unittest

from calc import subtract


class SubtractTest(unittest.TestCase):
    def test_subtract(self):
        self.assertEqual(subtract(5, 3), 2)

    def test_negative_result(self):
        self.assertEqual(subtract(3, 5), -2)

    def test_zero(self):
        self.assertEqual(subtract(4, 4), 0)
        self.assertEqual(subtract(7, 0), 7)


if __name__ == "__main__":
    unittest.main()
