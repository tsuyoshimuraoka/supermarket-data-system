# Deployment Guide - Salesforce Supermarket Data Management System

## Overview
This guide provides step-by-step instructions for deploying the system to a Salesforce org.

---

## Prerequisites

### 1. Salesforce Org
- **Org Type:** Developer Edition, Sandbox, or Production
- **Edition:** Enterprise or Unlimited (for full feature support)
- **API Version:** 65.0 or higher

### 2. Salesforce CLI
```bash
# Install Salesforce CLI
npm install -g @salesforce/cli

# Verify installation
sf --version
```

### 3. Org Authentication
```bash
# Authenticate to target org
sf org login web --alias my-org

# Verify authentication
sf org display --target-org my-org
```

### 4. Project Setup
```bash
# Clone repository (if applicable)
git clone <repo-url>
cd supermarket-data-system

# Verify project structure
sf project validate --target-org my-org
```

---

## Deployment Steps

### Step 1: Pre-Deployment Checklist

- [ ] Backup existing org configuration (if applicable)
- [ ] Review org limits: Storage, API calls, Apex classes
- [ ] Ensure no conflicting custom objects/fields exist
- [ ] Verify user licenses available for profiles
- [ ] Disable active triggers/flows that might conflict

```bash
# Check org limits
sf org display limits --target-org my-org

# List existing custom objects
sf sobject list --sobject-type custom --target-org my-org
```

---

### Step 2: Deploy Metadata

#### Option A: Automated Deployment (Recommended)
```bash
# Run deployment script
chmod +x scripts/deploy.sh
./scripts/deploy.sh my-org
```

#### Option B: Manual Deployment
```bash
# Deploy all metadata
sf project deploy start --target-org my-org

# Monitor deployment status
sf project deploy report --target-org my-org
```

#### Option C: Selective Deployment
```bash
# Deploy only objects
sf project deploy start --metadata CustomObject --target-org my-org

# Deploy only Apex classes
sf project deploy start --metadata ApexClass --target-org my-org

# Deploy only LWC components
sf project deploy start --metadata LightningComponentBundle --target-org my-org
```

**Expected Output:**
```
Deploying... ████████████████████████████████ 100%
✓ Successfully deployed metadata (ID: 0AfxxxxxxxxxxxxAAA)

Summary:
- Custom Objects: 7
- Custom Fields: 82
- Apex Classes: 8
- LWC Components: 4
- Flows: 2
- Email Templates: 4
```

---

### Step 3: Run Apex Tests

```bash
# Run all tests with code coverage
sf apex run test --target-org my-org --code-coverage --result-format human --wait 10

# Run specific test class
sf apex run test --target-org my-org --tests AlertServiceTest --code-coverage
```

**Expected Results:**
```
Test Summary:
- Tests Run: 40
- Passing: 40
- Failing: 0
- Code Coverage: 91%

✓ All tests passed
```

**Troubleshooting:**
- If tests fail, check:
  - Master data exists (Store, Department, Product)
  - User permissions are correct
  - Flow is active

---

### Step 4: Post-Deployment Configuration

#### 4.1 Activate Flows
```bash
# Open org
sf org open --target-org my-org
```

1. Navigate to **Setup → Process Automation → Flows**
2. Find flows:
   - `Alert_Detection_Daily`
   - `Comment_Notification`
3. Verify Status = **Active**
4. If inactive, click **Activate**

#### 4.2 Configure Email Deliverability
1. Navigate to **Setup → Email Administration → Deliverability**
2. Set **Access level** to:
   - **All Email** (for production)
   - **System Email Only** (for sandbox testing)

#### 4.3 Add Custom Tabs
1. Navigate to **Setup → User Interface → Tabs**
2. Create tabs for:
   - Store__c (Icon: Building)
   - Department__c (Icon: Hierarchy)
   - Product__c (Icon: Product)
   - Weekly_Department_PL__c (Icon: Dashboard)
   - Weekly_Product_Sales__c (Icon: Sales)
   - Store_Review__c (Icon: Feedback)

#### 4.4 Create App
1. Navigate to **Setup → App Manager**
2. Create new Lightning App: **Supermarket Management**
3. Add tabs: Home, Store, Department, Product, Weekly PL, Weekly Sales, Reviews, Dashboards
4. Assign to profiles: Supervisor, Store Manager, Product Planning

