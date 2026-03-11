# Phase 1: Master Data Objects - Deployment Guide

## Overview
This phase creates the three master data objects for the Supermarket Data Management System:
1. **Store Master (店舗マスター)** - Store__c
2. **Department Master (部門マスター)** - Department__c
3. **Product Master (商品マスター)** - Product__c

## Prerequisites
- Salesforce CLI (SFDX) installed
- Salesforce org with appropriate permissions
- System Administrator access

## Created Objects

### 1. Store__c (店舗マスター)
Master data for all ~50 stores.

**Fields:**
- Store_Code__c (店舗コード) - Text, External ID, Unique, Required
- Store_Type__c (店舗タイプ) - Picklist (ディオ, ラ・ムー, その他)
- Region__c (地域) - Picklist (岡山, 広島, 兵庫, その他)
- Opening_Date__c (開店日) - Date
- Status__c (ステータス) - Picklist (営業中, 閉店)
- Address__c (住所) - Long Text Area
- Assigned_SV__c (担当スーパーバイザー) - Lookup to User

**Features:**
- Field history tracking enabled
- Feed tracking enabled
- Public Read/Write sharing

### 2. Department__c (部門マスター)
Hierarchical department/category master with configurable alert thresholds.

**Fields:**
- Department_Code__c (部門コード) - Text, External ID, Unique, Required
- Category_Level__c (カテゴリレベル) - Number (1=大分類, 2=中分類, 3=小分類)
- Parent_Department__c (親部門) - Lookup to Department__c (Self)
- Active__c (有効) - Checkbox, Default: true

**Alert Threshold Fields:**
- Waste_Rate_Threshold__c (廃棄率閾値) - Percent, Default: 5%
- Loss_Rate_Threshold__c (ロス率閾値) - Percent, Default: 20%
- Discount_Rate_Threshold__c (値引率閾値) - Percent, Default: 5%
- Profit_Margin_Min__c (荒利率最低値) - Percent, Default: 20%
- YoY_Decline_Threshold__c (前年比閾値) - Percent, Default: -10%
- Inventory_Days_Max__c (在庫日数最大) - Number, Default: 7

**Features:**
- Hierarchical structure (self-lookup)
- Configurable alert thresholds per department
- Field history tracking enabled
- Public Read/Write sharing

### 3. Product__c (商品マスター)
Master data for products (~10,000-50,000 products).

**Fields:**
- Product_Code__c (商品コード) - Text(50), External ID, Unique, Required
- Department__c (部門) - Lookup to Department__c
- Category_Code__c (分類コード) - Text(20)
- Category_Name__c (分類名) - Text(100)
- Unit_Price__c (単価) - Currency
- Active__c (有効) - Checkbox, Default: true

**Features:**
- Lookup to Department__c
- Field history tracking enabled
- Public Read/Write sharing

## Deployment Instructions

### Step 1: Authenticate to Salesforce

Choose one of the following methods:

**Option A: Web Login (Recommended for first-time)**
```bash
cd supermarket-data-system
sfdx org login web --alias my-org
```

**Option B: OAuth**
```bash
sfdx org login web --alias my-org --instance-url https://your-instance.salesforce.com
```

**Option C: JWT-based (for CI/CD)**
```bash
sfdx org login jwt --username your-username --jwt-key-file path/to/server.key --client-id your-client-id --alias my-org
```

### Step 2: Verify Metadata

Check that all metadata files are present:
```bash
ls -R force-app/main/default/objects/
```

You should see:
- Store__c/
- Department__c/
- Product__c/

Each with:
- [Object].object-meta.xml
- fields/ directory with field metadata files

### Step 3: Deploy to Salesforce

**Option A: Deploy All Metadata**
```bash
sfdx project deploy start --target-org my-org
```

**Option B: Deploy Specific Objects**
```bash
# Deploy Store object
sfdx project deploy start --source-dir force-app/main/default/objects/Store__c --target-org my-org

# Deploy Department object
sfdx project deploy start --source-dir force-app/main/default/objects/Department__c --target-org my-org

# Deploy Product object
sfdx project deploy start --source-dir force-app/main/default/objects/Product__c --target-org my-org
```

**Option C: Validate First (No deployment)**
```bash
sfdx project deploy start --target-org my-org --dry-run
```

### Step 4: Verify Deployment

Check deployment status:
```bash
sfdx project deploy report --target-org my-org
```

Or check in Salesforce UI:
1. Go to Setup
2. Navigate to: Object Manager
3. Verify the following objects exist:
   - 店舗マスター (Store__c)
   - 部門マスター (Department__c)
   - 商品マスター (Product__c)

### Step 5: Create Tabs (Optional)

Create tabs for easy access in the UI:

