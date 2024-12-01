# *********************************************************** PIZZA SALES *****************************************************************************************

# ****************************************************** CREATING DATABASE *****************************************************************************************

Create Database Pizza_sales;

# ****************************************************** USING DATABASE ********************************************************************************************

Use Pizza_sales;

# ***************************************************** CREATING TABLES AND IMPORTING DATA FROM CSV FILES ************************************************************

# ***************************************************** PIZZA TYPES TABLE *********************************************************************************************

# This table conatins information about Pizza Types.

Create table Pizza_Types(Pizza_type_id varchar(255) Primary Key,
                         Pizza_name varchar(255),
                         Category varchar(255),
                         Ingrediants varchar(255));
                         
Select * from Pizza_Types;

#****************************************************** PIZZAS TABLE ****************************************************************************************************

# This table conatins information about various Pizzas.

Create table Pizzas(Pizza_id varchar(255) Primary Key,
                    Pizza_type_id varchar(255),
                    Pizza_size varchar(255),
                    Pizza_Price decimal(4,2),
                    foreign key(Pizza_type_id) references Pizza_Types(Pizza_type_id) on update cascade on delete cascade);
                    
Select * from Pizzas;

# **************************************************** ORDERS TABLE ****************************************************************************************************

# This table conatins information about Orders.

Create table orders(Order_id Int Primary Key,
					Order_date Date,
                    Order_time Time);
                    
Select * from Orders;

# ***************************************************** ORDER DETAILS TABLE **********************************************************************************************

# This table contains order details of various orders.

Create table order_details(Order_details_id Int Primary Key,
                           Order_id int,
                           Pizza_id varchar(255),
                           Quantity tinyint,
                           foreign key(Order_id) references Orders(order_id) on update cascade on delete cascade,
                           foreign key(Pizza_id) references Pizzas(Pizza_id) on update cascade on delete cascade);

Select * from Order_details;

# **************************************************** QUERY SOLVING ********************************************************************************************************

# *************** BASIC QUESTIONS ********************************

-- 1Q)Retrieve the total number of orders placed.

Select count(*) as Total_Orders from Orders;

# ****************************************************************************************************************************************

-- 2Q)Calculate the total revenue generated from pizza sales.

With cte_1 as (Select *, (Pizza_Price * quantity) as Revenue from Pizzas 
     Left Join Order_details
     using(Pizza_id))
     
Select sum(Revenue)  as Total_Revenue from cte_1;
     
# **********************************************************************************************************************************************

-- 3Q)Identify the highest-priced pizza.

Select Pizza_name,Pizza_Price from Pizzas
   Join Pizza_Types
   Using(Pizza_type_id)
   order by Pizza_Price desc
   limit 1;

# **************************************************************************************************************************************************

-- 4Q)Identify the most common pizza size ordered.

Select Pizza_size,count(order_id) as Total_orders from Pizzas
   Join Order_details
   using(Pizza_id)
   Group by Pizza_size
   Order by Total_orders desc
   limit 1;

# *************************************************************************************************************************************************

-- 5Q)List the top 5 most ordered pizza types along with their quantities.

Select Pizza_name,sum(Quantity) as Total_quantity from Pizzas
 Join Order_details
 using(Pizza_id)
 Join Pizza_Types
 using(Pizza_type_id)
 Group by Pizza_name
 order by Total_quantity desc
 limit 5;
 
# *******************************************************************************************************************************************************

# ************** INTERMEDIATE QUESTIONS ***************************
 
 -- 5Q) Join the necessary tables to find the total quantity of each pizza category ordered.
 
 Select Category,sum(Quantity) as Total_Quantity from Pizzas
      Left Join Order_details
      using(Pizza_id)
      Left Join Pizza_Types
      using(Pizza_type_id)
      Group by Category;
      
# *********************************************************************************************************************************************************

-- 6Q) Determine the distribution of orders by hour of the day.     

With cte_1 as (Select *, hour(Order_time) as Hour_of_Day from Orders)

Select Hour_of_Day,concat(round(count(*)/(select count(*) from Orders)*100,2),"%") as Total_orders_of_hour from cte_1
             group by Hour_of_Day;

# *********************************************************************************************************************************************************

-- 7Q) Join relevant tables to find the category-wise distribution of pizzas.

Select Category,concat(round((count(*)/(select count(*) from Pizza_types)*100),1),"%") as Distribution from Pizza_Types
        Group by Category;

# *********************************************************************************************************************************************************

-- 8Q) Group the orders by date and calculate the average number of pizzas ordered per day.

With Cte_1 as (Select Order_date,sum(Quantity) as Pizzas_ordered from Orders
    Join Order_details
    using(Order_id)
    Group by Order_date)
    
Select round(avg(Pizzas_ordered),0) as Average_orders_per_day from cte_1;
    
# ***************************************************************************************************************************************************************

-- 9Q) Determine the top 3 most ordered pizza types based on revenue.

With cte_1 as (Select *, (Pizza_Price * quantity) as Revenue from Pizzas 
     Left Join Order_details
     using(Pizza_id)
     Join Pizza_Types
     using(Pizza_Type_id))
     
Select Pizza_name,sum(Revenue) as Total_Revenue from cte_1
        Group by Pizza_name
        order by Total_Revenue desc
        limit 3;
        
# ******************************************************************************************************************************************************************

# ****************** ADVANCED QUESTIONS ******************************

-- 10Q) Calculate the percentage contribution of each pizza type to total revenue.

With cte_1 as (Select *, (Pizza_Price * quantity) as Revenue from Pizzas 
     Left Join Order_details
     using(Pizza_id)
     Join Pizza_Types
     using(Pizza_Type_id))
     
Select Pizza_name,concat(round(sum(revenue)/(Select sum(Revenue) from cte_1)*100,2),"%") as Percentage from cte_1
     Group by Pizza_name;

# ******************************************************************************************************************************************************************

-- 11Q) Analyze the cumulative revenue generated over time.

With cte_1 as (Select order_date,sum(Pizza_price * Quantity) as Revenue from order_details
Join Pizzas
Using(Pizza_id)
Join Orders
Using(Order_id)
Group by Order_date)

Select order_date, sum(Revenue) over (order by  Order_date) as Cummulative_Revenue from cte_1;

# ***********************************************************************************************************************************************************************

-- 12Q) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

With cte_1 as (Select Category,Pizza_name, sum(Pizza_Price * quantity) as Revenue from Pizzas 
     Left Join Order_details
     using(Pizza_id)
     Left Join Pizza_Types
     Using(Pizza_type_id)
     Group by Pizza_name,Category),
     
cte_2 as (Select *, row_number() over (partition by Category order by Revenue desc) as rnk from cte_1)

Select Category,Pizza_name,Revenue from cte_2 where rnk In (1,2,3);

# *************************************************************************************************************************************************************************
