FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl gnupg2 unixodbc-dev g++ \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft SQL Server repository and install ODBC 18
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000
CMD ["python", "app.py"]