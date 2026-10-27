
import json
import sys
from pathlib import Path

from garmin_personal_api import (
    GarminPersonalApiClient,
    PersonalApiAuthenticator,
    resolve_api_key,
)


def fetch_day(date: str) -> dict:
    with PersonalApiAuthenticator() as auth:
        token = auth.obtain_token(resolve_api_key())

    with GarminPersonalApiClient(token.access_token) as api:
        return {
            "date": date,
            "sleep": api.get_daily_sleep(date),
            "stress": api.get_daily_stress(date, date),
            "body_battery": api.get_daily_body_battery(date, date),
        }


if __name__ == "__main__":
    date, output_file = sys.argv[1:3]

    data = fetch_day(date)

    output = Path(output_file)
    output.parent.mkdir(parents=True, exist_ok=True)

    output.write_text(
        json.dumps(data, indent=2),
        encoding="utf-8",
    )
