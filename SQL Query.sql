-- CREATE TABLE ROUTE DETAILS 
Create Table route_details (
route_id int,
flight_num int NOT NULL,
origin_airport char (3),
destination_airport char (3),
aircraft_id varchar (255),
distance_miles int,
CONSTRAINT route_id_unique UNIQUE (route_id),
check (distance_miles > 0)
);


select * from air_cargo_analysis..route_details

select * from air_cargo_analysis..customer

select * from air_cargo_analysis..passengers_on_flights

select * from air_cargo_analysis.dbo.ticket_details

--Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. Take data  from the passengers_on_flights table.

SELECT * FROM air_cargo_analysis..PASSENGERS_ON_FLIGHTS
WHERE ROUTE_ID BETWEEN 1 and 25;

--Write a query to identify the number of passengers and total revenue in business class from the ticket_details table.

select count(customer_id) as Count_of_Customers, sum(price_per_ticket) as Total_revenue_from_business_class
from air_cargo_analysis.dbo.ticket_details
where class_id = 'Bussiness';

--Write a query to display the full name of the customer by extracting the first name and last name from the customer table.

select CONCAT(first_name,' ',last_name) as [full name]
from air_cargo_analysis..customer;

--Write a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables.

select c.customer_id, c.first_name, c.last_name, c.date_of_birth, c.gender, t.no_of_tickets
from air_cargo_analysis..customer c
left join air_cargo_analysis..ticket_details t on c.customer_id = t.customer_id
where t.no_of_tickets = 1;

or 

SELECT c.customer_id, c.first_name, c.last_name, c.date_of_birth, c.gender, t.no_of_tickets
FROM air_cargo_analysis..customer c
INNER JOIN air_cargo_analysis..ticket_details t ON c.customer_id = t.customer_id

--Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table.

select c.customer_id, c.first_name, c.last_name, t.customer_id, t.brand
from air_cargo_analysis..ticket_details t
inner join air_cargo_analysis..customer c on t.customer_id = c.customer_id
where t.brand = 'Emirates';

--Write a query to identify the customers who have travelled by Economy Plus class using Group By and Having clause on the passengers_on_flights table.

select c.customer_id,c.first_name, c.last_name, p.customer_id, p.class_id
from air_cargo_analysis..passengers_on_flights p
left join air_cargo_analysis..customer c on p.customer_id=c.customer_id
group by c.customer_id,c.first_name, c.last_name, p.customer_id, p.class_id
having class_id = '"Economy Plus"'

--Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.

IF ((
    SELECT SUM(price_per_ticket) AS Revenue
    FROM air_cargo_analysis.dbo.ticket_details
) > 10000)
    SELECT 'Yes Revenue is high' AS [Revenue Information];
ELSE
    SELECT 'No' AS [Revenue Information];

or

select sum(price_per_ticket), CASE WHEN SUM(price_per_ticket) > 10000 THEN 'Yes Revenue is high' ELSE 'No' END AS [Revenue Information]
FROM air_cargo_analysis.dbo.ticket_details;

--Write a query to create and grant access to a new user to perform operations on a database.

CREATE LOGIN user1 WITH PASSWORD = 'testuser';

USE air_cargo_analysis;
CREATE USER user1 FOR LOGIN user1;

GRANT SELECT, INSERT, UPDATE, DELETE ON air_cargo_analysis.dbo.ticket_details TO user1;

GRANT EXECUTE TO user1;

--Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.

select max(price_per_ticket) as [Maximum_ticket_price], class_id
from  air_cargo_analysis.dbo.ticket_details
group by class_id

--Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table.
select * from air_cargo_analysis..passengers_on_flights

CREATE INDEX idx_route_id ON air_cargo_analysis..passengers_on_flights (route_id);

SELECT *
FROM passengers_on_flights
WHERE route_id = 4;

-- For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.
SELECT *
FROM passengers_on_flights
WHERE route_id = 4;

--Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function.
SELECT customer_id, aircraft_id, SUM(price_per_ticket) AS total_price
FROM air_cargo_analysis.dbo.ticket_details
GROUP BY ROLLUP (customer_id, aircraft_id);

--Write a query to create a view with only business class customers along with the brand of airlines.
CREATE VIEW view_business_customers AS
SELECT c.customer_id, c.first_name, c.last_name, t.brand
FROM air_cargo_analysis..customer c
join air_cargo_analysis..ticket_details t on c.customer_id=t.customer_id
where t.class_id = 'Bussiness';

select * from air_cargo_analysis..view_business_customers

--Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time. Also, return an error message if the table doesn't exist.

CREATE PROCEDURE GetPassengerDetailsBetweenRoutes
    @startRouteId INT,
    @endRouteId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the table exists
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'passengers_on_flights'
    )
    BEGIN
        THROW 50001, 'The table "passengers_on_flights" does not exist.', 1;
        RETURN;
    END;

    -- Retrieve passenger details between the specified range of routes
    SELECT p.*
    FROM air_cargo_analysis..passengers_on_flights p
    WHERE p.route_id BETWEEN @startRouteId AND @endRouteId;
END;


EXEC GetPassengerDetailsBetweenRoutes @startRouteId = 1, @endRouteId = 20;

--Write a query to create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles.

CREATE PROCEDURE DistanceExceeding2000miles AS
BEGIN
	SELECT * 
	FROM air_cargo_analysis..route_details 
	WHERE distance_miles >2000;
END;

EXEC DistanceExceeding2000miles;

--Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500.

select * from air_cargo_analysis..route_details

CREATE PROCEDURE Flightcategories AS
BEGIN
	SELECT *,
	CASE WHEN distance_miles >=0 AND distance_miles <= 2000 THEN 'Short Distance Travel'
		 WHEN distance_miles >2000 AND distance_miles <=6500 THEN 'Intermediate Distance Travel'
		 WHEN distance_miles >6500 THEN 'Long Distance Travel' END AS CATEGORY
	from air_cargo_analysis..route_details;

END;

EXEC Flightcategories;

--Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for the specific class using a stored function in stored procedure on the ticket_details table.
--Condition: If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No


CREATE FUNCTION ComplimentaryServices
(@class_id VARCHAR(50))
RETURNS VARCHAR(3)
AS
BEGIN
    DECLARE @complimentary_services VARCHAR(3)

    IF @class_id IN ('Bussiness', '"Economy Plus"')
        SET @complimentary_services = 'Yes';
    ELSE
        SET @complimentary_services = 'No';

    RETURN @complimentary_services;
END;



CREATE PROCEDURE GetTicketDetails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p_date, customer_id, class_id,
           dbo.ComplimentaryServices(class_id) AS complimentary_services
    FROM ticket_details;
END;

EXEC GetTicketDetails;

--Write a query to extract the first record of the customer whose last name ends with Scott using a cursor from the customer table.

DECLARE @customer_id INT, @first_name VARCHAR(50), @last_name VARCHAR(50)

DECLARE customer_cursor CURSOR FOR
SELECT customer_id, first_name, last_name
FROM air_cargo_analysis..customer
WHERE last_name LIKE '%Scott'
ORDER BY customer_id

OPEN customer_cursor
FETCH NEXT FROM customer_cursor INTO @customer_id, @first_name, @last_name

IF @@FETCH_STATUS = 0
BEGIN
    -- Process the first record
    SELECT @customer_id AS customer_id, @first_name AS first_name, @last_name AS last_name
END

CLOSE customer_cursor
DEALLOCATE customer_cursor






