/**
 * ExcelImportControllerTest - ExcelImportControllerのテストクラス
 */
@isTest
private class ExcelImportControllerTest {

    @testSetup
    static void setupTestData() {
        // テスト用店舗作成
        Store__c store = new Store__c(
            Name = 'Test Store',
            Store_Code__c = 'S001'
        );
        insert store;

        // テスト用部門作成
        Department__c dept = new Department__c(
            Name = 'Test Department',
            Department_Code__c = 'D001'
        );
        insert dept;

        // テスト用商品作成
        Product__c product = new Product__c(
            Name = 'Test Product',
            Product_Code__c = 'P001',
            Department__c = dept.Id
        );
        insert product;
    }

    @isTest
    static void testImportDepartmentPL() {
        // CSVデータ作成（部門別PL）
        String csvContent = '店舗コード,部門コード,日付,売上高,荒利率,廃棄率,ロス率,在庫日数\n';
        csvContent += 'S001,D001,2026-03-10,1000000,25.5,3.2,18.5,5.5\n';
        csvContent += 'S001,D001,2026-03-11,1100000,26.0,2.8,17.0,5.0\n';

        Blob csvBlob = Blob.valueOf(csvContent);
        String base64Data = 'data:text/csv;base64,' + EncodingUtil.base64Encode(csvBlob);

        Test.startTest();
        ExcelImportController.ImportResult result = ExcelImportController.parseAndImport(
            base64Data,
            'test_pl.csv',
            'PL'
        );
        Test.stopTest();

        System.assert(result.success, 'Import should succeed');
        System.assertEquals(2, result.recordCount, 'Should have 2 records');
        System.assertEquals(2, result.successCount, 'Should have 2 successful inserts');

        List<Weekly_Department_PL__c> plRecords = [SELECT Id, Sales_Amount__c FROM Weekly_Department_PL__c];
        System.assertEquals(2, plRecords.size(), 'Should have 2 PL records');
    }

    @isTest
    static void testImportProductSales() {
        // CSVデータ作成（単品売上）
        String csvContent = '店舗コード,商品コード,日付,数量,金額,廃棄数,廃棄額,ロス率,前年比\n';
        csvContent += 'S001,P001,2026-03-10,100,50000,5,2500,5.0,105.5\n';
        csvContent += 'S001,P001,2026-03-11,110,55000,3,1500,2.7,110.0\n';

        Blob csvBlob = Blob.valueOf(csvContent);
        String base64Data = 'data:text/csv;base64,' + EncodingUtil.base64Encode(csvBlob);

        Test.startTest();
        ExcelImportController.ImportResult result = ExcelImportController.parseAndImport(
            base64Data,
            'test_sales.csv',
            'Sales'
        );
        Test.stopTest();

        System.assert(result.success, 'Import should succeed');
        System.assertEquals(2, result.recordCount, 'Should have 2 records');

        List<Weekly_Product_Sales__c> salesRecords = [SELECT Id, Quantity__c FROM Weekly_Product_Sales__c];
        System.assertEquals(2, salesRecords.size(), 'Should have 2 sales records');
    }

    @isTest
    static void testImportEmptyFile() {
        String csvContent = '';
        Blob csvBlob = Blob.valueOf(csvContent);
        String base64Data = 'data:text/csv;base64,' + EncodingUtil.base64Encode(csvBlob);

        Test.startTest();
        ExcelImportController.ImportResult result = ExcelImportController.parseAndImport(
            base64Data,
            'empty.csv',
            'PL'
        );
        Test.stopTest();

        System.assertEquals(false, result.success, 'Import should fail');
        System.assert(result.errorMessage.contains('空'), 'Should have error message');
    }

    @isTest
    static void testImportInvalidObjectType() {
        String csvContent = 'header\ndata';
        Blob csvBlob = Blob.valueOf(csvContent);
        String base64Data = 'data:text/csv;base64,' + EncodingUtil.base64Encode(csvBlob);

        Test.startTest();
        ExcelImportController.ImportResult result = ExcelImportController.parseAndImport(
            base64Data,
            'test.csv',
            'INVALID'
        );
        Test.stopTest();

        System.assertEquals(false, result.success, 'Import should fail');
        System.assert(result.errorMessage.contains('無効'), 'Should have error message');
    }

    @isTest
    static void testImportWithQuotedFields() {
        // 引用符を含むCSV
        String csvContent = '店舗コード,部門コード,日付,売上高\n';
        csvContent += '"S001","D001","2026-03-10","1,000,000"\n';

        Blob csvBlob = Blob.valueOf(csvContent);
        String base64Data = 'data:text/csv;base64,' + EncodingUtil.base64Encode(csvBlob);

        Test.startTest();
        ExcelImportController.ImportResult result = ExcelImportController.parseAndImport(
            base64Data,
            'test_quoted.csv',
            'PL'
        );
        Test.stopTest();

        System.assert(result.success, 'Import should succeed');
    }

    @isTest
    static void testBulkImport() {
        // 大量データのインポート
        String csvContent = '店舗コード,部門コード,日付,売上高\n';
        for (Integer i = 1; i <= 200; i++) {
            csvContent += 'S001,D001,2026-03-10,' + (1000000 + i) + '\n';
        }

        Blob csvBlob = Blob.valueOf(csvContent);
        String base64Data = 'data:text/csv;base64,' + EncodingUtil.base64Encode(csvBlob);

        Test.startTest();
        ExcelImportController.ImportResult result = ExcelImportController.parseAndImport(
            base64Data,
            'bulk_test.csv',
            'PL'
        );
        Test.stopTest();

        System.assert(result.recordCount == 200, 'Should have 200 records');
        System.assert(result.successCount > 0, 'Should have successful inserts');
    }

    @isTest
    static void testImportWithMissingMasterData() {
        // 存在しない店舗コード
        String csvContent = '店舗コード,部門コード,日付,売上高\n';
        csvContent += 'INVALID,D001,2026-03-10,1000000\n';

        Blob csvBlob = Blob.valueOf(csvContent);
        String base64Data = 'data:text/csv;base64,' + EncodingUtil.base64Encode(csvBlob);

        Test.startTest();
        ExcelImportController.ImportResult result = ExcelImportController.parseAndImport(
            base64Data,
            'test_invalid.csv',
            'PL'
        );
        Test.stopTest();

        // 店舗が見つからないため失敗するはず
        System.assertEquals(1, result.errorCount, 'Should have 1 error');
    }
}
