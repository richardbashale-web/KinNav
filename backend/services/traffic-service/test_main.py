from fastapi.testclient import TestClient

from main import app, reports

client = TestClient(app)


def setup_function() -> None:
    reports.clear()


def test_create_filter_and_vote_report() -> None:
    created = client.post(
        "/traffic/reports",
        json={"type": "accident", "lat": -4.325, "lng": 15.322, "description": "Accident signalé"},
    )
    assert created.status_code == 201
    report = created.json()
    assert client.get("/traffic/reports?type=accident").json()["reports"][0]["id"] == report["id"]
    response = client.post(f"/traffic/reports/{report['id']}/vote", json={"vote": "confirm"})
    assert response.status_code == 200
    assert response.json()["votes_confirm"] == 1


def test_reject_invalid_vote_and_coordinate_pair() -> None:
    assert client.post("/traffic/reports/missing/vote", json={"vote": "maybe"}).status_code == 422
    assert client.get("/traffic/reports?lat=-4.3").status_code == 400
