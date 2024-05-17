select * 
from portfolio_project..NashvilleHousing

-- Standardize Date Format

select saleDate, CONVERT(Date, SaleDate)
from portfolio_project.dbo.NashvilleHousing

SELECT saleDate, 
       CONVERT(Date, SaleDate) AS SaleDateConverted
FROM portfolio_project.dbo.NashvilleHousing;


-- Populate Property Address data

Select *
From portfolio_project.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio_project.dbo.NashvilleHousing a
JOIN portfolio_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio_project.dbo.NashvilleHousing a
JOIN portfolio_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From portfolio_project.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address1,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address2
FROM portfolio_project.dbo.NashvilleHousing;

ALTER TABLE portfolio_project.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255);

UPDATE portfolio_project.dbo.NashvilleHousing
SET PropertySplitAddress = CASE 
                              WHEN CHARINDEX(',', PropertyAddress) > 0 
                              THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
                              ELSE PropertyAddress 
                           END,
    PropertySplitCity = CASE 
                           WHEN CHARINDEX(',', PropertyAddress) > 0 
                           THEN LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)))
                           ELSE ''
                        END;

Select *
From portfolio_project.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From portfolio_project.dbo.NashvilleHousing

ALTER TABLE portfolio_project.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

-- Add OwnerSplitAddress column if it doesn't exist
IF COL_LENGTH('portfolio_project.dbo.NashvilleHousing', 'OwnerSplitAddress') IS NULL
BEGIN
    ALTER TABLE portfolio_project.dbo.NashvilleHousing
    ADD OwnerSplitAddress NVARCHAR(255);
END;

-- Update OwnerSplitAddress using PARSENAME function
UPDATE portfolio_project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

-- Add OwnerSplitCity column if it doesn't exist
IF COL_LENGTH('portfolio_project.dbo.NashvilleHousing', 'OwnerSplitCity') IS NULL
BEGIN
    ALTER TABLE portfolio_project.dbo.NashvilleHousing
    ADD OwnerSplitCity NVARCHAR(255);
END;

-- Update OwnerSplitCity using PARSENAME function
UPDATE portfolio_project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

-- Add OwnerSplitState column if it doesn't exist
IF COL_LENGTH('portfolio_project.dbo.NashvilleHousing', 'OwnerSplitState') IS NULL
BEGIN
    ALTER TABLE portfolio_project.dbo.NashvilleHousing
    ADD OwnerSplitState NVARCHAR(255);
END;

-- Update OwnerSplitState using PARSENAME function
UPDATE portfolio_project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Select all records to verify the results
SELECT *
FROM portfolio_project.dbo.NashvilleHousing;

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolio_project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From portfolio_project.dbo.NashvilleHousing

UPDATE portfolio_project.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
                      WHEN SoldAsVacant = 'Y' THEN 'Yes'
                      WHEN SoldAsVacant = 'N' THEN 'No'
                      ELSE SoldAsVacant
                   END;

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM portfolio_project.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE;



WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM portfolio_project.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

Select *
From portfolio_project.dbo.NashvilleHousing

-- Delete Unused Columns



Select *
From portfolio_project.dbo.NashvilleHousing


ALTER TABLE portfolio_project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



