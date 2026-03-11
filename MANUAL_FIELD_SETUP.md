# Manual Field Setup Guide for Salesforce Org "adaptive"

## Overview
The following custom fields need to be manually created in Setup UI. Use this guide to add all missing fields to Store__c, Department__c, and Product__c objects.

---

## Store__c Object - Missing Fields

**Navigate to:** Setup → Object Manager → Store__c → Fields & Relationships → New

### 1. Store_Type__c (店舗タイプ)
- **Data Type:** Picklist
- **Field Label:** 店舗タイプ
- **Field Name:** Store_Type__c
- **Picklist Values:** (Enter one per line)
  ```
  ディオ
  ラ・ムー
  ```
- **Required:** No
- **Default Value:** (leave blank)
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 2. Region__c (地域)
- **Data Type:** Picklist
- **Field Label:** 地域
- **Field Name:** Region__c
- **Picklist Values:** (Enter one per line)
  ```
  関東
  関西
  中部
  九州
  ```
- **Required:** No
- **Default Value:** (leave blank)
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 3. Status__c (ステータス)
- **Data Type:** Picklist
- **Field Label:** ステータス
- **Field Name:** Status__c
- **Picklist Values:** (Enter one per line)
  ```
  Active
  Closed
  ```
- **Required:** No
- **Default Value:** Active
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 4. Opening_Date__c (開店日)
- **Data Type:** Date
- **Field Label:** 開店日
- **Field Name:** Opening_Date__c
- **Required:** No
- **Default Value:** (leave blank)
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 5. Address__c (住所)
- **Data Type:** Text Area (Long)
- **Field Label:** 住所
- **Field Name:** Address__c
- **Length:** 32,768 characters
- **# Visible Lines:** 3
- **Required:** No
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 6. Assigned_SV__c (担当SV)
- **Data Type:** Lookup Relationship
- **Field Label:** 担当SV
- **Field Name:** Assigned_SV__c
- **Related To:** User
- **Required:** No
- **Delete Constraint:** Clear the value of this field (SetNull)
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

---

## Department__c Object - Missing Fields

**Navigate to:** Setup → Object Manager → Department__c → Fields & Relationships → New

### 1. Category_Level__c (カテゴリレベル)
- **Data Type:** Number
- **Field Label:** カテゴリレベル
- **Field Name:** Category_Level__c
- **Length:** 18
- **Decimal Places:** 0
- **Required:** No
- **Default Value:** (leave blank)
- **Help Text:** 1=大分類, 2=中分類, 3=小分類
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 2. Active__c (有効)
- **Data Type:** Checkbox
- **Field Label:** 有効
- **Field Name:** Active__c
- **Default Value:** Checked
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 3. Parent_Department__c (親部門)
- **Data Type:** Lookup Relationship
- **Field Label:** 親部門
- **Field Name:** Parent_Department__c
- **Related To:** Department__c
- **Required:** No
- **Delete Constraint:** Clear the value of this field (SetNull)
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 4. Waste_Rate_Threshold__c (廃棄率閾値)
- **Data Type:** Percent
- **Field Label:** 廃棄率閾値
- **Field Name:** Waste_Rate_Threshold__c
- **Length:** 18
- **Decimal Places:** 2
- **Required:** No
- **Default Value:** 5
- **Help Text:** デフォルト: 5%
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 5. Loss_Rate_Threshold__c (ロス率閾値)
- **Data Type:** Percent
- **Field Label:** ロス率閾値
- **Field Name:** Loss_Rate_Threshold__c
- **Length:** 18
- **Decimal Places:** 2
- **Required:** No
- **Default Value:** 20
- **Help Text:** デフォルト: 20%
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 6. Discount_Rate_Threshold__c (値引率閾値)
- **Data Type:** Percent
- **Field Label:** 値引率閾値
- **Field Name:** Discount_Rate_Threshold__c
- **Length:** 18
- **Decimal Places:** 2
- **Required:** No
- **Default Value:** 5
- **Help Text:** デフォルト: 5%
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 7. Profit_Margin_Min__c (荒利率最低値)
- **Data Type:** Percent
- **Field Label:** 荒利率最低値
- **Field Name:** Profit_Margin_Min__c
- **Length:** 18
- **Decimal Places:** 2
- **Required:** No
- **Default Value:** 20
- **Help Text:** デフォルト: 20%
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 8. YoY_Decline_Threshold__c (前年比閾値)
- **Data Type:** Percent
- **Field Label:** 前年比閾値
- **Field Name:** YoY_Decline_Threshold__c
- **Length:** 18
- **Decimal Places:** 2
- **Required:** No
- **Default Value:** -10
- **Help Text:** デフォルト: -10% (負の値は前年比減少を示す)
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 9. Inventory_Days_Max__c (在庫日数最大)
- **Data Type:** Number
- **Field Label:** 在庫日数最大
- **Field Name:** Inventory_Days_Max__c
- **Length:** 18
- **Decimal Places:** 0
- **Required:** No
- **Default Value:** 7
- **Help Text:** デフォルト: 7日
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

