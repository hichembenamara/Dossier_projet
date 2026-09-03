import unittest

from etl_common import (
    hours_to_minutes,
    normalize_gender_fr,
    normalize_meal_type,
    normalize_sleep_disorder,
    parse_blood_pressure,
    to_float,
)


class TestEtlHelpers(unittest.TestCase):
    def test_normalize_gender(self):
        self.assertEqual(normalize_gender_fr("Male"), "Homme")
        self.assertEqual(normalize_gender_fr("female"), "Femme")
        self.assertEqual(normalize_gender_fr(None), "Inconnu")

    def test_normalize_meal_type(self):
        self.assertEqual(normalize_meal_type("Breakfast"), "PetitDejeuner")
        self.assertEqual(normalize_meal_type("Lunch"), "Dejeuner")
        self.assertEqual(normalize_meal_type("Snack"), "Collation")

    def test_normalize_sleep_disorder(self):
        self.assertEqual(normalize_sleep_disorder("None"), "Aucun")
        self.assertEqual(normalize_sleep_disorder("Sleep Apnea"), "Apnee")
        self.assertEqual(normalize_sleep_disorder("Insomnia"), "Insomnie")

    def test_parse_blood_pressure(self):
        self.assertEqual(parse_blood_pressure("126/83"), (126, 83))
        self.assertEqual(parse_blood_pressure("bad-value"), (None, None))

    def test_conversions(self):
        self.assertEqual(to_float("1.75"), 1.75)
        self.assertEqual(hours_to_minutes("1.5"), 90)


if __name__ == "__main__":
    unittest.main()


class TestDemoPasswordHash(unittest.TestCase):
    def test_hash_format_matches_backend_verify_password(self):
        import base64
        import hashlib
        import hmac

        from etl_common import PBKDF2_ITERATIONS, hash_password_demo

        encoded = hash_password_demo("secret")
        algorithm, iterations, salt, digest_b64 = encoded.split("$", 3)

        # Reproduit backend.app.core.security.verify_password sans dépendre du backend.
        candidate = hashlib.pbkdf2_hmac("sha256", b"secret", salt.encode("utf-8"), int(iterations))
        self.assertEqual(algorithm, "pbkdf2_sha256")
        self.assertEqual(int(iterations), PBKDF2_ITERATIONS)
        self.assertEqual(PBKDF2_ITERATIONS, 600_000)
        self.assertTrue(hmac.compare_digest(base64.b64encode(candidate).decode("ascii"), digest_b64))
