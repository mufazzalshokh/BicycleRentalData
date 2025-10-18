-- ============================================================================
-- PART 2: CREATE DATA MART TABLE FOR BONUS CALCULATION (FIXED)
-- ============================================================================

-- Drop existing objects if they exist
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BonusDataMart')
    DROP TABLE [BonusDataMart]

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_LoadBonusDataMart')
    DROP PROCEDURE [sp_LoadBonusDataMart]

-- Create the bonus data mart table
CREATE TABLE [BonusDataMart]
(
    [Id] int IDENTITY(1,1) not null,
    [Year] int not null,
    [Month] int not null,
    [StaffId] int not null,
    [StaffName] varchar(100) not null,
    [TenureMonths] int not null,
    [TenurePercent] decimal(5, 2) not null,
    [RentRevenue] decimal(15, 2) not null,
    [RentBonusPercent] decimal(5, 2) not null,
    [RepairRevenue] decimal(15, 2) not null,
    [RepairBonusPercent] decimal(5, 2) not null,
    [BonusAmount] decimal(15, 2) not null,
    [CreatedDate] datetime default getdate(),
    [LoadedDate] datetime null,
    primary key([Id]),
    FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id])
)
GO

CREATE INDEX IX_BonusDataMart_YearMonth ON [BonusDataMart]([Year], [Month])
CREATE INDEX IX_BonusDataMart_StaffId ON [BonusDataMart]([StaffId])
GO

-- ============================================================================
-- CREATE STORED PROCEDURE - SIMPLIFIED VERSION (FIXED)
-- ============================================================================

CREATE PROCEDURE sp_LoadBonusDataMart
    @Year INT = NULL,
    @Month INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @TargetYear INT = ISNULL(@Year, YEAR(GETDATE()))
    DECLARE @TargetMonth INT = ISNULL(@Month, MONTH(GETDATE()))
    DECLARE @TargetDate DATE = DATEFROMPARTS(@TargetYear, @TargetMonth, 1)
    DECLARE @EndOfMonth DATE = EOMONTH(@TargetDate)
    
    -- Delete existing records for this month to allow re-runs
    DELETE FROM [BonusDataMart]
    WHERE [Year] = @TargetYear AND [Month] = @TargetMonth
    
    -- Insert bonus calculations for all staff
    INSERT INTO [BonusDataMart]
    (
        [Year],
        [Month],
        [StaffId],
        [StaffName],
        [TenureMonths],
        [TenurePercent],
        [RentRevenue],
        [RentBonusPercent],
        [RepairRevenue],
        [RepairBonusPercent],
        [BonusAmount],
        [LoadedDate]
    )
    SELECT
        @TargetYear as [Year],
        @TargetMonth as [Month],
        s.[Id],
        s.[Name],
        DATEDIFF(MONTH, s.[Date], @EndOfMonth) as [TenureMonths],
        CASE
            WHEN DATEDIFF(MONTH, s.[Date], @EndOfMonth) < 12 THEN 5.0
            WHEN DATEDIFF(MONTH, s.[Date], @EndOfMonth) < 24 THEN 10.0
            ELSE 15.0
        END as [TenurePercent],
        ISNULL(SUM(rb.[Time] * bc.RentPrice), 0) as [RentRevenue],
        30.0 as [RentBonusPercent],
        ISNULL(SUM(sb.Price), 0) as [RepairRevenue],
        80.0 as [RepairBonusPercent],
        CAST(
            (
                ISNULL(SUM(rb.[Time] * bc.RentPrice), 0) * 0.30 +
                ISNULL(SUM(sb.Price), 0) * 0.80
            ) *
            CASE
                WHEN DATEDIFF(MONTH, s.[Date], @EndOfMonth) < 12 THEN 0.05
                WHEN DATEDIFF(MONTH, s.[Date], @EndOfMonth) < 24 THEN 0.10
                ELSE 0.15
            END
        AS DECIMAL(15, 2)) as [BonusAmount],
        GETDATE()
    FROM [Staff] s
    LEFT JOIN [RentBook] rb ON s.Id = rb.StaffId
        AND YEAR(rb.[Date]) = @TargetYear
        AND MONTH(rb.[Date]) = @TargetMonth
        AND rb.Paid = 1
    LEFT JOIN [Bicycle] bc ON rb.BicycleId = bc.Id
    LEFT JOIN [ServiceBook] sb ON s.Id = sb.StaffId
        AND YEAR(sb.[Date]) = @TargetYear
        AND MONTH(sb.[Date]) = @TargetMonth
    GROUP BY
        s.[Id],
        s.[Name],
        s.[Date]
    
    PRINT 'Data Mart loaded successfully'
END
GO

-- ============================================================================
-- TEST THE STORED PROCEDURE
-- ============================================================================

-- Load bonus data for January 2025
EXEC sp_LoadBonusDataMart @Year = 2025, @Month = 1
GO

-- Load bonus data for October 2024
EXEC sp_LoadBonusDataMart @Year = 2024, @Month = 10
GO

-- View the loaded data
SELECT * FROM [BonusDataMart] ORDER BY [Year], [Month], [StaffName]
GO

-- Sample query: Top earners for a specific month
SELECT TOP 5
    [StaffName],
    [TenureMonths],
    [TenurePercent],
    [RentRevenue],
    [RepairRevenue],
    [BonusAmount]
FROM [BonusDataMart]
WHERE [Year] = 2025 AND [Month] = 1
ORDER BY [BonusAmount] DESC
GO