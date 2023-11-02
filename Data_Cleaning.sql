--SQL Data Cleaning Project--

--Let's Check The Table--

select *from NashvilleHousing

--We can see there are NULL values in different Columns. We will try to fix them.

--First we will convert SaleDate to Date Format.

----------------------------------------------------------------------Standardize Date Format-------------------------------------------------------------------

select SaleDate, Convert(Date,SaleDate) 
from NashvilleHousing

Update NashvilleHousing
set SaleDate = Convert(Date,SaleDate)

--The table is not updating. So we will add a new column in the table

Alter table NashvilleHousing
add SellingDate Date

Update NashvilleHousing
set SellingDate = Convert(Date,SaleDate)

select * from NashvilleHousing

-------------------------------------------------------Yes new date column is added-------------------------------------------------------------



------------------------------------------------------------------------Fix the null values of Property Addresses----------------------------------------------------------------------------
select* from NashvilleHousing
where PropertyAddress is null

--we can see parcelid is not unique and with similar parcelid some has no property address.So we will Populate Property Addresses with those which have........

--we will do self Join to populate property address..

select a.ParcelID ,a.PropertyAddress , b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------Successfully Updated property Adrresses and now there is no null values in this column--------------------------------------------


--------------------------------------------------Change Property Address To  two different columns [address and City]----------------------------------------------------------------------

select PropertyAddress from NashvilleHousing

--we can see a delimeter (comma) is separating Adrress and City. we will separate them into two columns...........charindex gives position

select 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Home_Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from NashvilleHousing

Alter table NashvilleHousing
add Property_Address nvarchar(255)

Alter table NashvilleHousing
add Property_City nvarchar(255)

update NashvilleHousing
set Property_Address = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

update NashvilleHousing
set Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select * from NashvilleHousing

-----------------------------------------------------------------------Similarly  Play With Owner's Address-------------------------------------------------------------------------

select OwnerAddress from NashvilleHousing

select 
PARSENAME(replace(OwnerAddress,',','.'),3) as Road,
PARSENAME(replace(OwnerAddress,',','.'),2) as City,
PARSENAME(replace(OwnerAddress,',','.'),1) as State
from NashvilleHousing

Alter table NashvilleHousing
add Owner_Address nvarchar(255)

Alter table NashvilleHousing
add Owner_City nvarchar(255)

Alter table NashvilleHousing
add Owner_State nvarchar(255)

update NashvilleHousing
set Owner_Address = PARSENAME(replace(OwnerAddress,',','.'),3)

update NashvilleHousing
set Owner_City = PARSENAME(replace(OwnerAddress,',','.'),2)

update NashvilleHousing
set Owner_State = PARSENAME(replace(OwnerAddress,',','.'),1)

select * from NashvilleHousing

-------Now we have Owners Address separately as state,cty and address.........................

Update NashvilleHousing
set OwnerAddress = 'No Address'
where OwnerAddress is null

update NashvilleHousing
set Owner_Address = 'None'
where Owner_Address is null

update NashvilleHousing
set Owner_City = 'None'
where Owner_City is null

update NashvilleHousing
set Owner_State = 'None'
where Owner_State is null


-------------------------------------------------------------------Owner's Name Feild Has null values-----------------------------------------------------------------
select OwnerName
from NashvilleHousing


update NashvilleHousing
set OwnerName = 'Anonymous'
where OwnerName is null


------------------------------------------------------Fill Nul Values Of Numeric Feilds like LandValue,BuildingValue, TotalValue, Bedrooms,Bath-----------------------------------------------------
select * from NashvilleHousing

update NashvilleHousing
set LandValue = (select convert(int ,AVG(LandValue)) from NashvilleHousing)
where LandValue is null

update NashvilleHousing
set BuildingValue = (select convert(int ,AVG(BuildingValue)) from NashvilleHousing)
where BuildingValue is null

update NashvilleHousing
set TotalValue = (select convert(int ,AVG(TotalValue)) from NashvilleHousing)
where TotalValue is null

update NashvilleHousing
set Bedrooms = (select convert(int ,AVG(Bedrooms)) from NashvilleHousing)
where Bedrooms is null


update NashvilleHousing
set FullBath = (select convert(int ,AVG(FullBath)) from NashvilleHousing)
where FullBath is null


update NashvilleHousing
set HalfBath = (select convert(int ,AVG(HalfBath)) from NashvilleHousing)
where HalfBath is null


update NashvilleHousing
set YearBuilt = (select convert(int ,AVG(YearBuilt)) from NashvilleHousing)
where YearBuilt is null


update NashvilleHousing
set Acreage = 2.24
where Acreage is null

-------------------------------------------------------------
select * from NashvilleHousing



----------------------------------------------------------Change Y/N to Yes/No in "Sold as Vacant" field for efficiency------------------------------------------------
select * from NashvilleHousing

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant,
case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end
from NashvilleHousing


Update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end



--------------------------------------------------------------------------------------Remove Duplicates------------------------------------------------------------------------------------

with Row_NumCTE AS (
select * ,
row_number() over (partition by 
					ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					Order by
					UniqueID) row_num
from NashvilleHousing 

)
select * from Row_NumCTE
--Delete from Row_NumCTE
where row_num>1


-----------------------------------------------------------------------------Delete Unnecessary Columns-------------------------------------------------------------------------
select * from NashvilleHousing

Alter table NashvilleHousing
drop column PropertyAddress,SaleDate,TaxDistrict, OwnerAddress
