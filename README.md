# Little Lemon Restaurant Booking & Order Management System

a relational database and python based booking system for Little Lemon restaurant, built as part of the meta database engineering capstone.

## Contents

| File | Description |
|---|---|
| `LittleLemonDB.sql` | Full schema: tables, sample data, and the five required stored procedures |
| `db_connection.py` | Python (mysql-connector-python) script that connects to the database and calls each procedure |
| `er_diagram.png` | Entity-relationship diagram (add your screenshot here) |
| `LittleLemon_Analysis.twbx` | Tableau workbook with worksheets and dashboards (add your export here) |

## Database schema

Tables: `Customers`, `Staff`, `Menu`, `Bookings`, `Orders`, `OrderItems`.

- A **Customer** can make many **Bookings** and place many **Orders**.
- A **Booking** is tied to one **Staff** member and generates one or more **Orders**.
- An **Order** contains multiple **Menu** items via `OrderItems`.

## Stored procedures

| Procedure | Purpose |
|---|---|
| `GetMaxQuantity()` | Returns the highest quantity ordered across all orders |
| `ManageBooking(table_no, booking_date)` | Checks whether a table is already booked on a given date |
| `AddBooking(...)` | Creates a new booking record |
| `UpdateBooking(booking_id, new_slot)` | Updates the time slot of an existing booking |
| `CancelBooking(booking_id)` | Marks a booking as cancelled |

## Setup

1. Import the schema:
   ```bash
   mysql -u root -p < LittleLemonDB.sql
   ```
2. Install the Python connector:
   ```bash
   pip install mysql-connector-python
   ```
3. Update the credentials in `db_connection.py` (host, user, password) to match your local MySQL instance.
4. Run it:
   ```bash
   python3 db_connection.py
   ```

## Data analysis

The `Orders` table structure mirrors the Little Lemon order dataset (customer, city, country, cost, sales, quantity, discount, delivery cost, course, cuisine, starter, dessert, drink, sides), which was analyzed and visualized in Tableau — see the attached workbook for the dashboards.
