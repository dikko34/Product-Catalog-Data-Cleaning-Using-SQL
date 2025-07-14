
--- Performing Data Cleaning on a Products Catalog Dataset

--- Creating Duplicate Table to Work with


CREATE TABLE [dbo].[Messy Product Catalog 2](
	[ProductID] [nvarchar](255) NULL,
	[ProductName] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Price] [float] NULL
) ON [PRIMARY]
GO


INSERT INTO [Messy Product Catalog 2]
SELECT *
FROM [Messy Product Catalog]

-- 1.Standardize product names (consistent casing and naming)

-- Identifying inconsistencies in product name
SELECT DISTINCT(ProductName),COUNT(ProductName) CountOfProducts
FROM [Messy Product Catalog 2]
GROUP BY ProductName

-- Standadising Case format

SELECT LOWER(ProductName)
FROM [Messy Product Catalog 2]

UPDATE [Messy Product Catalog 2]
SET ProductName = LOWER(ProductName)
FROM [Messy Product Catalog 2]

--- Merging Duplicate Product name

--- merging men's wear
SELECT ProductName
FROM [Messy Product Catalog 2]
WHERE ProductName LIKE 'men%'

UPDATE [Messy Product Catalog 2]
SET ProductName = 'mens wear'
WHERE ProductName LIKE 'men%'

--- shoes
SELECT ProductName
FROM [Messy Product Catalog 2]
WHERE ProductName LIKE 'shoe%'


UPDATE [Messy Product Catalog 2]
SET ProductName = 'shoes'
WHERE ProductName LIKE 'shoe%'

-- t shirt
SELECT ProductName
FROM [Messy Product Catalog 2]
WHERE ProductName LIKE 't%'

UPDATE [Messy Product Catalog 2]
SET ProductName = 't-shirt'
WHERE ProductName LIKE 't%'


--- women s clothes
SELECT ProductName
FROM [Messy Product Catalog 2]
WHERE ProductName LIKE 'women%'

UPDATE [Messy Product Catalog 2]
SET ProductName = 'womens clothes'
WHERE ProductName LIKE 'women%'


SELECT DISTINCT(ProductName)
FROM [Messy Product Catalog 2]


-- 2. Standardize Category Column 

-- Identifying inconsistencies in Category Column
SELECT DISTINCT(Category),COUNT(Category) CountOfProducts
FROM [Messy Product Catalog 2]
GROUP BY Category


-- Standadising Case format

SELECT LOWER(Category)
FROM [Messy Product Catalog 2]

UPDATE [Messy Product Catalog 2]
SET Category = LOWER(Category)
FROM [Messy Product Catalog 2]




--- Standardizing category names 

UPDATE [Messy Product Catalog 2]
SET Category = 'accessories'
WHERE Category LIKE 'access%'


UPDATE [Messy Product Catalog 2]
SET Category = 'mens wear'
WHERE Category LIKE 'men%'


UPDATE [Messy Product Catalog 2]
SET Category = 'foot wear'
WHERE Category LIKE 'foot%'



--- Merging similar categories into unified labels

SELECT Category
FROM [Messy Product Catalog 2]
WHERE Category IN('mens wear','women clothes')


UPDATE [Messy Product Catalog 2]
SET Category = 'clothing'
WHERE Category IN('mens wear','women clothes')


UPDATE [Messy Product Catalog 2]
SET Category = 'foot wear'
WHERE Category LIKE 'shoes%'



--- Updating ProductName Category 

UPDATE [Messy Product Catalog 2]
SET Category = 'footwear'
WHERE ProductName IN ('Shoes','sneakers')

UPDATE [Messy Product Catalog 2]
SET Category = 'clothing'
WHERE ProductName IN ('jacket','jeans','mens wear','t-shirt','womens clothes')

SELECT *
FROM [Messy Product Catalog 2]



--- 3.Handiling missing values/ NULL values


-- Identifying missing values

SELECT *
FROM [Messy Product Catalog 2]
WHERE Price IS NULL


--- Filling Null Prices With Average prices of Products

SELECT *,AVG(Price)OVER(PARTITION BY ProductName ORDER BY ProductName) Average_Price
FROM [Messy Product Catalog 2];


CREATE TABLE #Temp_AveragePrice(
ProductID NVARCHAR(255),
ProductName NVARCHAR(255),
Category NVARCHAR(255),
Price float,
Average_Prices float
)

INSERT INTO #Temp_AveragePrice
SELECT *,AVG(Price)OVER(PARTITION BY ProductName ORDER BY ProductName) Average_Price
FROM [Messy Product Catalog 2];

SELECT TempT.Price,Average_Prices,ISNULL(TempT.Price,Average_Prices)Price_Updated
FROM #Temp_AveragePrice TempT
JOIN [Messy Product Catalog 2] Pro2
	ON TempT.ProductID = Pro2.ProductID
WHERE TempT.Price IS NULL


--- Replacing Null prices

UPDATE [Messy Product Catalog 2]
SET Price = ISNULL(TempT.Price,Average_Prices)
FROM #Temp_AveragePrice TempT
JOIN [Messy Product Catalog 2] Pro2
	ON TempT.ProductID = Pro2.ProductID
WHERE TempT.Price IS NULL


SELECT *
FROM [Messy Product Catalog 2]
WHERE Price = Null;


--- 4.Removing Duplicates

-- identifying Duplicate Rows
WITH ROW_NUMBER_CTE AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY ProductID,
										ProductName,
										Category,
										Price ORDER BY ProductID) RowNumber
FROM [Messy Product Catalog 2]
)
SELECT *
FROM ROW_NUMBER_CTE
WHERE RowNumber > 1

SELECT *
FROM [Messy Product Catalog 2]
WHERE ProductID = 'P0014'


--- Deleting Duplicate Rows

WITH ROW_NUMBER_CTE AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY ProductID,
										ProductName,
										Category,
										Price ORDER BY ProductID) RowNumber
FROM [Messy Product Catalog 2]
)
DELETE
FROM ROW_NUMBER_CTE
WHERE RowNumber > 1