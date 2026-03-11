/**
 * AlertServiceTest - AlertServiceのテストクラス
 */
@isTest
private class AlertServiceTest {

    @testSetup
    static void setupTestData() {
        // テスト用店舗作成
        Store__c store = new Store__c(
            Name = 'Test Store',
            Store_Code__c = 'TEST001'
        );
        insert store;

        // テスト用部門作成（閾値設定）
        Department__c dept = new Department__c(
            Name = 'Test Department',
            Department_Code__c = 'DEPT001',
            Waste_Rate_Threshold__c = 5.0,
            Loss_Rate_Threshold__c = 20.0,
            Discount_Rate_Threshold__c = 5.0,
            Profit_Margin_Min__c = 20.0,
            YoY_Decline_Threshold__c = -10.0,
            Inventory_Days_Max__c = 7
        );
        insert dept;

        // テスト用商品作成
        Product__c product = new Product__c(
            Name = 'Test Product',
            Product_Code__c = 'PROD001',
            Department__c = dept.Id
        );
        insert product;
    }

    @isTest
    static void testHighWasteAlert() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        Department__c dept = [SELECT Id FROM Department__c LIMIT 1];

        Weekly_Department_PL__c pl = new Weekly_Department_PL__c(
            Store__c = store.Id,
            Department__c = dept.Id,
            Date__c = Date.today(),
            Waste_Rate__c = 10.0
        );
        insert pl;

        Test.startTest();
        List<Weekly_Department_PL__c> plList = [
            SELECT Id, Department__c, Waste_Rate__c, Loss_Rate__c, Discount_Rate__c,
                   Gross_Profit_Margin__c, YoY_Ratio__c, Inventory_Days__c,
                   Has_Alert__c, Alert_Type__c
            FROM Weekly_Department_PL__c
        ];
        AlertService.checkAlerts(plList);
        update plList;
        Test.stopTest();

