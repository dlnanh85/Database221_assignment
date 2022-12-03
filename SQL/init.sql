DROP DATABASE assignment2;

CREATE DATABASE IF NOT EXISTS assignment2;

USE assignment2;

-- 1
CREATE TABLE Branch (
  id varchar(6) PRIMARY KEY,
  province varchar(255) NOT NULL,
  address varchar(255) NOT NULL,
  phone varchar(11),
  email varchar(255)
);

-- GENERATING Branch_id
CREATE TABLE Branch_seq (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY
);

DELIMITER $$
CREATE TRIGGER Branch_id_gen
BEFORE INSERT ON Branch
FOR EACH ROW
BEGIN
  INSERT INTO Branch_seq VALUES (NULL);
  SET NEW.id = CONCAT('CN', LAST_INSERT_ID());
END $$
DELIMITER ;
-- END: GENERATING Branch_id

-- 2
CREATE TABLE Branch_image (
  branch_id varchar(6),
  image varchar(255),
  PRIMARY KEY (branch_id, image)
);

-- 3
CREATE TABLE Zone (
  branch_id varchar(6),
  name varchar(255),
  PRIMARY KEY (branch_id, name)
);

-- 4
CREATE TABLE Room_type (
  id int PRIMARY KEY AUTO_INCREMENT,
  name varchar(255),
  area float COMMENT 'Unit: meter square',
  description varchar(255) DEFAULT NULL,
  customer_no int NOT NULL
	CHECK (customer_no >= 1 AND customer_no <= 10)
);

-- 5
CREATE TABLE Bed (
  room_type_id int,
  size decimal(2,1),
  number int NOT NULL DEFAULT 1
	CHECK (number >= 1 AND number <= 10),
  PRIMARY KEY (room_type_id, size)
);

-- 6
CREATE TABLE Branch_room_type (
  room_type_id int,
  branch_id varchar(6),
  price int NOT NULL COMMENT 'Unit: 1000VND',
  PRIMARY KEY (room_type_id, branch_id)
);

-- 7
CREATE TABLE Room (
  branch_id varchar(6),
  code char(3),
  zone_name varchar(255),
  room_type_id int,
  PRIMARY KEY (branch_id, code)
);

-- 8
CREATE TABLE Supply_type (
  id char(6) PRIMARY KEY COMMENT 'VT[0-9][0-9][0-9][0-9]',
  name varchar(255) NOT NULL
);

-- 9
CREATE TABLE Room_type_supply_type (
  room_type_id int,
  supply_type_id char(6),
  number int NOT NULL DEFAULT 1
	CHECK (number >= 1 AND number <= 20),
  PRIMARY KEY (supply_type_id, room_type_id)
);

-- 10
CREATE TABLE Supply (
  branch_id varchar(6),
  room_code char(3),
  supply_type_id char(6),
  id int CHECK (id > 0),
  status varchar(255),
  PRIMARY KEY (branch_id, supply_type_id, id)
);

-- 11
CREATE TABLE Supply_provider (
  id char(7) PRIMARY KEY COMMENT 'NCC[0-9][0-9][0-9][0-9]',
  name varchar(255) UNIQUE,
  email varchar(255),
  address varchar(255)
);

-- 12
CREATE TABLE Supply_providing (
  supply_provider_id char(7),
  branch_id varchar(6),
  supply_type_id char(6),
  PRIMARY KEY (branch_id, supply_type_id)
);

-- 13
CREATE TABLE Customer (
  id char(8) PRIMARY KEY COMMENT 'in form of KH[0-9][0-9][0-9][0-9][0-9][0-9]',
  ssn varchar(12) UNIQUE NOT NULL,
  name varchar(255) NOT NULL,
  phone varchar(11) UNIQUE NOT NULL,
  email varchar(255) UNIQUE,
  username varchar(255) UNIQUE,
  passignment2word varchar(255),
  point int NOT NULL DEFAULT 0 CHECK (point >= 0),
  customer_rank int DEFAULT 1 COMMENT '1-potential, 2-loyal, 3-vip, 4-supervip'
	CHECK (customer_rank >= 1 AND customer_rank <= 4)
);

