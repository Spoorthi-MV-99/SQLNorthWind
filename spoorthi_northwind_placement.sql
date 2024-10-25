---
#### Question 1: List of Customers and Their Orders
### Write an SQL query to list all customers and their corresponding order IDs. Include customers who have not placed any orders.
---
SELECT 
    customers.customer_id, 
    customers.company_name, 
    orders.order_id
FROM 
    customers
LEFT JOIN 
    orders ON customers.customer_id = orders.customer_id
ORDER BY 
    customers.customer_id;
---
#### Question 2: Total Sales for Each Product
#### Task: Write an SQL query to find the total sales amount for each product, including the product name
---

SELECT
	products.product_id,
	products.product_name, 
    SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS total_sales
FROM 
    order_details
JOIN 
    products ON order_details.product_id = products.product_id
GROUP BY 
    products.product_id, products.product_name;

---
#### Question 3: Employees and the Number of Orders They Handled
### Task: Write an SQL query to count the number of orders handled by each employee. Include the employee's first and last name
---

SELECT 
	e.employee_id , 
	e.last_name,
    e. first_name,
    count(o.order_id) as no_of_orders
FROM
	employees e
LEFT JOIN
    orders o on e.employee_id = o.employee_id
GROUP BY 
	e.employee_id, e.last_name, e.first_name;
    
---
#### Question 4: Customers Who Have Not Ordered in 1998
### Task: Identify all customers who did not place an order in 1998.
---

SELECT
	c.customer_id,
    c.contact_name,
    o.order_date
FROM 
	customers c
LEFT JOIN
	orders o on c.customer_id = o.customer_id
    AND YEAR(o.order_date) = 1998
WHERE o. order_id IS NULL
ORDER BY c.customer_id;


----
#### Question 5: Highest Selling Product Categories
#### Task: Find the highest selling product categories based on total sales volume.
----
SELECT
	categories.category_id,
    categories.category_name,
    SUM(order_details.unit_price * order_details.quantity * (1- order_details.discount)) AS total_sales
FROM
	order_details
JOIN
	products on order_details.product_id = products.product_id
JOIN
	categories on products.product_id = categories.category_id 
GROUP BY
	 categories.category_id, categories.category_name
ORDER BY
	total_sales DESC;

---
#### Question 6: List Suppliers and Their Products Count
#### Task: Write an SQL query to list all suppliers along with the number of products they supply. Include suppliers who do not supply any products.
---
SELECT
	suppliers.supplier_id,
    suppliers.company_name,
    count(products.product_id) as product_count
FROM
	suppliers
LEFT JOIN
	products on suppliers.supplier_id = products.supplier_id
GROUP BY
	suppliers.supplier_id,suppliers.company_name;
    
 ----   
#### Question 7: Customers with Orders Over $500
#### Task: Identify customers whose total order amount exceeds $500. Show customer ID and total amount.
----
SELECT 
    customers.customer_id, 
    customers.company_name,  -- Change 'contact_name' to the correct column if needed
    SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS total_sales
FROM 
    order_details
JOIN 
    orders ON order_details.order_id = orders.order_id
JOIN 
    customers ON orders.customer_id = customers.customer_id
GROUP BY 
    customers.customer_id, customers.company_name  -- Include company_name in GROUP BY
HAVING 
    SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) > 500
ORDER BY 
    total_sales ASC;  
   
   
----
#### Question 8: Employees with More Than 50 Orders
#### Task: Write an SQL query to find employees who have processed more than 50 orders. Include employee ID, last name, and the number of orders processed.
----
SELECT 
	employees.employee_id,
    employees.last_name,
    count(orders.order_id) AS no_of_orders
FROM
	employees
LEFT JOIN
	orders on employees.employee_id = orders.employee_id
GROUP BY 
	employees.employee_id, employees.last_name
HAVING
	count(orders.order_id) > 50
ORDER BY
	no_of_orders ASC;


----  
#### Question 9: Detailed Order Information
#### Task: Provide detailed information for each order, including order ID, customer company name, employee last name, and total order amount.
----
SELECT 
	orders.order_id,
    customers.company_name,
    employees.last_name,
    SUM(order_details.unit_price * order_details.quantity * (1-order_details.discount)) as total_order_amount
