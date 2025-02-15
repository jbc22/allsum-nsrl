# Use the official Python image
FROM python:3.13-slim

# Set the working directory
WORKDIR /app

# Copy dependency file and install
COPY webapp/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY ./webapp/ .

# Expose port 5000
EXPOSE 5000

# Run the application
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
