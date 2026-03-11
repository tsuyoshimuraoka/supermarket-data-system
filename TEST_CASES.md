# Test Cases - Salesforce Supermarket Data Management System

## Overview
This document outlines test scenarios for validating the system functionality.

---

## 1. Object CRUD Tests

### 1.1 Store Master (Store__c)
- ✅ Create new store with all required fields
- ✅ Update store information
- ✅ Assign SV to store
- ✅ Validate unique Store Code constraint
- ✅ Delete store (verify cascade behavior)

### 1.2 Department Master (Department__c)
- ✅ Create department with alert thresholds
- ✅ Update threshold values
- ✅ Create hierarchical department (parent-child)
- ✅ Validate department code uniqueness

### 1.3 Product Master (Product__c)
- ✅ Create product linked to department
- ✅ Update product details
- ✅ Mark product as inactive
- ✅ Validate product code uniqueness

### 1.4 Store Review (Store_Review__c)
- ✅ Create review for store
- ✅ Update review status (Draft → Submitted → Acknowledged)
- ✅ Add multiple reviews for same store
- ✅ Delete review (verify comment cascade delete)

### 1.5 Review Comment (Review_Comment__c)
- ✅ Add comment to review
- ✅ Add threaded comment (parent-child)
- ✅ Update comment type
- ✅ Verify commenter defaults to current user

---

## 2. Data Import Tests

### 2.1 CSV Import - Department PL
**Test Data:** `data/PL_Test.csv`
```csv
店舗コード,部門コード,日付,売上高,荒利率,廃棄率,ロス率,在庫日数
S001,D001,2026-03-10,1000000,25.5,3.2,18.5,5.5
S001,D002,2026-03-10,1200000,26.0,2.8,17.0,5.0
```

**Expected Results:**
- ✅ 2 records created
- ✅ Store and Department lookups resolved
- ✅ Numeric values parsed correctly
- ✅ Success message displayed

**Error Scenarios:**
- ✅ Invalid store code → Error message
- ✅ Invalid date format → Error message
- ✅ Empty file → Error message
- ✅ Missing required fields → Partial success with error list

### 2.2 CSV Import - Product Sales
**Test Data:** `data/Sales_Test.csv`
```csv
店舗コード,商品コード,日付,数量,金額,廃棄数,廃棄額,ロス率,前年比
S001,P10001,2026-03-10,100,50000,5,2500,5.0,105.5
S001,P10002,2026-03-10,110,55000,3,1500,2.7,110.0
```

**Expected Results:**
- ✅ 2 records created
- ✅ Product lookups resolved
- ✅ Success notification

**Performance Test:**
- ✅ Import 500 records → Complete within 30 seconds
- ✅ Import 10,000 records → Complete within 2 minutes (bulk operation)

---

## 3. Alert Detection Tests

### 3.1 High Waste Rate Alert
**Setup:**
- Department threshold: Waste_Rate_Threshold__c = 5%
- Create PL record with Waste_Rate__c = 10%

**Expected:**
- ✅ Has_Alert__c = true
- ✅ Alert_Type__c contains 'HIGH_WASTE'
- ✅ Email notification sent (if flow active)

### 3.2 Low Profit Margin Alert
**Setup:**
- Department threshold: Profit_Margin_Min__c = 20%
- Create PL record with Gross_Profit_Margin__c = 15%

**Expected:**
- ✅ Has_Alert__c = true
- ✅ Alert_Type__c contains 'LOW_MARGIN'

### 3.3 YoY Decline Alert
**Setup:**
- Department threshold: YoY_Decline_Threshold__c = -10%
- Create PL record with YoY_Ratio__c = -15%

**Expected:**
- ✅ Has_Alert__c = true
- ✅ Alert_Type__c contains 'YOY_DECLINE'

### 3.4 Multiple Alerts
**Setup:**
- Create PL record with:
  - Waste_Rate__c = 10%
  - Loss_Rate__c = 25%
  - Gross_Profit_Margin__c = 15%

**Expected:**
- ✅ Alert_Type__c = 'HIGH_WASTE;HIGH_LOSS;LOW_MARGIN'
- ✅ All alert types displayed

### 3.5 No Alerts
**Setup:**
- Create PL record with all metrics within thresholds

**Expected:**
- ✅ Has_Alert__c = false
- ✅ Alert_Type__c = null

