.PHONY: help run push-inference helm-upgrade helm-status helm-uninstall test-local test-gke

PROJECT_ID ?= lily-demo-ml
REGION ?= us-central1

INFERENCE_IMAGE := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/inference-template/inference-template:latest

help:
	@echo "Local Development:"
	@echo "  make run-local        - Run inference API locally"
	@echo "  make test-api         - Test local API endpoints"
	@echo "  make unit-test        - Unit tests for inference API"
	@echo "  make lint             - Run pre-commit on all files"
	@echo ""
	@echo "Deployment:"
	@echo "  make push-inference   - Build and push inference image"
	@echo "  make helm-upgrade     - Deploy/upgrade GKE service"
	@echo "  make test-gke         - Test deployed service"

run-local:
	@echo "Setting up virtual environment..."
	uv venv
	uv pip install -e ".[dev,inference]"
	@echo "Starting inference API locally at http://localhost:8000"
	uv run uvicorn inference.main:app --reload --host 0.0.0.0 --port 8000

test-api:
	@echo "Testing local API endpoints..."
	@sleep 2
	@curl -f http://localhost:8000/health || echo "Health check failed - is API running?"
	@echo ""
	@curl -f -X POST http://localhost:8000/predict \
		-H "Content-Type: application/json" \
		-d '{"f_0":1.5,"f_1":2.3,"f_2":0.8,"f_3":-0.5,"f_4":1.2,"months_since_signup":12,"calendar_month":6,"signup_month":6,"is_first_month":0}' \
		|| echo "Prediction test failed"
	@echo ""
	@echo "API test complete"

unit-test:
	uv run pytest tests/test_inference_api.py -v

lint:
	uv run pre-commit run --all-files

push-inference:
	gcloud auth configure-docker $(REGION)-docker.pkg.dev --quiet
	docker build -f docker/Dockerfile.inference -t $(INFERENCE_IMAGE) .
	docker push $(INFERENCE_IMAGE)

push-inference-cloudbuild:
	gcloud builds submit --config docker/cloudbuild.yaml \
		--substitutions _PROJECT_ID=$(PROJECT_ID),_REGION=$(REGION) . | tee build_output.txt
	# Print Cloud Build console link to the job log for manual inspection
	grep -oE 'https://console.cloud.google.com/cloud-build/builds/[a-z0-9-]+' build_output.txt || true

helm-upgrade:
	gcloud container clusters get-credentials inference-template-cluster \
		--zone=$(REGION) --project=$(PROJECT_ID)
	kubectl delete deployment inference-template --ignore-not-found
	helm upgrade inference-template ./helm --install --wait --timeout=5m

test-gke:
	@SERVICE_IP=$$(kubectl get service inference-template -o jsonpath='{.status.loadBalancer.ingress[0].ip}'); \
	echo "Testing service at $$SERVICE_IP..."; \
	curl -f http://$$SERVICE_IP/health && \
	curl -f -X POST http://$$SERVICE_IP/predict \
		-H "Content-Type: application/json" \
		-d '{"f_0":1.5,"f_1":2.3,"f_2":0.8,"f_3":-0.5,"f_4":1.2,"months_since_signup":12,"calendar_month":6,"signup_month":6,"is_first_month":0}' && \
	echo "All tests passed"
