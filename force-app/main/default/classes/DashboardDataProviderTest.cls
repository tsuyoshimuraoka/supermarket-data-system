/**
 * DashboardDataProviderTest - DashboardDataProviderのテストクラス
 */
@isTest
private class DashboardDataProviderTest {

    @testSetup
    static void setupTestData() {
        // テスト用店舗作成
        List<Store__c> stores = new List<Store__c>();
        for (Integer i = 1; i <= 5; i++) {
            stores.add(new Store__c(
                Name = 'Test Store ' + i,
                Store_Code__c = 'S00' + i
            ));
        }
        insert stores;

        // テスト用部門作成
        Department__c dept = new Department__c(
            Name = 'Test Department',
            Department_Code__c = 'DEPT001',
            Waste_Rate_Threshold__c = 5.0,
            Loss_Rate_Threshold__c = 20.0,
            Profit_Margin_Min__c = 20.0
        );
        insert dept;

        // テスト用PLデータ作成
        List<Weekly_Department_PL__c> plRecords = new List<Weekly_Department_PL__c>();
        for (Store__c store : stores) {
            for (Integer i = 0; i < 10; i++) {
                plRecords.add(new Weekly_Department_PL__c(
                    Store__c = store.Id,
                    Department__c = dept.Id,
                    Date__c = Date.today().addDays(-i),
                    Sales_Amount__c = 1000000 + (i * 10000),
                    Gross_Profit_Margin__c = 25.0 - i,
                    Waste_Rate__c = 3.0 + i * 0.5,
                    Loss_Rate__c = 15.0 + i,
                    YoY_Ratio__c = 5.0 - i * 0.5,
                    Has_Alert__c = Math.mod(i, 3) == 0,
                    Alert_Type__c = Math.mod(i, 3) == 0 ? 'HIGH_WASTE' : null
                ));
            }
        }
        insert plRecords;
    }

    @isTest
    static void testGetKPIData() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];

        Test.startTest();
        Map<String, Object> kpiData = DashboardDataProvider.getKPIData(
            store.Id,
            Date.today().addDays(-30),
            Date.today()
        );
        Test.stopTest();

        System.assertNotEquals(null, kpiData, 'KPI data should not be null');
        System.assert(kpiData.containsKey('salesSummary'), 'Should have sales summary');
        System.assert(kpiData.containsKey('profitSummary'), 'Should have profit summary');
        System.assert(kpiData.containsKey('alertSummary'), 'Should have alert summary');
    }

    @isTest
    static void testGetKPIDataAllStores() {
        Test.startTest();
        Map<String, Object> kpiData = DashboardDataProvider.getKPIData(
            null,  // 全店舗
            Date.today().addDays(-10),
            Date.today()
        );
        Test.stopTest();

        System.assertNotEquals(null, kpiData, 'KPI data should not be null');

        Map<String, Object> salesSummary = (Map<String, Object>)kpiData.get('salesSummary');
        System.assertNotEquals(null, salesSummary.get('totalSales'), 'Should have total sales');
    }

    @isTest
    static void testGetDepartmentPerformance() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];

        Test.startTest();
        List<Map<String, Object>> performance = DashboardDataProvider.getDepartmentPerformance(
            store.Id,
            Date.today().addDays(-10),
            Date.today()
        );
        Test.stopTest();

        System.assertNotEquals(null, performance, 'Performance data should not be null');
        System.assert(performance.size() > 0, 'Should have performance data');
    }

    @isTest
    static void testGetActiveAlerts() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];

        Test.startTest();
        List<DashboardDataProvider.AlertWrapper> alerts = DashboardDataProvider.getActiveAlerts(
            store.Id,
            5
        );
        Test.stopTest();

        System.assertNotEquals(null, alerts, 'Alerts should not be null');
        System.assert(alerts.size() > 0, 'Should have some alerts');

        // アラートデータ検証
        DashboardDataProvider.AlertWrapper alert = alerts[0];
        System.assertNotEquals(null, alert.id, 'Alert should have ID');
        System.assertNotEquals(null, alert.storeName, 'Alert should have store name');
    }

    @isTest
    static void testGetActiveAlertsAllStores() {
        Test.startTest();
        List<DashboardDataProvider.AlertWrapper> alerts = DashboardDataProvider.getActiveAlerts(
            null,  // 全店舗
            10
        );
        Test.stopTest();

        System.assertNotEquals(null, alerts, 'Alerts should not be null');
        System.assert(alerts.size() > 0, 'Should have alerts from all stores');
    }

    @isTest
    static void testTopAndBottomStores() {
        Test.startTest();
        Map<String, Object> kpiData = DashboardDataProvider.getKPIData(
            null,
            Date.today().addDays(-10),
            Date.today()
        );
        Test.stopTest();

        List<Object> topStores = (List<Object>)kpiData.get('topStores');
        List<Object> bottomStores = (List<Object>)kpiData.get('bottomStores');

        System.assertNotEquals(null, topStores, 'Top stores should not be null');
        System.assertNotEquals(null, bottomStores, 'Bottom stores should not be null');
        System.assert(topStores.size() > 0, 'Should have top stores');
        System.assert(bottomStores.size() > 0, 'Should have bottom stores');
    }

    @isTest
    static void testSalesTrend() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];

        Test.startTest();
        Map<String, Object> kpiData = DashboardDataProvider.getKPIData(
            store.Id,
            Date.today().addDays(-10),
            Date.today()
        );
        Test.stopTest();

        List<Object> salesTrend = (List<Object>)kpiData.get('salesTrend');
        System.assertNotEquals(null, salesTrend, 'Sales trend should not be null');
        System.assert(salesTrend.size() > 0, 'Should have trend data');
    }

    @isTest
    static void testAlertSummaryTypes() {
        Test.startTest();
        Map<String, Object> kpiData = DashboardDataProvider.getKPIData(
            null,
            Date.today().addDays(-10),
            Date.today()
        );
        Test.stopTest();

        Map<String, Object> alertSummary = (Map<String, Object>)kpiData.get('alertSummary');
        System.assertNotEquals(null, alertSummary.get('totalAlerts'), 'Should have total alerts');
        System.assertNotEquals(null, alertSummary.get('alertTypes'), 'Should have alert types');
    }

    @isTest
    static void testDefaultDateRange() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];

        Test.startTest();
        // null日付でテスト（デフォルト30日間）
        Map<String, Object> kpiData = DashboardDataProvider.getKPIData(
            store.Id,
            null,
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, kpiData, 'Should use default date range');
        System.assert(kpiData.containsKey('salesSummary'), 'Should have data');
    }
}
