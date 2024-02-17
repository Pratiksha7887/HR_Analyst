Create database hr_analytic; 
select * from hr_1;
select * from hr_2;

-- Count of Employees
select count(EmployeeCount) as "Employee Count" from hr_1;

-- Count of YES & NO attrition

select count(Attrition) from hr_1 where Attrition="Yes";
select count(Attrition) from hr_1 where Attrition="No";

SELECT
  COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS "Attrition Yes",
  COUNT(CASE WHEN Attrition = 'No' THEN 1 END) AS "Attrition No"
FROM hr_1;

SELECT Attrition, COUNT(Attrition) AS AttritionCount
FROM hr_1
WHERE Attrition IN ('Yes', 'No')
GROUP BY Attrition;

-- Average Hourly rate, Age, Job satisfaction & Performence rating
select avg(HourlyRate) as "Avg. Hourly Rate" from hr_1;
select avg(Age)"Avg. Age"from hr_1;
select format(avg(JobSatisfaction),2)"Avg. Job Satisfaction"from hr_1;
select avg(PerformanceRating)"Avg Performance Rating"from hr_2;

SELECT
  FORMAT(AVG(hr1.HourlyRate),2) AS "Avg. Hourly Rate",
  FORMAT(AVG(hr1.Age),2) AS "Avg. Age",
  FORMAT(AVG(hr1.JobSatisfaction), 2) AS "Avg. Job Satisfaction",
  FORMAT(AVG(hr2.PerformanceRating),2) AS "Avg Performance Rating"
FROM
  hr_1 hr1
JOIN
  hr_2 hr2 ON hr1.EmployeeNumber = hr2.EmployeeNumber;

-- Average Distance from home, MonthlyIncome & PercentSalaryHike
select concat(avg(DistanceFromHome)," " "Km") as "Average Distance from home" from hr_1;
select concat(avg(MonthlyIncome)," " "₹") as "Avg salary"from hr_2;
select concat(avg(PercentSalaryHike)," " "%") as "Avg % SALARY Hike"from hr_2;

SELECT
    CONCAT(FORMAT(AVG(hr1.distancefromhome), 2), ' Km') AS 'Avg Distance From Home',
    CONCAT(FORMAT(AVG(hr2.MonthlyIncome), 2), ' ₹') AS 'Avg Salary in ₹',
    CONCAT(FORMAT(AVG(hr2.PercentSalaryHike), 2), ' %') AS 'Avg % Salary Hike'
FROM
    hr_1 hr1
JOIN
    hr_2 hr2 ON hr1.EmployeeNumber = hr2.EmployeeNumber;

-- Q.1 Average Attrition rate for all Departments

SELECT
    `Department`, Concat(format(AVG(`Attrition` = 'Yes') * 100,2),'%') AS `Attrition_Percentage`
FROM
    `hr_1`
GROUP BY
    `Department`;

CREATE
ALGORITHM = UNDEFINED 
DEFINER = `root`@`localhost` 
SQL SECURITY DEFINER
VIEW `kpi_1` AS
SELECT `a`.`Department` AS `Department`,CONCAT(FORMAT((AVG(`a`.`Attrition_Y`) * 100),2),'%') AS `Attrition_Rate`
FROM
(SELECT `hr_1`.`Department` AS `Department`,`hr_1`.`Attrition` AS `Attrition`,
(CASE WHEN (`hr_1`.`Attrition` = 'Yes') THEN 1
ELSE 0 END) AS `Attrition_Y`
FROM `hr_1`) `a`
GROUP BY `a`.`Department`;

select * from kpi_1;

-- Q.2 Average Hourly rate of Male Research Scientist

CREATE 
ALGORITHM = UNDEFINED 
DEFINER = `root`@`localhost` 
SQL SECURITY DEFINER
VIEW `kpi_2` AS
SELECT AVG(`hr_1`.`HourlyRate`) AS `Average Hourly Rate`,`hr_1`.`Gender` AS `Gender`,`hr_1`.`JobRole` AS `JobRole`
FROM `hr_1`
WHERE((`hr_1`.`JobRole` = 'Research Scientist')
AND (`hr_1`.`Gender` = 'Male'))
GROUP BY `hr_1`.`Gender` , `hr_1`.`JobRole`;

select * from kpi_2;

