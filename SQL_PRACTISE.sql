************************************************************ TABLE AND COLUMNS ********************************************************************************

Employees(emp_id, name, salary, dept_id, manager_id, hire_date)
Departments(dept_id, dept_name)
 
############## Find the 3rd highest salary in each department. ###################

#* LEARNING - use rank,row_number or dense rank whenever specified rank of the category wise is needed

WITH employee_cte AS (
SELECT
emp_id,
name,
salary,
dept_id,
ROW_NUMBER() OVER(PARTITION BY dept_id ORDER BY salary DESC) AS salary_rank
FROM employees
)

SELECT
e.emp_id, e.name, d.dept_name, e.salary
FROM employee_cte e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary_rank = 3;

############## List employees who earn more than their manager. ###################

#* LEARNING - need to do self join with the same table whenever there is req to compare between one record to another record in same table 


SELECT
e.emp_id, e.name, e.salary, m.name AS manager_name, m.salary AS manager_salary
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
WHERE e.salary > m.salary;

############## Rank employees by salary within each department. ###################

#* LEARNING - Can use rank, dense rank or row number whenever rank on specific category is needed

SELECT
e.emp_id,
e.name,
d.dept_name,
RANK() OVER(PARTITION BY d.dept_name ORDER BY e.salary DESC) AS salary_rank
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;


############## Get running total of salaries department-wise ordered by hire_date. ###################

#* LEARNING - We are using SUM with partition by which is similar to group by

SELECT
dept_id,
emp_id,
name,
salary,
hire_date,
SUM(salary) OVER(PARTITION BY dept_id ORDER BY hire_date) AS running_salary_total
FROM employees;

############## Find departments where the average salary is greater than the overall average ###################

#* LEARNING - First get the avg salary of the department by group by on dept_id and dep_name then in where condition use avg(group by salary) > (select avg(salary) from table)
which is nothing but total avg of the table inside inner query 

SELECT
e.dept_id,
d.dept_name,
AVG(e.salary) AS dept_avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY e.dept_id, d.dept_name
HAVING AVG(e.salary) > (
SELECT AVG(salary) FROM employees
);


************************************************************ TABLE AND COLUMNS ********************************************************************************

Customers(cust_id, cust_name, region)
Orders(order_id, cust_id, order_date, order_amount)

############## Find top 3 customers by total sales in each region. ###################


#* LEARNING - breaking the problem to chunks -
 1. Region wise and customer wise we need to get the sum(order_amount)
 2. Rank it over the region by total_sales which we got in above cte by  desc order
 3.  Now get the desired rank which we want 

WITH customer_sales AS (
SELECT
c.cust_id,
c.cust_name,
c.region,
SUM(o.order_amount) AS total_sales
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.cust_name, c.region
),

ranked_customers AS (
SELECT *,
RANK() OVER(PARTITION BY region ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales
)

SELECT *
FROM ranked_customers
WHERE sales_rank <= 3;
