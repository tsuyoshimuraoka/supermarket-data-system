# Phase 2: Transaction Data Objects - Deployment Guide

## Overview
This phase creates the two main transaction data objects for daily operations:
1. **Weekly Department P&L (週間部門別PL)** - Weekly_Department_PL__c
2. **Weekly Product Sales (週間単品売上)** - Weekly_Product_Sales__c

These objects handle high-volume daily data imports (~500 dept records + ~10,000 product records per day).

## Prerequisites
- Phase 1 deployed successfully (Store__c, Department__c, Product__c)
- Salesforce CLI (SFDX) authenticated
- System Administrator access

## Created Objects

### 1. Weekly_Department_PL__c (週間部門別PL)
Daily/weekly P&L data by department and store.

**Key Relationships:**
- Store__c (Lookup, Required) - Which store
- Department__c (Lookup, Required) - Which department
- Date__c (Date, Required) - Transaction date

**Field Categories:**

**A. Basic Information (5 fields)**
- Store__c (店舗) - Lookup to Store__c
- Department__c (部門) - Lookup to Department__c
- Date__c (日付) - Date, Required
- Week__c (週) - Text
- Period__c (期) - Text

**B. Sales Data (6 fields)**
- Sales_Amount__c (売上高) - Currency
- Sales_Ratio__c (構成比) - Percent
- YoY_Ratio__c (前年比) - Percent
- Sales_Per_Hour__c (人時売上高) - Currency
- Productivity_Per_Hour__c (人時生産性) - Currency
- Variance__c (乖離) - Percent

**C. Profit Data (4 fields)**
- Gross_Profit__c (荒利高) - Currency
- Gross_Profit_Margin__c (荒利率) - Percent
- Margin_Budget__c (率予算) - Percent
- Purchase_Rate__c (値入率) - Percent

**D. Loss & Waste Data (6 fields)**
- Loss_Rate__c (ロス率) - Percent
- Unknown_Loss__c (不明ロス) - Percent
- Discount_Rate__c (値引率) - Percent
- Discount_Amount__c (値引金額) - Currency
- Waste_Rate__c (廃棄率) - Percent
- Waste_Amount__c (廃棄金額) - Currency

**E. Inventory Data (4 fields)**
- Inventory_Days__c (在庫日数) - Number
- Beginning_Inventory__c (期首在庫) - Currency
- Purchase_Amount__c (仕入高) - Currency
- Ending_Inventory__c (期末在庫) - Currency

**F. Alert Flags (2 fields)**
- Has_Alert__c (アラート有) - Checkbox
- Alert_Type__c (アラート種別) - Text (comma-separated alert types)

**Total: 27 custom fields + AutoNumber Name field**

**Features:**
- AutoNumber: PL-{0000000}
- Field history tracking enabled
- Feed tracking enabled
- Public Read/Write sharing
- Expected volume: ~500 records/day (50 stores × 10 departments)

---

### 2. Weekly_Product_Sales__c (週間単品売上)
Daily/weekly product-level sales data.

**Key Relationships:**
- Store__c (Lookup, Required) - Which store
- Product__c (Lookup, Required) - Which product
- Department__c (Lookup, Optional) - Product's department
- Date__c (Date, Required) - Transaction date

**Field Categories:**

**A. Basic Information (5 fields)**
- Store__c (店舗) - Lookup to Store__c
- Product__c (商品) - Lookup to Product__c
- Department__c (部門) - Lookup to Department__c
- Date__c (日付) - Date, Required
- Period__c (期間) - Text

**B. Sales Data (6 fields)**
- Quantity__c (数量) - Number
- Sales_Amount__c (金額) - Currency
- Unit_Price_With_Tax__c (込単) - Currency
- Unit_Price_Without_Tax__c (抜単) - Currency
- Customer_Count__c (客数) - Number
- Daily_Sales_Qty__c (日販数) - Number (2 decimals)