SELECT AVG(`hr_1`.`HourlyRate`) AS `AverageHourlyRate`,`hr_1`.`Gender` AS `Gender`,`hr_1`.`JobRole` AS `JobRole`
FROM `hr_1`
WHERE((`hr_1`.`JobRole` = 'Research Scientist')
AND (`hr_1`.`Gender` = 'Male'))
GROUP BY `hr_1`.`Gender` , `hr_1`.`JobRole`;

alter table hr_2 rename column  `Employee ID` to `employeenumber`;

-- Q.3 Attrition rate Vs Monthly income stats
CREATE 
ALGORITHM = UNDEFINED 
DEFINER = `root`@`localhost` 
SQL SECURITY DEFINER
VIEW `kpi_3` AS
SELECT `a`.`Department` AS `Department`,CONCAT(FORMAT((AVG(`a`.`Attrition_Rate`) * 100),2),'%') AS `Average_Attrition`,
FORMAT(AVG(`b`.`MonthlyIncome`), 2) AS `Average_Monthly_Income`
FROM
((SELECT `hr_1`.`Department` AS `Department`,`hr_1`.`Attrition` AS `Attrition`,`hr_1`.`EmployeeNumber` AS `EmployeeNumber`,
(CASE WHEN (`hr_1`.`Attrition` = 'Yes') THEN 1 ELSE 0 END) AS `Attrition_Rate`
FROM `hr_1`) `a` INNER JOIN `hr_2` `b` ON ((`b`.`employeenumber` = `a`.`EmployeeNumber`)))
GROUP BY `a`.`Department`;

select * from kpi_3;

-- Q.4 Average working years for each Department

CREATE 
ALGORITHM = UNDEFINED 
DEFINER = `root`@`localhost` 
SQL SECURITY DEFINER
VIEW `kpi_4` AS
SELECT `a`.`Department` AS `Department`,FORMAT(AVG(`b`.`TotalWorkingYears`), 1) AS `Average_Working_Year`
FROM (`hr_1` `a` JOIN `hr_2` `b` ON ((`b`.`employeenumber` = `a`.`EmployeeNumber`)))
GROUP BY `a`.`Department`;

select * from kpi_4;

-- Q.5 Job Role Vs Work life balance

CREATE 
ALGORITHM = UNDEFINED 
DEFINER = `root`@`localhost` 
SQL SECURITY DEFINER
VIEW `kpi_5` AS
SELECT `a`.`JobRole` AS `JobRole`,
SUM((CASE WHEN (`b`.`PerformanceRating` = 1) THEN 1 ELSE 0 END)) AS `1st_Rating_Total`,
SUM((CASE WHEN (`b`.`PerformanceRating` = 2) THEN 1 ELSE 0 END)) AS `2nd_Rating_Total`,
SUM((CASE WHEN (`b`.`PerformanceRating` = 3) THEN 1 ELSE 0 END)) AS `3rd_Rating_Total`,
SUM((CASE WHEN (`b`.`PerformanceRating` = 4) THEN 1 ELSE 0 END)) AS `4th_Rating_Total`,
COUNT(`b`.`PerformanceRating`) AS `Total_Employee`,
FORMAT(AVG(`b`.`WorkLifeBalance`), 2) AS `Average_WorkLifeBalance_Rating`
FROM (`hr_1` `a` JOIN `hr_2` `b` ON ((`b`.`employeenumber` = `a`.`EmployeeNumber`)))
GROUP BY `a`.`Job Role`;
    
select * from kpi_5;
    
    -- Q.6 Attrition rate Vs Year since last promotion relation

CREATE 
ALGORITHM = UNDEFINED 
DEFINER = `root`@`localhost` 
SQL SECURITY DEFINER
VIEW `kpi_6` AS
SELECT `a`.`JobRole` AS `JobRole`,CONCAT(FORMAT((AVG(`a`.`Attrition_Rate`) * 100),2),'%') AS `Average_Attrition_Rate`,
FORMAT(AVG(`b`.`YearsSinceLastPromotion`), 2) AS `Average_YearsSinceLastPromotion`
FROM
((SELECT `hr_1`.`JobRole` AS `JobRole`,`hr_1`.`Attrition` AS `Attrition`,`hr_1`.`EmployeeNumber` AS `EmployeeNumber`,
(CASE WHEN (`hr_1`.`Attrition` = 'Yes') THEN 1 ELSE 0 END) AS `Attrition_Rate`
FROM `hr_1`) `a` JOIN `hr_2` `b` ON ((`b`.`employeenumber` = `a`.`EmployeeNumber`)))
GROUP BY `a`.`JobRole`;

select * from kpi_6;