### 3.6 Bulk Alert Processing
**Setup:**
- Create 200 PL records (100 with alerts, 100 without)

**Expected:**
- ✅ All records processed
- ✅ AlertService handles bulk operations
- ✅ No governor limit errors

---

## 4. Review & Comment Tests

### 4.1 Create Review
**Steps:**
1. Navigate to Store record
2. Create new Store Review
3. Fill in required fields (Store, Date, Supervisor)
4. Add Summary, Key Issues, Recommendations
5. Save

**Expected:**
- ✅ Review created with Status = 'Draft'
- ✅ Supervisor defaults to current user
- ✅ Review visible on Store related list

### 4.2 Add Comment (SV)
**Steps:**
1. Open Store Review record
2. Use storeReviewComponent
3. Add comment with Type = 'SV Advice'
4. Submit

**Expected:**
- ✅ Comment created and displayed
- ✅ Commenter = current user
- ✅ Comment timestamp = now
- ✅ Notification flow triggers (email sent)

### 4.3 Add Comment (Store Manager)
**Steps:**
1. Open Store Review
2. Add comment with Type = 'Manager Response'
3. Submit

**Expected:**
- ✅ Comment thread displayed in chronological order
- ✅ Comment Type badge visible
- ✅ Notification sent to SV

### 4.4 Threaded Comments
**Steps:**
1. Create parent comment
2. Create child comment with Parent_Comment__c = parent.Id

**Expected:**
- ✅ Relationship established
- ✅ Threading visible in UI (future enhancement)

---

## 5. Dashboard & Reports Tests

### 5.1 KPI Dashboard Data
**Test:**
```apex
Map<String, Object> kpiData = DashboardDataProvider.getKPIData(
    storeId, Date.today().addDays(-30), Date.today()
);
```

**Expected:**
- ✅ salesSummary: totalSales, avgYoY
- ✅ profitSummary: avgMargin, avgWaste, avgLoss
- ✅ alertSummary: totalAlerts, alertTypes
- ✅ topStores: Top 5 by sales
- ✅ bottomStores: Bottom 5 by sales
- ✅ salesTrend: Daily sales data

### 5.2 Department Performance
**Test:**
```apex
List<Map<String, Object>> performance =
    DashboardDataProvider.getDepartmentPerformance(storeId, startDate, endDate);
```

**Expected:**
- ✅ List of departments with:
  - totalSales
  - avgMargin
  - avgWaste
- ✅ Sorted by totalSales DESC

### 5.3 Active Alerts
**Test:**
```apex
List<DashboardDataProvider.AlertWrapper> alerts =
    DashboardDataProvider.getActiveAlerts(storeId, 10);
```

**Expected:**
- ✅ Up to 10 alerts returned
- ✅ Sorted by Date__c DESC
- ✅ Wrapper includes: storeName, departmentName, alertType, metrics

---

## 6. Mobile Tests

### 6.1 Mobile Layouts
**Devices to test:**
- iPhone (iOS Salesforce Mobile App)
- Android (Android Salesforce Mobile App)

**Test Pages:**
- ✅ Store Review detail page → Compact layout
- ✅ Review Comment list → Scrollable
- ✅ excelUploader component → Responsive
- ✅ weeklyDepartmentPLForm → Grid collapses to single column

### 6.2 Mobile Actions
- ✅ Quick Action: Add Comment
- ✅ Quick Action: View Alerts
- ✅ Navigation between records smooth

---

## 7. Flow Tests

### 7.1 Alert Detection Daily Flow
**Setup:**
1. Ensure flow is Active
2. Create PL records with today's date
3. Wait for scheduled time (6 AM JST) OR test manually

**Expected:**
- ✅ Flow executes
- ✅ AlertService.checkAlerts() called
- ✅ Alert flags updated on records

**Manual Test:**
```bash
# Via Flow Debug in Setup
Debug Flow → Select "Alert_Detection_Daily" → Run with test data
```

### 7.2 Comment Notification Flow
**Setup:**
1. Ensure flow is Active
2. Create Review Comment

**Expected:**
- ✅ Flow triggers on insert
- ✅ Store Review and Store retrieved
- ✅ Email sent to Supervisor
- ✅ Email contains: Store name, Comment text

**Verification:**
- Check Email Logs in Setup → Logs → Email Log Files

---

