DROP TRIGGER IF EXISTS Package_order_trigger;

DELIMITER $$
CREATE TRIGGER Package_order_trigger
BEFORE INSERT ON Package_order
FOR EACH ROW
BEGIN
	DECLARE newrank int;
    
	SET newrank := (SELECT Customer.customer_rank FROM Customer WHERE (NEW.customer_id = Customer.id));
    
    IF (newrank = 1) THEN 
		SET NEW.cost = NEW.cost;
        
    ELSEIF (newrank = 2) THEN 
        SET NEW.cost = NEW.cost * 0.9;
        
    ELSEIF (newrank = 3) THEN 
        SET NEW.cost = NEW.cost * 0.85;
        
    ELSEIF (newrank = 4) THEN 
        SET NEW.cost = NEW.cost * 0.8;
        
    END IF;
END $$
DELIMITER ;

-- ------------------------------ 
DELIMITER $$
CREATE TRIGGER Room_order_trigger
AFTER INSERT ON Rent_room
FOR EACH ROW
BEGIN	
	
    
	SET roomlist := SELECT branch_id,room_code FROM Rent_room WHERE NEW.room_order_id = room_order_id;
    SET newroomlist := SELECT branch_id,room_type_id FROM Room WHERE (roomlist.roomcode = Room.code AND roomlist.branch_id = Room.branch_id);
    SET sumcost := SELECT SUM(price) FROM Branch_room_type WHERE (newroomlist.branch_id = Room.branch_id AND newroomlist.room_type_id = Room.room_type_id);
    
    SET @bookerid := SELECT customer_id FROM Room_order WHERE Room_order.id = NEW.room_order_id;
	DECLARE newrank INT;
	SET newrank := (SELECT Customer.customer_rank FROM Customer WHERE bookerid = Customer.id);
	IF(newrank = 1) THEN SET Room_order.cost = @sumcost FROM Room_order WHERE Room_order.id = NEW.room_order_id ;
    IF(newrank = 2) THEN SET Room_order.cost = @sumcost * 0.9 FROM Room_order WHERE Room_order.id = NEW.room_order_id ;
    IF(newrank = 3) THEN SET Room_order.cost = @sumcost * 0.85 FROM Room_order WHERE Room_order.id = NEW.room_order_id ;
    IF(newrank = 4) THEN SET Room_order.cost = @sumcost * 0.8 FROM Room_order WHERE Room_order.id = NEW.room_order_id ;
    
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER PLUS_point_trigger
AFTER UPDATE ON Room_order
FOR EACH ROW
BEGIN
	IF(NEW.status = 1) THEN
    BEGIN
		DECLARE @bonuspoint INT;
		SET @bonuspoint = NEW.cost / 1000000;
        UPDATE Customer SET point = point + @bonuspoint WHERE Customer.id = NEW.customer_id;
    END;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER UP_RANK
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
	IF(NEW.point > 50) THEN UPDATE Customer SET customer_rank = 1 WHERE Customer.id = NEW.customer_id;
    IF(NEW.point > 100) THEN UPDATE Customer SET customer_rank = 2 WHERE Customer.id = NEW.customer_id;
    IF(NEW.point > 1000) UPDATE Customer SET customer_rank = 3 WHERE Customer.id = NEW.customer_id;
END $$
DELIMITER ;