**C. Discount & Waste (5 fields)**
- Discount_Quantity__c (値引数) - Number
- Discount_Amount__c (値引額) - Currency
- Waste_Quantity__c (廃棄数) - Number
- Waste_Amount__c (廃棄額) - Currency
- Loss_Rate__c (ロス率) - Percent

**D. YoY Comparison (5 fields)**
- Prior_Year_Date__c (前年日付) - Date
- Prior_Year_Quantity__c (前年数量) - Number
- Prior_Year_Amount__c (前年金額) - Currency
- Prior_Year_Customer_Count__c (前年客数) - Number
- YoY_Ratio__c (前年比) - Percent

**E. Performance Indicators (4 fields)**
- Quantity_PI__c (数量PI) - Number
- Amount_PI__c (金額PI) - Number
- Category__c (区分) - Number
- Composition_Ratio__c (構成比) - Percent

**F. Alert Flags (2 fields)**
- Has_Alert__c (アラート有) - Checkbox
- Alert_Type__c (アラート種別) - Text (comma-separated)

**Total: 27 custom fields + AutoNumber Name field**

**Features:**
- AutoNumber: PS-{0000000}
- Field history tracking disabled (for performance with high volume)
- Feed tracking enabled
- Public Read/Write sharing
- Expected volume: ~10,000 records/day (50 stores × 200 products average)

---

## Deployment Instructions

### Step 1: Verify Phase 1 Deployment

Ensure Phase 1 objects exist:
```bash
sfdx data query --query "SELECT COUNT() FROM Store__c" --target-org my-org
sfdx data query --query "SELECT COUNT() FROM Department__c" --target-org my-org
sfdx data query --query "SELECT COUNT() FROM Product__c" --target-org my-org
```

### Step 2: Deploy Phase 2 Objects

**Option A: Deploy All Phase 2 Metadata**
```bash
cd supermarket-data-system
sfdx project deploy start --target-org my-org
```

**Option B: Deploy Individual Objects**
```bash
# Deploy Weekly Department P&L
sfdx project deploy start --source-dir force-app/main/default/objects/Weekly_Department_PL__c --target-org my-org

# Deploy Weekly Product Sales
sfdx project deploy start --source-dir force-app/main/default/objects/Weekly_Product_Sales__c --target-org my-org
```

**Option C: Validate First**
```bash
sfdx project deploy start --target-org my-org --dry-run
```

### Step 3: Verify Deployment

Check in Salesforce UI:
1. Setup > Object Manager
2. Verify objects exist:
   - 週間部門別PL (Weekly_Department_PL__c) - 27 fields
   - 週間単品売上 (Weekly_Product_Sales__c) - 27 fields

Or via CLI:
```bash
sfdx data query --query "SELECT QualifiedApiName, Label FROM EntityDefinition WHERE QualifiedApiName IN ('Weekly_Department_PL__c', 'Weekly_Product_Sales__c')" --target-org my-org
```

### Step 4: Create Tabs

Create tabs for easy navigation:
1. Setup > User Interface > Tabs
2. Click **New** in Custom Object Tabs
3. Create tabs for:
   - Weekly_Department_PL__c (週間部門別PL)
   - Weekly_Product_Sales__c (週間単品売上)

### Step 5: Configure List Views

Create useful list views:

**Weekly_Department_PL__c:**
- "今日のPL" - Records from today
- "アラート有" - Has_Alert__c = TRUE
- "高廃棄率" - Waste_Rate__c > 5%
- "低利益率" - Gross_Profit_Margin__c < 20%

**Weekly_Product_Sales__c:**
- "今日の売上" - Records from today
- "トップ商品" - Sorted by Sales_Amount__c (descending)
- "アラート有" - Has_Alert__c = TRUE
- "前年割れ" - YoY_Ratio__c < 100%

---

## Data Model Architecture

