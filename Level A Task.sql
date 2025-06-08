-- Create Customers Table
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    ContactName NVARCHAR(100),
    CompanyName NVARCHAR(100),
    City NVARCHAR(50),
    Country NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Fax NVARCHAR(20) NULL
);

-- Create Products Table
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100),
    SupplierID INT,
    Category NVARCHAR(50),
    UnitsInStock INT,
    UnitsOnOrder INT,
    Discontinued BIT
);

-- Create Orders Table
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    ShipCountry NVARCHAR(50),
    TotalAmount DECIMAL(10,2)
);


-- Create OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);

-- Create Employees Table
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    ManagerID INT NULL FOREIGN KEY REFERENCES Employees(EmployeeID)
);

-- Create Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100)
);

-- Insert Data into Customers
INSERT INTO Customers (ContactName, CompanyName, City, Country, PostalCode, Fax) VALUES 
('John Doe', 'Alpha Corp', 'Berlin', 'Germany', '10179', '123-456'),
('Alice Smith', 'Beta Ltd', 'London', 'UK', 'E1 6AN', NULL),
('Raj Patel', 'Gamma Enterprises', 'New York', 'USA', '10001', '789-123');

-- Insert Data into Products
INSERT INTO Products (ProductName, SupplierID, Category, UnitsInStock, UnitsOnOrder, Discontinued) VALUES 
('Chai', 1, 'Beverages', 25, 5, 0),
('Tofu', 2, 'Groceries', 8, 2, 0),
('Biscuits', 3, 'Snacks', 12, 0, 1);

-- Insert Data into Orders
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, ShipCountry, TotalAmount) VALUES 
(1, 3, '2025-06-01', 'Germany', 250.00),
(2, 4, '2025-06-02', 'UK', 180.00),
(3, 1, '2025-06-03', 'USA', 320.00);

-- Insert Data into OrderDetails
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES 
(1, 1, 2, 10.50),
(2, 2, 3, 12.00),
(3, 3, 5, 8.75);

-- Insert Data into Employees
INSERT INTO Employees (FirstName, LastName, ManagerID) VALUES 
('Michael', 'Brown', NULL),
('Sarah', 'Johnson', 1),
('David', 'White', 1),
('Emily', 'Davis', 2);

-- Insert Data into Suppliers
INSERT INTO Suppliers (SupplierName) VALUES 
('Specialty Biscuits, Ltd.'),
('Northwind Traders'),
('Exotic Liquids');
-- 1. List of all customers
SELECT * FROM Customers;

-- 2. List of all customers where company name ends in 'N'
SELECT * FROM Customers WHERE CompanyName LIKE '%N';

-- 3. List of all customers who live in Berlin or London
SELECT * FROM Customers WHERE City IN ('Berlin', 'London');

-- 4. List of all customers who live in UK or USA
SELECT * FROM Customers WHERE Country IN ('UK', 'USA');

-- 5. List of all products sorted by product name
SELECT * FROM Products ORDER BY ProductName;

-- 6. List of all products where product name starts with 'A'
SELECT * FROM Products WHERE ProductName LIKE 'A%';

-- 7. List of customers who ever placed an order
SELECT DISTINCT c.* FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID;

-- 8. List of Customers who live in London and have bought 'Chai'
SELECT DISTINCT c.* FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE c.City = 'London' AND p.ProductName = 'Chai';

-- 9. List of customers who never placed an order
SELECT * FROM Customers WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders);

-- 10. List of customers who ordered 'Tofu'
SELECT DISTINCT c.* FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE p.ProductName = 'Tofu';

-- 11. Details of the first order in the system
SELECT TOP 1 * FROM Orders ORDER BY OrderDate ASC;

-- 12. Details of the most expensive order (by total order amount)
SELECT o.OrderID, SUM(od.Quantity * od.UnitPrice) AS TotalAmount
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY o.OrderID
ORDER BY SUM(od.Quantity * od.UnitPrice) DESC;

-- 13. For each order, get the OrderID and average quantity of items in that order
SELECT OrderID, AVG(Quantity) AS AvgQuantity FROM OrderDetails GROUP BY OrderID;

-- 14. For each order, get OrderID, minimum quantity, and maximum quantity
SELECT OrderID, MIN(Quantity) AS MinQuantity, MAX(Quantity) AS MaxQuantity FROM OrderDetails GROUP BY OrderID;

-- 15. List of all managers and the total number of employees reporting to them
SELECT ManagerID, COUNT(EmployeeID) AS TotalEmployees FROM Employees GROUP BY ManagerID;

-- 16. Get the OrderID and total quantity for orders with total quantity > 300
SELECT OrderID, SUM(Quantity) AS TotalQuantity FROM OrderDetails GROUP BY OrderID HAVING SUM(Quantity) > 300;