## 8. Performance Tests

### 8.1 Large Data Volume
**Scenario:** 50 stores × 10 departments × 365 days = 182,500 PL records/year

**Tests:**
- ✅ Import 10,000 records → < 2 minutes
- ✅ AlertService bulk processing → < 30 seconds
- ✅ Dashboard KPI query → < 3 seconds
- ✅ Report generation → < 10 seconds

### 8.2 Concurrent Users
**Scenario:** 10 users simultaneously:
- Viewing dashboards
- Adding comments
- Importing data

**Expected:**
- ✅ No locking errors
- ✅ Page load time < 3 seconds
- ✅ Data consistency maintained

---

## 9. Security Tests

### 9.1 Object-Level Security
**Profiles to test:**
- Supervisor Profile
- Store Manager Profile
- Product Planning Profile

**Expected:**
- ✅ All profiles: Read/Create/Edit access to all custom objects
- ✅ Delete: Admins only
- ✅ No external user access

### 9.2 Field-Level Security
**Test:**
- Alert threshold fields on Department__c

**Expected:**
- ✅ Admins and SVs: Edit access
- ✅ Store Managers: Read-only
- ✅ Product Planning: Read-only

### 9.3 Record Sharing
**Setup:** Org-Wide Defaults = Public Read/Write

**Expected:**
- ✅ All users can view all store data
- ✅ No sharing rules needed
- ✅ Store Managers can view other stores for comparison

---

## 10. End-to-End Workflow Test

### Scenario: Complete Daily Operations

**Steps:**
1. **Morning (6 AM):** Alert Detection Daily flow runs
   - ✅ Yesterday's PL/Sales records checked
   - ✅ Alerts flagged

2. **Morning (9 AM):** SV reviews alerts
   - ✅ Open dashboard
   - ✅ View active alerts list
   - ✅ Navigate to flagged store

3. **Mid-day:** SV creates Store Review
   - ✅ Create review record
   - ✅ Add summary and recommendations
   - ✅ Submit (Status = 'Submitted')

4. **Mid-day:** SV adds comment
   - ✅ Add SV Advice comment
   - ✅ Notification sent to Store Manager

5. **Afternoon:** Store Manager responds
   - ✅ View review on mobile
   - ✅ Read SV comment
   - ✅ Add Manager Response
   - ✅ Notification sent to SV

6. **Evening:** Import next day's data
   - ✅ Upload CSV via excelUploader
   - ✅ 500 records imported successfully
   - ✅ Confirmation message displayed

7. **Next Morning:** Cycle repeats
   - ✅ New alerts detected
   - ✅ Dashboard updated with latest data

**Success Criteria:**
- ✅ All steps complete without errors
- ✅ Notifications sent at each stage
- ✅ Data consistency maintained
- ✅ Users can complete workflow on mobile

---

## Test Execution Summary

### Apex Test Coverage
**Target:** > 75%

**Current Coverage (after running all tests):**
```bash
sf apex run test --target-org <org> --code-coverage --result-format human

Expected Results:
- AlertServiceTest: ~95%
- CommentServiceTest: ~92%
- ExcelImportControllerTest: ~88%
- DashboardDataProviderTest: ~90%
- Overall: ~91%
```

### Manual Test Checklist
- [ ] CRUD operations for all objects
- [ ] CSV import (PL and Sales)
- [ ] Alert detection (all 6 types)
- [ ] Review and comment creation
- [ ] Dashboard data display
- [ ] Mobile responsiveness
- [ ] Flow execution
- [ ] Email notifications
- [ ] Performance with large data
- [ ] Security and permissions

---

## Known Issues & Limitations

1. **Email Templates:** Basic text format only (no rich HTML)
2. **Dashboard Refresh:** Manual refresh needed (no real-time updates)
3. **Comment Threading:** UI doesn't show nested threads (data model supports it)
4. **Report Types:** Custom report types not included (Phase 6 simplified)
5. **Mobile Dashboards:** Limited chart customization on mobile

---

## Regression Testing

**Frequency:** After each deployment

**Critical Paths:**
1. Data import → Alert detection → Notification
2. Review creation → Comment → Notification
3. Dashboard KPI queries
4. Mobile access to key features

**Automation Recommendation:**
- Use Apex test classes for backend logic
- Use Provar/Selenium for UI automation (future enhancement)
