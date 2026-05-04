CREATE DATABASE AEI_DBMS;
USE AEI_DBMS;

CREATE TABLE Region (
    Region_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Terrain_Type VARCHAR(50) NOT NULL,
    Coordinates VARCHAR(100) NOT NULL,
    Country VARCHAR(50) DEFAULT 'India'
);

CREATE TABLE Hazard (
    Hazard_ID   INT PRIMARY KEY AUTO_INCREMENT,
    Type        VARCHAR(50) NOT NULL,
    Severity    VARCHAR(20) NOT NULL,
    Description TEXT        NOT NULL,
    CONSTRAINT chk_severity CHECK (Severity IN ('Low','Medium','High','Critical'))
);

CREATE TABLE Unit (
    Unit_ID       INT PRIMARY KEY AUTO_INCREMENT,
    Unit_Name     VARCHAR(100) NOT NULL UNIQUE,
    Commander     VARCHAR(100) NOT NULL,
    Base_Location VARCHAR(100) NOT NULL,
    Region_ID     INT,
    FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID)
);


CREATE TABLE Environmental_Report (
    Report_ID   INT PRIMARY KEY AUTO_INCREMENT,
    Region_ID   INT NOT NULL,
    Hazard_ID   INT NOT NULL,
    Report_Date DATE NOT NULL,
    Reported_By VARCHAR(100) NOT NULL,
    Status      VARCHAR(30) DEFAULT 'Active',
    FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID),
    FOREIGN KEY (Hazard_ID) REFERENCES Hazard(Hazard_ID)
);


CREATE TABLE Weather_Data (
    Weather_ID    INT PRIMARY KEY AUTO_INCREMENT,
    Region_ID     INT   NOT NULL,
    Temperature   FLOAT NOT NULL,
    Rainfall      FLOAT DEFAULT 0.0,
    Wind_Speed    FLOAT DEFAULT 0.0,
    Recorded_Date DATE  NOT NULL,
    CONSTRAINT chk_wind CHECK (Wind_Speed >= 0),
    FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID)
);


CREATE TABLE Soldier (
    Soldier_ID   INT PRIMARY KEY AUTO_INCREMENT,
    Name         VARCHAR(100) NOT NULL,
    Soldier_Rank VARCHAR(50)  NOT NULL,
    Unit_ID      INT          NOT NULL,
    Date_Joined  DATE         NOT NULL,
    FOREIGN KEY (Unit_ID) REFERENCES Unit(Unit_ID)
);

CREATE TABLE Mission (
    Mission_ID   INT PRIMARY KEY AUTO_INCREMENT,
    Mission_Name VARCHAR(100) NOT NULL UNIQUE,
    Region_ID    INT          NOT NULL,
    Unit_ID      INT          NOT NULL,
    Start_Date   DATE         NOT NULL,
    End_Date     DATE,
    Status       VARCHAR(30)  DEFAULT 'Planned',
    CONSTRAINT chk_status CHECK (Status IN ('Planned','Active','Completed')),
    FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID),
    FOREIGN KEY (Unit_ID)   REFERENCES Unit(Unit_ID)
);

CREATE TABLE Water_Source (
    Source_ID      INT PRIMARY KEY AUTO_INCREMENT,
    Source_Name    VARCHAR(100) NOT NULL,
    Region_ID      INT          NOT NULL,
    Quality_Status VARCHAR(30)  NOT NULL,
    Water_Type     VARCHAR(30)  NOT NULL,
    Last_Tested    DATE         NOT NULL,
    FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID)
);

CREATE TABLE Hazard_Audit_Log (
    Log_ID       INT PRIMARY KEY AUTO_INCREMENT,
    Hazard_ID    INT,
    Old_Severity VARCHAR(20),
    New_Severity VARCHAR(20),
    Change_Time  DATETIME DEFAULT CURRENT_TIMESTAMP,
    Changed_By   VARCHAR(100) DEFAULT 'system'
);

INSERT INTO Region (Name, Terrain_Type, Coordinates, Country) VALUES
('Northern Border Zone',  'Mountain', '34.5N, 72.3E', 'India'),
('Eastern Delta Region',  'Wetland',  '22.5N, 88.3E', 'India'),
('Western Desert Belt',   'Desert',   '25.1N, 70.2E', 'India'),
('Central Plains Sector', 'Plains',   '23.2N, 79.4E', 'India'),
('Southern Coastal Area', 'Coastal',  '8.5N,  76.9E', 'India');