### Relationship Diagram
```
Store__c (店舗マスター)
  ├── Weekly_Department_PL__c (多数)
  └── Weekly_Product_Sales__c (多数)

Department__c (部門マスター)
  ├── Weekly_Department_PL__c (多数)
  ├── Weekly_Product_Sales__c (多数)
  └── Product__c (多数)

Product__c (商品マスター)
  └── Weekly_Product_Sales__c (多数)
```

### Data Volume Estimates

**Daily Data Import:**
- Weekly_Department_PL__c: ~500 records/day
  - 50 stores × 10 departments average
- Weekly_Product_Sales__c: ~10,000 records/day
  - 50 stores × 200 active products average

**Annual Growth:**
- Weekly_Department_PL__c: ~182,500 records/year
- Weekly_Product_Sales__c: ~3,650,000 records/year

**Storage Considerations:**
- Monitor data storage usage quarterly
- Consider archiving strategy after 2-3 years
- Optimize indexes on Date__c, Store__c lookups

---

## Alert System Design

### Alert Detection Logic

Alerts are triggered when metrics exceed department-level thresholds.

**Alert Types:**
1. **HIGH_WASTE** - Waste_Rate__c > Department.Waste_Rate_Threshold__c
2. **HIGH_LOSS** - Loss_Rate__c > Department.Loss_Rate_Threshold__c
3. **HIGH_DISCOUNT** - Discount_Rate__c > Department.Discount_Rate_Threshold__c
4. **LOW_MARGIN** - Gross_Profit_Margin__c < Department.Profit_Margin_Min__c
5. **YOY_DECLINE** - YoY_Ratio__c < Department.YoY_Decline_Threshold__c
6. **HIGH_INVENTORY** - Inventory_Days__c > Department.Inventory_Days_Max__c

### Implementation (Phase 5)

Alert detection will be implemented using:
- **Flow Builder** - Scheduled flow runs daily after data import
- **Apex Trigger** - Real-time alert detection on record creation
- **Formula Fields** - For simple alert conditions

Alert_Type__c field stores comma-separated alert types:
```
Example: "HIGH_WASTE,LOW_MARGIN,YOY_DECLINE"
```

---

## Sample Data Import

### Import Weekly Department P&L Data

**CSV Format:**
```csv
Store__c,Department__c,Date__c,Sales_Amount__c,Gross_Profit_Margin__c,Waste_Rate__c,Loss_Rate__c
a015g000001234AAA,a025g000005678BBB,2026-03-10,2938.48,27.94,0.06,3.14
```

**Import Methods:**
1. Data Import Wizard
2. Data Loader
3. Apex batch import (for large volumes)

### Import Weekly Product Sales Data

**CSV Format:**
```csv
Store__c,Product__c,Date__c,Quantity__c,Sales_Amount__c,Loss_Rate__c,YoY_Ratio__c
a015g000001234AAA,a035g000009999CCC,2026-03-10,198,15583,0,71.9
```

**Best Practices:**
- Use External IDs (Store_Code__c, Product_Code__c) for upserts
- Import in batches of 10,000 records
- Run after business hours for large imports
- Validate data before import

---

## Performance Optimization

### Indexes

Salesforce automatically creates indexes on:
- Id fields
- External ID fields
- Lookup relationship fields

**Custom Indexes Recommended:**
- Weekly_Department_PL__c.Date__c
- Weekly_Product_Sales__c.Date__c

Create via Support case if needed.

### Query Optimization

**Good Practice:**
```sql
SELECT Id, Sales_Amount__c, Store__r.Name
FROM Weekly_Department_PL__c
WHERE Date__c = TODAY
AND Store__c = :storeId
LIMIT 100
```

**Avoid:**
```sql
-- Don't query without filters on large objects
SELECT Id FROM Weekly_Product_Sales__c
```

### Bulk Data Operations

For data imports:
- Use Bulk API 2.0
- Process in batches of 10,000
- Schedule during off-peak hours
- Monitor governor limits

---

## Testing Checklist