---

## Product__c Object - Missing Fields

**Navigate to:** Setup → Object Manager → Product__c → Fields & Relationships → New

### 1. Department__c (部門)
- **Data Type:** Lookup Relationship
- **Field Label:** 部門
- **Field Name:** Department__c
- **Related To:** Department__c
- **Required:** No
- **Delete Constraint:** Clear the value of this field (SetNull)
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 2. Category_Code__c (分類コード)
- **Data Type:** Text
- **Field Label:** 分類コード
- **Field Name:** Category_Code__c
- **Length:** 50
- **Required:** No
- **Unique:** No
- **External ID:** No
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 3. Category_Name__c (分類名)
- **Data Type:** Text
- **Field Label:** 分類名
- **Field Name:** Category_Name__c
- **Length:** 255
- **Required:** No
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 4. Unit_Price__c (単価)
- **Data Type:** Currency
- **Field Label:** 単価
- **Field Name:** Unit_Price__c
- **Length:** 18
- **Decimal Places:** 0
- **Required:** No
- **Default Value:** (leave blank)
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

### 5. Active__c (有効)
- **Data Type:** Checkbox
- **Field Label:** 有効
- **Field Name:** Active__c
- **Default Value:** Checked
- **Track Field History:** Yes
- **Visible to all profiles:** Yes

---

## Verification Steps

After creating all fields, verify they are accessible:

### 1. Check Field Creation
```bash
sf data query --query "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Store__c'" --target-org adaptive
```

**Expected Store__c fields:**
- Store_Code__c ✓ (already exists)
- Store_Type__c
- Region__c
- Status__c
- Opening_Date__c
- Address__c
- Assigned_SV__c

### 2. Check Department__c
```bash
sf data query --query "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Department__c'" --target-org adaptive
```

**Expected Department__c fields:**
- Department_Code__c ✓ (already exists)
- Category_Level__c
- Active__c
- Parent_Department__c
- Waste_Rate_Threshold__c
- Loss_Rate_Threshold__c
- Discount_Rate_Threshold__c
- Profit_Margin_Min__c
- YoY_Decline_Threshold__c
- Inventory_Days_Max__c

### 3. Check Product__c
```bash
sf data query --query "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Product__c'" --target-org adaptive
```

**Expected Product__c fields:**
- Product_Code__c ✓ (already exists)
- Department__c
- Category_Code__c
- Category_Name__c
- Unit_Price__c
- Active__c

### 4. Run Test Data Script
After all fields are created:

```bash
sf apex run --target-org adaptive --file scripts/apex/createTestDataSimplified.apex
```

**Expected Output:**
```
Stores created: 5
Departments created: 10
Products created: 50
PL Records created: 100
Alerts checked and updated
Sales Records created: 500
Sales alerts checked and updated
Reviews created: 10
Comments created: 30
=== Test Data Creation Complete ===
PL Alerts: 34
Sales Alerts: 100
```

