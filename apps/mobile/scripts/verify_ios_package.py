"""Reject simulator/debug or incomplete packages before delivering to Windows."""

import plistlib
import sys
from zipfile import ZipFile


def verify(path):
    with ZipFile(path) as archive:
        if archive.testzip() is not None:
            raise ValueError("Corrupt IPA")
        names = set(archive.namelist())
        root = "Payload/Runner.app/"
        info = plistlib.loads(archive.read(root + "Info.plist"))
        if info.get("CFBundleSupportedPlatforms") != ["iPhoneOS"]:
            raise ValueError("Expected physical iPhone build, not simulator")
        for required in (
            info["CFBundleExecutable"],
            "Frameworks/App.framework/App",
            "Frameworks/Flutter.framework/Flutter",
        ):
            if root + required not in names:
                raise ValueError("Missing executable: " + required)
        if any(name.endswith("kernel_blob.bin") for name in names):
            raise ValueError("Debug kernel is not a standalone Release build")
        for permission in (
            "NSCameraUsageDescription", "NSPhotoLibraryUsageDescription",
            "NSLocationWhenInUseUsageDescription",
        ):
            if not info.get(permission):
                raise ValueError("Missing permission description: " + permission)
        print("Verified device IPA structure, AOT files and permission descriptions.")


if __name__ == "__main__":
    verify(sys.argv[1])
