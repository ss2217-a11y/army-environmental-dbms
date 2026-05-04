# Army Environmental Intelligence Dashboard (AEI-DBMS)

## Overview

This project is a full-stack database-driven system designed to manage and analyze environmental intelligence data for military operations. It enables real-time monitoring of hazards, missions, and environmental reports through an interactive dashboard.

## Tech Stack

* Backend: FastAPI (Python)
* Database: MySQL
* Frontend: HTML, CSS, JavaScript

## Features

* 8-entity relational database (Region, Hazard, Mission, Unit, Soldier, etc.)
* Fully normalized schema (up to 3NF)
* REST APIs for data retrieval and insertion
* Real-time dashboard with live data
* Advanced SQL queries (JOINs, subqueries, aggregates)
* Views for simplified reporting
* Triggers for enforcing business rules

## Key Functionalities

* Track environmental hazards and severity levels
* Monitor mission readiness and unit deployment
* Manage soldier and unit information
* Analyze weather and water source data

## How to Run

1. Start MySQL and import database schema
2. Run backend:

   ```bash
   python -m uvicorn backend:app --reload
   ```
3. Open frontend (index.html) in browser

## Future Improvements

* Add authentication system
* Deploy using Docker / cloud
* Enhance analytics with charts

## Author

Sourish Sankar
