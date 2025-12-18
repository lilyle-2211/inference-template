"""Unit tests for WebSocket endpoint using FastAPI TestClient."""
import json
import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def client():
    """Create test client."""
    from inference.main import app
    return TestClient(app)


def test_websocket_accepts_connection(client):
    """Test that WebSocket endpoint accepts connections."""
    with client.websocket_connect("/ws/predict") as websocket:
        # Connection successful if no exception raised
        assert websocket is not None


def test_websocket_validates_json_input(client):
    """Test that WebSocket validates JSON input."""
    with client.websocket_connect("/ws/predict") as websocket:
        # Send invalid JSON
        websocket.send_text("invalid json")
        
        # Should receive error response
        response = websocket.receive_json()
        assert response["status"] == "error"
        assert "Invalid JSON format" in response["error"]


def test_websocket_validates_prediction_input(client):
    """Test that WebSocket validates prediction input schema."""
    with client.websocket_connect("/ws/predict") as websocket:
        # Send valid JSON but missing required fields
        invalid_data = {"f_0": 1.5}  # Missing other required fields
        websocket.send_text(json.dumps(invalid_data))
        
        # Should receive validation error
        response = websocket.receive_json()
        assert response["status"] == "error"


def test_websocket_accepts_valid_input(client):
    """Test that WebSocket accepts valid prediction input."""
    with client.websocket_connect("/ws/predict") as websocket:
        # Send valid prediction data
        valid_data = {
            "f_0": 1.5,
            "f_1": 2.3,
            "f_2": 0.8,
            "f_3": -0.5,
            "f_4": 1.2,
            "months_since_signup": 12,
            "calendar_month": 6,
            "signup_month": 6,
            "is_first_month": 0
        }
        
        websocket.send_text(json.dumps(valid_data))
        
        # Should receive response (success or model not loaded)
        response = websocket.receive_json()
        assert "status" in response
        assert response["status"] in ["success", "error"]
        
        # If model not loaded, should get appropriate error
        if response["status"] == "error":
            assert "Model not loaded" in response["error"]
        else:
            # If successful, should have prediction fields
            assert "prob_probability" in response
            assert "binary_prediction" in response
            assert "model_version" in response


def test_websocket_handles_multiple_requests(client):
    """Test that WebSocket can handle multiple prediction requests."""
    with client.websocket_connect("/ws/predict") as websocket:
        valid_data = {
            "f_0": 1.5,
            "f_1": 2.3,
            "f_2": 0.8,
            "f_3": -0.5,
            "f_4": 1.2,
            "months_since_signup": 12,
            "calendar_month": 6,
            "signup_month": 6,
            "is_first_month": 0
        }
        
        # Send first request
        websocket.send_text(json.dumps(valid_data))
        response1 = websocket.receive_json()
        assert "status" in response1
        
        # Send second request with different data
        valid_data["f_0"] = 2.0
        websocket.send_text(json.dumps(valid_data))
        response2 = websocket.receive_json()
        assert "status" in response2
        
        # Both should have same status (both success or both error due to model)
        assert response1["status"] == response2["status"]