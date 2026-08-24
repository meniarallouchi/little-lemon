CREATE DATABASE LittleLemonDB;
USE LittleLemonDB;

-- =========================================================
-- TABLES
-- =========================================================

CREATE TABLE Customers (
    CustomerID   INT AUTO_INCREMENT PRIMARY KEY,
    FullName     VARCHAR(100) NOT NULL,
    City         VARCHAR(50),
    Country      VARCHAR(50),
    PostalCode   VARCHAR(20),
    CountryCode  VARCHAR(5),
    ContactEmail VARCHAR(100)
);

CREATE TABLE Staff (
    StaffID      INT AUTO_INCREMENT PRIMARY KEY,
    FullName     VARCHAR(100) NOT NULL,
    Role         VARCHAR(50) NOT NULL,
    Salary       DECIMAL(10,2)
);

CREATE TABLE Menu (
    MenuID       INT AUTO_INCREMENT PRIMARY KEY,
    ItemName     VARCHAR(100) NOT NULL,
    Category     VARCHAR(30) NOT NULL,   -- Starter, Course, Dessert, Drink, Side
    Cuisine      VARCHAR(50),
    Price        DECIMAL(8,2) NOT NULL
);

CREATE TABLE Bookings (
    BookingID     INT AUTO_INCREMENT PRIMARY KEY,
    BookingDate   DATE NOT NULL,
    BookingSlot   TIME NOT NULL,
    TableNo       INT NOT NULL,
    CustomerID    INT NOT NULL,
    StaffID       INT,
    NumberOfGuests INT DEFAULT 1,
    Status        VARCHAR(20) DEFAULT 'Confirmed',   -- Confirmed, Cancelled
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Orders (
    OrderID       INT AUTO_INCREMENT PRIMARY KEY,
    BookingID     INT,
    CustomerID    INT NOT NULL,
    OrderDate     DATE NOT NULL,
    DeliveryDate  DATE,
    Cost          DECIMAL(10,2),
    Sales         DECIMAL(10,2),
    Quantity      INT NOT NULL,
    Discount      DECIMAL(5,2) DEFAULT 0,
    DeliveryCost  DECIMAL(8,2) DEFAULT 0,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
    OrderItemID  INT AUTO_INCREMENT PRIMARY KEY,
    OrderID      INT NOT NULL,
    MenuID       INT NOT NULL,
    ItemQuantity INT DEFAULT 1,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuID) REFERENCES Menu(MenuID)
);

-- =========================================================
-- SAMPLE DATA (small seed set for testing the procedures)
-- =========================================================

INSERT INTO Customers (FullName, City, Country, PostalCode, CountryCode, ContactEmail) VALUES
('Laney Fadden', 'Daruoyan', 'China', '993-0031', 'CN', 'laney.f@example.com'),
('Giacopo Bramich', 'Ongjin', 'North Korea', '216282', 'KP', 'giacopo.b@example.com'),
('Amina Haddad', 'Ben Arous', 'Tunisia', '2013', 'TN', 'amina.h@example.com');

INSERT INTO Staff (FullName, Role, Salary) VALUES
('Mario Rossi', 'Manager', 45000.00),
('Adrian Smith', 'Head Chef', 38000.00),
('Sara Lee', 'Waiter', 22000.00);

INSERT INTO Menu (ItemName, Category, Cuisine, Price) VALUES
('Greek salad', 'Starter', 'Greek', 12.00),
('Bean soup', 'Starter', 'Italian', 8.50),
('Olives', 'Side', 'Greek', 3.00),
('Athens White wine', 'Drink', 'Greek', 15.00),
('Greek yoghurt', 'Dessert', 'Greek', 6.00);

INSERT INTO Bookings (BookingDate, BookingSlot, TableNo, CustomerID, StaffID, NumberOfGuests) VALUES
('2026-08-25', '19:00:00', 5, 1, 3, 2),
('2026-08-25', '20:00:00', 8, 2, 3, 4);

INSERT INTO Orders (BookingID, CustomerID, OrderDate, DeliveryDate, Cost, Sales, Quantity, Discount, DeliveryCost) VALUES
(1, 1, '2020-06-15', '2020-03-26', 125.00, 187.50, 2, 20.00, 60.51),
(2, 2, '2020-08-25', '2020-07-17', 235.00, 352.50, 1, 15.00, 96.75);

-- =========================================================
-- STORED PROCEDURES
-- =========================================================

DELIMITER //

-- 1. GetMaxQuantity()
-- Returns the highest order quantity recorded across all orders.
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS MaxQuantity FROM Orders;
END //

-- 2. ManageBooking(IN table_no INT, IN booking_date DATE)
-- Checks whether a table is already booked for a given date;
-- returns the matching booking rows if any exist.
CREATE PROCEDURE ManageBooking(IN p_TableNo INT, IN p_BookingDate DATE)
BEGIN
    SELECT BookingID, TableNo, BookingDate, BookingSlot, Status
    FROM Bookings
    WHERE TableNo = p_TableNo
    AND BookingDate = p_BookingDate
    AND Status = 'Confirmed';
END //

-- 3. AddBooking(IN ...)
-- Inserts a new booking record.
CREATE PROCEDURE AddBooking(
    IN p_BookingDate DATE,
    IN p_BookingSlot TIME,
    IN p_TableNo INT,
    IN p_CustomerID INT,
    IN p_StaffID INT,
    IN p_NumberOfGuests INT
)
BEGIN
    INSERT INTO Bookings (BookingDate, BookingSlot, TableNo, CustomerID, StaffID, NumberOfGuests, Status)
    VALUES (p_BookingDate, p_BookingSlot, p_TableNo, p_CustomerID, p_StaffID, p_NumberOfGuests, 'Confirmed');

    SELECT CONCAT('New Booking Added: BookingID = ', LAST_INSERT_ID()) AS Confirmation;
END //

-- 4. UpdateBooking(IN booking_id INT, IN new_slot TIME)
-- Updates the time slot of an existing booking.
CREATE PROCEDURE UpdateBooking(
    IN p_BookingID INT,
    IN p_NewSlot TIME
)
BEGIN
    UPDATE Bookings
    SET BookingSlot = p_NewSlot
    WHERE BookingID = p_BookingID;

    SELECT CONCAT('Booking ', p_BookingID, ' updated to new slot ', p_NewSlot) AS Confirmation;
END //

-- 5. CancelBooking(IN booking_id INT)
-- Cancels (soft-deletes) a booking by marking its status.
CREATE PROCEDURE CancelBooking(IN p_BookingID INT)
BEGIN
    UPDATE Bookings
    SET Status = 'Cancelled'
    WHERE BookingID = p_BookingID;

    SELECT CONCAT('Booking ', p_BookingID, ' has been cancelled') AS Confirmation;
END //

DELIMITER ;