FROM
	orders
JOIN
	customers on orders.customer_id = customers.customer_id
JOIN
	employees on orders.employee_id = employees.employee_id
JOIN
	order_details on orders.order_id = order_details.order_id
GROUP BY
	orders.order_id, customers.company_name, employees.last_name;




----
#### Question 10: Average Product Price by Category
#### Task: Calculate the average price of products in each category.
----
SELECT 
    categories.category_id, 
    categories.category_name, 
    AVG(products.unit_price) AS average_price
FROM 
    products
JOIN 
    categories ON products.category_id = categories.category_id
GROUP BY 
    categories.category_id, categories.category_name;
    
    
----
#### Question 11: Top 3 Most Frequently Ordered Products Per Category
#### Task: Write an SQL query to find the top three most frequently ordered products in each category based on the quantity ordered.
----

WITH ProductOrderRanking AS (
    SELECT 
        categories.category_id,
        categories.category_name,
        products.product_id,
        products.product_name,
        SUM(order_details.quantity) AS total_quantity,
        ROW_NUMBER() OVER (PARTITION BY categories.category_id ORDER BY SUM(order_details.quantity) DESC) AS ranks
    FROM 
        order_details
    JOIN 
        products ON order_details.product_id = products.product_id
    JOIN 
        categories ON products.category_id = categories.category_id
    GROUP BY 
        categories.category_id, categories.category_name, products.product_id, products.product_name
)
SELECT 
    category_id, 
    category_name, 
    product_id, 
    product_name, 
    total_quantity
FROM 
    ProductOrderRanking
WHERE 
    ranks <= 3
ORDER BY 
    category_id, ranks;



----
#### Question 12: Sales Trends by Quarter
#### Task: Calculate the total sales for each quarter of each year and identify quarters that showed a growth in sales over the previous quarter.
----

WITH QuarterlySales AS (
    SELECT
        YEAR(orders.order_date) AS year,
        QUARTER(orders.order_date) AS quarter,
        SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS total_sales
    FROM
        orders
    JOIN
        order_details ON orders.order_id = order_details.order_id
    GROUP BY
        YEAR(orders.order_date), QUARTER(orders.order_date)
)
SELECT
    year,
    quarter,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year, quarter) AS previous_quarter_sales,
    CASE 
        WHEN total_sales > LAG(total_sales) OVER (ORDER BY year, quarter) THEN 'Growth'
        ELSE 'No Growth'
    END AS trend
FROM
    QuarterlySales
ORDER BY
    year, quarter;
    

----
#### Question 13: Customer Retention Rate
#### Task: Write an SQL query to calculate the retention rate of customers from year to year.
----

WITH CustomersPerYear AS (
    SELECT 
        customers.customer_id, 
        YEAR(orders.order_date) AS order_year
    FROM 
        customers
    JOIN 
        orders ON customers.customer_id = orders.customer_id
    GROUP BY 
        customers.customer_id, YEAR(orders.order_date)
),
CustomerRetention AS (
    SELECT 
        c1.order_year AS year, 
        COUNT(DISTINCT c1.customer_id) AS total_customers,
        COUNT(DISTINCT c2.customer_id) AS retained_customers
    FROM 
        CustomersPerYear c1
    LEFT JOIN 
        CustomersPerYear c2 ON c1.customer_id = c2.customer_id 
        AND c1.order_year = c2.order_year - 1
    GROUP BY 
        c1.order_year
)
SELECT 
    year,
    total_customers,
    retained_customers,
    (retained_customers / total_customers) * 100 AS retention_rate
FROM 
    CustomerRetention
WHERE 
    retained_customers IS NOT NULL
ORDER BY 
    year;

----
#### Question 14: Total Sales Weighted by Order Freight Cost
#### Task: Determine total sales weighted by the freight cost of each order.
----

SELECT 
    SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount) * orders.freight) AS total_weighted_sales
FROM 
    order_details
JOIN 
    orders ON order_details.order_id = orders.order_id;
