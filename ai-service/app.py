from typing import List, Optional
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib, os, numpy as np

app = FastAPI(title="Swim Coach AI", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ganti domain produksi nanti
    allow_methods=["*"],
    allow_headers=["*"],
)

# === load models (siapkan file .joblib di folder models/) ===
MODEL_DIR = os.environ.get("MODEL_DIR", "models")
def _load(name):
    path = os.path.join(MODEL_DIR, name)
    if not os.path.exists(path):
        raise FileNotFoundError(f"Model file not found: {path}")
    return joblib.load(path)

# Sesuaikan nama file ini dengan milikmu
clf_fatigue = _load("fatigue.joblib")
clf_stroke  = _load("stroke.joblib")
# scaler opsional (hapus kalau tidak pakai)
scaler_path = os.path.join(MODEL_DIR, "scaler.joblib")
scaler = joblib.load(scaler_path) if os.path.exists(scaler_path) else None

FEATS = [
    "stroke_rate_spm","lap_speed_mps",
    "roll_std","pitch_std","yaw_drift",
    "gyro_y_mean","accel_z_mean"
]

class Features(BaseModel):
    stroke_rate_spm: float
    lap_speed_mps: float
    roll_std: float
    pitch_std: float
    yaw_drift: float
    gyro_y_mean: float
    accel_z_mean: float

@app.get("/health")
def health():
    return {"status":"ok","models":{"fatigue":True,"stroke":True,"scaler":bool(scaler)}}

def _prep_x(f: Features):
    x = np.array([[getattr(f, k) for k in FEATS]], dtype=float)
    if scaler is not None:
        x = scaler.transform(x)
    return x

@app.post("/predict/fatigue")
def predict_fatigue(f: Features):
    x = _prep_x(f)
    prob = float(clf_fatigue.predict_proba(x)[0,1])  # 0..1
    label = "Stabil" if prob < 0.3 else ("Waspada" if prob < 0.6 else "Tinggi")
    return {"fatigue_level": prob, "note": label}

@app.post("/predict/stroke")
def predict_stroke(f: Features):
    x = _prep_x(f)
    label = clf_stroke.predict(x)[0]
    return {"stroke_type": str(label)}

@app.post("/predict/both")
def predict_both(f: Features):
    x = _prep_x(f)
    prob = float(clf_fatigue.predict_proba(x)[0,1])
    label = clf_stroke.predict(x)[0]
    grade = "Stabil" if prob < 0.3 else ("Waspada" if prob < 0.6 else "Tinggi")
    return {
        "fatigue_level": prob,
        "fatigue_note": grade,
        "stroke_type": str(label)
    }