INSERT INTO Hazard (Type, Severity, Description) VALUES
('Chemical',     'High',     'Industrial chemical spill detected near river bank'),
('Biological',   'Critical', 'Unknown pathogen outbreak in northern sector'),
('Natural',      'Medium',   'Flash flood risk due to heavy monsoon rainfall'),
('Radiological', 'Low',      'Minor radioactive trace near decommissioned site'),
('Chemical',     'Medium',   'Pesticide contamination in water table'),
('Natural',      'High',     'Landslide risk zone identified in mountain pass');

INSERT INTO Unit (Unit_Name, Commander, Base_Location, Region_ID) VALUES
('Alpha Battalion', 'Col. Rajesh Kumar',    'Pathankot Base',     1),
('Bravo Regiment',  'Lt. Col. Anil Sharma', 'Kolkata Cantonment', 2),
('Delta Force Unit','Maj. Priya Nair',       'Jaisalmer Camp',     3),
('Echo Corps',      'Brig. Suresh Iyer',    'Nagpur Base',        4),
('Sierra Command',  'Col. Meena Pillai',    'Trivandrum Base',    5);

INSERT INTO Environmental_Report (Region_ID, Hazard_ID, Report_Date, Reported_By, Status) VALUES
(1, 1, '2024-01-15', 'Lt. Arjun Singh',   'Active'),
(1, 2, '2024-02-10', 'Capt. Priya Nair',  'Active'),
(2, 3, '2024-03-05', 'Lt. Ravi Kumar',    'Resolved'),
(3, 5, '2024-04-12', 'Maj. Sita Ram',     'Active'),
(4, 6, '2024-05-20', 'Capt. Anwar Khan',  'Active'),
(5, 4, '2024-06-01', 'Lt. Devansh Patel', 'Resolved');

INSERT INTO Weather_Data (Region_ID, Temperature, Rainfall, Wind_Speed, Recorded_Date) VALUES
(1, -5.2, 0.0,   45.0, '2024-01-15'),
(2, 32.4, 120.5, 18.0, '2024-03-05'),
(3, 42.1, 0.0,   30.0, '2024-04-12'),
(4, 28.3, 65.2,  22.0, '2024-05-20'),
(5, 34.7, 200.0, 25.5, '2024-06-01');

INSERT INTO Soldier (Name, Soldier_Rank, Unit_ID, Date_Joined) VALUES
('Arjun Singh',   'Lieutenant', 1, '2018-07-15'),
('Priya Nair',    'Captain',    1, '2016-08-22'),
('Ravi Kumar',    'Lieutenant', 2, '2019-01-10'),
('Sita Ram',      'Major',      3, '2014-06-05'),
('Anwar Khan',    'Captain',    4, '2017-03-18'),
('Devansh Patel', 'Lieutenant', 5, '2020-09-01');

INSERT INTO Mission (Mission_Name, Region_ID, Unit_ID, Start_Date, End_Date, Status) VALUES
('Operation Clearwater',    1, 1, '2024-01-20', NULL, 'Active'),
('Operation Storm Watch',   2, 2, '2024-03-10', '2024-04-10', 'Completed'),
('Operation Sandstorm',     3, 3, '2024-04-15', NULL, 'Active'),
('Operation Terrain Scout', 4, 4, '2024-05-25', NULL, 'Planned'),
('Operation Coastal Guard', 5, 5, '2024-06-05', NULL, 'Active');

INSERT INTO Water_Source (Source_Name, Region_ID, Quality_Status, Water_Type, Last_Tested) VALUES
('Himalayan Spring A1',   1, 'Contaminated', 'Spring',      '2024-01-14'),
('Delta River Tap',       2, 'Safe',         'River',       '2024-03-04'),
('Desert Well DW-3',      3, 'Questionable', 'Well',        '2024-04-11'),
('Central Reservoir CR-1',4, 'Safe',         'Reservoir',   '2024-05-19'),
('Coastal Groundwater',   5, 'Safe',         'Groundwater', '2024-05-30'); 

CREATE VIEW Active_Threat_Summary AS
SELECT R.Name AS Region_Name, H.Type AS Hazard_Type,
       H.Severity, E.Report_Date, E.Reported_By
