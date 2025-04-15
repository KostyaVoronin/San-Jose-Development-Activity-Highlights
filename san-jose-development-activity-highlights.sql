-- PIPELINE SUMMARY
-- Getting development project counts grouped by the development type and project status.

SELECT
  type,
  status,
  count(*) AS projects
FROM
  pipeline_basic
GROUP BY
  type, status
ORDER BY
  type, status ASC
  
Result:
+-----+-------------+--------------------+----------+
| Row | Type        | Status             | Projects |
+-----+-------------+--------------------+----------+
| 1   | Commercial  | Approved           | 23       |
+-----+-------------+--------------------+----------+
| 2   | Commercial  | Completed          | 4        |
+-----+-------------+--------------------+----------+
| 3   | Commercial  | Pending            | 3        |
+-----+-------------+--------------------+----------+
| 4   | Commercial  | Under Construction | 6        |
+-----+-------------+--------------------+----------+
| 5   | Industrial  | Approved           | 20       |
+-----+-------------+--------------------+----------+
| 6   | Industrial  | Completed          | 4        |
+-----+-------------+--------------------+----------+
| 7   | Industrial  | Pending            | 8        |
+-----+-------------+--------------------+----------+
| 8   | Industrial  | Under Construction | 14       |
+-----+-------------+--------------------+----------+
| 9   | Mixed-use   | Approved           | 7        |
+-----+-------------+--------------------+----------+
| 10  | Mixed-use   | Pending            | 7        |
+-----+-------------+--------------------+----------+
| 11  | Mixed-use   | Under Construction | 1        |
+-----+-------------+--------------------+----------+
| 12  | Residential | Approved           | 40       |
+-----+-------------+--------------------+----------+
| 13  | Residential | Completed          | 9        |
+-----+-------------+--------------------+----------+
| 14  | Residential | Pending            | 27       |
+-----+-------------+--------------------+----------+
| 15  | Residential | Under Construction | 27       |
+-----+-------------+--------------------+----------+



