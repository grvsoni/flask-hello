# Flask Counter Application

A simple Flask application that displays a visit counter and current UTC time. The application features a modern, responsive UI that works across all device sizes.

## Features

- Visit counter that tracks page views
- Real-time UTC clock
- Responsive design for mobile, tablet, and desktop
- Dark mode support
- Health check endpoint
- Docker support

## Running Locally

### Prerequisites

- Python 3.11 or higher
- pip (Python package manager)

### Local Setup

1. Clone the repository:
```bash
git clone <your-repo-url>
cd flask-hello
```

2. Create and activate a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run the application:
```bash
flask run --port=3000
```

The application will be available at `http://localhost:3000`

## Docker Support

### Running with Docker (Local Build)

1. Build the image:
```bash
docker build -t flask-counter .
```

2. Run the container:
```bash
docker run -d -p 3000:3000 --name flask-app flask-counter
```

### Using Pre-built Image from Docker Hub

You can directly pull and run the application from Docker Hub:

```bash
# Pull the latest version
docker pull grvsoni/flask-counter:latest

# Or pull a specific version (e.g., v1.0.0)
docker pull grvsoni/flask-counter:v1.0.0

# Run the container
docker run -d -p 3000:3000 --name flask-app grvsoni/flask-counter
```

The application will be available at `http://localhost:3000`

### Docker Container Management

```bash
# Stop the container
docker stop flask-app

# Start an existing container
docker start flask-app

# Remove the container
docker rm -f flask-app

# View logs
docker logs -f flask-app
```

## Development

### Running Tests

```bash
# Install test dependencies
pip install -r requirements.txt

# Run tests
python -m pytest -v
```

### Available Versions

The application is versioned using semantic versioning. Available versions on Docker Hub:
- Latest: `grvsoni/flask-counter:latest`
- v1.0.0: `grvsoni/flask-counter:v1.0.0`

## Health Check

The application includes a built-in health check that monitors:
- Application availability
- Response time
- Basic functionality

Docker will automatically monitor the health of the container.

## Environment Variables

The application supports the following environment variables:
- `FLASK_ENV`: Set to 'production' by default
- `FLASK_APP`: Set to 'app.py' by default

## Contributing

1. Fork the repository
2. Create your feature branch
3. Run tests before submitting a PR
4. Submit a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.