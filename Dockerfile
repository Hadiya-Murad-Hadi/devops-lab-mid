FROM python:3.11-slim

WORKDIR /app

# The image only needs runtime deps (pytest/httpx are for the Jenkins test stage)
RUN pip install --no-cache-dir "fastapi>=0.110,<1" "uvicorn>=0.27,<1" \
    "numpy>=1.26,<3" "pandas>=2.2,<3" "scikit-learn>=1.4,<2" "joblib>=1.3,<2"

COPY app.py train.py config.json ./
COPY dataset ./dataset
# artifacts/ (model.joblib + metrics.json) are produced by `python train.py`
# in the Jenkins Train stage, so every image ships the freshly retrained model.
COPY artifacts ./artifacts

EXPOSE 8000
HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD python -c "import urllib.request;urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