After deployment:

### Functional Testing
- [ ] Create Weekly_Department_PL__c record manually
- [ ] Create Weekly_Product_Sales__c record manually
- [ ] Verify lookup relationships work
- [ ] Test required field validation
- [ ] Verify data displays correctly in UI

### Data Import Testing
- [ ] Import sample PL data (10 records)
- [ ] Import sample product sales data (100 records)
- [ ] Verify no duplicate records
- [ ] Check field mappings
- [ ] Validate currency/percent fields display correctly

### Performance Testing
- [ ] Import 500 PL records in one batch
- [ ] Import 10,000 product sales records
- [ ] Monitor deployment time
- [ ] Check list view load times
- [ ] Verify report performance

### Alert Fields Testing
- [ ] Set Has_Alert__c = TRUE manually
- [ ] Add comma-separated values to Alert_Type__c
- [ ] Create list views filtered by alerts
- [ ] Verify alert fields in reports

---

## Troubleshooting

### Issue: Lookup Relationship Not Working

**Symptoms:** Cannot select Store/Department/Product when creating records

**Solution:**
1. Verify Phase 1 objects deployed successfully
2. Check field-level security for lookup fields
3. Ensure user has Read access to master objects
4. Verify sharing settings (Public Read/Write)

### Issue: Import Performance Slow

**Symptoms:** Data Loader taking too long

**Solution:**
1. Use Bulk API 2.0 instead of SOAP API
2. Reduce batch size to 5,000 records
3. Disable parallel processing if conflicts occur
4. Schedule imports during off-peak hours

### Issue: Field History Not Tracking

**Symptoms:** Changes not appearing in history

**Solution:**
1. Verify object-level history tracking enabled
2. Check specific fields have tracking enabled
3. Note: Weekly_Product_Sales__c has history disabled by default (performance)
4. Enable field tracking: Setup > Object Manager > Fields > Edit > Track Field History

### Issue: Cannot See Records

**Symptoms:** No records visible in list views

**Solution:**
1. Check list view filters
2. Verify sharing settings
3. Check record ownership
4. Ensure user has Read permission on object

---

## Data Archiving Strategy (Future)

Given the high data volume (3.6M+ records/year), consider archiving after 2-3 years:

**Options:**
1. **Big Objects** - Archive to Big Objects for historical reporting
2. **External Storage** - Export to data warehouse
3. **Heroku Postgres** - Store in external database
4. **Custom Archive Object** - Summarized historical data

**Retention Policy Recommendation:**
- Keep last 2 years in Salesforce (hot data)
- Archive 2-5 years in Big Objects (warm data)
- Export 5+ years to external storage (cold data)

---

## Next Steps

### Phase 2: ✅ COMPLETE
- Transaction data objects created
- High-volume data structure ready
- Alert fields configured

### Phase 3: 📋 Ready to Start
Create collaboration objects:
- Store_Review__c (店舗レビュー) - SV daily reviews
- Review_Comment__c (レビューコメント) - Two-way comments

### Phase 4: Data Import & Entry UI
- Excel upload component
- Manual entry forms
- Data validation

### Phase 5: Alert System
- Flow-based alert detection
- Email notifications
- Alert dashboard

---

## Support

For issues:
- Check deployment logs: `sfdx project deploy report`
- Review CLAUDE.md for overall architecture
- Check Salesforce debug logs for errors
- Contact Salesforce support for org limits

## Rollback

To remove Phase 2 objects:
```bash
# WARNING: This will delete all data
sfdx project delete source --source-dir force-app/main/default/objects/Weekly_Department_PL__c --target-org my-org
sfdx project delete source --source-dir force-app/main/default/objects/Weekly_Product_Sales__c --target-org my-org
```

---

**Phase 2 Status**: ✅ Ready for Deployment
**Last Updated**: 2026-03-10
**Version**: 1.0
**Metadata Files**: 56 (2 objects + 54 fields)
