-- 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT a.model, s.fare_conditions, count(*) AS seat_count
FROM aircrafts_data a
         JOIN demo.bookings.seats AS s ON a.aircraft_code = s.aircraft_code
GROUP BY s.fare_conditions, a.model;

-- 2. Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT a.model, count(seat_no) AS seat_count
FROM aircrafts_data a
         JOIN seats ON a.aircraft_code = seats.aircraft_code
GROUP BY a.model
ORDER BY seat_count DESC
LIMIT 3;

-- 3. Найти все рейсы, которые задерживались более 2 часов
SELECT f.*
FROM flights f
WHERE EXTRACT(EPOCH FROM
              (f.actual_departure - f.scheduled_departure)) > 7200;

-- 4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
SELECT t.ticket_no, t.passenger_name, t.contact_data
FROM tickets AS t
         JOIN ticket_flights tf
              ON tf.ticket_no = t.ticket_no
                  AND tf.fare_conditions = 'Business'
         JOIN bookings on bookings.book_ref = t.book_ref
ORDER BY bookings.book_date DESC
LIMIT 10;

-- 5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT f.*
FROM flights f
         JOIN ticket_flights tf ON tf.flight_id = f.flight_id
WHERE f.status NOT IN ('Arrived', 'Departed', 'Cancelled')
GROUP BY f.flight_id
HAVING COUNT(CASE WHEN tf.fare_conditions = 'Business' THEN 1 END) = 0;

-- 6. Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой
SELECT a.airport_name, a.city
FROM airports_data a
         JOIN flights f ON a.airport_code = f.departure_airport
WHERE f.status = 'Delayed'
GROUP BY airport_name, city;

-- 7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
SELECT a.airport_name,
       count(f.flight_id) AS flights_count
FROM airports_data a
         JOIN flights f
              ON f.departure_airport = a.airport_code AND
                 f.status NOT IN ('Arrived', 'Departed', 'Cancelled')
GROUP BY a.airport_name
ORDER BY flights_count DESC;

-- 8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
SELECT f.*
FROM flights f
WHERE scheduled_arrival != actual_arrival;

-- 9. Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
SELECT a.aircraft_code, a.model, s.seat_no
FROM aircrafts_data a
         JOIN seats s ON s.aircraft_code = a.aircraft_code
WHERE s.aircraft_code = '321'
  AND s.fare_conditions != 'Economy'
ORDER BY seat_no;

--     10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT a.city
FROM airports_data a
GROUP BY a.city
HAVING count(a.airport_code) > 1;

-- 11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
SELECT t.passenger_id, t.passenger_name, t.contact_data
FROM tickets t
WHERE book_ref IN (SELECT b.book_ref
                   FROM bookings b
                   GROUP BY b.book_ref
                   HAVING sum(b.total_amount) > (SELECT avg(b.total_amount) FROM bookings b));

-- 12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT f.*
FROM flights f
WHERE f.status != 'Arrived'
  AND f.departure_airport = 'SVX'
  AND f.arrival_airport IN ('VKO', 'SVO', 'DME')
ORDER BY f.scheduled_departure
LIMIT 1;

-- 13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
SELECT t.*, max(tf.amount) AS ticket_amount
FROM tickets t
         JOIN ticket_flights tf
              ON t.ticket_no = tf.ticket_no
WHERE t.ticket_no = (SELECT tf.ticket_no
                     FROM ticket_flights tf
                     WHERE tf.amount =
                           (SELECT max(tf.amount)
                            FROM ticket_flights tf)
                     LIMIT 1)
GROUP BY t.ticket_no
UNION
SELECT t.*, min(tf.amount) AS ticket_amount
FROM tickets t
         JOIN ticket_flights tf
              ON t.ticket_no = tf.ticket_no
WHERE t.ticket_no = (SELECT tf.ticket_no
                     FROM ticket_flights tf
                     WHERE tf.amount =
                           (SELECT min(tf.amount)
                            FROM ticket_flights tf)
                     LIMIT 1)
GROUP BY t.ticket_no;

-- 14. Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
CREATE TABLE Customers
(
    id        INT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName  VARCHAR(50) NOT NULL,
    email     VARCHAR(100) UNIQUE,
    phone     VARCHAR(20) NOT NULL
);

-- 15. Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE Orders
(
    id         INT PRIMARY KEY,
    customerId INT,
    quantity   INT,
    FOREIGN KEY (customerId) REFERENCES Customers (id)
);

-- 16. Написать 5 insert в эти таблицы
INSERT INTO Customers (id, firstName, lastName, email, phone)
VALUES (1, 'John', 'Doe', 'johndoe@gmail.com', '1234567890');

INSERT INTO Customers (id, firstName, lastName, email, phone)
VALUES (2, 'John', 'Wick', 'johnwick@gmail.com', '9876543210');

INSERT INTO Customers (id, firstName, lastName, email, phone)
VALUES (3, 'Brad', 'Pitt', 'bradpitt@gmail.com', '5555555555');

INSERT INTO Customers (id, firstName, lastName, email, phone)
VALUES (4, 'Bil', 'Will', 'bilwill@gmail.com', '1112223333');

INSERT INTO Customers (id, firstName, lastName, email, phone)
VALUES (5, 'David', 'Brown', 'davidbrown@gmail.com', '4444444444');


INSERT INTO Orders (id, customerId, quantity)
VALUES (1, 1, 5);

INSERT INTO Orders (id, customerId, quantity)
VALUES (2, 3, 10);

INSERT INTO Orders (id, customerId, quantity)
VALUES (3, 2, 2);

INSERT INTO Orders (id, customerId, quantity)
VALUES (4, 4, 8);

INSERT INTO Orders (id, customerId, quantity)
VALUES (5, 5, 3);

-- 17. Удалить таблицы
DROP TABLE Orders;
DROP TABLE Customers;