-- 17. List of all orders placed on or after '1996-12-31'
SELECT * FROM Orders WHERE OrderDate >= '1996-12-31';

-- 18. List of all orders shipped to Canada
SELECT * FROM Orders WHERE ShipCountry = 'Canada';

-- 19. List of all orders with order total > 200
SELECT * FROM Orders WHERE TotalAmount > 200;

-- 20. List of countries and sales made in each country
SELECT ShipCountry, SUM(TotalAmount) AS TotalSales FROM Orders GROUP BY ShipCountry;

-- 21. List of Customer ContactName and number of orders they placed
SELECT c.ContactName, COUNT(o.OrderID) AS TotalOrders FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName;

-- 22. List of customer contact names who placed more than 3 orders
SELECT c.ContactName FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName HAVING COUNT(o.OrderID) > 3;

-- 23. List of discontinued products ordered between '1997-01-01' and '1998-01-01'
SELECT DISTINCT p.ProductName FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE p.Discontinued = 1 AND o.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- 24. List of employee first name, last name, supervisor first name, last name
SELECT e.EmployeeID, e.FirstName, e.LastName, s.FirstName AS SupervisorFirstName, s.LastName AS SupervisorLastName
FROM Employees e LEFT JOIN Employees s ON e.ManagerID = s.EmployeeID;

-- 25. List of Employees ID and total sales conducted by employee
SELECT EmployeeID, SUM(TotalAmount) AS TotalSales FROM Orders GROUP BY EmployeeID;

-- 26. List of employees whose first name contains 'a'
SELECT * FROM Employees WHERE FirstName LIKE '%a%';

-- 27. List of managers who have more than four employees reporting to them
SELECT ManagerID FROM Employees GROUP BY ManagerID HAVING COUNT(EmployeeID) > 4;

-- 28. List of Orders and ProductNames
SELECT o.OrderID, p.ProductName FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;

-- 29. List of orders placed by the best customer (highest total purchases)
SELECT TOP 1 o.* FROM Orders o
JOIN (SELECT TOP 1 CustomerID FROM Orders GROUP BY CustomerID ORDER BY SUM(TotalAmount) DESC) bestCustomer
ON o.CustomerID = bestCustomer.CustomerID;

-- 30. List of orders placed by customers who do not have a Fax number
SELECT * FROM Orders WHERE CustomerID IN (SELECT CustomerID FROM Customers WHERE Fax IS NULL);

-- 31. List of postal codes where the product 'Tofu' was shipped
SELECT DISTINCT c.PostalCode FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE p.ProductName = 'Tofu';

-- 32. List of product names that were shipped to France
SELECT DISTINCT p.ProductName FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.ShipCountry = 'France';

-- 33. List of product names and categories for the supplier 'Specialty Biscuits, Ltd.'
SELECT ProductName, Category FROM Products WHERE SupplierID = (SELECT SupplierID FROM Suppliers WHERE SupplierName = 'Specialty Biscuits, Ltd.');

-- 34. List of products that were never ordered
SELECT * FROM Products WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM OrderDetails);

-- 35. List of products where units in stock < 10 and units on order = 0
SELECT * FROM Products WHERE UnitsInStock < 10 AND UnitsOnOrder = 0;

-- 36. List of top 10 countries by sales
SELECT TOP 10 ShipCountry, SUM(TotalAmount) AS TotalSales FROM Orders GROUP BY ShipCountry ORDER BY TotalSales DESC;

-- 37. Number of orders each employee has taken for customers with CustomerIDs between 'A' and 'AO'
SELECT EmployeeID, COUNT(OrderID) AS TotalOrders FROM Orders WHERE CustomerID BETWEEN '1' AND '50' GROUP BY EmployeeID;

-- 38. Order date of most expensive order
SELECT TOP 1 OrderDate FROM Orders ORDER BY TotalAmount DESC;

-- 39. Product name and total revenue from that product
SELECT p.ProductName, SUM(od.Quantity * od.UnitPrice) AS TotalRevenue FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID GROUP BY p.ProductName ORDER BY TotalRevenue DESC;

-- 40. Supplier ID and number of products offered
SELECT SupplierID, COUNT(ProductID) AS TotalProducts FROM Products GROUP BY SupplierID;

-- 41. Top ten customers based on their business
SELECT TOP 10 CustomerID, SUM(TotalAmount) AS BusinessValue FROM Orders GROUP BY CustomerID ORDER BY BusinessValue DESC;

-- 42. Total revenue of the company
SELECT SUM(TotalAmount) AS TotalRevenue FROM Orders;
