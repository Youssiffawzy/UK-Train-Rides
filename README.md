# UK-Train-Rides
Data analysis project for Data Vanguard team under the supervision of Digital Egypt Pioneers Initiative
![Data Vanguard - Copy](https://github.com/user-attachments/assets/ed76c248-90bb-4f41-b564-ae58607e6052)
# Team members
- Youssif Sayed Fawzy
- Omar Mohamed Abd Eldayem
- Modather Osama Mohamed
- Abdelrahman Ahmed Mahmoud
- Samy Nasser Mohamed Aly
# Project Overview
The UK Train Rides Data Analysis project aims to build a data model, clean and preprocess railway ticket transaction data, analyze trends, forecast future demand, and create a visualization dashboard to support decision-making. The project will leverage SQL, Python (pandas, Matplotlib, sci-kit-learn), and PowerBI for data processing, analysis, and visualization.
# Project Objectives
•	Develop a structured and cleaned dataset for analysis.
•	Identify key trends and insights from the given railway dataset.
•	Generate forecasting models to predict future train rides, revenue, and ticket class demand.
•	Build an interactive visualization dashboard to present insights effectively.
•	Prepare a final report summarizing findings and recommendations.
# Project Scope
•	Data Preprocessing: Clean and preprocess the dataset to ensure consistency and accuracy.
•	Analysis Questions Phase: Identify meaningful data analysis questions for business decision-makers.
•	Forecasting Phase: Predict future train rides, revenue trends, and ticket class demand.
•	Visualization Dashboard & Reporting: Develop a PowerBi dashboard and compile a final report.
# Project Plan
The project will be executed over a period of 7 weeks, starting from 22/02/2025 and concluding on 11/04/2025.
Timeline & Milestones
- Week 1 (22/02 - 28/02): Data Preprocessing & Model Building:
o	Tasks: Clean and preprocess data using SQL and Python.
o	Deliverables: Cleaned dataset and preprocessing notebook.
- Week 2 (01/03 - 07/03): Analysis Questions Phase:
o	Tasks: Identify key analysis questions and insights.
o	Deliverables: Documented set of analysis questions
- Week 3 (08/03 - 14/03): Forecasting Phase:
o	Tasks: Predict number of rides, revenue, and ticket demand.
o	Deliverables: Forecasting results and visualization plots.
- Week 4 (15/03 - 21/03): Visualization Dashboard & Report Preparation:
o	Tasks: Build a PowerBI dashboard and prepare a report.
o	Deliverables: Completed dashboard and draft report.
- Week 5 (22/03 - 28/03): Review and Refinement:
o	Tasks: Enhance dashboard and refine analysis based on feedback.
o	Deliverables: Improved dashboard and report.
- Week 6 (29/03 - 04/04): Final Testing & Documentation:
o	Tasks: Conduct validation testing and finalize documentation.
o	Deliverables: Fully tested dashboard and final report.
-	Week 7 (05/04 - 11/04): Presentation & Deployment:
o	Tasks: Prepare the final presentation and submit all deliverables.
o	Deliverables: Presentation slides and project submission.
![Gantt chart](https://github.com/user-attachments/assets/15dd0bbd-703e-428c-8c5d-12c8354e43b1)
# Resource Allocation & Task Assignments
- Project Lead: Youssif Sayed Fawzy - Oversees execution, tracks progress, and manages deliverables.
- Data Analyst: Omar Mohamed Abd Eldayem - Focuses on data preprocessing and cleaning.
- Data Analyst: Modather Osama Mohamed - Works on defining analysis questions and insights.
- Data Analyst: Abdelrahman Ahmed Mahmoud - Develops forecasting models.
- Data Analyst: Samy Nasser Mohamed Aly - Builds visualization dashboard and report.
# Stakeholder Analysis
Key Stakeholders & Their Needs
- Project Team (Data Analysts):
o	Need access to clean, structured data.
o	Require tools (SQL, Python, PowerBI) for data analysis and visualization.
o	Need clear objectives and task assignments.
-	Railway Operators & Management:
o	Require insights on ticket sales trends, delays, and revenue forecasts.
o	Need forecasts for future demand to optimize resource allocation.
o	Benefit from a dashboard for easy monitoring of key metrics.
-	Passengers & Customers:
o	Need improved services based on data-driven insights.
o	Benefit from demand forecasting to anticipate ticket availability.
-	Investors & Stakeholders in Public Transport:
o	Require financial projections and insights into revenue growth opportunities.
o	Need analysis on potential investments in infrastructure and services.
# Entity-Relationship Diagram (ERD)
The following entities are identified for database design:
-	Passengers (Passenger_ID, Name, Age, Gender)
-	Tickets (Ticket_ID, Passenger_ID, Train_ID, Class, Price, Purchase_Date)
-	Trains (Train_ID, Train_Name, Route_ID, Capacity)
-	Routes (Route_ID, Start_Station, End_Station, Distance, Duration)
-	Stations (Station_ID, Station_Name, Location)
-	Transactions (Transaction_ID, Ticket_ID, Payment_Method, Transaction_Date, Amount)
# Normalization Considerations
-	The schema follows 3rd Normal Form (3NF) to eliminate redundancy.
-	Passenger details are stored separately from tickets to maintain integrity.
-	Routes and Stations are separate entities to facilitate route expansion.
-	Transactions are linked to tickets to track payments independently.
  
  ![ERD Diagram](https://github.com/user-attachments/assets/bf113da1-c2b1-4ed0-a75c-2455c3f2bb83)


