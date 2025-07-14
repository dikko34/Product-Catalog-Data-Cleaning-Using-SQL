
# 🧹 Product Catalog Data Cleaning Using SQL

## 🧩 Problem Statement / Business Context
The product catalog contained inconsistent naming conventions, missing values, and duplicate entries. Before analysis or integration with other systems, the data needed to be cleaned and standardized for accuracy, reporting, and usability in downstream processes.

---

## 🎯 Objectives / What Was Done

### 1. Product Name Standardization
- Converted all product names to lowercase for consistency
- Merged variations like `men's wear`, `menswear`, `MenWears` into `mens wear`
- Standardized names:
  - `tshirt`, `T-shirt`, `Tee` → `t-shirt`
  - `shoes`, `shoe`, `Sneaker` → `shoes`
  - `womens clothes`, `ladies wear` → `womens clothes`

### 2. Category Normalization
- Standardized all category entries using `LOWER()`
- Corrected and unified:
  - `accessories`, `accs.` → `accessories`
  - `footwear`, `foot wear` → `footwear`
  - Multiple clothing labels → `clothing`

### 3. Handling Missing Values
- Detected rows with `NULL` price values
- Computed average price per product using `AVG() OVER (PARTITION BY ProductName)`
- Replaced `NULL` prices using a temp table join

### 4. Duplicate Removal
- Identified duplicate entries using `ROW_NUMBER()`
- Removed all but one row using `DELETE` with a CTE

---

## 🗃️ Dataset Description
**Table:** `Messy Product Catalog`  
**Clean Copy:** `Messy Product Catalog 2`

**Columns:**
- `ProductID`
- `ProductName`
- `Category`
- `Price`

---

## 🛠️ Tools & SQL Concepts Used
- SQL Server
- `LOWER()`, `LIKE`, `UPDATE`
- `ISNULL()`, `AVG() OVER()`
- `ROW_NUMBER()` and `DELETE` for deduplication
- Temporary tables (`#Temp_AveragePrice`) for intermediate steps

---

## 🧠 Sample SQL Snippets

### Replacing NULL Prices with Averages
```sql
SELECT *, AVG(Price) OVER(PARTITION BY ProductName ORDER BY ProductName) AS Average_Price
FROM [Messy Product Catalog 2];
```

### Removing Duplicates with ROW_NUMBER
```sql
WITH ROW_NUMBER_CTE AS (
    SELECT *, ROW_NUMBER() OVER(
        PARTITION BY ProductID, ProductName, Category, Price 
        ORDER BY ProductID) AS RowNumber
    FROM [Messy Product Catalog 2]
)
DELETE FROM ROW_NUMBER_CTE
WHERE RowNumber > 1;
```

---

## 📈 Outcome

- ✅ Product names and categories are now consistent and analysis-ready
- ✅ Missing prices were filled using relevant product-level averages
- ✅ Duplicate entries removed, preserving dataset uniqueness
- ✅ A clean version of the dataset was created for further business use
