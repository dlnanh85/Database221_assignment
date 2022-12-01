
-- 1 
drop procedure if exists ass.GoiDichVu;

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

-- 2
drop procedure if exists ass.ThongKeLuotKhach;

delimiter $$
CREATE PROCEDURE ass.ThongKeLuotKhach (
	IN branch_identity varchar(6),
	IN year_no YEAR,
	OUT customer_statistic int,
	OUT month_no varchar(2)
)
	
BEGIN
	SELECT DISTINCT YEAR(checkin_date) AS 'YEAR', MONTH(checkin_date) AS 'MONTH', COUNT(room_order_id)
	FROM Room_order INNER JOIN Rent_room ON Room_order.id = Rent_room.room_order_id  WHERE status = 1 AND branch_id = branch_identity AND year_no = YEAR(checkin_date)
	GROUP BY YEAR(checkin_date), MONTH(checkin_date);
END
$$
delimiter ;

-- TESTING SCRIPTS
-- Test Procedure 1
-- CALL ass.GoiDichVu('KH000005', @package_type, @customer_limitation, @start_date, @end_date, @remain_date);
-- SELECT @remain_date; 

-- Test Procedure 2
CALL ass.Thongkesomething('CN4', '2022', @customer_statistic, @month_no);