        pl = [SELECT Has_Alert__c, Alert_Type__c FROM Weekly_Department_PL__c WHERE Id = :pl.Id];
        System.assert(pl.Has_Alert__c, 'Alert should be set');
        System.assert(pl.Alert_Type__c.contains('HIGH_WASTE'), 'Should have HIGH_WASTE alert');
    }

    @isTest
    static void testHighLossAlert() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        Department__c dept = [SELECT Id FROM Department__c LIMIT 1];

        Weekly_Department_PL__c pl = new Weekly_Department_PL__c(
            Store__c = store.Id,
            Department__c = dept.Id,
            Date__c = Date.today(),
            Loss_Rate__c = 25.0
        );
        insert pl;

        Test.startTest();
        List<Weekly_Department_PL__c> plList = [
            SELECT Id, Department__c, Waste_Rate__c, Loss_Rate__c, Discount_Rate__c,
                   Gross_Profit_Margin__c, YoY_Ratio__c, Inventory_Days__c,
                   Has_Alert__c, Alert_Type__c
            FROM Weekly_Department_PL__c
        ];
        AlertService.checkAlerts(plList);
        update plList;
        Test.stopTest();

        pl = [SELECT Has_Alert__c, Alert_Type__c FROM Weekly_Department_PL__c WHERE Id = :pl.Id];
        System.assert(pl.Has_Alert__c, 'Alert should be set');
        System.assert(pl.Alert_Type__c.contains('HIGH_LOSS'), 'Should have HIGH_LOSS alert');
    }

    @isTest
    static void testLowMarginAlert() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        Department__c dept = [SELECT Id FROM Department__c LIMIT 1];

        Weekly_Department_PL__c pl = new Weekly_Department_PL__c(
            Store__c = store.Id,
            Department__c = dept.Id,
            Date__c = Date.today(),
            Gross_Profit_Margin__c = 15.0
        );
        insert pl;

        Test.startTest();
        List<Weekly_Department_PL__c> plList = [
            SELECT Id, Department__c, Waste_Rate__c, Loss_Rate__c, Discount_Rate__c,
                   Gross_Profit_Margin__c, YoY_Ratio__c, Inventory_Days__c,
                   Has_Alert__c, Alert_Type__c
            FROM Weekly_Department_PL__c
        ];
        AlertService.checkAlerts(plList);
        update plList;
        Test.stopTest();

        pl = [SELECT Has_Alert__c, Alert_Type__c FROM Weekly_Department_PL__c WHERE Id = :pl.Id];
        System.assert(pl.Has_Alert__c, 'Alert should be set');
        System.assert(pl.Alert_Type__c.contains('LOW_MARGIN'), 'Should have LOW_MARGIN alert');
    }

    @isTest
    static void testYoYDeclineAlert() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        Department__c dept = [SELECT Id FROM Department__c LIMIT 1];

        Weekly_Department_PL__c pl = new Weekly_Department_PL__c(
            Store__c = store.Id,
            Department__c = dept.Id,
            Date__c = Date.today(),
            YoY_Ratio__c = -15.0
        );
        insert pl;

        Test.startTest();
        List<Weekly_Department_PL__c> plList = [
            SELECT Id, Department__c, Waste_Rate__c, Loss_Rate__c, Discount_Rate__c,
                   Gross_Profit_Margin__c, YoY_Ratio__c, Inventory_Days__c,
                   Has_Alert__c, Alert_Type__c
            FROM Weekly_Department_PL__c
        ];
        AlertService.checkAlerts(plList);
        update plList;
        Test.stopTest();

        pl = [SELECT Has_Alert__c, Alert_Type__c FROM Weekly_Department_PL__c WHERE Id = :pl.Id];
        System.assert(pl.Has_Alert__c, 'Alert should be set');
        System.assert(pl.Alert_Type__c.contains('YOY_DECLINE'), 'Should have YOY_DECLINE alert');
    }

    @isTest
    static void testMultipleAlerts() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        Department__c dept = [SELECT Id FROM Department__c LIMIT 1];

        Weekly_Department_PL__c pl = new Weekly_Department_PL__c(
            Store__c = store.Id,
            Department__c = dept.Id,
            Date__c = Date.today(),
            Waste_Rate__c = 10.0,
            Loss_Rate__c = 25.0,
            Gross_Profit_Margin__c = 15.0
        );
        insert pl;

        Test.startTest();
        List<Weekly_Department_PL__c> plList = [
            SELECT Id, Department__c, Waste_Rate__c, Loss_Rate__c, Discount_Rate__c,
                   Gross_Profit_Margin__c, YoY_Ratio__c, Inventory_Days__c,
                   Has_Alert__c, Alert_Type__c
            FROM Weekly_Department_PL__c
        ];
        AlertService.checkAlerts(plList);
        update plList;
        Test.stopTest();

        pl = [SELECT Has_Alert__c, Alert_Type__c FROM Weekly_Department_PL__c WHERE Id = :pl.Id];
        System.assert(pl.Has_Alert__c, 'Alert should be set');
        System.assert(pl.Alert_Type__c.contains('HIGH_WASTE'), 'Should have HIGH_WASTE');
        System.assert(pl.Alert_Type__c.contains('HIGH_LOSS'), 'Should have HIGH_LOSS');
        System.assert(pl.Alert_Type__c.contains('LOW_MARGIN'), 'Should have LOW_MARGIN');
    }

    @isTest
    static void testNoAlerts() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        Department__c dept = [SELECT Id FROM Department__c LIMIT 1];

        Weekly_Department_PL__c pl = new Weekly_Department_PL__c(
            Store__c = store.Id,
            Department__c = dept.Id,
            Date__c = Date.today(),
            Waste_Rate__c = 3.0,
            Loss_Rate__c = 15.0,
            Gross_Profit_Margin__c = 25.0
        );
        insert pl;

        Test.startTest();
        List<Weekly_Department_PL__c> plList = [
            SELECT Id, Department__c, Waste_Rate__c, Loss_Rate__c, Discount_Rate__c,
                   Gross_Profit_Margin__c, YoY_Ratio__c, Inventory_Days__c,
                   Has_Alert__c, Alert_Type__c
            FROM Weekly_Department_PL__c
        ];
        AlertService.checkAlerts(plList);
        update plList;
        Test.stopTest();

        pl = [SELECT Has_Alert__c, Alert_Type__c FROM Weekly_Department_PL__c WHERE Id = :pl.Id];
        System.assertEquals(false, pl.Has_Alert__c, 'Alert should not be set');
        System.assertEquals(null, pl.Alert_Type__c, 'Alert type should be null');
    }

    @isTest
    static void testProductSalesAlert() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        Department__c dept = [SELECT Id FROM Department__c LIMIT 1];
        Product__c product = [SELECT Id FROM Product__c LIMIT 1];

        Weekly_Product_Sales__c sales = new Weekly_Product_Sales__c(
            Store__c = store.Id,
            Product__c = product.Id,
            Department__c = dept.Id,
            Date__c = Date.today(),
            Loss_Rate__c = 25.0,
            YoY_Ratio__c = -15.0
        );
        insert sales;

        Test.startTest();
        List<Weekly_Product_Sales__c> salesList = [
            SELECT Id, Department__c, Loss_Rate__c, YoY_Ratio__c, Has_Alert__c, Alert_Type__c
            FROM Weekly_Product_Sales__c
        ];
        AlertService.checkAlerts(salesList);
        update salesList;
        Test.stopTest();

        sales = [SELECT Has_Alert__c, Alert_Type__c FROM Weekly_Product_Sales__c WHERE Id = :sales.Id];
        System.assert(sales.Has_Alert__c, 'Alert should be set');
        System.assert(sales.Alert_Type__c.contains('HIGH_LOSS'), 'Should have HIGH_LOSS');
        System.assert(sales.Alert_Type__c.contains('YOY_DECLINE'), 'Should have YOY_DECLINE');
    }

    @isTest
    static void testBulkProcessing() {
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        Department__c dept = [SELECT Id FROM Department__c LIMIT 1];

        List<Weekly_Department_PL__c> plList = new List<Weekly_Department_PL__c>();
        for (Integer i = 0; i < 200; i++) {
            plList.add(new Weekly_Department_PL__c(
                Store__c = store.Id,
                Department__c = dept.Id,
                Date__c = Date.today().addDays(-i),
                Waste_Rate__c = Math.mod(i, 2) == 0 ? 10.0 : 3.0
            ));
        }
        insert plList;

        Test.startTest();
        List<Weekly_Department_PL__c> plListWithFields = [
            SELECT Id, Department__c, Waste_Rate__c, Loss_Rate__c, Discount_Rate__c,
                   Gross_Profit_Margin__c, YoY_Ratio__c, Inventory_Days__c,
                   Has_Alert__c, Alert_Type__c
            FROM Weekly_Department_PL__c
        ];
        AlertService.checkAlerts(plListWithFields);
        update plListWithFields;
        Test.stopTest();

        Integer alertCount = [SELECT COUNT() FROM Weekly_Department_PL__c WHERE Has_Alert__c = true];
        System.assertEquals(100, alertCount, 'Should have 100 records with alerts');
    }
}
