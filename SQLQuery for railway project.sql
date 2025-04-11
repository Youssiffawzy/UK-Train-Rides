
--Cleaning 
SELECT 
    [Transaction ID],
    -- Clean Date of Purchase (remove time)
    CONVERT(DATE, [Date of Purchase]) AS [Date of Purchase],
    
    -- Clean Time of Purchase (remove date and milliseconds)
    CONVERT(TIME(0), [Time of Purchase]) AS [Time of Purchase],
    
    [Purchase Type],
    [Payment Method],
    [Railcard],
    [Ticket Class],
    [Ticket Type],
    [Price],
    [Departure Station],
    [Arrival Destination],
    
    -- Clean Date of Journey (remove time)
    CONVERT(DATE, [Date of Journey]) AS [Date of Journey],
    
    -- Clean Departure/Arrival Times (remove dates and milliseconds)
    CONVERT(TIME(0), [Departure Time]) AS [Departure Time],
    CONVERT(TIME(0), [Arrival Time]) AS [Arrival Time],
    CONVERT(TIME(0), [Actual Arrival Time]) AS [Actual Arrival Time],
    
    -- Round to zero decimals
    ROUND([Actual trip time], 0) AS [Actual trip time],
    ROUND([Delayed time], 0) AS [Delayed time],
    ROUND([Delayed minuts], 0) AS [Delayed minuts],
    
    [Journey Status],
    [Reason for Delay],
    [Refund Request]
FROM 
    [Railway Final Project].[dbo].[railway];

		-- Step 1: Backup the original table
SELECT *
INTO [Railway Final Project].[dbo].[railway_backup]
FROM [Railway Final Project].[dbo].[railway];

-- Step 2: Modify date columns to store only dates (remove time)
ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Date of Purchase] DATE;

ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Date of Journey] DATE;

-- Step 3: Modify time columns to store only times (remove dates and milliseconds)
ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Time of Purchase] TIME(0);

ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Departure Time] TIME(0);

ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Arrival Time] TIME(0);

ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Actual Arrival Time] TIME(0);

-- Step 4: Round numeric columns and convert to integers
UPDATE [Railway Final Project].[dbo].[railway]
SET 
    [Actual trip time] = ROUND([Actual trip time], 0),
    [Delayed time] = ROUND([Delayed time], 0),
    [Delayed minuts] = ROUND([Delayed minuts], 0);

-- Step 5: Convert numeric columns to INT (to remove decimal places permanently)
ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Actual trip time] INT;

ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Delayed time] INT;

ALTER TABLE [Railway Final Project].[dbo].[railway]
ALTER COLUMN [Delayed minuts] INT;

select * from [Railway Final Project].[dbo].[railway]









-------How do passenger demographics (Railcard type, Ticket Class) influence their  likelihood to request refunds?
SELECT 
    [Railcard],
    [Ticket Class],
    
    -- Refund request rate rounded to 2 decimal places with "%" symbol
    FORMAT(
        ROUND(
            (COUNT(CASE WHEN [Refund Request] = 'Yes' THEN 1 END) * 100.0) / 
            NULLIF(COUNT(*), 0),
            2
        ),
        'N2'
    ) + '%' AS Refund_Request_Rate_Percent
FROM 
    [Railway Final Project].[dbo].[railway]
GROUP BY 
    [Railcard],
    [Ticket Class]
