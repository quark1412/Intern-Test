CREATE TABLE STATION (
    station_id    INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    station_name  VARCHAR(100) NOT NULL,
    address       TEXT NOT NULL,
    status        VARCHAR(50) NOT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CK_STATION_status CHECK (status IN ('ĐANG HOẠT ĐỘNG','ĐANG BẢO TRÌ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE PRODUCT (
    product_id       INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    product_name     VARCHAR(50) NOT NULL,
    product_type     VARCHAR(50) NOT NULL,
    price_per_liter  DECIMAL(12,3) NOT NULL,
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE EMPLOYEE (
    employee_id       INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employee_name     VARCHAR(50)  NOT NULL,
    employee_phone    VARCHAR(15)  NOT NULL,
    employee_email    VARCHAR(100) NOT NULL,
    employee_address  TEXT NOT NULL,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE CUSTOMER (
    customer_id       VARCHAR(50) PRIMARY KEY, 
    customer_name     VARCHAR(100) NULL,
    customer_phone    VARCHAR(15)  NULL,
    customer_email    VARCHAR(100) NULL,
    customer_address  TEXT NULL,
    customer_type     VARCHAR(50)  NOT NULL,
    tax_code          VARCHAR(30)  NULL,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CK_CUSTOMER_type CHECK (customer_type IN ('KHÁCH CÔNG NỢ','KHÁCH LẺ'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE PUMP (
    pump_id                INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    station_id             INT NOT NULL,
    product_id             INT NOT NULL,
    pump_number            VARCHAR(10) NOT NULL,
    pump_serial_number     VARCHAR(50) UNIQUE,
    installation_date      DATE NULL,
    last_maintenance_date  DATE NULL,
    next_maintenance_date  DATE NULL,
    capacity_liters        DECIMAL(12,2) NULL,
    status                 VARCHAR(50) NOT NULL,
    created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT UQ_PUMP_station_pumpnumber UNIQUE (station_id, pump_number),
    CONSTRAINT FK_PUMP_station  FOREIGN KEY (station_id) REFERENCES STATION(station_id) ON DELETE CASCADE,
    CONSTRAINT FK_PUMP_product  FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
    CONSTRAINT CK_PUMP_status CHECK (status IN ('HẾT XĂNG','CÒN XĂNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE TRANSACTION_DETAIL (
    transaction_id      CHAR(36) NOT NULL DEFAULT (UUID()),
    station_id          INT NOT NULL,
    pump_id             INT NOT NULL,
    product_id          INT NOT NULL,
    transaction_number  VARCHAR(50) NOT NULL UNIQUE,
    transaction_date    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    quantity_liters     DECIMAL(12,3) NOT NULL,
    price_per_liter     DECIMAL(12,3) NOT NULL,
    total_amount        DECIMAL(14,2) GENERATED ALWAYS AS (ROUND(quantity_liters * price_per_liter, 2)) STORED,
    payment_method      VARCHAR(50) NOT NULL, 
    customer_id         VARCHAR(50) NULL,
    employee_id         INT NULL,
    receipt_number      VARCHAR(50) NULL,
    notes               TEXT NULL,
    status              VARCHAR(50) NOT NULL,  
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_TRANSACTION_DETAIL PRIMARY KEY (transaction_id),
    CONSTRAINT FK_TX_station   FOREIGN KEY (station_id)  REFERENCES STATION(station_id),
    CONSTRAINT FK_TX_pump      FOREIGN KEY (pump_id)     REFERENCES PUMP(pump_id),
    CONSTRAINT FK_TX_product   FOREIGN KEY (product_id)  REFERENCES PRODUCT(product_id),
    CONSTRAINT FK_TX_customer  FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT FK_TX_employee  FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id),
    CONSTRAINT CK_TX_qty       CHECK (quantity_liters > 0),
    CONSTRAINT CK_TX_price     CHECK (price_per_liter > 0),
    CONSTRAINT CK_TX_paymethod CHECK (payment_method IN ('TIỀN MẶT','CHUYỂN KHOẢN')),
    CONSTRAINT CK_TX_status    CHECK (status IN ('ĐÃ THANH TOÁN','CHƯA THANH TOÁN'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER //
CREATE TRIGGER tr_STATION_set_updated_at
BEFORE UPDATE ON STATION
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END//
CREATE TRIGGER tr_PRODUCT_set_updated_at
BEFORE UPDATE ON PRODUCT
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END//
CREATE TRIGGER tr_EMPLOYEE_set_updated_at
BEFORE UPDATE ON EMPLOYEE
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END//
CREATE TRIGGER tr_CUSTOMER_set_updated_at
BEFORE UPDATE ON CUSTOMER
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END//
CREATE TRIGGER tr_PUMP_set_updated_at
BEFORE UPDATE ON PUMP
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END//

CREATE TRIGGER tr_TX_pump_consistency_ins
BEFORE INSERT ON TRANSACTION_DETAIL
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM PUMP p
    WHERE p.pump_id = NEW.pump_id
      AND (p.station_id <> NEW.station_id OR p.product_id <> NEW.product_id)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction station/product must match pump station/product';
  END IF;
END//
CREATE TRIGGER tr_TX_pump_consistency_upd
BEFORE UPDATE ON TRANSACTION_DETAIL
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM PUMP p
    WHERE p.pump_id = NEW.pump_id
      AND (p.station_id <> NEW.station_id OR p.product_id <> NEW.product_id)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction station/product must match pump station/product';
  END IF;
END//
DELIMITER ;

CREATE INDEX IX_STATION_status ON STATION(status);

CREATE INDEX IX_PRODUCT_type ON PRODUCT(product_type);

CREATE INDEX IX_PUMP_station ON PUMP(station_id);
CREATE INDEX IX_PUMP_product ON PUMP(product_id);
CREATE INDEX IX_PUMP_status  ON PUMP(status);
CREATE INDEX IX_PUMP_station_status ON PUMP(station_id, status);

CREATE INDEX IX_TX_date           ON TRANSACTION_DETAIL(transaction_date);
CREATE INDEX IX_TX_station        ON TRANSACTION_DETAIL(station_id);
CREATE INDEX IX_TX_pump           ON TRANSACTION_DETAIL(pump_id);
CREATE INDEX IX_TX_product        ON TRANSACTION_DETAIL(product_id);
CREATE INDEX IX_TX_payment_method ON TRANSACTION_DETAIL(payment_method);
CREATE INDEX IX_TX_status         ON TRANSACTION_DETAIL(status);
CREATE INDEX IX_TX_station_date   ON TRANSACTION_DETAIL(station_id, transaction_date);
CREATE INDEX IX_TX_product_date   ON TRANSACTION_DETAIL(product_id, transaction_date);

INSERT INTO EMPLOYEE (employee_name, employee_phone, employee_email, employee_address) VALUES
('Nguyễn Văn An', '0901234567', 'an.nguyen@fuel.com', '123 Đường ABC, Quận 1, TP.HCM'),
('Trần Thị Bình', '0912345678', 'binh.tran@fuel.com', '456 Đường DEF, Quận 2, TP.HCM'),
('Lê Văn Cường', '0923456789', 'cuong.le@fuel.com', '789 Đường GHI, Quận 3, TP.HCM'),
('Phạm Thị Dung', '0934567890', 'dung.pham@fuel.com', '321 Đường JKL, Quận 4, TP.HCM');

INSERT INTO CUSTOMER (customer_id, customer_name, customer_phone, customer_email, customer_address, customer_type, tax_code) VALUES
('KHÁCH LẺ', NULL, NULL, NULL, NULL, 'KHÁCH LẺ', NULL),
('KH001', 'Công ty TNHH One',   '0978000001', 'one@ex.com',   '111 Đường AAA, TP.HCM', 'KHÁCH CÔNG NỢ', '010000001'),
('KH002', 'Công ty TNHH Two',   '0978000002', 'two@ex.com',   '222 Đường BBB, TP.HCM', 'KHÁCH CÔNG NỢ', '010000002'),
('KH003', 'Công ty TNHH Three', '0978000003', 'three@ex.com', '333 Đường CCC, TP.HCM', 'KHÁCH CÔNG NỢ', '010000003'),
('KH004', 'Công ty TNHH ABC',   '0978901234', 'info@abc.com.vn', '444 Đường VWX, Quận 8, TP.HCM', 'KHÁCH CÔNG NỢ', '0123456789'),
('KH005', 'Công ty CP XYZ',     '0989012345', 'contact@xyz.com.vn', '555 Đường YZ, Quận 9, TP.HCM', 'KHÁCH CÔNG NỢ', '9876543210');

INSERT INTO STATION (station_name, address, status) VALUES
('Cửa hàng xăng dầu số 27', '123 Đường Nguyễn Huệ, Quận 1, TP.HCM', 'ĐANG HOẠT ĐỘNG'),
('Cửa hàng xăng dầu số 28', '456 Đường Cao Tốc TP.HCM - Long Thành, Đồng Nai', 'ĐANG HOẠT ĐỘNG'),
('Cửa hàng xăng dầu số 29', '789 Đường Lê Văn Việt, Quận 9, TP.HCM', 'ĐANG HOẠT ĐỘNG'),
('Cửa hàng xăng dầu số 30', '321 Đường Quốc Lộ 1A, Huyện Củ Chi, TP.HCM', 'ĐANG BẢO TRÌ');

INSERT INTO PRODUCT (product_name, product_type, price_per_liter) VALUES
('Xăng RON95', 'XĂNG', 23500),
('Xăng RON97', 'XĂNG', 25000),
('Dầu Diesel', 'DẦU DIESEL', 21500),
('Xăng E5',    'XĂNG', 23000),
('Gas LPG',    'GAS', 15000);

INSERT INTO PUMP (station_id, product_id, pump_number, pump_serial_number, installation_date, capacity_liters, status) VALUES
(1, 1, 'P01', 'TXT001-P01-2023', '2023-01-15', 10000.00, 'CÒN XĂNG'),
(1, 2, 'P02', 'TXT001-P02-2023', '2023-01-15', 10000.00, 'CÒN XĂNG'),
(1, 3, 'P03', 'TXT001-P03-2023', '2023-01-15', 15000.00, 'CÒN XĂNG'),

(2, 1, 'P01', 'TXC002-P01-2022', '2022-08-10', 12000.00, 'CÒN XĂNG'),
(2, 3, 'P02', 'TXC002-P02-2022', '2022-08-10', 18000.00, 'CÒN XĂNG'),
(2, 5, 'P03', 'TXC002-P03-2023', '2023-03-15',  8000.00, 'HẾT XĂNG'),

(3, 1, 'P01', 'TXK003-P01-2023', '2023-05-20', 10000.00, 'CÒN XĂNG'),
(3, 2, 'P02', 'TXK003-P02-2023', '2023-05-20', 10000.00, 'CÒN XĂNG'),
(3, 4, 'P03', 'TXK003-P03-2023', '2023-05-20', 10000.00, 'CÒN XĂNG'),

(4, 1, 'P01', 'TXN004-P01-2023', '2023-04-10',  8000.00, 'HẾT XĂNG'),
(4, 4, 'P02', 'TXN004-P02-2023', '2023-04-10',  8000.00, 'CÒN XĂNG');

INSERT INTO TRANSACTION_DETAIL
(station_id, pump_id, product_id, transaction_number, transaction_date, quantity_liters, price_per_liter, payment_method, customer_id, employee_id, receipt_number, status)
VALUES
(1, 1, 1, 'TXN240101001', '2024-01-01 08:15:30', 45.250, 23500, 'CHUYỂN KHOẢN', 'KH001', 1, 'RCP240101001', 'ĐÃ THANH TOÁN'),
(1, 3, 3, 'TXN240101002', '2024-01-01 08:32:45', 62.100, 21500, 'TIỀN MẶT',      'KHÁCH LẺ', 1, 'RCP240101002', 'ĐÃ THANH TOÁN'),
(2, 4, 1, 'TXN240101003', '2024-01-01 09:05:15', 38.750, 23500, 'CHUYỂN KHOẢN', 'KH002', 2, 'RCP240101003', 'ĐÃ THANH TOÁN'),
(1, 2, 2, 'TXN240101004', '2024-01-01 09:18:22', 55.000, 25000, 'CHUYỂN KHOẢN', 'KH004', 1, 'RCP240101004', 'ĐÃ THANH TOÁN'),
(3, 7, 1, 'TXN240101005', '2024-01-01 10:25:18', 42.330, 23500, 'TIỀN MẶT',      'KHÁCH LẺ', 3, 'RCP240101005', 'ĐÃ THANH TOÁN'),
(4,10, 1, 'TXN240101006', '2024-01-01 11:42:33', 48.900, 23500, 'CHUYỂN KHOẢN', 'KH005', 4, 'RCP240101006', 'ĐÃ THANH TOÁN'),
(2, 5, 3, 'TXN240101007', '2024-01-01 12:15:45', 75.500, 21500, 'CHUYỂN KHOẢN', 'KH003', 2, 'RCP240101007', 'ĐÃ THANH TOÁN'),
(3, 9, 4, 'TXN240101008', '2024-01-01 13:22:10', 35.750, 23000, 'TIỀN MẶT',      'KHÁCH LẺ', 3, 'RCP240101008', 'ĐÃ THANH TOÁN'),
(1, 1, 1, 'TXN240101009', '2024-01-01 14:35:55', 41.200, 23500, 'CHUYỂN KHOẢN', 'KH001', 1, 'RCP240101009', 'CHƯA THANH TOÁN'),
(3, 7, 1, 'TXN240101010', '2024-01-01 15:48:20', 68.850, 23500, 'CHUYỂN KHOẢN', 'KH002', 3, 'RCP240101010', 'ĐÃ THANH TOÁN'),

(1, 1, 1, 'TXN231231001', '2023-12-31 16:20:30', 52.750, 23500, 'CHUYỂN KHOẢN', 'KH004', 1, 'RCP231231001', 'ĐÃ THANH TOÁN'),
(2, 4, 1, 'TXN231231002', '2023-12-31 17:15:45', 44.200, 23500, 'TIỀN MẶT',      'KHÁCH LẺ', 2, 'RCP231231002', 'ĐÃ THANH TOÁN'),
(3, 8, 2, 'TXN231231003', '2023-12-31 18:30:22', 39.500, 25000, 'CHUYỂN KHOẢN', 'KH003', 3, 'RCP231231003', 'ĐÃ THANH TOÁN'),
(4,11, 4, 'TXN231231004', '2023-12-31 19:45:10', 46.800, 23000, 'TIỀN MẶT',      'KHÁCH LẺ', 4, 'RCP231231004', 'ĐÃ THANH TOÁN'),
(1, 3, 3, 'TXN231231005', '2023-12-31 20:22:55', 71.250, 21500, 'CHUYỂN KHOẢN', 'KH005', 1, 'RCP231231005', 'ĐÃ THANH TOÁN');


-- QUERY 1: Lấy ra danh sách giao dịch của trạm xăng 1 trong tháng 1 năm 2024

SET @station_id = 1; SET @start_date = '2024-01-01'; SET @end_date = '2024-01-31';
SELECT 
    t.transaction_id,
    t.transaction_number,
    t.transaction_date,
    s.station_name,
    p.pump_number,
    pr.product_name,
    t.quantity_liters,
    t.price_per_liter,
    t.total_amount,
    t.payment_method,
    CASE WHEN c.customer_id = 'KHÁCH LẺ' THEN 'KHÁCH LẺ' ELSE c.customer_name END AS customer_name,
    c.customer_type,
    e.employee_name,
    t.receipt_number,
    t.status,
    t.notes
FROM TRANSACTION_DETAIL t
JOIN STATION  s ON t.station_id  = s.station_id
JOIN PUMP     p ON t.pump_id     = p.pump_id
JOIN PRODUCT  pr ON t.product_id = pr.product_id
JOIN CUSTOMER c ON t.customer_id = c.customer_id
JOIN EMPLOYEE e ON t.employee_id = e.employee_id
WHERE t.station_id = @station_id
  AND DATE(t.transaction_date) BETWEEN @start_date AND @end_date
  AND t.status = 'ĐÃ THANH TOÁN'
ORDER BY t.transaction_date DESC;
  
-- QUERY 2: Lấy ra doanh thu của bơm 1 trong ngày 01/01/2024

SET @pump_id = 1; SET @target_date = '2024-01-01';
SELECT 
    p.pump_id,
    p.pump_number,
    s.station_name,
    pr.product_name,
    CAST(@target_date AS DATE) AS revenue_date,
    COUNT(t.transaction_id)       AS total_transactions,
    SUM(t.quantity_liters)        AS total_liters_sold,
    SUM(t.total_amount)           AS daily_revenue
FROM PUMP p
JOIN STATION s ON p.station_id = s.station_id
JOIN PRODUCT pr ON p.product_id = pr.product_id
LEFT JOIN TRANSACTION_DETAIL t
    ON p.pump_id = t.pump_id
   AND DATE(t.transaction_date) = @target_date
   AND t.status = 'ĐÃ THANH TOÁN'
WHERE p.pump_id = @pump_id
GROUP BY p.pump_id, p.pump_number, s.station_name, pr.product_name;

-- QUERY 3: Lấy ra doanh thu của trạm xăng 1 trong ngày 01/01/2024

SET @station_id = 1; SET @target_date = '2024-01-01';
SELECT 
    s.station_id,
    s.station_name,
    CAST(@target_date AS DATE) as revenue_date,
    COUNT(t.transaction_id)                          as total_transactions,
    SUM(t.quantity_liters)                           as total_liters_sold,
    SUM(t.total_amount)                              as daily_revenue
FROM STATION s
LEFT JOIN TRANSACTION_DETAIL t 
  ON s.station_id = t.station_id
 AND DATE(t.transaction_date) = @target_date
 AND t.status = 'ĐÃ THANH TOÁN'
WHERE s.station_id = @station_id
GROUP BY s.station_id, s.station_name;

-- QUERY 4: Lấy ra top 3 sản phẩm bán chạy nhất trong tháng 1 năm 2024

SET @station_id = 1; SET @year = 2024; SET @month = 1;
WITH monthly AS (
  SELECT 
      pr.product_id,
      pr.product_name,
      pr.product_type,
      s.station_name,
      SUM(t.quantity_liters) AS total_liters_sold,
      SUM(t.total_amount)    AS total_revenue
  FROM PRODUCT pr
  JOIN TRANSACTION_DETAIL t ON pr.product_id = t.product_id
  JOIN STATION s ON t.station_id = s.station_id
  WHERE t.station_id = @station_id
    AND YEAR(t.transaction_date) = @year
    AND MONTH(t.transaction_date) = @month
    AND t.status = 'ĐÃ THANH TOÁN'
  GROUP BY pr.product_id, pr.product_name, pr.product_type, s.station_name
)
SELECT
    m.product_id,
    m.product_name,
    m.product_type,
    m.station_name,
    CONCAT(@year, '-', LPAD(@month, 2, '0')) AS sales_month,
    (SELECT COUNT(*) FROM TRANSACTION_DETAIL t 
      WHERE t.product_id = m.product_id 
        AND t.station_id = @station_id 
        AND YEAR(t.transaction_date)=@year 
        AND MONTH(t.transaction_date)=@month 
        AND t.status='ĐÃ THANH TOÁN') AS total_transactions,
    m.total_liters_sold,
    m.total_revenue,
    RANK() OVER (ORDER BY m.total_liters_sold DESC) AS sales_rank
FROM monthly m
ORDER BY m.total_liters_sold DESC
LIMIT 3;
