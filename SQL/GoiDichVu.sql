-- 1 
DROP PROCEDURE IF EXISTS assignment2.GoiDichVu;

DELIMITER $$
CREATE PROCEDURE GoiDichVu (
	IN customer_id char(8),
	OUT package_type varchar(255),
	OUT customer_limitation int,
    OUT start_date date,
    OUt end_date timestamp,
	OUT remain_date int
)
	
BEGIN
	SELECT package_name INTO package_type FROM Package_order INNER JOIN Package ON Package_order.package_name = Package.name WHERE Package_order.customer_id = customer_id;
	SELECT total_customer INTO customer_limitation FROM Package_order INNER JOIN Package ON Package_order.package_name = Package.name WHERE Package_order.customer_id = customer_id;
	SELECT Package_order.start_date  INTO start_date FROM Package_order INNER JOIN Package ON Package_order.package_name = Package.name WHERE Package_order.customer_id = customer_id;
	SELECT DATE_ADD(Package_order.start_date, INTERVAL (
		SELECT total_day FROM Package_order INNER JOIN Package ON Package_order.package_name = Package.name WHERE Package_order.customer_id = customer_id
	) DAY) INTO end_date FROM Package_order INNER JOIN Package ON Package_order.package_name = Package.name WHERE Package_order.customer_id = customer_id;
	SELECT DATEDIFF(end_date, CURRENT_DATE())  INTO remain_date FROM Package_order INNER JOIN Package ON Package_order.package_name = Package.name WHERE Package_order.customer_id = customer_id;
END 
$$
DELIMITER ;


-- CALLING PROCEDURE GOIDICHVU
CALL assignment2.GoiDichVu('KH000005', @package_type, @customer_limitation, @start_date, @end_date, @remain_date);
SELECT @package_type, @customer_limitation, @start_date, @end_date, @remain_date; 