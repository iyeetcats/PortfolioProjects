
--standardized date format

SELECT SaleDate, CONVERT(Date,SaleDate) as SaleDate
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

--for some reason saledate wont convert permanently. will add another column instead and delete the old one

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)

--populate property address data
--29 addresses need to be filled. common point is the parcel ID with different unique ID. use inner join

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--lines above to show which unique ID should be matched with their respective addresses. created unnamed column with result

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)  
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--breaking address into individual columns (address, city, state)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar (255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar (255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--easier way is to use PARSENAME. replace all ',' with '.'

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar (255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar (255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar (255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)

-- change Y and N to Yes and No in "Sold as Vacant" field

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 

CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

--remove duplicates using CTE
--partition by unique value to each row(house) to remove duplicate house

WITH RowNumCTE AS
(
SELECT*
, 
ROW_NUMBER() OVER (
PARTITION BY 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID
) row_num
FROM PortfolioProject..NashvilleHousing
)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--delete unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





