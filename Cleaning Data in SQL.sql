SELECT * 
FROM [dbo].[HousingMarket]

-- Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [dbo].[HousingMarket]

ALTER TABLE [dbo].[HousingMarket]
ADD SaleDateConverted Date

UPDATE [dbo].[HousingMarket]
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM [dbo].[HousingMarket]

-- Populate Property Address
SELECT *
FROM [dbo].[HousingMarket]
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[HousingMarket] a JOIN
[dbo].[HousingMarket] b ON a.ParcelID = b.ParcelID and
a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[HousingMarket] a JOIN
[dbo].[HousingMarket] b ON a.ParcelID = b.ParcelID and
a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM [dbo].[HousingMarket]

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [dbo].[HousingMarket]

ALTER TABLE [dbo].[HousingMarket]
ADD PropertySplitAddress nvarchar(255);

UPDATE [dbo].[HousingMarket]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [dbo].[HousingMarket]
ADD PropertySplitCity nvarchar(255);

UPDATE [dbo].[HousingMarket]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM [dbo].[HousingMarket]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [dbo].[HousingMarket]

ALTER TABLE [dbo].[HousingMarket]
ADD OwnerSplitAddress nvarchar(255);

UPDATE [dbo].[HousingMarket]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [dbo].[HousingMarket]
ADD OwnerSplitCity nvarchar(255);

UPDATE [dbo].[HousingMarket]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [dbo].[HousingMarket]
ADD OwnerSplitState nvarchar(255);

UPDATE [dbo].[HousingMarket]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in 'Sold as Vacant'
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[HousingMarket]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM [dbo].[HousingMarket]

UPDATE [dbo].[HousingMarket]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


-- Remove Duplicates
WITH RowNumCTE as 
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_number
FROM [dbo].[HousingMarket]
)
SELECT *
FROM RowNumCTE
WHERE row_number >1


-- Delete Unused Columns
SELECT *
FROM [dbo].[HousingMarket]


ALTER TABLE [dbo].[HousingMarket]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [dbo].[HousingMarket]
DROP COLUMN SaleDate