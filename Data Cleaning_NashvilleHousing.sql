SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]





--LIMPANDO OS DADOS
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------

--Padronizando formato de data
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE 


-----------------------------------------------------------------------------------------------------------

--Populando PropertyAddress
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID --nota-se que o parcelID se repete algumas vezes e o PropertyAddress é sempre o mesmo, entao dessa forma, 
--caso PropertyAddress esteja nulo mas tenha ele preenchido em outra linha onde o ParcelID é igual, podemos preenche-lo
--nota-se tambem que UNIQUEID realmente é unico kkk


SELECT NashA.ParcelID, NashA.PropertyAddress, NashB.ParcelID, NashB.PropertyAddress, ISNULL(NashA.PropertyAddress,NashB.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing NashA
JOIN PortfolioProject.dbo.NashvilleHousing NashB
	ON NashA.ParcelID = NashB.ParcelID
	AND NashA.[UniqueID ] <> NashB.[UniqueID ]
WHERE NashA.PropertyAddress IS NULL

UPDATE NashA 
SET PropertyAddress = ISNULL(NashA.PropertyAddress,NashB.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing NashA
JOIN PortfolioProject.dbo.NashvilleHousing NashB
	ON NashA.ParcelID = NashB.ParcelID
	AND NashA.[UniqueID ] <> NashB.[UniqueID ]
WHERE NashA.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------------

--Quebrando endereço de propriedade em colunas individuais (Endereco, Cidade, Estado)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------

--Quebrando endereço do dono em colunas individuais (Endereco, Cidade, Estado)
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)






--------------------------------------------------------------------------------------------------------------------------------
--Mudando Y e N para Yes e No no campo SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


--------------------------------------------------------------------------------------------------------------------------------
--Removendo duplicados

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


--------------------------------------------------------------------------------------------------------------------------------
--Removendo colunas inuteis

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress