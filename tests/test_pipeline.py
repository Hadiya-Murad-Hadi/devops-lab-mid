"""Run by Jenkins AFTER train.py. Checks the trained artifacts and the API."""
import json
from pathlib import Path

import pandas as pd
from fastapi.testclient import TestClient

from app import app

client = TestClient(app)
METRICS = json.loads(Path("artifacts/metrics.json").read_text())
CONFIG = json.loads(Path("config.json").read_text())


def test_artifacts_exist():
    assert Path("artifacts/model.joblib").exists()
    assert Path("artifacts/metrics.json").exists()


def test_training_rows_match_dataset():
    assert METRICS["training_rows"] == len(pd.read_csv("dataset/train.csv"))
    assert METRICS["training_rows"] >= 100


def test_accuracy_is_reasonable():
    assert 0.55 <= METRICS["accuracy"] <= 1.0


def test_student_id_matches_config():
    assert METRICS["student_id"] == CONFIG["student_id"]


def test_metrics_endpoint():
    r = client.get("/metrics")
    assert r.status_code == 200
    body = r.json()
    for key in ("student_id", "accuracy", "training_rows", "model_version", "git_sha"):
        assert key in body
    assert body["training_rows"] == METRICS["training_rows"]


def test_predict_endpoint():
    record = {f: 0.0 for f in CONFIG["features"]}
    r = client.post("/predict", json={"records": [record, record]})
    assert r.status_code == 200
    out = r.json()
    assert len(out["predictions"]) == 2
    assert set(out["predictions"]) <= {0, 1}
