-- =====================================================================
-- ADVANCED SQL & DATABASE LEVEL LOGIC PORTFOLIO
-- Dialect: PostgreSQL / MySQL Compatible
-- =====================================================================

-- ---------------------------------------------------------------------
-- CASE 1: Analytical Reporting using Window Functions
-- Target: Calculate running totals, monthly growth, and rank products 
--         within categories without using subqueries where possible.
-- ---------------------------------------------------------------------

SELECT 
    order_id,
    customer_id,
    order_date,
    product_category,
    order_amount,
    -- 1. Running total of sales within each product category over time
    SUM(order_amount) OVER (
        PARTITION BY product_category 
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_by_category,
    
    -- 2. Comparing current order amount with the previous order from the same customer
    LAG(order_amount, 1, 0.00) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) AS previous_customer_order_amount,
    
    -- 3. Dynamic ranking of products inside their category based on revenue generated
    DENSE_RANK() OVER (
        PARTITION BY product_category 
        ORDER BY order_amount DESC
    ) AS product_revenue_rank
FROM sales_orders;


-- ---------------------------------------------------------------------
-- CASE 2: User-Defined Function (UDF) for Custom Business Logic
-- Target: Calculate a progressive loyalty discount rate based on the 
--         customer's total historical spending and account age.
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION calculate_loyalty_discount(
    total_spent NUMERIC, 
    account_age_months INT
) 
RETURNS NUMERIC 
DETERMINISTIC
BEGIN
    DECLARE discount_rate NUMERIC DEFAULT 0.00;
    
    -- Business logic rules for dynamic discount calculation
    IF total_spent > 50000 AND account_age_months >= 12 THEN
        SET discount_rate = 0.15; -- 15% VIP discount
    ELSEIF total_spent > 20000 OR account_age_months >= 6 THEN
        SET discount_rate = 0.07; -- 7% Loyal customer discount
    ELSEIF total_spent > 5000 THEN
        SET discount_rate = 0.03; -- 3% Standard discount
    END IF;
    
    RETURN discount_rate;
END;


-- ---------------------------------------------------------------------
-- CASE 3: Database Automation via Trigger and Auditing
-- Target: Automatically maintain an immutable log table whenever a 
--         product's stock level drops below the critical threshold.
-- ---------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_audit_low_stock
AFTER UPDATE ON inventory_products
FOR EACH ROW
BEGIN
    -- Check if the stock dropped below the critical threshold (e.g., 10 items)
    IF NEW.stock_quantity < 10 AND OLD.stock_quantity >= 10 THEN
        INSERT INTO inventory_audit_logs (
            product_id, 
            old_stock, 
            new_stock, 
            alert_level, 
            logged_at
        )
        VALUES (
            NEW.product_id, 
            OLD.stock_quantity, 
            NEW.stock_quantity, 
            'CRITICAL_LOW_STOCK', 
            NOW()
        );
    END IF;
END;