-- 14
CREATE TABLE Package (
  name varchar(255) PRIMARY KEY,
  total_day int NOT NULL
	CHECK (total_day >= 1 AND total_day <= 100),
  total_customer int NOT NULL
	CHECK (total_customer >= 1 AND total_customer <= 10),
  price float NOT NULL COMMENT 'Unit: 1000VND'
);

-- 15
CREATE TABLE Package_order (
  customer_id char(8),
  package_name varchar(255),
  buy_time timestamp DEFAULT current_timestamp,
  start_date date NOT NULL COMMENT 'this package will expired 1 year after start_date',
  cost int NOT NULL COMMENT 'Unit: 1000VND',
  PRIMARY KEY (customer_id, package_name, buy_time),
  CHECK (start_date >= DATE(buy_time))
);

-- 16
CREATE TABLE Room_order (
  id char(16) PRIMARY KEY,
  order_time timestamp NOT NULL DEFAULT current_timestamp,
  checkin_date date NOT NULL,
  checkout_date date NOT NULL,
  status int NOT NULL DEFAULT 0 COMMENT '0-unpaid, 1-paid, 2-cancel not refund yet, 3-cancel refund already'
	  CHECK (status >= 0 AND status <= 3),
  cost int NOT NULL DEFAULT 0 COMMENT 'Unit: 1000VND',
  customer_id char(8),
  package_name varchar(255),
  CHECK (checkin_date > DATE(order_time) AND checkout_date > checkin_date)
);

-- GENERATING Room_order_id
CREATE TABLE Room_order_seq (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY
);

DELIMITER $$
CREATE TRIGGER Room_order_id_gen
BEFORE INSERT ON Room_order
FOR EACH ROW
BEGIN
  INSERT INTO Room_order_seq VALUES (NULL);
  SET NEW.id = CONCAT('DP', REPLACE(DATE(NEW.order_time), '-', ''), LPAD(LAST_INSERT_ID(), 6, '0'));
END $$
DELIMITER ;
-- END: GENERATING Room_order_id

-- 17
CREATE TABLE Rent_room (
  room_order_id char(16),
  branch_id varchar(6),
  room_code char(3),
  PRIMARY KEY (room_order_id, branch_id, room_code)
);

-- 18
CREATE TABLE Receipt (
  id varchar(255) PRIMARY KEY COMMENT 'in form of DP[DDMMYYYY][6-digit incremental int_num]',
  checkin_time time NOT NULL COMMENT 'must be greater than booking_date',
  checkout_time time NOT NULL COMMENT 'must be greater than checkin_date',
  room_order_id char(16)
);

-- GENERATING Receipt_id
CREATE TABLE Receipt_seq (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY
);

DELIMITER $$
CREATE TRIGGER Receipt_id_gen
BEFORE INSERT ON Receipt
FOR EACH ROW
BEGIN
  INSERT INTO Receipt_seq VALUES (NULL);
  SET NEW.id = CONCAT('HD', REPLACE(DATE(current_timestamp), '-', ''), LPAD(LAST_INSERT_ID(), 6, '0'));
END $$
DELIMITER ;
-- END: GENERATING Receipt_id

-- 19
CREATE TABLE Company (
  id char(6) PRIMARY KEY COMMENT 'in form of DN[0-9][0-9][0-9][0-9]',
  name varchar(255) UNIQUE NOT NULL
);

-- 20
CREATE TABLE Service (
  id char(6) PRIMARY KEY COMMENT 'in form of DV[R|S|C|M|B][0-9][0-9][0-9]',
  type char(1) NOT NULL,
  company_id char(6)
);


-- 21
CREATE TABLE Spa_product (
  service_id char(6),
  product varchar(255),
  PRIMARY KEY (service_id, product)
);

-- 22
CREATE TABLE Souvenir_type (
  service_id char(6),
  type varchar(255),
  PRIMARY KEY (service_id, type)
);

-- 23
CREATE TABLE Souvenir_brand (
  service_id char(6),
  brand varchar(255),
  PRIMARY KEY (service_id, brand)
);

-- 24
CREATE TABLE Premises (
  branch_id varchar(6),
  code int NOT NULL DEFAULT 1
    CHECK (code >= 1 AND code <= 50),
  length int,
  width int,
  price int NOT NULL,
  description varchar(255),
  zone_name varchar(255),
  service_id char(6) DEFAULT NULL,
  store_name varchar(255) DEFAULT NULL,
  logo varchar(255) DEFAULT NULL,
  PRIMARY KEY (branch_id, code)
);

