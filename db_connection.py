"""
connects to the LittleLemonDB database using mysql-connector-python and demonstrates calling each of the five required stored procedures:
    GetMaxQuantity(), ManageBooking(), AddBooking(), UpdateBooking(), CancelBooking()
"""

import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

# Loads variables from a local .env file (never committed to GitHub —
# see .gitignore). Create a .env file in this folder with:
#   DB_HOST=localhost
#   DB_USER=root
#   DB_PASSWORD=your_actual_password
#   DB_NAME=LittleLemonDB
load_dotenv()


def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME"),
    )


def get_max_quantity(cursor):
    cursor.callproc("GetMaxQuantity")
    for result in cursor.stored_results():
        for row in result.fetchall():
            print("Max quantity ordered:", row)


def manage_booking(cursor, table_no, booking_date):
    cursor.callproc("ManageBooking", [table_no, booking_date])
    for result in cursor.stored_results():
        rows = result.fetchall()
        if rows:
            print(f"Table {table_no} is already booked on {booking_date}:", rows)
        else:
            print(f"Table {table_no} is free on {booking_date}.")


def add_booking(cursor, booking_date, booking_slot, table_no,
                customer_id, staff_id, num_guests):
    cursor.callproc(
        "AddBooking",
        [booking_date, booking_slot, table_no, customer_id, staff_id, num_guests],
    )
    for result in cursor.stored_results():
        for row in result.fetchall():
            print(row)


def update_booking(cursor, booking_id, new_slot):
    cursor.callproc("UpdateBooking", [booking_id, new_slot])
    for result in cursor.stored_results():
        for row in result.fetchall():
            print(row)


def cancel_booking(cursor, booking_id):
    cursor.callproc("CancelBooking", [booking_id])
    for result in cursor.stored_results():
        for row in result.fetchall():
            print(row)


def main():
    try:
        connection = get_connection()
        if connection.is_connected():
            print("Connected to LittleLemonDB\n")
            cursor = connection.cursor()

            get_max_quantity(cursor)
            manage_booking(cursor, table_no=5, booking_date="2026-08-25")
            add_booking(
                cursor,
                booking_date="2026-08-26",
                booking_slot="18:30:00",
                table_no=3,
                customer_id=1,
                staff_id=2,
                num_guests=2,
            )
            update_booking(cursor, booking_id=1, new_slot="19:30:00")
            cancel_booking(cursor, booking_id=2)

            connection.commit()

    except Error as e:
        print("Error while connecting to MySQL:", e)

    finally:
        if "connection" in locals() and connection.is_connected():
            cursor.close()
            connection.close()
            print("\nMySQL connection closed.")


if __name__ == "__main__":
    main()