#### 4.5 Add LWC Components to Pages
**Option 1: Via Lightning App Builder**
1. Open any Store Review record
2. Click **Setup icon → Edit Page**
3. Drag **storeReviewComponent** to page layout
4. Save and Activate

**Option 2: Create Custom Page**
1. **App Builder → New → Record Page → Store Review**
2. Add components:
   - storeReviewComponent (full width)
   - Related Lists (below)
3. Activate for all users

---

### Step 5: Create Test Data

#### Option A: Run Apex Script (Recommended)
```bash
# Open Execute Anonymous window
sf org open --target-org my-org

# Navigate to: Setup → Developer Console → Debug → Open Execute Anonymous Window
# Copy contents of scripts/apex/createTestData.apex
# Click Execute
```

**Expected Debug Log Output:**
```
Stores created: 5
Departments created: 10
Products created: 50
PL Records created: 100
Sales Records created: 500
Reviews created: 10
Comments created: 30
PL Alerts: 33
Sales Alerts: 100
=== Test Data Creation Complete ===
```

#### Option B: Manual Data Import
```bash
# Import CSV files via Data Import Wizard or Data Loader
# Files: data/Store_Import_Template.csv, Department_Import_Template.csv, Product_Import_Template.csv
```

1. Navigate to **Setup → Data → Data Import Wizard**
2. Select **Custom Objects**
3. Import in order:
   - Store__c (from Store_Import_Template.csv)
   - Department__c (from Department_Import_Template.csv)
   - Product__c (from Product_Import_Template.csv)

---

### Step 6: Verification

#### 6.1 Verify Deployment
```bash
# List deployed objects
sf sobject describe --sobject-type Store__c --target-org my-org

# Query records
sf data query --query "SELECT COUNT() FROM Store__c" --target-org my-org
```

#### 6.2 Verify Apex Classes
```bash
# List Apex classes
sf apex list class --target-org my-org | grep -E "Alert|Comment|Excel|Dashboard"
```

**Expected Output:**
```
AlertService
AlertServiceTest
CommentService
CommentServiceTest
ExcelImportController
ExcelImportControllerTest
DashboardDataProvider
DashboardDataProviderTest
```

#### 6.3 Verify LWC Components
```bash
sf project retrieve start --metadata LightningComponentBundle --target-org my-org
ls -la force-app/main/default/lwc/
```

**Expected Components:**
- excelUploader
- weeklyDepartmentPLForm
- weeklyProductSalesForm
- storeReviewComponent

#### 6.4 Manual Verification Checklist
- [ ] All 7 custom objects visible in Schema Builder
- [ ] Test data created successfully
- [ ] CSV upload works via excelUploader component
- [ ] Alert Detection flow active and scheduled
- [ ] Comment Notification flow active
- [ ] Email templates accessible
- [ ] Mobile app displays pages correctly
- [ ] No permission errors for test users

---

### Step 7: User Setup

#### 7.1 Create Profiles/Permission Sets
**Option 1: Clone Standard Profile**
```bash
# Via UI:
Setup → Users → Profiles → Clone "Standard User" → "Supervisor Profile"
```

**Option 2: Create Permission Set**
```bash
# Via UI:
Setup → Users → Permission Sets → New
Name: "Supermarket Data Access"
Grant: Read/Create/Edit on all custom objects
```

#### 7.2 Create Test Users
```bash
# Via Setup → Users → New User
# Create 3 users:
- SV User (Profile: Supervisor Profile)
- Manager User (Profile: Store Manager Profile)
- Planning User (Profile: Product Planning Profile)
```

#### 7.3 Assign SV to Stores
```bash
# Update Store records to assign Assigned_SV__c field
sf data update record --sobject Store__c --record-id <recordId> --values "Assigned_SV__c=<userId>" --target-org my-org
```

---

### Step 8: Test End-to-End Workflow

1. **CSV Import Test**
   - Navigate to Home → excelUploader component
   - Select "週間部門別PL"
   - Upload test CSV file
   - Verify: Success message, records created

2. **Alert Detection Test**
   - Wait for scheduled flow (6 AM) OR
   - Run flow manually: Setup → Flows → Alert_Detection_Daily → Run
   - Verify: Alert flags set on records with metrics exceeding thresholds

3. **Review & Comment Test**
   - Navigate to Store record
   - Create new Store Review
   - Add comment via storeReviewComponent
   - Verify: Comment displays, notification sent