FROM Environmental_Report E
JOIN Region R ON E.Region_ID = R.Region_ID
JOIN Hazard H ON E.Hazard_ID = H.Hazard_ID
WHERE E.Status = 'Active';

CREATE VIEW Mission_Readiness AS
SELECT M.Mission_Name, U.Unit_Name, R.Name AS Region,
       WS.Quality_Status, M.Status AS Mission_Status
FROM Mission M
JOIN Unit U ON M.Unit_ID = U.Unit_ID
JOIN Region R ON M.Region_ID = R.Region_ID
LEFT JOIN Water_Source WS ON R.Region_ID = WS.Region_ID;

USE AEI_DBMS;

DELIMITER //

CREATE TRIGGER trg_hazard_severity_upgrade
AFTER UPDATE ON Hazard
FOR EACH ROW
BEGIN
    IF NEW.Severity != OLD.Severity THEN
        INSERT INTO Hazard_Audit_Log (Hazard_ID, Old_Severity, New_Severity)
        VALUES (OLD.Hazard_ID, OLD.Severity, NEW.Severity);
    END IF;
END //

CREATE TRIGGER trg_prevent_active_mission_delete
BEFORE DELETE ON Mission
FOR EACH ROW
BEGIN
    IF OLD.Status = 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete an Active mission. Change status first.';
    END IF;
END //

CREATE TRIGGER trg_set_end_date
BEFORE UPDATE ON Mission
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' AND OLD.Status != 'Completed' THEN
        SET NEW.End_Date = CURDATE();
    END IF;
END //

DELIMITER ;

USE AEI_DBMS;

DELIMITER //

CREATE PROCEDURE sp_list_active_missions()
BEGIN
    DECLARE v_mission_name VARCHAR(100);
    DECLARE v_region_name  VARCHAR(100);
    DECLARE v_status       VARCHAR(30);
    DECLARE done INT DEFAULT 0;
    DECLARE cur_missions CURSOR FOR
        SELECT M.Mission_Name, R.Name, M.Status
        FROM Mission M JOIN Region R ON M.Region_ID = R.Region_ID
        WHERE M.Status = 'Active';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Mission_Output (
        Mission_Name VARCHAR(100), Region VARCHAR(100), Status VARCHAR(30));
    DELETE FROM Mission_Output;

    OPEN cur_missions;
    read_loop: LOOP
        FETCH cur_missions INTO v_mission_name, v_region_name, v_status;
        IF done THEN LEAVE read_loop; END IF;
        INSERT INTO Mission_Output VALUES (v_mission_name, v_region_name, v_status);
    END LOOP;
    CLOSE cur_missions;

    SELECT * FROM Mission_Output;
    DROP TEMPORARY TABLE Mission_Output;
END //

CREATE PROCEDURE sp_check_water_quality()
BEGIN
    DECLARE v_source  VARCHAR(100);
    DECLARE v_region  VARCHAR(100);
    DECLARE v_quality VARCHAR(30);
    DECLARE done INT DEFAULT 0;
    DECLARE cur_water CURSOR FOR
        SELECT WS.Source_Name, R.Name, WS.Quality_Status
        FROM Water_Source WS JOIN Region R ON WS.Region_ID = R.Region_ID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Water_Alerts (Alert_Message VARCHAR(255));
    DELETE FROM Water_Alerts;

    OPEN cur_water;
    read_loop: LOOP
        FETCH cur_water INTO v_source, v_region, v_quality;
        IF done THEN LEAVE read_loop; END IF;
        IF v_quality != 'Safe' THEN
            INSERT INTO Water_Alerts VALUES
                (CONCAT('ALERT: ', v_source, ' in ', v_region, ' is ', v_quality));
        END IF;
    END LOOP;
    CLOSE cur_water;

    SELECT * FROM Water_Alerts;
    DROP TEMPORARY TABLE Water_Alerts;
END //

DELIMITER ;

INSERT INTO Region (Name, Terrain_Type, Coordinates, Country) 
VALUES ('Test Zone', 'Forest', '10.0N, 80.0E', 'India');

INSERT INTO Hazard (Type, Severity, Description) VALUES
('Nuclear', 'Critical', 'Nuclear radiation detected near border outpost');


INSERT INTO Region (Name, Terrain_Type, Coordinates, Country) 
VALUES ('Himalayan Frontier', 'Mountain', '35.0N, 77.5E', 'India');
