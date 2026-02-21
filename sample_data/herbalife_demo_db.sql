-- Customers table
CREATE TABLE Customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT,
    contact TEXT,
    region TEXT
);
INSERT INTO Customers VALUES (2001, 'Alice Smith', 'alice@example.com', 'West');
INSERT INTO Customers VALUES (2002, 'Bob Lee', 'bob@example.com', 'East');
INSERT INTO Customers VALUES (2003, 'Carlos Diaz', 'carlos@example.com', 'South');

-- Products table
CREATE TABLE Products (
    product_id INTEGER PRIMARY KEY,
    name TEXT,
    category TEXT,
    price REAL
);
INSERT INTO Products VALUES (3001, 'Herbalife Formula 1', 'Shake', 39.99);
INSERT INTO Products VALUES (3002, 'Herbalife Tea Concentrate', 'Tea', 24.99);
INSERT INTO Products VALUES (3003, 'Herbalife Protein Bar', 'Snack', 19.99);

-- Orders table
CREATE TABLE Orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    order_date TEXT
);
INSERT INTO Orders VALUES (1001, 2001, 3001, 2, '2026-02-01');
INSERT INTO Orders VALUES (1002, 2002, 3002, 1, '2026-02-02');
INSERT INTO Orders VALUES (1003, 2003, 3003, 5, '2026-02-03');
INSERT INTO Orders VALUES (1004, 2001, 3002, 3, '2026-02-04');
