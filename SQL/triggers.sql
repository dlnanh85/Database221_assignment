USE assignment2;

DROP TRIGGER IF EXISTS Package_order_trigger;
DROP TRIGGER IF EXISTS PLUS_point_trigger_UPDATE;
DROP TRIGGER IF EXISTS PLUS_point_trigger_INSERT;
DROP TRIGGER IF EXISTS UP_RANK_UPDATE;
DROP TRIGGER IF EXISTS UP_RANK_INSERT;
DROP TRIGGER IF EXISTS Room_order_trigger;
DROP TRIGGER IF EXISTS CHECK_PACKAGE;

-- TRIGGER 1A
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
END$$
DELIMITER ;

-- TRIGGER 1B
DELIMITER $$
CREATE TRIGGER Room_order_trigger
BEFORE INSERT ON Rent_room
FOR EACH ROW
BEGIN	
	DECLARE newrank INT;
    DECLARE sumcost INT;
	DECLARE myroom_code char(16);
    DECLARE mybranch_id varchar(6);
    DECLARE myroom_type_id INT;
    DECLARE bookerid char(8);
    SET myroom_code = (SELECT NEW.room_code);
    SET mybranch_id = (SELECT NEW.branch_id);
    
    SET myroom_type_id := (SELECT room_type_id FROM Room WHERE branch_id = mybranch_id AND myroom_code = code);
	SET sumcost := (SELECT price FROM branch_room_type WHERE ( branch_id = mybranch_id AND room_type_id = myroom_type_id));
    
    UPDATE Room_order SET cost = cost + sumcost*0.5 WHERE Room_order.id = NEW.room_order_id ;
	
    SET bookerid := (SELECT customer_id FROM Room_order WHERE Room_order.id = NEW.room_order_id);

	SET newrank := (SELECT Customer.customer_rank FROM Customer WHERE bookerid = Customer.id);
	IF(newrank = 1) THEN 
		UPDATE Room_order SET Room_order.cost = sumcost WHERE Room_order.id = NEW.room_order_id ;
    ELSEIF(newrank = 2) THEN 
		UPDATE Room_order SET Room_order.cost = sumcost*0.9 WHERE Room_order.id = NEW.room_order_id ;
    ELSEIF(newrank = 3) THEN 
		UPDATE Room_order SET Room_order.cost = sumcost*0.85 WHERE Room_order.id = NEW.room_order_id ;
    ELSEIF(newrank = 4) THEN 
		UPDATE Room_order SET Room_order.cost = sumcost*0.80 WHERE Room_order.id = NEW.room_order_id ;
    END IF;
END$$
DELIMITER ;

-- TRIGGER 1C - PLUS point
DELIMITER $$
CREATE TRIGGER PLUS_point_trigger_UPDATE
BEFORE UPDATE ON room_order
FOR EACH ROW
BEGIN
	DECLARE bonuspoint INT;
	IF(NEW.status = 1) THEN
		SET bonuspoint = NEW.cost / 1000000;
        UPDATE Customer SET point = point + bonuspoint WHERE id = NEW.customer_id;
    END IF;
END $$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER PLUS_point_trigger_INSERT
BEFORE INSERT ON Room_order
FOR EACH ROW
BEGIN
	DECLARE bonuspoint INT;
	IF(NEW.status = 1) THEN
		SET bonuspoint = NEW.cost / 1000000;
        UPDATE Customer SET point = point + bonuspoint WHERE id = NEW.customer_id;
    END IF;
END $$
DELIMITER ;

-- TRIGGER 1D
DELIMITER $$
CREATE TRIGGER UP_RANK_UPDATE
BEFORE UPDATE ON Customer
FOR EACH ROW
BEGIN
    IF(NEW.point > 50) THEN 
		SET NEW.customer_rank = 2;
    ELSEIF(NEW.point > 100) THEN 
		SET NEW.customer_rank = 3;
    ELSEIF(NEW.point > 1000) THEN
		SET NEW.customer_rank = 4;
	ELSE 
		SET NEW.customer_rank = 1;
	END IF;
END $$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER UP_RANK_INSERT
BEFORE INSERT ON Customer
FOR EACH ROW
BEGIN
    IF(NEW.point > 50) THEN 
		SET NEW.customer_rank = 2;
    ELSEIF(NEW.point > 100) THEN 
		SET NEW.customer_rank = 3;
    ELSEIF(NEW.point > 1000) THEN
		SET NEW.customer_rank = 4;
	ELSE 
		SET NEW.customer_rank = 1;
	END IF;
END $$
DELIMITER ;

-- TRIGGER 2 - Package on the same day
DELIMITER $$
CREATE TRIGGER CHECK_PACKAGE
BEFORE INSERT ON Package_order
FOR EACH ROW
BEGIN
	DECLARE datenew DATE;
    SET datenew := (SELECT NEW.start_date );
    IF EXISTS(SELECT start_date FROM Package_order WHERE customer_id = NEW.customer_id AND NEW.package_name = package_name) THEN
				IF EXISTS (SELECT start_date FROM (SELECT start_date FROM Package_order WHERE customer_id = NEW.customer_id AND NEW.package_name = package_name) AS T WHERE DATE_ADD(start_date, INTERVAL 1 YEAR) >datenew ) THEN
					SIGNAL SQLSTATE '45000' 
					SET MESSAGE_TEXT = "CONFLICT PACKAGE";
				END IF;
    END IF;
END$$
DELIMITER ;
        