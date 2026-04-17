
ARG PYTHON_VERSION=3.13
# Builder stage: Install dependencies
FROM python:3.13-slim AS builder
WORKDIR /app
# Install curl for uv
RUN apt-get update && apt-get install -y curl
# Install uv
RUN curl -Ls https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"
# Copy project files needed for dependency installation
COPY pyproject.toml uv.lock .python-version ./
RUN uv venv
RUN uv sync
# Runtime stage: Clean image with only runtime dependencies
FROM python:3.13-slim
WORKDIR /app
# Copy Python environment and application from builder
COPY --from=builder /app/.venv /app/.venv
# Copy application code
COPY main.py ./
COPY smoothies ./smoothies
# Set the entrypoint
ENTRYPOINT ["/app/.venv/bin/python", "main.py"]