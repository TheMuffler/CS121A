SELECT p.pid, MAX(ftimes.ftime) AS MaxFlight
FROM Pilot_Operates_Flight p, (
	SELECT flight_number, abs(timestampdiff(second,actual_departure_datetime,actual_arrival_datetime)) AS ftime
    FROM flight
) AS ftimes
WHERE p.flight_number=ftimes.flight_number
GROUP BY p.pid/*Q1*/;


SELECT o.lid, COUNT(*)
FROM DishOrder o, Credit_Card c
WHERE o.cid = c.cid AND length(c.card_number)=15
GROUP BY o.lid/*Q2*/;

SELECT o.cid, SUM(o.total_amount)
FROM DishOrder o
GROUP BY o.cid
HAVING SUM(o.total_amount) >= 100 AND NOT EXISTS (
	(
		SELECT ap.iata_code
		FROM airport ap
        WHERE NOT EXISTS (
			SELECT *
            FROM Lounge l, DishOrder o2
            WHERE l.lid = o2.lid AND o2.cid = o.cid AND l.airport_iata_code = ap.iata_code
        )
	)
)/*Q3*/;

SELECT f.flight_number, f.projected_departure_datetime
FROM flight f, airplane a
WHERE f.aiplane_registration_number = a.registration_number
AND a.capacity = (
	SELECT SUM(c.quantity)
    FROM customer_reserves_flight c
    WHERE c.flight_number = f.flight_number
    AND c.projected_departure_dateUpdateTotalUpdateTotalUpdateTotaltime = f.projected_departure_datetime
)/*Q4*/;

ALTER TABLE Credit_Card
ADD CONSTRAINT CardCascadeCustomer
FOREIGN KEY(cid)
REFERENCES  Customer(cid)
ON DELETE CASCADE/*Q5*/;

CREATE VIEW Flights_offered_view AS
SELECT DISTINCT f.flight_number, f.departure_airport_IATA_code, f.arrival_airport_IATA_CODE
FROM flight f/*Q6*/;

GRANT SELECT ON Flights_offered_view TO futurecustomer/*Q8*/;

CREATE TRIGGER UpdateTotal
AFTER INSERT ON dishorder_contains_dish
FOR EACH ROW
	UPDATE DishOrder o
    SET o.total_amount = o.total_amount + NEW.quantity *
    (
		SELECT d.price
		FROM Dish d
		WHERE d.name = NEW.name AND d.lid = NEW.lid
    )
    WHERE o.oid = NEW.oid/*Q9*/;
