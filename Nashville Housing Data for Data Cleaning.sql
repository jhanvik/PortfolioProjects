/* 

Cleaning data in SQL Queries

*/

SELECT 
	*
FROM PortfolioProject..[NashvilleHousing]
------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format

SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

---- Here's another way to update it

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
join  PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL


UPDATE a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
join  PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address 
from PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)



ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))



Select *
From PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
from PortfolioProject..NashvilleHousing


select 
PARSENAME(replace(OwnerAddress,',','.'),3)
, PARSENAME(replace(OwnerAddress,',','.'),2)
, PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)




select * from PortfolioProject..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct SoldAsVacant, count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



SELECT 
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' then 'Yes'
		WHEN SoldAsVacant ='N' then 'no'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing



UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' then 'Yes'
		WHEN SoldAsVacant ='N' then 'no'
	ELSE SoldAsVacant
	END


--------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates


WITH RowNumCTE as (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference 
				ORDER BY 
					UniqueID) as rownum
FROM PortfolioProject..NashvilleHousing
--order by ParcelID
)
select * 
from RowNumCTE
where rownum > 1
order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
FROM PortfolioProject..NashvilleHousing



ALTER PortfolioProject..NashvilleHousing
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-------------------------------------------------------------------------------------------------------------------------------------------------

-- Importing Data using OPENROWSET and BULK Insert

-- More advanced and looks cooler, but have to configure server appropriately to do correctly
-- Wanted to provide this incase you wanted to try it


-- sp_configure 'show advanced options' , 1;
-- RECONFIGURE;
-- sp_configure ' Ad Hoc distributed Queries', 1;
-- RECONFIGURE;
-- GO


-- Use PortfoliProject

-- GO

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\jhanvi\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