-- DISTRICT-LEVEL DATA
-- Joining two table ('pipeline_basic' and 'pipeline_extended' to create a summary of the development activity in each City Council District.
-- Use the data to create a parallel coordinates plot to compare new residential unit counts and non-residential square footage in each district and levels of the development acitivity in each district.

SELECT
  pe.City_Council_District AS Council_District,
  SUM(pb.residential_units) AS Residential_Units,
  SUM(pb.non_residential_area) AS Non_Residential_Square_Footage,
  SUM(pb.hotel_rooms) AS Hotel_Rooms,
  SUM(pb.residential_care) AS Residential_Care_Units,
FROM
  pipeline_extended pe
    JOIN
      pipeline_basic pb
        ON pb.file_number = pe.File_Number
GROUP BY
  pe.City_Council_District
ORDER BY
  pe.City_Council_District ASC
  
Result:
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| Row | Council_District | Residential_Units | Non_Residential_Square_Footage | Hotel_Rooms | Residential_Care_Units |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 1   | 1                | 3613              | 2658764                        | 574         | null                   |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 2   | 2                | 1297              | 1274411                        | 302         | null                   |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 3   | 3                | 11523             | 16089603                       | 897         | 210                    |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 4   | 4                | 1863              | 5153354                        | 400         | null                   |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 5   | 5                | 915               | 245305                         | null        | null                   |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 6   | 6                | 11881             | 14388170                       | 1296        | 273                    |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 7   | 7                | 2176              | 755771                         | 81          | null                   |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 8   | 8                | 250               | 91714                          | null        | null                   |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 9   | 9                | 881               | 570010                         | 229         | 195                    |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+
| 10  | 10               | null              | 938577                         | null        | null                   |
+-----+------------------+-------------------+--------------------------------+-------------+------------------------+



-- AVERAGE TIME TO APPROVAL
-- Using the 'Filing Date' and 'Approval Date' fields in the 'pipeline_basic' table to estimate an average approval duration for each development time (in months);
-- Compare the calculated averages to minimum and maximum durations in each category.

SELECT
  type AS Development_Type,
  ROUND(MIN(EXTRACT(day FROM (approval_date - filing_date))) / 30) AS Minimum_Approval_Time,
  ROUND((AVG(EXTRACT(day FROM (approval_date - filing_date)))) / 30) AS Average_Approval_Time,
  ROUND(MAX(EXTRACT(day FROM (approval_date - filing_date))) / 30) AS Maximum_Approval_Time
FROM
  `kostyaio.sjpipeline.pipeline_basic`
WHERE
  -- Excluding the record with erroneous dates result in a negative project duration
  EXTRACT(day FROM (approval_date - filing_date)) > 0
GROUP BY
  type
ORDER BY
  ROUND(AVG(EXTRACT(day FROM (approval_date - filing_date)))) ASC
  
Result:
+-----+------------------+-----------------------+-----------------------+-----------------------+
| Row | Development_Type | Minimum_Approval_Time | Average_Approval_Time | Maximum_Approval_Time |
+-----+------------------+-----------------------+-----------------------+-----------------------+
| 1   | Residential      | 2.0                   | 13.0                  | 45.0                  |
+-----+------------------+-----------------------+-----------------------+-----------------------+
| 2   | Mixed-use        | 5.0                   | 13.0                  | 22.0                  |
+-----+------------------+-----------------------+-----------------------+-----------------------+
| 3   | Industrial       | 3.0                   | 14.0                  | 57.0                  |
+-----+------------------+-----------------------+-----------------------+-----------------------+
| 4   | Commercial       | 1.0                   | 18.0                  | 78.0                  |
+-----+------------------+-----------------------+-----------------------+-----------------------+



-- DEVELOPMENTS SUMMARY BY TYPE
-- Using CASE statements to get development projects counts in each City Council district grouped by the type of development project.

SELECT
  pe.City_Council_District,
  COUNT(CASE WHEN pb.type = "Residential" then 1 ELSE NULL END) as Residential,
  COUNT(CASE WHEN pb.type = "Commercial" then 1 ELSE NULL END) as Commercial,
  COUNT(CASE WHEN pb.type = "Industrial" then 1 ELSE NULL END) as Industrial,
  COUNT(CASE WHEN pb.type = "Mixed-use" then 1 ELSE NULL END) as Mixed_Use,
  COUNT(*) as Total
FROM `pipeline_basic` pb
JOIN  `pipeline_extended` pe
ON pb.file_number = pe.File_Number
GROUP BY
  pe.City_Council_District
ORDER BY
  pe.City_Council_District
  
Result:
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| Row | City_Council_District | Residential | Commercial | Industrial | Mixed_Use | Total |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 1   | 1                     | 12          | 6          | 4          | 3         | 25    |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 2   | 2                     | 5           | 2          | 5          | 0         | 12    |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 3   | 3                     | 39          | 8          | 14         | 4         | 65    |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 4   | 4                     | 1           | 5          | 9          | 1         | 16    |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 5   | 5                     | 5           | 1          | 1          | 2         | 9     |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 6   | 6                     | 31          | 9          | 6          | 4         | 50    |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 7   | 7                     | 5           | 3          | 4          | 0         | 12    |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 8   | 8                     | 1           | 1          | 0          | 0         | 2     |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 9   | 9                     | 4           | 1          | 0          | 1         | 6     |
+-----+-----------------------+-------------+------------+------------+-----------+-------+
| 10  | 10                    | 0           | 0          | 3          | 0         | 3     |
+-----+-----------------------+-------------+------------+------------+-----------+-------+



-- PLANNING APPROVALS BY YEAR
-- Extracting years from the 'approval_date' feature (DATE type) to summarize project approval data between 2016 and 2021.

SELECT
  EXTRACT(year FROM (approval_date)) AS Approval_Year,
  COUNT(CASE WHEN type = "Residential" then 1 ELSE NULL END) as Residential,
  COUNT(CASE WHEN type = "Commercial" then 1 ELSE NULL END) as Commercial,
  COUNT(CASE WHEN type = "Industrial" then 1 ELSE NULL END) as Industrial,
  COUNT(CASE WHEN type = "Mixed-use" then 1 ELSE NULL END) as Mixed_Use
FROM
  pipeline_basic
WHERE
  EXTRACT(year FROM (approval_date)) >= 2016 AND EXTRACT(year FROM (approval_date)) < 2022 AND approval_date IS NOT NULL
GROUP BY
  EXTRACT(year FROM (approval_date))
  
Result:
+---------------+-------------+------------+------------+-----------+
| Approval_Date | Residential | Commercial | Industrial | Mixed_Use |
+---------------+-------------+------------+------------+-----------+
| 2016          | 11          | 3          | 3          | 1         |
+---------------+-------------+------------+------------+-----------+
| 2017          | 7           | 3          | 5          | 1         |
+---------------+-------------+------------+------------+-----------+
| 2018          | 3           | 4          | 5          | 0         |
+---------------+-------------+------------+------------+-----------+
| 2019          | 9           | 9          | 8          | 4         |
+---------------+-------------+------------+------------+-----------+
| 2020          | 15          | 5          | 8          | 0         |
+---------------+-------------+------------+------------+-----------+
| 2021          | 10          | 4          | 6          | 1         |
+---------------+-------------+------------+------------+-----------+



-- WALK SCORE BY PROJECT TYPE
-- The 'pipeline_extended' table includes the 'Walk Score' column with a score and description of the score for each development project in the Planning
-- Deparment's Major Development Activity dataset. This query calculate the average Walk Score for each development type in the report.

SELECT
  pb.type AS Project_Type,
  ROUND(AVG(pe.Walk_Score)) AS Walk_Score
FROM
  pipeline_basic pb
JOIN
  pipeline_extended pe
ON
  pb.file_number = pe.file_number
GROUP BY
  pb.type
ORDER BY
  ROUND(AVG(pe.Walk_Score)) DESC

Result:
+--------------+------------+
| Project_Type | Walk_Score |
+--------------+------------+
| Mixed-use    | 80.0       |
+--------------+------------+
| Residential  | 77.0       |
+--------------+------------+
| Commercial   | 63.0       |
+--------------+------------+
| Industrial   | 56.0       |
+--------------+------------+



-- MAJOR RESIDENTIAL PROJECTS
-- A list of the biggest residential projects in each district with unit counts and share of the overall pipelined units in each district.

SELECT
  *
FROM (
  SELECT
    pe.City_Council_District,
    ROW_NUMBER() OVER (PARTITION BY pe.City_Council_District ORDER BY residential_units DESC) AS Rank,
    pb.project_name AS Project_Name,
    pb.residential_units AS Residential_Units,
    ROUND((pb.residential_units / SUM(pb.residential_units) OVER (PARTITION BY pe.City_Council_District)) * 100, 1) AS Perceantage_of_All
  FROM
    `pipeline_basic` pb
  JOIN
    `pipeline_extended` pe
  ON
    pb.file_number = pe.File_Number
  WHERE
    pb.residential_units IS NOT NULL
  ORDER BY
    pe.City_Council_District ASC )
WHERE
  rank = 1
  
Result:
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| Row | City_Council_District | Rank | Project_Name                                   | Residential_Units | Perceantage_of_All |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 1   | 1                     | 1    | El Paseo & 1777 Saratoga Ave Mixed Use Village | 741               | 20.5               |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 2   | 2                     | 1    | Monterey Mixed Use                             | 438               | 33.8               |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 3   | 3                     | 1    | StarCity (Co-Living)                           | 800               | 6.9                |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 4   | 4                     | 1    | Seely Mixed Use                                | 1480              | 79.4               |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 5   | 5                     | 1    | Villa Del Sol Mixed Use Residential            | 194               | 21.2               |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 6   | 6                     | 1    | Google - Downtown West Mixed Use               | 5000              | 42.1               |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 7   | 7                     | 1    | Comm Hill Phase 3                              | 798               | 36.7               |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 8   | 8                     | 1    | Arcadia/Evergreen Part 1                       | 250               | 100.0              |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+
| 9   | 9                     | 1    | Cambrian Park Plaza                            | 378               | 42.9               |
+-----+-----------------------+------+------------------------------------------------+-------------------+--------------------+

