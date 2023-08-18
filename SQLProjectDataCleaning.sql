
--Cleaning Data in SQL Queries

Select *
From [Portfolio Project]..NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted,SaleDate
From [Portfolio Project]..NashvilleHousing


Alter Table NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address Data

Select *
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID, b. ParcelID, a.PropertyAddress, b. PropertyAddress, ISNULL(a.PropertyAddress,b. PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b. PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is NULL

-- Breaking Out Address into Individual Columns (Address, City, State)

Select PropertySplitAddress, PropertySplitCity
From [Portfolio Project]..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress,1 ,CHARINDEX(',', PropertyAddress)-1 ) As Address,
SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As Address
From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1 ,CHARINDEX(',', PropertyAddress)-1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From [Portfolio Project]..NashvilleHousing

--

Select OwnerAddress
From [Portfolio Project]..NashvilleHousing

Select
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)

-- Changing Y and N to Yes and No

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
From [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						Else SoldAsVacant
						END

-- Removing Duplicates

WITH Row_NUMCTE AS 
(Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
From [Portfolio Project]..NashvilleHousing)

Select *
From Row_NUMCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused Columns

Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