ORDER BY 
   
    Refund_Request_Rate_Percent DESC;





	---------. Do online purchasers behave differently than station buyers (e.g., refund habits, route choices)?

	WITH Purchase_Type_Analysis AS (
    SELECT 
        [Purchase Type],
        -- Calculate Refund Rate for each purchase type
        FORMAT(
            ROUND(
                (COUNT(CASE WHEN [Refund Request] = 'Yes' THEN 1 END) * 100.0) / 
                NULLIF(COUNT(*), 0),
                2
            ),
            'N2'
        ) + '%' AS Refund_Rate_Percent,
        -- Calculate Average Ticket Price
        ROUND(AVG([Price]), 2) AS Avg_Ticket_Price,
        -- Count Total Transactions
        COUNT(*) AS Total_Transactions
    FROM 
        [Railway Final Project].[dbo].[railway]
    GROUP BY 
        [Purchase Type]
),
Top_Routes AS (
    SELECT 
        [Purchase Type],
        CONCAT([Departure Station], ' → ', [Arrival Destination]) AS Route,
        COUNT(*) AS Route_Count
    FROM 
        [Railway Final Project].[dbo].[railway]
    GROUP BY 
        [Purchase Type],
        CONCAT([Departure Station], ' → ', [Arrival Destination])
),
Concatenated_Routes AS (
    SELECT 
        [Purchase Type],
        STUFF((
            SELECT TOP 3 
                ', ' + Route
            FROM 
                Top_Routes tr2
            WHERE 
                tr2.[Purchase Type] = tr1.[Purchase Type]
            ORDER BY 
                tr2.Route_Count DESC
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Top_Routes
    FROM 
        Top_Routes tr1
    GROUP BY 
        [Purchase Type]
)
SELECT 
    pta.[Purchase Type],
    pta.Refund_Rate_Percent,
    cr.Top_Routes,
    pta.Avg_Ticket_Price,
    pta.Total_Transactions
FROM 
    Purchase_Type_Analysis pta
LEFT JOIN 
    Concatenated_Routes cr
ON 
    pta.[Purchase Type] = cr.[Purchase Type]
ORDER BY 
    pta.[Purchase Type];








	----------Which station pairs have the highest 'phantom delays' (delays not explained by obvious factors like weather)?

	-- **Question 1: Average Delay Duration by Railcard and Ticket Class**
WITH Delayed_Passengers AS (
    SELECT 
        [Railcard],
        [Ticket Class],
        SUM([Delayed minuts]) AS Total_Delay_Minutes,
        COUNT(CASE WHEN [Delayed minuts] > 0 THEN 1 END) AS Count_Passengers_With_Delays
    FROM 
        [Railway Final Project].[dbo].[railway]
    GROUP BY 
        [Railcard],
        [Ticket Class]
)
SELECT 
    [Railcard],
    [Ticket Class],
    ROUND(
        Total_Delay_Minutes * 1.0 / NULLIF(Count_Passengers_With_Delays, 0),
        2
    ) AS Avg_Delay_Duration,
    FORMAT(
        ROUND(
            (COUNT(CASE WHEN [Refund Request] = 'Yes' THEN 1 END) * 100.0) / 
            NULLIF(COUNT(*), 0),
            2
        ),
        'N2'
    ) + '%' AS Refund_Request_Rate_Percent
FROM 
    [Railway Final Project].[dbo].[railway]
GROUP BY 
    [Railcard],
    [Ticket Class],
    Total_Delay_Minutes,
    Count_Passengers_With_Delays
ORDER BY 
    Avg_Delay_Duration DESC,
    Refund_Request_Rate_Percent DESC;

-- **Question 2: Compare Online vs. Station Buyers**
WITH Purchase_Type_Analysis AS (
    SELECT 
        [Purchase Type],
        -- Refund Rate: Percentage of refunds requested
        FORMAT(
            ROUND(
                (COUNT(CASE WHEN [Refund Request] = 'Yes' THEN 1 END) * 100.0) / 
                NULLIF(COUNT(*), 0),
                2
            ),
            'N2'
        ) + '%' AS Refund_Rate_Percent,
        -- Average Ticket Price
        ROUND(AVG([Price]), 2) AS Avg_Ticket_Price,
        -- Total Transactions
        COUNT(*) AS Total_Transactions
    FROM 
        [Railway Final Project].[dbo].[railway]
    GROUP BY 
        [Purchase Type]
),
Top_Routes AS (
    SELECT 
        [Purchase Type],
        CONCAT([Departure Station], ' → ', [Arrival Destination]) AS Route,
        COUNT(*) AS Route_Count
    FROM 
        [Railway Final Project].[dbo].[railway]
    GROUP BY 
        [Purchase Type],
        CONCAT([Departure Station], ' → ', [Arrival Destination])
),
Concatenated_Routes AS (
    SELECT 
        [Purchase Type],
        STUFF((
            SELECT TOP 3 
                ', ' + Route
            FROM 
                Top_Routes tr2
            WHERE 
                tr2.[Purchase Type] = tr1.[Purchase Type]
            ORDER BY 
                tr2.Route_Count DESC
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Top_Routes
    FROM 
        Top_Routes tr1
    GROUP BY 
        [Purchase Type]
)
SELECT 
    pta.[Purchase Type],
    pta.Refund_Rate_Percent,
    cr.Top_Routes,
    pta.Avg_Ticket_Price,
    pta.Total_Transactions
FROM 
    Purchase_Type_Analysis pta
LEFT JOIN 
    Concatenated_Routes cr
ON 
    pta.[Purchase Type] = cr.[Purchase Type]
ORDER BY 
    pta.[Purchase Type];










-- **Question 3: Correlation Between Ticket Price and Passengers’ Patience with Delays**

		-- Step 1: Categorize tickets into price brackets
	WITH Price_Brackets AS (
		SELECT 
			[Price],                -- Ticket price
			[Delayed minuts],       -- Delay duration in minutes
			[Refund Request],       -- Whether a refund was requested ('Yes' or 'No')
			CASE 
				WHEN [Price] < 20 THEN '<£20'             -- Tickets under £20
				WHEN [Price] BETWEEN 20 AND 50 THEN '£20-£50' -- Tickets between £20 and £50
				ELSE '>£50'                                 -- Tickets above £50
			END AS Price_Bracket   -- Create a new column for price bracket
		FROM 
			[Railway Final Project].[dbo].[railway] -- Source table
	),
	Bracket_Analysis AS (
		SELECT 
			Price_Bracket,                              -- Price bracket category
			-- Average Delay Duration (only for delayed transactions)
			ROUND(
				SUM(CASE WHEN [Delayed minuts] > 0 THEN [Delayed minuts] ELSE 0 END) * 1.0 / 
				NULLIF(SUM(CASE WHEN [Delayed minuts] > 0 THEN 1 ELSE 0 END), 0),
				2
			) AS Avg_Delay_Duration,
			-- Refund Request Rate
			ROUND(
				SUM(CASE WHEN [Refund Request] = 'Yes' THEN 1 ELSE 0 END) * 100.0 / 
				NULLIF(COUNT(*), 0),
				2
			) AS Refund_Request_Rate_Percent
		FROM 
			Price_Brackets
		GROUP BY 
			Price_Bracket -- Group by price bracket
	)
	-- Step 3: Display results
	SELECT 
		Price_Bracket,
		Avg_Delay_Duration,
		Refund_Request_Rate_Percent
	FROM 
		Bracket_Analysis
	ORDER BY 
		Price_Bracket; -- Order results by price bracket









		--Which station pairs have the highest 'phantom delays' (delays not explained by obvious factors like weather)?


		WITH Phantom_Delays AS (
    SELECT 
        [Departure Station],
        [Arrival Destination],
        [Delayed minuts],
        [Reason for Delay],
        CASE 
            WHEN [Reason for Delay] IN ('Weather', 'Weather Conditions') THEN 'No phantom delays'
            WHEN [Reason for Delay] = 'No Delay' THEN 'No phantom delays'
            ELSE 'Phantom delays'
        END AS Delay_Type
    FROM 
        [Railway Final Project].[dbo].[railway]
    WHERE 
        [Delayed minuts] > 0 -- Only include delayed transactions
),
Station_Pairs_Analysis AS (
    SELECT 
        [Departure Station],
        [Arrival Destination],
        COUNT(CASE WHEN Delay_Type = 'Phantom delays' THEN 1 END) AS Total_Phantom_Delays
    FROM 
        Phantom_Delays
    GROUP BY 
        [Departure Station],
        [Arrival Destination]
)
SELECT 
    [Departure Station],
    [Arrival Destination],
    Total_Phantom_Delays
FROM 
    Station_Pairs_Analysis
ORDER BY 

    Total_Phantom_Delays DESC; -- Rank by total phantom delays








	WITH Route_Clusters AS (
    SELECT 
        [Departure Station],
        [Arrival Destination],
        AVG([Price]) AS Avg_Price, -- Average price for the route
        AVG(CASE WHEN [Delayed minuts] > 0 THEN [Delayed minuts] ELSE 0 END) AS Avg_Delay_Risk, -- Average delay risk
        AVG(DATEDIFF(MINUTE, [Departure Time], [Arrival Time])) AS Avg_Journey_Time -- Average journey time in minutes
    FROM 
        [Railway Final Project].[dbo].[railway]
    GROUP BY 
        [Departure Station],
        [Arrival Destination]
),
Composite_Score AS (
    SELECT 
        [Departure Station],
        [Arrival Destination],
        Avg_Price,
        Avg_Delay_Risk,
        Avg_Journey_Time,
        -- Calculate composite score
        ROUND(Avg_Price + Avg_Delay_Risk + Avg_Journey_Time, 2) AS Composite_Score
    FROM 
        Route_Clusters
)
-- Step 3: Identify underserved routes
SELECT 
    [Departure Station],
    [Arrival Destination],
    Avg_Price,
    Avg_Delay_Risk,
    Avg_Journey_Time,
    Composite_Score
FROM 
    Composite_Score
ORDER BY 
    Composite_Score DESC; -- Rank routes by composite score





	--Which route clusters (price + delay risk + journey time) are underserved and could benefit from targeted promotions?







	WITH Route_Clusters AS (
    SELECT 
        [Departure Station],
        [Arrival Destination],
        AVG([Price]) AS Avg_Price,
        AVG(CASE WHEN [Delayed minuts] > 0 THEN [Delayed minuts] ELSE 0 END) AS Avg_Delay_Risk,
        AVG(
            CASE 
                WHEN [Arrival Time] < [Departure Time] THEN DATEDIFF(MINUTE, [Departure Time], DATEADD(DAY, 1, [Arrival Time]))
                ELSE DATEDIFF(MINUTE, [Departure Time], [Arrival Time])
            END
        ) AS Avg_Journey_Time
    FROM 
        [Railway Final Project].[dbo].[railway]
    WHERE 
        [Departure Time] IS NOT NULL 
        AND [Arrival Time] IS NOT NULL 
        AND ([Arrival Time] >= [Departure Time] OR [Arrival Time] < [Departure Time] AND DATEDIFF(DAY, [Departure Time], [Arrival Time]) = 1)
    G	ROUP BY 
        [Departure Station],
        [Arrival Destination]
),
Composite_Score AS (
    SELECT 
        [Departure Station],
        [Arrival Destination],
        ROUND(Avg_Price, 2) AS Avg_Price,
        Avg_Delay_Risk,
        Avg_Journey_Time,
        ROUND(Avg_Price + Avg_Delay_Risk + Avg_Journey_Time, 2) AS Composite_Score
    FROM 
        Route_Clusters
    WHERE 
        Avg_Delay_Risk > 0 -- Exclude routes with zero delay risk
)
SELECT 
    [Departure Station],
    [Arrival Destination],
    Avg_Price,
    Avg_Delay_Risk,
    Avg_Journey_Time,
    Composite_Score
FROM 
    Composite_Score
WHERE 
    Composite_Score >= 0 -- Ensure non-negative composite scores
ORDER BY 
    Composite_Score DESC; -- Rank routes by composite score









	---What are the most common reasons for delays, and how do they impact refund requests?

WITH Refund_Rate_Analysis AS (
    SELECT 
        [Reason for Delay],
        COUNT(*) AS Total_Transactions,
        SUM(CASE WHEN [Refund Request] = 'Yes' THEN 1 ELSE 0 END) AS Total_Refunds,
        -- Calculate refund rate as a percentage (rounded to 2 decimal places)
        ROUND(SUM(CASE WHEN [Refund Request] = 'Yes' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS Refund_Rate_Percent
    FROM 
        [Railway Final Project].[dbo].[railway]
    WHERE 
        [Delayed minuts] > 0 -- Focus only on delayed transactions
    GROUP BY 
        [Reason for Delay]
)
SELECT 
    [Reason for Delay],
    Total_Transactions,
    Total_Refunds,
    -- Format the refund rate as a percentage with exactly 2 decimal places
    FORMAT(Refund_Rate_Percent, 'N2') + '%' AS Refund_Rate_Percent_Formatted
FROM 
    Refund_Rate_Analysis
ORDER BY 
    Total_Transactions DESC; -- Rank by the frequency of delays