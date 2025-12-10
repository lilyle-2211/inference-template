"""Utility functions for model loading."""
import logging
from pathlib import Path
import yaml
from inference.schemas import Config as AppConfig
import xgboost as xgb
from google.cloud import storage

logger = logging.getLogger(__name__)

def load_config(config_path: str = "inference/config.yaml"):
    """Load YAML config file."""
    with open(config_path, "r") as f:
        data = yaml.safe_load(f) or {}
    return AppConfig(**(data or {}))

config = load_config()

BUCKET_NAME = config.gcs.bucket_name
MODEL_PATH = config.gcs.model_path


def download_model_from_gcs(
    bucket_name: str = BUCKET_NAME, 
    model_path: str = MODEL_PATH, 
    local_dir: str = "model"
) -> str:
    """
    Download model from GCS.

    Args:
        bucket_name: GCS bucket name
        model_path: Path to model in GCS bucket
        local_dir: Local directory to save model

    Returns:
        Path to downloaded model directory
    """
    logger.info(f"Downloading model from gs://{bucket_name}/{model_path}")

    client = storage.Client()
    bucket = client.bucket(bucket_name)

    # Create local directory
    Path(local_dir).mkdir(exist_ok=True)

    # Download all files in the model path
    blobs = bucket.list_blobs(prefix=model_path)
    for blob in blobs:
        if not blob.name.endswith("/"):
            local_file = Path(local_dir) / Path(blob.name).relative_to(model_path)
            local_file.parent.mkdir(parents=True, exist_ok=True)
            blob.download_to_filename(str(local_file))
            logger.info(f"Downloaded {blob.name}")

    logger.info(f"Model downloaded to {local_dir}")
    return local_dir


def load_model(model_dir: str):
    """
    Load XGBoost model from local directory.

    Args:
        model_dir: Local directory containing the model

    Returns:
        Loaded XGBoost model
    """
    model_path = Path(model_dir) / "model.json"

    if not model_path.exists():
        raise FileNotFoundError(f"Model file not found: {model_path}")

    model = xgb.Booster()
    model.load_model(str(model_path))

    logger.info(f"Model loaded from {model_path}")
    return model



