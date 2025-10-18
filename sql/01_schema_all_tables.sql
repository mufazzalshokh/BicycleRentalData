-- ============================================================================
-- PART 1: CREATE TABLES (as provided)
-- ============================================================================

CREATE TABLE [Bicycle]
(
   [Id] int IDENTITY(1,1) not null,
   [Brand] varchar(50) not null,
   [RentPrice] int not null,
   primary key(Id)
)

CREATE TABLE [Client]
(
   [Id] int IDENTITY(1,1) not null,
   [Name] varchar(10) not null,
   [Passport] varchar(50) not null,
   [Phone number] varchar(50) not null,
   [Country] varchar(50) not null,
   primary key(Id)
)

CREATE TABLE [Staff]
(
   [Id] int IDENTITY(1,1) not null,
   [Name] varchar(10) not null,
   [Passport] varchar(50) not null,
   [Date] date not null,
   primary key(Id)
)

CREATE TABLE [Detail]
(
   [Id] int IDENTITY(1,1) not null,
   [Brand] varchar(50) not null,
   [Type] varchar(50) not null,
   [Name] varchar(50) not null,
   [Price] int not null,
   primary key(Id)
)

CREATE TABLE [DetailForBicycle]
(
   [BicycleId] int not null,
   [DetailId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
)

CREATE TABLE [ServiceBook]
(
   [BicycleId] int not null,
   [DetailId] int not null,
   [Date] date not null,
   [Price] int not null,
   [StaffId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
)

CREATE TABLE [RentBook]
(
   [Id] int IDENTITY(1,1) not null,
   [Date] date not null,
   [Time] int not null,
   [Paid] bit not null,
   [BicycleId] int not null,
   [ClientId] int not null,
   [StaffId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([ClientId]) REFERENCES [Client] ([Id])
)

-- ============================================================================
-- PART 2: SCHEMA IMPROVEMENTS WITH ALTER STATEMENTS
-- ============================================================================

-- Change 1: Client.Name should be larger - people names can exceed 10 chars
-- Change 2: Staff.Name should be larger for same reason
ALTER TABLE [Client] ALTER COLUMN [Name] varchar(100) not null
ALTER TABLE [Staff] ALTER COLUMN [Name] varchar(100) not null

-- Change 3: Add DateTime columns for better temporal tracking in RentBook
-- Currently only Date - need to track exact time of rental/return
ALTER TABLE [RentBook] ADD [StartTime] datetime null
ALTER TABLE [RentBook] ADD [EndTime] datetime null

-- Change 4: Add primary key to DetailForBicycle (currently has no PK)
ALTER TABLE [DetailForBicycle] ADD PRIMARY KEY ([BicycleId], [DetailId])

-- Change 5: Add primary key to ServiceBook (currently has no PK)
ALTER TABLE [ServiceBook] ADD PRIMARY KEY ([BicycleId], [DetailId], [Date], [StaffId])

-- Change 6: Add check constraint - RentPrice should be positive
ALTER TABLE [Bicycle] ADD CONSTRAINT CK_RentPrice_Positive CHECK ([RentPrice] > 0)

-- Change 7: Add check constraint - Detail.Price should be positive
ALTER TABLE [Detail] ADD CONSTRAINT CK_DetailPrice_Positive CHECK ([Price] > 0)

-- Change 8: Add check constraint - ServiceBook.Price should be positive
ALTER TABLE [ServiceBook] ADD CONSTRAINT CK_ServicePrice_Positive CHECK ([Price] > 0)

-- Change 9: Add index on RentBook for date-based queries (common in analytics)
CREATE INDEX IX_RentBook_Date ON [RentBook]([Date])

-- Change 10: Add index on ServiceBook for date-based queries
CREATE INDEX IX_ServiceBook_Date ON [ServiceBook]([Date])

-- Change 11: Add index on Staff.Date for tenure calculations
CREATE INDEX IX_Staff_Date ON [Staff]([Date])

-- ============================================================================
-- PART 3: INSERT TEST DATA
-- ============================================================================

-- Insert bicycles
INSERT INTO [Bicycle] ([Brand], [RentPrice]) VALUES
('Giant', 50),
('Trek', 60),
('Specialized', 55),
('Cannondale', 65),
('Scott', 52),
('Cube', 48),
('Merida', 58),
('Kona', 62)

-- Insert clients
INSERT INTO [Client] ([Name], [Passport], [Phone number], [Country]) VALUES
('Ivan Petrov', 'RU123456', '+7-999-111-11-11', 'Russia'),
('Maria Sidorova', 'RU234567', '+7-999-222-22-22', 'Russia'),
('Alexei Volkov', 'RU345678', '+7-999-333-33-33', 'Russia'),
('Olga Smirnova', 'RU456789', '+7-999-444-44-44', 'Russia'),
('Dmitri Pavlov', 'RU567890', '+7-999-555-55-55', 'Russia'),
('Elena Mikhailova', 'RU678901', '+7-999-666-66-66', 'Russia'),
('Igor Lebedev', 'RU789012', '+7-999-777-77-77', 'Russia'),
('Natalia Volkova', 'RU890123', '+7-999-888-88-88', 'Russia')

-- Insert staff (with varied hire dates for tenure testing)
INSERT INTO [Staff] ([Name], [Passport], [Date]) VALUES
('Sergey Ivanov', 'PA111111', '2024-09-15'),   -- ~1 month
('Tatiana Kuznetsova', 'PA222222', '2024-06-01'),  -- ~4 months
('Yuri Antonov', 'PA333333', '2023-10-15'),  -- ~1 year
('Ekaterina Sokolov', 'PA444444', '2023-04-01'),  -- ~1.5 years
('Mikhail Orlov', 'PA555555', '2022-08-20'),  -- ~2+ years
('Irina Morozov', 'PA666666', '2021-03-10'),  -- ~3+ years
('Viktor Kirov', 'PA777777', '2020-01-15')    -- ~4+ years

-- Insert details (bicycle parts)
INSERT INTO [Detail] ([Brand], [Type], [Name], [Price]) VALUES
('Shimano', 'Chain', 'Chain 11-speed', 2500),
('Shimano', 'Sprocket', 'Cassette 11-50T', 5000),
('Continental', 'Tire', 'Grand Prix 700x28', 1800),
('Sram', 'Brake Pad', 'Brake Pad Set', 800),
('Specialized', 'Seat', 'Comfort Saddle', 1200),
('Ritchey', 'Stem', 'Steel Stem 80mm', 1500),
('Hayes', 'Brakes', 'Hydraulic Disc Brake', 3500),
('Mavic', 'Wheel', 'Wheel Set 700c', 6000)

-- Insert detail-bicycle compatibility (simplified: bikes 1-4 compatible with parts 1-8)
INSERT INTO [DetailForBicycle] ([BicycleId], [DetailId]) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(2, 1), (2, 2), (2, 3), (2, 6), (2, 7),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 8),
(4, 1), (4, 2), (4, 3), (4, 7), (4, 8),
(5, 1), (5, 3), (5, 4), (5, 5),
(6, 1), (6, 3), (6, 6),
(7, 2), (7, 3), (7, 4),
(8, 1), (8, 2), (8, 7), (8, 8)

-- Insert rental records (past 6 months)
INSERT INTO [RentBook] ([Date], [Time], [Paid], [BicycleId], [ClientId], [StaffId]) VALUES
('2024-09-01', 3, 1, 1, 1, 1),
('2024-09-02', 5, 1, 2, 2, 2),
('2024-09-03', 2, 1, 3, 3, 3),
('2024-09-05', 4, 0, 4, 4, 4),
('2024-09-10', 6, 1, 1, 5, 5),
('2024-09-12', 3, 1, 2, 6, 6),
('2024-09-15', 2, 1, 3, 7, 7),
('2024-09-18', 5, 1, 5, 8, 1),
('2024-10-01', 4, 1, 1, 1, 2),
('2024-10-03', 3, 1, 2, 3, 3),
('2024-10-05', 2, 1, 4, 4, 4),
('2024-10-08', 6, 1, 5, 5, 5),
('2024-10-10', 5, 0, 6, 6, 6),
('2024-10-12', 3, 1, 7, 7, 7),
('2024-10-15', 4, 1, 8, 8, 1),
('2024-10-18', 2, 1, 1, 2, 2),
('2024-10-20', 5, 1, 3, 3, 3),
('2024-10-22', 3, 1, 2, 4, 4),
('2024-10-25', 4, 1, 4, 5, 5),
('2024-10-28', 6, 1, 5, 6, 6),
('2024-11-01', 3, 1, 1, 7, 7),
('2024-11-05', 5, 1, 2, 8, 1),
('2024-11-08', 2, 1, 3, 1, 2),
('2024-11-10', 4, 1, 4, 2, 3),
('2024-11-12', 3, 1, 5, 3, 4),
('2024-11-15', 6, 1, 6, 4, 5),
('2024-11-18', 4, 1, 7, 5, 6),
('2024-11-20', 2, 1, 8, 6, 7),
('2024-12-01', 5, 1, 1, 7, 1),
('2024-12-03', 3, 1, 2, 8, 2),
('2024-12-05', 4, 1, 3, 1, 3),
('2024-12-08', 6, 1, 4, 2, 4),
('2024-12-10', 2, 1, 5, 3, 5),
('2024-12-12', 5, 1, 6, 4, 6),
('2025-01-05', 3, 1, 1, 5, 7),
('2025-01-08', 4, 1, 2, 6, 1),
('2025-01-10', 2, 1, 3, 7, 2),
('2025-01-15', 5, 1, 4, 8, 3),
('2025-01-18', 3, 1, 5, 1, 4)

-- Insert service records
INSERT INTO [ServiceBook] ([BicycleId], [DetailId], [Date], [Price], [StaffId]) VALUES
(1, 1, '2024-09-08', 1000, 3),
(1, 3, '2024-09-20', 500, 4),
(2, 2, '2024-09-25', 1500, 5),
(2, 4, '2024-10-05', 800, 6),
(3, 1, '2024-10-12', 1000, 7),
(3, 7, '2024-10-20', 2000, 1),
(4, 2, '2024-11-01', 1500, 2),
(4, 3, '2024-11-10', 500, 3),
(5, 1, '2024-11-15', 1000, 4),
(6, 4, '2024-11-22', 800, 5),
(7, 2, '2024-12-01', 1500, 6),
(8, 8, '2024-12-10', 3000, 7),
(1, 2, '2024-12-15', 1500, 1),
(2, 1, '2025-01-05', 1000, 2),
(3, 4, '2025-01-12', 800, 3)

-- ============================================================================
-- PART 4: ANALYTICAL QUERIES (5 T-SQL queries)
-- ============================================================================

-- QUERY 1: Top 5 most profitable bikes (max rent revenue - min repair costs)
-- Joins: Bicycle, RentBook, ServiceBook
SELECT TOP 5
    b.Id,
    b.Brand,
    COUNT(DISTINCT r.Id) as RentCount,
    SUM(r.Time * b.RentPrice) as TotalRentRevenue,
    ISNULL(SUM(sb.Price), 0) as TotalRepairCost,
    SUM(r.Time * b.RentPrice) - ISNULL(SUM(sb.Price), 0) as NetProfit
FROM [Bicycle] b
LEFT JOIN [RentBook] r ON b.Id = r.BicycleId
LEFT JOIN [ServiceBook] sb ON b.Id = sb.BicycleId
GROUP BY b.Id, b.Brand
ORDER BY NetProfit DESC

-- QUERY 2: Revenue by month with growth percentage
-- Joins: RentBook, Bicycle
SELECT
    YEAR(r.[Date]) as Year,
    MONTH(r.[Date]) as Month,
    DATEFROMPARTS(YEAR(r.[Date]), MONTH(r.[Date]), 1) as MonthStart,
    SUM(r.[Time] * b.RentPrice) as MonthlyRevenue,
    LAG(SUM(r.[Time] * b.RentPrice)) OVER (ORDER BY YEAR(r.[Date]), MONTH(r.[Date])) as PrevMonthRevenue,
    CAST(
        (SUM(r.[Time] * b.RentPrice) - 
         LAG(SUM(r.[Time] * b.RentPrice)) OVER (ORDER BY YEAR(r.[Date]), MONTH(r.[Date]))) 
        * 100.0 / 
        LAG(SUM(r.[Time] * b.RentPrice)) OVER (ORDER BY YEAR(r.[Date]), MONTH(r.[Date]))
        AS DECIMAL(10, 2)
    ) as GrowthPercentage
FROM [RentBook] r
JOIN [Bicycle] b ON r.BicycleId = b.Id
WHERE r.Paid = 1
GROUP BY YEAR(r.[Date]), MONTH(r.[Date])
ORDER BY Year, Month

-- QUERY 3: Staff performance: rentals handled and services performed
-- Joins: Staff, RentBook, ServiceBook
SELECT
    s.Id,
    s.Name,
    s.[Date] as HireDate,
    COUNT(DISTINCT r.Id) as RentalsHandled,
    COUNT(DISTINCT sb.BicycleId) as ServicesPerformed,
    SUM(r.[Time] * b.RentPrice) as RentRevenue,
    ISNULL(SUM(sb.Price), 0) as RepairRevenue
FROM [Staff] s
LEFT JOIN [RentBook] r ON s.Id = r.StaffId
LEFT JOIN [Bicycle] b ON r.BicycleId = b.Id
LEFT JOIN [ServiceBook] sb ON s.Id = sb.StaffId
GROUP BY s.Id, s.Name, s.[Date]
ORDER BY RentalsHandled DESC, RepairRevenue DESC

-- QUERY 4: Bikes needing maintenance (high repair costs vs rental revenue ratio)
-- Joins: Bicycle, RentBook, ServiceBook, Detail
SELECT TOP 10
    b.Id,
    b.Brand,
    b.RentPrice,
    SUM(r.[Time] * b.RentPrice) as TotalRentRevenue,
    ISNULL(SUM(sb.Price), 0) as TotalRepairCost,
    CAST(
        ISNULL(SUM(sb.Price), 0) * 100.0 / 
        NULLIF(SUM(r.[Time] * b.RentPrice), 0)
        AS DECIMAL(10, 2)
    ) as RepairCostPercentage,
    COUNT(DISTINCT sb.Date) as RepairEventCount
FROM [Bicycle] b
LEFT JOIN [RentBook] r ON b.Id = r.BicycleId
LEFT JOIN [ServiceBook] sb ON b.Id = sb.BicycleId
GROUP BY b.Id, b.Brand, b.RentPrice
HAVING ISNULL(SUM(sb.Price), 0) > 0
ORDER BY RepairCostPercentage DESC

-- QUERY 5: Client rental patterns and payment history
-- Joins: Client, RentBook, Bicycle
SELECT
    c.Id,
    c.Name,
    c.Country,
    COUNT(r.Id) as TotalRentals,
    SUM(CASE WHEN r.Paid = 1 THEN 1 ELSE 0 END) as PaidRentals,
    SUM(CASE WHEN r.Paid = 0 THEN 1 ELSE 0 END) as UnpaidRentals,
    CAST(
        SUM(CASE WHEN r.Paid = 1 THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(r.Id)
        AS DECIMAL(10, 2)
    ) as PaymentRate,
    SUM(r.[Time] * b.RentPrice) as TotalSpent,
    AVG(r.[Time]) as AvgRentalHours
FROM [Client] c
LEFT JOIN [RentBook] r ON c.Id = r.ClientId
LEFT JOIN [Bicycle] b ON r.BicycleId = b.Id
GROUP BY c.Id, c.Name, c.Country
ORDER BY TotalSpent DESC