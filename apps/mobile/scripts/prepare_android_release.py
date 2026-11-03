"""Validate CI inputs without printing credentials, then create ignored build files."""

import base64
import os
from pathlib import Path
from mobile_release_config import read_mobile_config, write_mobile_config


def prepare():
    required = (
        "MOBILE_CONFIG_JSON", "ANDROID_KEYSTORE_BASE64", "ANDROID_KEYSTORE_PATH",
        "ANDROID_KEYSTORE_PASSWORD", "ANDROID_KEY_ALIAS", "ANDROID_KEY_PASSWORD",
    )
    missing = [name for name in required if not os.environ.get(name, "").strip()]
    if missing:
        raise ValueError("Missing GitHub Actions secrets/environment: " + ", ".join(missing))
    config = read_mobile_config()
    keystore = base64.b64decode(os.environ["ANDROID_KEYSTORE_BASE64"], validate=True)
    if not keystore:
        raise ValueError("ANDROID_KEYSTORE_BASE64 is empty")
    destination = Path(os.environ["ANDROID_KEYSTORE_PATH"])
    destination.write_bytes(keystore)
    destination.chmod(0o600)
    write_mobile_config(config)
    print("Android release configuration prepared; credential values omitted.")


if __name__ == "__main__":
    try:
        prepare()
    except Exception as error:
        # JSON/base64 parsers can include input in their messages.
        message = str(error) if isinstance(error, ValueError) and type(error) is ValueError else type(error).__name__
        raise SystemExit("Release configuration failed: " + message)
