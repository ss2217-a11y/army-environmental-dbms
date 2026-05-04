from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import mysql.connector

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

DB = dict(
    host="localhost",
    port=3306,
    user="root",
    password="1234",
    database="AEI_DBMS",
)

def conn():
    return mysql.connector.connect(**DB)

def q(sql, params=(), fetch=True):
    c = conn()
    cur = c.cursor(dictionary=True)
    try:
        cur.execute(sql, params)
        if fetch:
            return cur.fetchall()
        c.commit()
        return {"affected": cur.rowcount}
    except mysql.connector.Error as e:
        c.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cur.close(); c.close()

@app.get("/")
def root():
    return {"status": "AEI-DBMS API running"}

@app.get("/table/{name}")
def get_table(name: str):
    allowed = {"region","hazard","unit","environmental_report","weather_data","soldier","mission","water_source","hazard_audit_log"}
    if name.lower() not in allowed:
        raise HTTPException(400, "Unknown table")
    return q(f"SELECT * FROM {name}")

@app.get("/view/active_threats")
def active_threats():
    return q("SELECT * FROM Active_Threat_Summary")

@app.get("/view/mission_readiness")
def mission_readiness():
    return q("SELECT * FROM Mission_Readiness")

@app.get("/query/avg_temp")
def avg_temp():
    return q("""SELECT R.Name AS Region, ROUND(AVG(W.Temperature),2) AS Avg_Temp
                FROM Weather_Data W JOIN Region R ON W.Region_ID=R.Region_ID
                GROUP BY R.Name ORDER BY Avg_Temp DESC""")

@app.get("/query/hazard_count")
def hazard_count():
    return q("""SELECT H.Severity, COUNT(E.Report_ID) AS Report_Count
                FROM Hazard H LEFT JOIN Environmental_Report E ON H.Hazard_ID=E.Hazard_ID
                GROUP BY H.Severity ORDER BY Report_Count DESC""")

@app.get("/procedure/active_missions")
def proc_active():
    c = conn()
    cur = c.cursor(dictionary=True)
    try:
        cur.callproc("sp_list_active_missions")
        rows = []
        for r in cur.stored_results():
            rows.extend(r.fetchall())
        return rows
    finally:
        cur.close(); c.close()

@app.get("/procedure/water_alerts")
def proc_water():
    c = conn()
    cur = c.cursor(dictionary=True)
    try:
        cur.callproc("sp_check_water_quality")
        rows = []
        for r in cur.stored_results():
            rows.extend(r.fetchall())
        return rows
    finally:
        cur.close(); c.close()

class RegionIn(BaseModel):
    Name: str
    Terrain_Type: str
    Coordinates: str
    Country: str = "India"

@app.post("/region")
def add_region(r: RegionIn):
    return q("INSERT INTO Region(Name,Terrain_Type,Coordinates,Country) VALUES(%s,%s,%s,%s)",
             (r.Name, r.Terrain_Type, r.Coordinates, r.Country), fetch=False)

class HazardIn(BaseModel):
    Type: str
    Severity: str
    Description: str

@app.post("/hazard")
def add_hazard(h: HazardIn):
    return q("INSERT INTO Hazard(Type,Severity,Description) VALUES(%s,%s,%s)",
             (h.Type, h.Severity, h.Description), fetch=False)

class ReportIn(BaseModel):
    Region_ID: int
    Hazard_ID: int
    Report_Date: str
    Reported_By: str
    Status: str = "Active"

@app.post("/report")
def add_report(r: ReportIn):
    return q("INSERT INTO Environmental_Report(Region_ID,Hazard_ID,Report_Date,Reported_By,Status) VALUES(%s,%s,%s,%s,%s)",
             (r.Region_ID, r.Hazard_ID, r.Report_Date, r.Reported_By, r.Status), fetch=False)

class SoldierIn(BaseModel):
    Name: str
    Soldier_Rank: str
    Unit_ID: int
    Date_Joined: str

@app.post("/soldier")
def add_soldier(s: SoldierIn):
    return q("INSERT INTO Soldier(Name,Soldier_Rank,Unit_ID,Date_Joined) VALUES(%s,%s,%s,%s)",
             (s.Name, s.Soldier_Rank, s.Unit_ID, s.Date_Joined), fetch=False)

class MissionIn(BaseModel):
    Mission_Name: str
    Region_ID: int
    Unit_ID: int
    Start_Date: str
    Status: str = "Planned"

@app.post("/mission")
def add_mission(m: MissionIn):
    return q("INSERT INTO Mission(Mission_Name,Region_ID,Unit_ID,Start_Date,Status) VALUES(%s,%s,%s,%s,%s)",
             (m.Mission_Name, m.Region_ID, m.Unit_ID, m.Start_Date, m.Status), fetch=False)

@app.put("/hazard/{hid}/severity")
def update_severity(hid: int, severity: str):
    return q("UPDATE Hazard SET Severity=%s WHERE Hazard_ID=%s",
             (severity, hid), fetch=False)

@app.put("/mission/{mid}/status")
def update_mission_status(mid: int, status: str):
    return q("UPDATE Mission SET Status=%s WHERE Mission_ID=%s",
             (status, mid), fetch=False)

@app.delete("/region/{rid}")
def del_region(rid: int):
    return q("DELETE FROM Region WHERE Region_ID=%s", (rid,), fetch=False)

@app.delete("/hazard/{hid}")
def del_hazard(hid: int):
    return q("DELETE FROM Hazard WHERE Hazard_ID=%s", (hid,), fetch=False)

@app.delete("/report/{rid}")
def del_report(rid: int):
    return q("DELETE FROM Environmental_Report WHERE Report_ID=%s", (rid,), fetch=False)

@app.delete("/soldier/{sid}")
def del_soldier(sid: int):
    return q("DELETE FROM Soldier WHERE Soldier_ID=%s", (sid,), fetch=False)

@app.delete("/mission/{mid}")
def del_mission(mid: int):
    return q("DELETE FROM Mission WHERE Mission_ID=%s", (mid,), fetch=False)