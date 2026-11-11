from datetime import datetime, timezone
from enum import Enum
from math import asin, cos, radians, sin, sqrt
from threading import Lock
from uuid import uuid4

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field

app = FastAPI(title="KinNav Traffic API", version="0.1.0")
reports: dict[str, dict] = {}
report_lock = Lock()


class ReportType(str, Enum):
    accident = "accident"
    works = "works"
    jam = "jam"
    barrier = "barrier"
    flood = "flood"
    clear = "clear"


class Severity(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"
    critical = "critical"


class ReportCreate(BaseModel):
    type: ReportType
    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)
    description: str = Field(min_length=1, max_length=500)
    severity: Severity = Severity.medium


class VoteCreate(BaseModel):
    vote: str = Field(pattern="^(confirm|deny)$")


def distance_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    delta_lat = radians(lat2 - lat1)
    delta_lng = radians(lng2 - lng1)
    value = sin(delta_lat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(delta_lng / 2) ** 2
    return 6371 * 2 * asin(sqrt(value))


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/traffic/reports", status_code=201)
def create_report(payload: ReportCreate) -> dict:
    report = {
        "id": str(uuid4()),
        **payload.model_dump(),
        "votes_confirm": 0,
        "votes_deny": 0,
        "status": "active",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    with report_lock:
        reports[report["id"]] = report
    return report


@app.get("/traffic/reports")
def list_reports(
    lat: float | None = Query(default=None, ge=-90, le=90),
    lng: float | None = Query(default=None, ge=-180, le=180),
    radius: float = Query(default=10, gt=0, le=100),
    report_type: ReportType | None = Query(default=None, alias="type"),
) -> dict[str, list[dict]]:
    if (lat is None) != (lng is None):
        raise HTTPException(status_code=400, detail="lat et lng doivent être fournis ensemble")
    with report_lock:
        items = list(reports.values())
    if report_type:
        items = [item for item in items if item["type"] == report_type.value]
    if lat is not None and lng is not None:
        items = [item for item in items if distance_km(lat, lng, item["lat"], item["lng"]) <= radius]
    return {"reports": items}


@app.post("/traffic/reports/{report_id}/vote")
def vote(report_id: str, payload: VoteCreate) -> dict:
    with report_lock:
        report = reports.get(report_id)
        if report is None:
            raise HTTPException(status_code=404, detail="Signalement introuvable")
        key = "votes_confirm" if payload.vote == "confirm" else "votes_deny"
        report[key] += 1
        if report["votes_deny"] >= 3 and report["votes_deny"] > report["votes_confirm"]:
            report["status"] = "false_positive"
        return report


@app.get("/traffic/segments")
def segments(bbox: str | None = None) -> dict[str, list]:
    # Traffic prediction is not available in the MVP; an empty collection is explicit.
    return {"segments": [], "bbox": bbox, "source": "unavailable"}
