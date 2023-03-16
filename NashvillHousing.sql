-- Data Cleaning Project in MS SQL Server

Select * From [Nashville Housing]

----------------------------------------------------------------------------------------------------------------------
-- Standardizing SaleDate Format

Select SaleDate from [Nashville Housing]

Select SaleDate, CONVERT(Date, SaleDate)
From [Nashville Housing]

Update [Nashville Housing]
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table [Nashville Housing]
Add SaleDateStd Date;

Update [Nashville Housing]
Set SaleDateStd = CONVERT(Date, SaleDate)

Select SaleDateStd
From [Nashville Housing]

----------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

Select *
From [Nashville Housing]
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing] a
Join [Nashville Housing] b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing] a
Join [Nashville Housing] b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

----------------------------------------------------------------------------------------------------------------------
-- Breaking-out Address into individual columns (Address, City, State)

Select PropertyAddress
From [Nashville Housing]

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as City

From [Nashville Housing]

Alter Table [Nashville Housing]
Add PropertyAddressSplit nvarchar(255);

Update [Nashville Housing]
Set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table [Nashville Housing]
Add PropertyCitySplit nvarchar(255);

Update [Nashville Housing]
Set PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))

-- Alternate and faster way:
Select OwnerAddress
From [Nashville Housing]

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

From [Nashville Housing]

Alter Table [Nashville Housing]
Add OwnerAdd Nvarchar(255);

Update [Nashville Housing]
Set OwnerAdd = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table [Nashville Housing]
Add OwnerCity Nvarchar(255);

Update [Nashville Housing]
Set OwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table [Nashville Housing]
Add OwnerState Nvarchar(255);

Update [Nashville Housing]
Set OwnerState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From [Nashville Housing]

----------------------------------------------------------------------------------------------------------------------
-- Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville Housing]
Group By SoldAsVacant
Order By 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From [Nashville Housing]

Update [Nashville Housing]
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
				   When SoldAsVacant = 'N' Then 'No'
				   Else SoldAsVacant
				   End

----------------------------------------------------------------------------------------------------------------------
-- Removing Duplicates

With RowNumCTE1 As(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 Order By UniqueID) rownum

From [Nashville Housing]
)

Delete
From RowNumCTE1
Where rownum > 1
--Order By PropertyAddress


----------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select * 
From [Nashville Housing]

Alter Table [Nashville Housing]
Drop Column SaleDate, OwnerAddress, TaxDistrict, PropertyAddress