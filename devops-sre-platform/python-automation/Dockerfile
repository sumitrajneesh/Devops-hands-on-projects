FROM python:3.10-slim
WORKDIR /app
COPY health_check.py ./
RUN pip install --no-cache-dir requests
CMD ["python", "health_check.py"]