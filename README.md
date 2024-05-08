# pacbook-elt Project

## Overview

Pacbook-elt is a data engineering project aimed at transferring data from a source database to a data warehouse using various technologies including Docker, dbt, Python, Luigi, PostgreSQL, and Sentry. The project focuses on creating a robust and scalable data pipeline for ETL (Extract, Transform, Load) processes.

ERD of Pacbook Source
![alt text](https://github.com/ihdarsyd/pacbook-etl/blob/main/image/pacbook-src.png?raw=true)

ERD of Pacbook Data Warehouse
![alt text](https://github.com/ihdarsyd/pacbook-etl/blob/main/image/pacbook-dwh-1.png?raw=true)

## Technologies Used
- Docker
- dbt
- Python
- Luigi
- PostgreSQL
- Sentry


## Installation and Setup

To set up the pacbook-elt project, follow these steps:

1. Clone the project repository from GitHub.
  ```
  # Clone
  git clone https://github.com/ihdarsyd/pacbook-etl.git
  ```
3. Install Docker and Docker Compose on your system.
4. Configure the environment variables and settings required for connecting to the source database and data warehouse.
  ```
  .env
  ```
6. Build and run the Docker containers using Docker Compose.
    ```
    docker-compose up -d
    ```
9. Run the Luigi scheduler to execute the ETL pipeline tasks.
  ```
  python elt_pipeline.py 
  ```