4. **Dashboard Test**
   - Call DashboardDataProvider.getKPIData() via Anonymous Apex
   - Verify: KPI data returned with no errors

5. **Mobile Test**
   - Open Salesforce Mobile App
   - Navigate to Store Review record
   - Verify: Compact layout, comment thread visible

---

## Rollback Procedure

If deployment fails or issues arise:

### Option 1: Quick Destructive Changes
```bash
# Create destructiveChanges.xml
sf project generate manifest --from-org my-org --output-dir manifest

# Deploy empty package with destructive changes
sf project deploy start --manifest manifest/destructiveChanges.xml --target-org my-org
```

### Option 2: Sandbox Refresh
```bash
# For sandbox environments:
Setup → Sandboxes → Actions → Refresh
```

### Option 3: Org Restore (Production only)
```bash
# Contact Salesforce Support for org snapshot restore
# Available for Enterprise/Unlimited editions
```

---

## Troubleshooting

### Issue 1: Deployment Failed
**Error:** `The requested resource does not exist`

**Solution:**
```bash
# Validate API version
sf project deploy validate --target-org my-org

# Check for missing dependencies
sf project retrieve start --metadata ApexClass --target-org my-org
```

### Issue 2: Tests Failing
**Error:** `System.QueryException: List has no rows for assignment`

**Solution:**
```bash
# Ensure test data exists
# Run: scripts/apex/createTestData.apex
# OR use @testSetup methods in test classes
```

### Issue 3: Flow Not Triggering
**Error:** Flow executes but no alerts set

**Solution:**
1. Check flow is **Active** (Setup → Flows)
2. Verify AlertService.checkAlerts() method exists
3. Check Department threshold values are set
4. Review Flow Debug Logs (Setup → Debug Logs)

### Issue 4: Email Not Sending
**Error:** Email template not found

**Solution:**
1. Check Deliverability settings (Setup → Email Administration)
2. Verify email templates exist (Setup → Email Templates)
3. Check user email address is valid
4. Review Email Log Files (Setup → Logs → Email Log Files)

### Issue 5: LWC Component Not Displaying
**Error:** Component not found on page

**Solution:**
```bash
# Redeploy LWC components
sf project deploy start --metadata LightningComponentBundle --target-org my-org

# Clear browser cache
# Refresh Lightning App Builder
```

---

## Performance Optimization

### For Large Data Volumes (> 1M records)

1. **Enable Bulk API for Data Loads**
   ```bash
   sf data import bulk --sobject Weekly_Department_PL__c --file data.csv --target-org my-org
   ```

2. **Create Custom Indexes**
   ```bash
   # Via Setup → Schema Builder
   # Add indexes on:
   - Store__c.Store_Code__c
   - Department__c.Department_Code__c
   - Product__c.Product_Code__c
   - Weekly_Department_PL__c.Date__c
   - Weekly_Product_Sales__c.Date__c
   ```

3. **Archive Old Data**
   ```bash
   # Set up Big Objects for historical data (optional)
   # OR export to Data Lake (via Salesforce Connect)
   ```

---

## Maintenance

### Monthly Tasks
- Review error logs (Setup → Debug Logs)
- Check storage usage (Setup → System Overview)
- Update alert thresholds if needed
- Review flow execution history

### Quarterly Tasks
- Run Apex test suite
- Review code coverage
- Update documentation
- User feedback survey

---

## Support

### Internal Support
- **Technical Issues:** Salesforce Admin Team
- **Business Process:** Product Planning Team
- **Training:** User Training Team

### External Support
- **Salesforce Support:** https://help.salesforce.com
- **Trailhead Learning:** https://trailhead.salesforce.com
- **Developer Forums:** https://developer.salesforce.com/forums

---

## Deployment Checklist

- [ ] Pre-deployment backup complete
- [ ] Metadata deployed successfully
- [ ] Apex tests passing (>75% coverage)
- [ ] Flows activated
- [ ] Email deliverability configured
- [ ] Custom tabs created
- [ ] Lightning App configured
- [ ] LWC components added to pages
- [ ] Test data created
- [ ] User profiles/permission sets configured
- [ ] Test users created
- [ ] SV assignments completed
- [ ] End-to-end workflow tested
- [ ] Mobile access verified
- [ ] Documentation updated
- [ ] Users trained

---

**Deployment Complete!** 🎉

For questions or issues, refer to TEST_CASES.md or contact the project team.