1. In Salesforce Setup, go to: **User Interface > Tabs**
2. Click **New** in Custom Object Tabs
3. Create tabs for:
   - Store__c (店舗マスター)
   - Department__c (部門マスター)
   - Product__c (商品マスター)

Or use CLI:
```bash
# Tab creation will be added in next update
```

### Step 6: Set Up Page Layouts (Optional)

The objects are created with default layouts. You can customize them in:
1. Setup > Object Manager > [Object] > Page Layouts
2. Organize fields as needed
3. Add related lists

## Post-Deployment Configuration

### 1. Configure User Permissions

Grant access to custom objects:
1. Setup > Users > Permission Sets
2. Create permission sets:
   - **Supervisor Access**
   - **Store Manager Access**
   - **Product Planning Access**
3. Grant Object permissions: Read, Create, Edit (not Delete for regular users)
4. Grant Field permissions: Read/Edit for all fields

### 2. Assign Supervisors to Stores

1. Navigate to Store records
2. Update the **Assigned_SV__c** field with the appropriate user
3. Each SV can be assigned to multiple stores

### 3. Set Up Department Hierarchy

1. Create top-level departments (Category_Level__c = 1)
2. Create mid-level categories (Category_Level__c = 2) with Parent_Department__c set
3. Create sub-categories (Category_Level__c = 3) with Parent_Department__c set

Example:
```
惣菜 (Level 1)
  ├── コロッケ (Level 2)
  │   ├── 牛コロッケ (Level 3)
  │   └── カニクリームコロッケ (Level 3)
  └── フライ (Level 2)
      ├── アジフライ (Level 3)
      └── 白身フライ (Level 3)
```

### 4. Configure Alert Thresholds

Review and adjust default alert thresholds per department:
1. Navigate to Department records
2. Update threshold fields as needed:
   - Waste_Rate_Threshold__c (Default: 5%)
   - Loss_Rate_Threshold__c (Default: 20%)
   - Discount_Rate_Threshold__c (Default: 5%)
   - Profit_Margin_Min__c (Default: 20%)
   - YoY_Decline_Threshold__c (Default: -10%)
   - Inventory_Days_Max__c (Default: 7 days)

## Sample Data Import

### Import Store Data

Create a CSV file with store data:
```csv
Name,Store_Code__c,Store_Type__c,Region__c,Status__c
ディオ玉島店,590,ディオ,岡山,営業中
ディオ岡山西店,591,ディオ,岡山,営業中
ラ・ムー姫路南店,592,ラ・ムー,兵庫,営業中
```

Import using Data Loader or Data Import Wizard:
1. Setup > Data > Data Import Wizard
2. Select "Custom Objects"
3. Choose "Store__c"
4. Upload CSV file
5. Map fields
6. Import

### Import Department Data

Example departments based on your Excel data:
```csv
Name,Department_Code__c,Category_Level__c,Active__c
惣菜,1,1,TRUE
青果,2,1,TRUE
精肉,3,1,TRUE
鮮魚,4,1,TRUE
日配,5,1,TRUE
グロサリー,6,1,TRUE
加工食品,7,1,TRUE
菓子,8,1,TRUE
```

### Import Product Data

Import product master data from your existing product list.

## Troubleshooting

### Issue: Deployment Fails

**Solution:**
1. Check error message in deployment report
2. Verify all required fields are present
3. Check for naming conflicts
4. Ensure org has available custom object/field capacity

### Issue: Cannot See Objects in UI

**Solution:**
1. Verify deployment succeeded
2. Create tabs for objects (see Step 5)
3. Check user permissions
4. Refresh browser cache

### Issue: Lookup Fields Not Working

**Solution:**
1. Ensure related objects are deployed first
2. Check field-level security
3. Verify relationship name is unique

## Next Steps

Once Phase 1 is deployed:
1. ✅ Master data objects created
2. ✅ Fields configured with proper data types
3. ✅ Alert thresholds set up
4. ⏭️ **Phase 2**: Create transaction data objects (Weekly_Department_PL__c, Weekly_Product_Sales__c)

## Support

For issues or questions:
- Check CLAUDE.md for overall project plan
- Review Salesforce Object Manager for object details
- Check deployment logs: `sfdx project deploy report`

## Rollback

To remove deployed objects:
```bash
# WARNING: This will delete all data in these objects
sfdx project delete source --source-dir force-app/main/default/objects/Store__c --target-org my-org
sfdx project delete source --source-dir force-app/main/default/objects/Department__c --target-org my-org
sfdx project delete source --source-dir force-app/main/default/objects/Product__c --target-org my-org
```

Or manually in Salesforce:
1. Setup > Object Manager
2. Select object
3. Click "Delete" (must delete all records first)

---

**Phase 1 Status**: ✅ Ready for Deployment
**Last Updated**: 2026-03-10
**Version**: 1.0