---

## Quick Reference Table

| Object | Field API Name | Field Label | Type | Default | Required |
|--------|---------------|-------------|------|---------|----------|
| **Store__c** | | | | | |
| | Store_Type__c | 店舗タイプ | Picklist | - | No |
| | Region__c | 地域 | Picklist | - | No |
| | Status__c | ステータス | Picklist | Active | No |
| | Opening_Date__c | 開店日 | Date | - | No |
| | Address__c | 住所 | Text Area (Long) | - | No |
| | Assigned_SV__c | 担当SV | Lookup(User) | - | No |
| **Department__c** | | | | | |
| | Category_Level__c | カテゴリレベル | Number | - | No |
| | Active__c | 有効 | Checkbox | ☑ | No |
| | Parent_Department__c | 親部門 | Lookup(Department__c) | - | No |
| | Waste_Rate_Threshold__c | 廃棄率閾値 | Percent | 5 | No |
| | Loss_Rate_Threshold__c | ロス率閾値 | Percent | 20 | No |
| | Discount_Rate_Threshold__c | 値引率閾値 | Percent | 5 | No |
| | Profit_Margin_Min__c | 荒利率最低値 | Percent | 20 | No |
| | YoY_Decline_Threshold__c | 前年比閾値 | Percent | -10 | No |
| | Inventory_Days_Max__c | 在庫日数最大 | Number | 7 | No |
| **Product__c** | | | | | |
| | Department__c | 部門 | Lookup(Department__c) | - | No |
| | Category_Code__c | 分類コード | Text(50) | - | No |
| | Category_Name__c | 分類名 | Text(255) | - | No |
| | Unit_Price__c | 単価 | Currency | - | No |
| | Active__c | 有効 | Checkbox | ☑ | No |

**Total Fields to Create: 21 fields**
- Store__c: 6 fields
- Department__c: 9 fields
- Product__c: 6 fields

---

## Time Estimate
- **Per field:** 1-2 minutes
- **Total time:** ~30-40 minutes

## Tips
1. **Copy-paste field API names exactly** - one typo will break the test data script
2. **Enable Field History Tracking** for all fields during creation
3. **Set all fields visible to all profiles** to avoid permission issues
4. **Use default values** as specified - they help with alert detection
5. **Create fields in order** - Lookup fields need their target objects' fields first

---

## After Field Creation

Once all 21 fields are created, run:

```bash
# Test field access
sf apex run --target-org adaptive --file scripts/apex/testStoreFields.apex

# Create 700+ test records
sf apex run --target-org adaptive --file scripts/apex/createTestDataSimplified.apex

# Verify data creation
sf data query --query "SELECT COUNT() FROM Store__c" --target-org adaptive
sf data query --query "SELECT COUNT() FROM Department__c" --target-org adaptive
sf data query --query "SELECT COUNT() FROM Product__c" --target-org adaptive
sf data query --query "SELECT COUNT() FROM Weekly_Department_PL__c WHERE Has_Alert__c = true" --target-org adaptive
```

**Success Indicators:**
- ✅ 5 Stores
- ✅ 10 Departments
- ✅ 50 Products
- ✅ 100 PL Records (with ~34 alerts)
- ✅ 500 Sales Records (with ~100 alerts)
- ✅ 10 Reviews
- ✅ 30 Comments

---

## Troubleshooting

**Error: "Field does not exist"**
- Double-check API name spelling (including `__c` suffix)
- Verify field is visible to your user profile
- Refresh Setup page and check Fields & Relationships list

**Error: "Delete constraint required"**
- For Lookup fields to User: Use "Clear the value of this field"
- For Lookup fields to custom objects: Can use either "Don't allow deletion" or "Clear the value"

**Percent fields not accepting negative values**
- For YoY_Decline_Threshold__c: Percent fields CAN store negative values
- Just enter `-10` in the Default Value field

---

**Ready to start? Open Salesforce Setup in your browser and begin with Store__c → New Field!** 🚀
