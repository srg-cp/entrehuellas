"""Ensure the artifact gate rejects packages unsuitable for standalone testing."""

from pathlib import Path
import plistlib
import tempfile
import unittest
from zipfile import ZipFile

from verify_ios_package import verify


class VerifyIosPackageTest(unittest.TestCase):
    def package(self, directory, *, simulator=False, debug=False, missing=False):
        path = Path(directory) / "app.ipa"
        root = "Payload/Runner.app/"
        info = {
            "CFBundleSupportedPlatforms": ["iPhoneSimulator" if simulator else "iPhoneOS"],
            "CFBundleExecutable": "Runner",
            "NSCameraUsageDescription": "Camera",
            "NSPhotoLibraryUsageDescription": "Photos",
            "NSLocationWhenInUseUsageDescription": "Location",
        }
        with ZipFile(path, "w") as archive:
            archive.writestr(root + "Info.plist", plistlib.dumps(info))
            archive.writestr(root + "Runner", b"fixture")
            archive.writestr(root + "Frameworks/Flutter.framework/Flutter", b"fixture")
            if not missing:
                archive.writestr(root + "Frameworks/App.framework/App", b"fixture")
            if debug:
                archive.writestr(root + "flutter_assets/kernel_blob.bin", b"fixture")
        return path

    def test_accepts_device_structure(self):
        with tempfile.TemporaryDirectory() as directory:
            verify(self.package(directory))

    def test_rejects_simulator_debug_and_incomplete_packages(self):
        for option in ("simulator", "debug", "missing"):
            with self.subTest(option=option), tempfile.TemporaryDirectory() as directory:
                with self.assertRaises(ValueError):
                    verify(self.package(directory, **{option: True}))


if __name__ == "__main__":
    unittest.main()
