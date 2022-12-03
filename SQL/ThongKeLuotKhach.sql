-- 2
DROP PROCEDURE IF EXISTS assignment2.ThongKeLuotKhach;

delimiter $$
CREATE PROCEDURE assignment2.ThongKeLuotKhach (
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


-- CALLING PROCEDURE THONGKELUOTKHACH
CALL assignment2.ThongKeLuotKhach('CN4', '2022', @customer_statistic, @month_no);