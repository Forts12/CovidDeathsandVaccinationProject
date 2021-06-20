--Data Cleaning SQL Queries



--1) Standarize date formats

Select SaleDate, convert(date,SaleDate)
from PortfolioProject..NashvilleHousing$

Alter table NashvilleHousing$
Add SaleDateConverted Date;

Update NashvilleHousing$
SET SaleDateConverted = convert(date,SaleDate)

Alter table NashvilleHousing$
Drop column SaleDate

Select * from NashvilleHousing$




--2) Populate Property Address Data

Select PropertyAddress from PortfolioProject..NashvilleHousing$
where PropertyAddress is null

Select pa.ParcelID, pa.PropertyAddress, pr.parcelID, pr.PropertyAddress, ISNULL(pa.propertyAddress, pr.PropertyAddress)
from PortfolioProject..NashvilleHousing$ as pa
join PortfolioProject..NashvilleHousing$ as pr
	on pa.ParcelID = pr.ParcelID
	and pa.[UniqueID ] <> pr.[UniqueID ]
where pa.PropertyAddress is null

update pa
SET PropertyAddress = ISNULL(pa.PropertyAddress,pr.PropertyAddress)
from PortfolioProject..NashvilleHousing$ as pa
join PortfolioProject..NashvilleHousing$ as pr
	on pa.ParcelID = pr.ParcelID
	and pa.[UniqueID ] <> pr.[UniqueID ]
where pa.PropertyAddress is null




--3) Breaking out address into individual columns(Address, City, State)

Select PropertyAddress from PortfolioProject..NashvilleHousing$

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing$

Alter table PortfolioProject..NashvilleHousing$
Add SplitAddress Nvarchar(225);

Update PortfolioProject..NashvilleHousing$
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter table PortfolioProject..NashvilleHousing$
Add SplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing$
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))




--4) Breaking Owner Address into Street, City and State Name

--Method 1
--trying double Substring
Select
SUBSTRING(OwnerAddress,1, CHARINDEX(',',OwnerAddress) -1) as OStreetAddress
,SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress) +1 , LEN(OwnerAddress)) as OCityAddress
,SUBSTRING(SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress) +1 , LEN(OwnerAddress)), 
CHARINDEX(',',SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress) +1 , LEN(OwnerAddress))) +1, 
LEN(SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress) +1 , LEN(OwnerAddress)))) as OStateAddress 
From PortfolioProject..NashvilleHousing$

--Method 2
--Parsename

Select OwnerAddress from PortfolioProject..NashvilleHousing$

Select 
Parsename(Replace(OwnerAddress,',','.'),1) as PState,
Parsename(Replace(OwnerAddress,',','.'),2) as PCity,
Parsename(Replace(OwnerAddress,',','.'),3) as PStreet
from PortfolioProject..NashvilleHousing$ as PState

Alter table PortfolioProject..NashvilleHousing$
Add Pstate nvarchar(255);

Update PortfolioProject..NashvilleHousing$
SET PState = Parsename(Replace(OwnerAddress,',','.'),1)

Alter table PortfolioProject..NashvilleHousing$
Add Pcityy nvarchar(255);

Update PortfolioProject..NashvilleHousing$
SET PCityy = Parsename(Replace(OwnerAddress,',','.'),2)

Alter table PortfolioProject..NashvilleHousing$
Add Pstreet nvarchar(255);

Update PortfolioProject..NashvilleHousing$
SET Pstreet = Parsename(Replace(OwnerAddress,',','.'),3)




--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct SoldAsVacant from PortfolioProject..NashvilleHousing$

Select SoldAsVacant 
CASE when SoldAsVacant = 'y' then 'Yes'
	 when SoldAsVacant = 'n' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing$





--Remove Duplicates


WITH ROWNUMCHECK AS(
Select *, 
	ROW_NUMBER() Over (
	Partition by	ParcelID, 
					PropertyAddress, 
					LegalReference, 
					OwnerAddress 
					order by 
						UniqueID
						) row_num

from PortfolioProject..NashvilleHousing$
)
Select * from ROWNUMCHECK
where row_num>1




--Delete Unused Columns


Alter table PortfolioProject..NashvilleHousing$
Drop column SplitAddress, PStAddress 

Select * from PortfolioProject..NashvilleHousing$