-- 25    
CREATE TABLE Premises_image (
  image varchar(255),
  branch_id varchar(6),
  premises_code int,
  PRIMARY KEY (branch_id, premises_code, image)
);

-- 26
CREATE TABLE Premises_active_hour (
  branch_id varchar(6),
  premises_code int,
  open_time time,
  close_time time,
  PRIMARY KEY (branch_id, premises_code, open_time, close_time)
);

-- 27
CREATE TABLE Restaurant (
  service_id char(6) PRIMARY KEY,
  customer_no int,
  style varchar(255)
);

ALTER TABLE Branch_image ADD FOREIGN KEY (branch_id) REFERENCES Branch (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Zone ADD FOREIGN KEY (branch_id) REFERENCES Branch (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Bed ADD FOREIGN KEY (room_type_id) REFERENCES Room_type (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Branch_room_type 
ADD FOREIGN KEY (room_type_id) REFERENCES Room_type (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (branch_id) REFERENCES Branch (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Room 
ADD FOREIGN KEY (branch_id) REFERENCES Branch (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (room_type_id) REFERENCES Room_type (id)
  ON DELETE SET NULL
  ON UPDATE CASCADE,
ADD FOREIGN KEY (branch_id, zone_name) REFERENCES Zone (branch_id, name)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Room_type_supply_type ADD FOREIGN KEY (supply_type_id) REFERENCES Supply_type (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (room_type_id) REFERENCES Room_type (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Supply 
ADD FOREIGN KEY (branch_id) REFERENCES Branch (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (supply_type_id) REFERENCES Supply_type (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (branch_id, room_code) REFERENCES Room (branch_id, code)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Supply_providing 
ADD FOREIGN KEY (supply_provider_id) REFERENCES Supply_provider (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (branch_id) REFERENCES Branch (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (supply_type_id) REFERENCES Supply_type (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Package_order 
ADD FOREIGN KEY (customer_id) REFERENCES Customer (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (package_name) REFERENCES Package (name)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Room_order 
ADD FOREIGN KEY (customer_id) REFERENCES Customer (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (package_name) REFERENCES Package_order (package_name)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

ALTER TABLE Rent_room 
ADD FOREIGN KEY (room_order_id) REFERENCES Room_order (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (branch_id, room_code) REFERENCES Room (branch_id, code)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Receipt ADD FOREIGN KEY (room_order_id) REFERENCES Room_order (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
    
ALTER TABLE Premises 
ADD FOREIGN KEY (branch_id) REFERENCES Branch (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (branch_id, zone_name) REFERENCES Zone (branch_id, name)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD FOREIGN KEY (service_id) REFERENCES Service (id)
  ON DELETE SET NULL
  ON UPDATE CASCADE;
    
ALTER TABLE Premises_image
ADD FOREIGN KEY (branch_id, premises_code) REFERENCES Premises (branch_id, code)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Premises_active_hour ADD FOREIGN KEY (branch_id, premises_code) REFERENCES Premises (branch_id, code)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Service ADD FOREIGN KEY (company_id) REFERENCES Company (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
    
ALTER TABLE Restaurant ADD FOREIGN KEY (service_id) REFERENCES Service (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Spa_product ADD FOREIGN KEY (service_id) REFERENCES Service (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
    
ALTER TABLE Souvenir_type ADD FOREIGN KEY (service_id) REFERENCES Service (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE Souvenir_brand ADD FOREIGN KEY (service_id) REFERENCES Service (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
    
-- 1
INSERT INTO Branch (province, address, phone, email) VALUES 
  ('hcm', '66 hoa hao', '0606123321', 'anh@gmail.com'),
  ('danang', '2505 hoa phu', '0505456654', 'ha@gmail.com'),
  ('nghean', '47 nghe an', '0407123456', 'lan@gmail.com'),
  ('hanoi', '195 ha dong', '0905010203', 'quy@gmail.com');

-- 2
INSERT INTO Branch_image (branch_id, image) VALUES 
  ('CN1', 'hcm.jpg'),
  ('CN2', 'danang.jpg'),
  ('CN3', 'nghean.jpg'),
  ('CN4', 'hanoi.jpg');

-- 3
INSERT INTO Zone (branch_id, name) VALUES 
  ('CN1', 'beach'),
  ('CN1', 'pool'),
  ('CN2', 'beach'),
  ('CN3', 'east'),
  ('CN4', 'north'),
  ('CN4', 'south');

-- 4
INSERT INTO Room_type (name, area, customer_no, description) VALUES
  ('single',  9,  1, 'very narrow'), 
  ('double',  16, 2, DEFAULT),
  ('doublex', 25, 2, DEFAULT),
  ('triple',  36, 3, 'reasonable for 3 persons'),
  ('quad',    49, 6, 'can be family room');

-- 5
INSERT INTO Bed (room_type_id, size, number) VALUES
  (1, 2.0, 1),
  (2, 3.0, 1),
  (3, 2.5, 2),
  (4, 2.5, 3),
  (5, 2.5, 2),
  (5, 3.0, 2);
    
-- 6
INSERT INTO Branch_room_type (room_type_id, branch_id, price) VALUES 	
  (1, 'CN1', 500),
  (2, 'CN1', 1000),
  (5, 'CN1', 4500),

  (1, 'CN2', 600),
  (3, 'CN2', 2000),
  (4, 'CN2', 3000),

  (2, 'CN3', 1200),
  (3, 'CN3', 2500),
  (5, 'CN3', 4500),
  
  (1, 'CN4', 550),
  (4, 'CN4', 3300),
  (5, 'CN4', 4000);
	
-- 7
INSERT INTO Room (branch_id, code, zone_name, room_type_id) VALUES 	
  ('CN1', '101', 'beach', 1),
  ('CN1', '102', 'beach', 2),
  ('CN1', '103', 'pool', 5),

  ('CN2', '101', 'beach', 1),
  ('CN2', '102', 'beach', 3),
  ('CN2', '103', 'beach', 4),

  ('CN3', '101', 'east', 2),
  ('CN3', '102', 'east', 3),
  ('CN3', '103', 'east', 5),

  ('CN4', '101', 'north', 1),
  ('CN4', '102', 'north', 4),
  ('CN4', '103', 'north', 5);
	
-- 8
INSERT INTO Supply_type (id, name) VALUES
  ('VT0001', 'chair'),
  ('VT0002', 'table'),
  ('VT0003', 'air conditioner'),
  ('VT0004', 'fan');
	
-- 9
INSERT INTO Room_type_supply_type (room_type_id, supply_type_id, number) VALUES
  (1, 'VT0001', 2),
  (1, 'VT0002', 1),
  (1, 'VT0004', 1),

  (2, 'VT0001', 2),
  (2, 'VT0002', 1),
  (2, 'VT0004', 1),

  (3, 'VT0001', 4),
  (3, 'VT0002', 1),
  (3, 'VT0003', 1),

  (4, 'VT0001', 4),
  (4, 'VT0002', 1),
  (4, 'VT0003', 2),

  (5, 'VT0001', 6),
  (5, 'VT0002', 2),
  (5, 'VT0003', 2);

	
-- 10
INSERT INTO Supply (branch_id, room_code, supply_type_id, id, status) VALUES 	
-- CN1
  ('CN1', '101', 'VT0001', 1, 'Good'),
  ('CN1', '101', 'VT0001', 2, 'Good'),
  ('CN1', '101', 'VT0002', 3, 'Good'),
  ('CN1', '101', 'VT0004', 4, 'Good'),

  ('CN1', '102', 'VT0001', 5, 'Good'),
  ('CN1', '102', 'VT0001', 6, 'Good'),
  ('CN1', '102', 'VT0002', 7, 'Good'),
  ('CN1', '102', 'VT0004', 8, 'Good'),

  ('CN1', '103', 'VT0001', 9, 'Good'),
  ('CN1', '103', 'VT0001', 10, 'Good'),
  ('CN1', '103', 'VT0001', 11, 'Good'),
  ('CN1', '103', 'VT0001', 12, 'Good'),
  ('CN1', '103', 'VT0001', 13, 'Good'),
  ('CN1', '103', 'VT0001', 14, 'Good'),
  ('CN1', '103', 'VT0002', 15, 'Good'),
  ('CN1', '103', 'VT0002', 16, 'Good'),
  ('CN1', '103', 'VT0003', 17, 'Good'),
  ('CN1', '103', 'VT0003', 18, 'Good'),

-- CN2
  ('CN2', '101', 'VT0001', 19, 'Good'),
  ('CN2', '101', 'VT0001', 20, 'Good'),
  ('CN2', '101', 'VT0002', 21, 'Good'),
  ('CN2', '101', 'VT0004', 22, 'Good'),

  ('CN2', '102', 'VT0001', 23, 'Good'),
  ('CN2', '102', 'VT0001', 24, 'Good'),
  ('CN2', '102', 'VT0001', 25, 'Good'),
  ('CN2', '102', 'VT0001', 26, 'Good'),
  ('CN2', '102', 'VT0002', 27, 'Good'),
  ('CN2', '102', 'VT0003', 28, 'Good'),

  ('CN2', '103', 'VT0001', 29, 'Good'),
  ('CN2', '103', 'VT0001', 30, 'Good'),
  ('CN2', '103', 'VT0001', 31, 'Good'),
  ('CN2', '103', 'VT0001', 32, 'Good'),
  ('CN2', '103', 'VT0002', 33, 'Good'),
  ('CN2', '103', 'VT0003', 34, 'Good'),
  ('CN2', '103', 'VT0003', 35, 'Good'),

-- CN3
  ('CN3', '101', 'VT0001', 36, 'Good'),
  ('CN3', '101', 'VT0001', 37, 'Good'),
  ('CN3', '101', 'VT0002', 38, 'Good'),
  ('CN3', '101', 'VT0004', 39, 'Good'),

  ('CN3', '102', 'VT0001', 40, 'Good'),
  ('CN3', '102', 'VT0001', 41, 'Good'),
  ('CN3', '102', 'VT0001', 42, 'Good'),
  ('CN3', '102', 'VT0001', 43, 'Good'),
  ('CN3', '102', 'VT0002', 44, 'Good'),
  ('CN3', '102', 'VT0003', 45, 'Good'),

  ('CN3', '103', 'VT0001', 46, 'Good'),
  ('CN3', '103', 'VT0001', 47, 'Good'),
  ('CN3', '103', 'VT0001', 48, 'Good'),
  ('CN3', '103', 'VT0001', 49, 'Good'),
  ('CN3', '103', 'VT0002', 50, 'Good'),
  ('CN3', '103', 'VT0003', 51, 'Good'),
  ('CN3', '103', 'VT0003', 52, 'Good'),

-- CN4
  ('CN4', '101', 'VT0001', 53, 'Good'),
  ('CN4', '101', 'VT0001', 54, 'Good'),
  ('CN4', '101', 'VT0002', 55, 'Good'),
  ('CN4', '101', 'VT0004', 56, 'Good'),

  ('CN4', '102', 'VT0001', 57, 'Good'),
  ('CN4', '102', 'VT0001', 58, 'Good'),
  ('CN4', '102', 'VT0001', 59, 'Good'),
  ('CN4', '102', 'VT0001', 60, 'Good'),
  ('CN4', '102', 'VT0002', 61, 'Good'),
  ('CN4', '102', 'VT0003', 62, 'Good'),
  ('CN4', '102', 'VT0003', 63, 'Good'),

  ('CN4', '103', 'VT0001', 64, 'Good'),
  ('CN4', '103', 'VT0001', 65, 'Good'),
  ('CN4', '103', 'VT0001', 66, 'Good'),
  ('CN4', '103', 'VT0001', 67, 'Good'),
  ('CN4', '103', 'VT0001', 68, 'Good'),
  ('CN4', '103', 'VT0001', 69, 'Good'),
  ('CN4', '103', 'VT0002', 70, 'Good'),
  ('CN4', '103', 'VT0002', 71, 'Good'),
  ('CN4', '103', 'VT0003', 72, 'Good'),
  ('CN4', '103', 'VT0003', 73, 'Good');

	
-- 11
INSERT INTO Supply_provider (id, name, email, address) VALUES 	
	('NCC0001', 'THANH CHAIR INC.', 'tci@gmail.com', 'Quan Hoan Kiem, HN'),
	('NCC0002', 'TABLET CORP.', 'tc@gmail.com', 'Binh Duong'),
	('NCC0003', 'AC INTERNATIONAL', 'aci@gmail.com', 'Da Nang'),
	('NCC0004', 'FAN CORPORATION', 'fc@gmail.com', 'Q4, TPHCM'),
	('NCC0005', 'DIEN MAY XANH', 'dmx@gmail.com', 'Quan Cau Giay, HN'),
	('NCC0006', 'NGUYEN KIM', 'nguyenkim@gmail.com', 'Q1, TPHCM');
	
-- 12
INSERT INTO Supply_providing (supply_provider_id, branch_id, supply_type_id) VALUES
  ('NCC0001', 'CN1', 'VT0001'),
  ('NCC0002', 'CN1', 'VT0002'),
  ('NCC0003', 'CN1', 'VT0003'),
  ('NCC0004', 'CN1', 'VT0004'),

  ('NCC0001', 'CN2', 'VT0001'),
  ('NCC0002', 'CN2', 'VT0002'),
  ('NCC0003', 'CN2', 'VT0003'),
  ('NCC0005', 'CN2', 'VT0004'),

  ('NCC0001', 'CN3', 'VT0001'),
  ('NCC0006', 'CN3', 'VT0002'),
  ('NCC0003', 'CN3', 'VT0003'),
  ('NCC0006', 'CN3', 'VT0004'),

  ('NCC0001', 'CN4', 'VT0001'),
  ('NCC0002', 'CN4', 'VT0002'),
  ('NCC0005', 'CN4', 'VT0003'),
  ('NCC0005', 'CN4', 'VT0004');
	
-- 13
INSERT INTO Customer (id, ssn, name, phone, email, username, passignment2word, point, customer_rank) VALUES
  ('KH000001', '111111111111', 'Nguyen Van A',  '0222112345', 'one@gmail.com',   'one',    '1234', DEFAULT, 1),
  ('KH000002', '333333333333', 'Nguyen Thi B',  '0123321456', 'two@gmail.com',   'two',    '4321', 5, 2),
  ('KH000003', '555555555555', 'Tran Van C',    '0987654321', 'three@gmail.com', 'three',  '4567', 9, 3),
  ('KH000004', '777777777777', 'Nguyen Van D',  '0123456789', 'four@gmail.com',  'four',   '7890', 10, 4),
  ('KH000005', '999999999999', 'Tran Van E',    '0123458769', 'five@gmail.com',  'five',   '42678', 10, 4);
	
-- 14
INSERT INTO Package (name, total_day, total_customer, price) VALUES
  ('Basics',    3, 2, 800),
  ('Standard',  5, 5, 4000),
  ('Vip',       6, 8, 7000),
  ('Luxury',    7, 10, 10000);

-- 15
INSERT INTO Package_order (customer_id, package_name, buy_time, start_date, cost) VALUES
  ('KH000002', 'Standard',  TIMESTAMP('2022-11-24', '08:00:00'), '2022-11-26', 4000),
  ('KH000003', 'Vip',       TIMESTAMP('2022-11-25', '08:00:00'), '2022-11-27', 7000),
  ('KH000004', 'Luxury',    TIMESTAMP('2022-11-26', '08:00:00'), '2022-11-28', 10000),
  ('KH000005', 'Luxury',    TIMESTAMP('2022-11-27', '08:00:00'), '2022-11-29', 10000);
        
-- 16
INSERT INTO Room_order (order_time, checkin_date, checkout_date, status, cost, customer_id, package_name) VALUE
  (TIMESTAMP('2022-11-22', '08:00:00'), '2022-11-24', '2022-11-30', DEFAULT, 900,     'KH000001', NULL),
  (TIMESTAMP('2022-11-27', '08:00:00'), '2022-11-28', '2022-12-05', 1,       DEFAULT, 'KH000002', 'Standard'),
  (TIMESTAMP('2022-11-28', '08:00:00'), '2022-11-29', '2022-12-05', 1,       DEFAULT, 'KH000003', 'Vip'),
  (TIMESTAMP('2022-11-29', '08:00:00'), '2022-11-30', '2022-12-05', 1,       DEFAULT, 'KH000004', 'Luxury'),
  (TIMESTAMP('2022-11-30', '08:00:00'), '2022-12-01', '2022-12-05', 1,       DEFAULT, 'KH000005', 'Luxury');

-- 17
INSERT INTO Rent_room(room_order_id, branch_id, room_code) VALUES
  ('DP20221122000001', 'CN1', '101'),
  ('DP20221127000002', 'CN2', '102'),
  ('DP20221128000003', 'CN2', '103'),
  ('DP20221129000004', 'CN3', '103'),
  ('DP20221130000005', 'CN4', '103');

-- 18
INSERT INTO Receipt (checkin_time, checkout_time, room_order_id) VALUES
  ('13:00', '12:00', 'DP20221122000001'),
  ('14:00', '12:00', 'DP20221127000002'),
  ('12:20', '12:00', 'DP20221128000003'),
  ('12:45', '12:00', 'DP20221129000004'),
  ('13:00', '12:00', 'DP20221130000005');

-- 19
INSERT INTO Company (id, name) VALUES 	
  ('DN0001', 'Coca Cola'),
  ('DN0002', 'Pepsi Co.'),
  ('DN0003', 'Dien May Xanh'),
  ('DN0004', 'Vin Group'),
  ('DN0005', 'Thuy Spa'),
  ('DN0006', 'The Frenchie');

-- 20
INSERT INTO Service (id, type, company_id) VALUES 	
  ('DVR001', 'R', 'DN0004'),
  ('DVR002', 'R', 'DN0006'),

  ('DVS003', 'S', 'DN0005'),

  ('DVM004', 'M', 'DN0001'),
  ('DVM005', 'M', 'DN0002'),

  ('DVC006', 'C', 'DN0003');

	
-- 21
INSERT INTO Spa_product (service_id, product) VALUES
  ('DVS003', 'foot'),
  ('DVS003', 'head'),
  ('DVS003', 'face'),
  ('DVS003', 'full');
	
-- 22
INSERT INTO Souvenir_type(service_id, type) VALUES 
  ('DVM004', 'cup'),
  ('DVM004', 'hat'),
  ('DVM004', 'jewelry'),
  ('DVM005', 'decoration');

-- 23
INSERT INTO Souvenir_brand(service_id, brand) VALUES 
  ('DVM004', 'dior'),
  ('DVM004', 'gucci'),
  ('DVM004', 'louis vuitton'),
  ('DVM005', 'zara');

-- 24
INSERT INTO Premises (branch_id, code, length, width, price, description, zone_name, service_id, store_name, logo) VALUES 
  ('CN1', 1, 10, 20, 1000, NULL, 'beach', DEFAULT, DEFAULT, DEFAULT),
  ('CN1', 2, 15, 20, 1500, NULL, 'pool', 'DVM004', 'Cua hang luu niem', DEFAULT),
  ('CN2', 3, 13, 20, 1300, NULL, 'beach', 'DVR001', 'Nha hang Phap', DEFAULT),
  ('CN2', 4, 11, 20, 1100, NULL, 'beach', 'DVM005', 'Cua hang luu niem', DEFAULT),
  ('CN3', 5, 20, 20, 2000, NULL, 'east', 'DVR002', 'Nha hang Y', DEFAULT),
  ('CN4', 6, 25, 20, 2500, NULL, 'south', 'DVS003', 'Spa Phap', DEFAULT),
  ('CN4', 7, 23, 20, 2300, NULL, 'south', 'DVC006', 'Circle K', DEFAULT);

-- 25
INSERT INTO Premises_image (branch_id, premises_code, image) VALUES 
  ('CN1', 1, 'hinh.jpg'),
  ('CN2', 3, 'hinh2.jpg'),
  ('CN2', 4, 'hinh3.jpg'),
  ('CN4', 7, 'hinh4.jpg');

-- 26
INSERT INTO Premises_active_hour (branch_id, premises_code, open_time, close_time) VALUES 
  ('CN1', 2, '08:00', '21:00'),
  ('CN2', 3, '08:00', '21:00'),
  ('CN2', 4, '08:00', '21:00'),
  ('CN3', 5, '08:00', '21:00'),
  ('CN4', 6, '08:00', '21:00'),
  ('CN4', 7, '08:00', '21:00');

-- 27
INSERT INTO Restaurant (service_id, customer_no, style) VALUES
  ('DVR001', 100, 'Phap'),
  ('DVR002', 200, 'Y');
