# Use Python 3.11 slim image pinned to the stable Debian (bookworm) track.
# The unpinned python:3.11-slim tag tracks Debian testing (trixie), which
# carries many vulnerabilities with no fix available; Snyk gating fails there.
FROM python:3.11-slim-bookworm

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py \
    FLASK_ENV=production \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Upgrade existing system packages for the latest security fixes,
# install build dependencies, and cleanup in one layer
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create a non-root user
RUN useradd -m myuser

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
# Upgrade setuptools/wheel to pull in patched versions of their vendored
# packages (fixes CVE-2026-23949 and CVE-2026-24049 flagged by Trivy).
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir pytest-cov coverage \
    && pip install --no-cache-dir --upgrade setuptools wheel

# Copy the application with proper permissions
COPY --chown=myuser:myuser . .

# Run tests (commented out temporarily)
# RUN python -m pytest

# Switch to non-root user
USER myuser

# Expose the port the app runs on
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Command to run the application
CMD ["flask", "run", "--host=0.0.0.0", "--port=3000"] 