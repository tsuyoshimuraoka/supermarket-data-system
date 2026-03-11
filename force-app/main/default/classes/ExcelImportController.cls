/**
 * ExcelImportController - CSVインポート処理コントローラー
 * 週間PL及び単品売上データのCSVインポート機能を提供
 */
public with sharing class ExcelImportController {

    /**
     * CSVデータをパースしてインポート
     * @param base64Data Base64エンコードされたCSVデータ
     * @param fileName ファイル名
     * @param objectType インポート対象オブジェクト ('PL' または 'Sales')
     * @return インポート結果
     */
    @AuraEnabled
    public static ImportResult parseAndImport(String base64Data, String fileName, String objectType) {
        ImportResult result = new ImportResult();
        result.fileName = fileName;

        try {
            // Base64デコード
            String csvData = base64Data.substringAfter(',');
            Blob csvBlob = EncodingUtil.base64Decode(csvData);
            String csvString = csvBlob.toString();

            // CSV行を分割
            List<String> rows = csvString.split('\n');
            
            // 空ファイルまたはヘッダーのみチェック
            if (rows.isEmpty() || String.isBlank(csvString.trim())) {
                result.success = false;
                result.errorMessage = 'CSVファイルが空です';
                return result;
            }

            // ヘッダー行を処理
            String headerRow = rows[0];
            List<String> headers = parseCSVLine(headerRow);

            // データ行を処理
            List<Map<String, String>> parsedData = new List<Map<String, String>>();
            for (Integer i = 1; i < rows.size(); i++) {
                if (String.isNotBlank(rows[i])) {
                    List<String> values = parseCSVLine(rows[i]);
                    Map<String, String> rowData = new Map<String, String>();
                    for (Integer j = 0; j < headers.size() && j < values.size(); j++) {
                        rowData.put(headers[j].trim(), values[j].trim());
                    }
                    parsedData.add(rowData);
                }
            }

            result.recordCount = parsedData.size();

            // オブジェクトタイプに応じてインポート
            if (objectType == 'PL') {
                result = importDepartmentPL(parsedData, result);
            } else if (objectType == 'Sales') {
                result = importProductSales(parsedData, result);
            } else {
                result.success = false;
                result.errorMessage = '無効なオブジェクトタイプです';
            }

        } catch (Exception e) {
            result.success = false;
            result.errorMessage = 'インポートエラー: ' + e.getMessage();
        }

        return result;
    }

    /**
     * 部門別PLデータをインポート
     */
    private static ImportResult importDepartmentPL(List<Map<String, String>> data, ImportResult result) {
        try {
            List<Weekly_Department_PL__c> records = new List<Weekly_Department_PL__c>();

            // 店舗・部門マップを事前取得
            Map<String, Id> storeMap = getStoreMap();
            Map<String, Id> deptMap = getDepartmentMap();

            for (Map<String, String> row : data) {
                Weekly_Department_PL__c pl = new Weekly_Department_PL__c();

                // 必須項目マッピング
                String storeCode = row.get('店舗コード');
                String deptCode = row.get('部門コード');

                if (storeMap.containsKey(storeCode)) {
                    pl.Store__c = storeMap.get(storeCode);
                }
                if (deptMap.containsKey(deptCode)) {
                    pl.Department__c = deptMap.get(deptCode);
                }

                // 日付
                if (row.containsKey('日付')) {
                    pl.Date__c = Date.valueOf(row.get('日付'));
                }

                // 売上データ
                pl.Sales_Amount__c = parseDecimal(row.get('売上高'));
                pl.Sales_Ratio__c = parseDecimal(row.get('構成比'));
                pl.YoY_Ratio__c = parseDecimal(row.get('前年比'));

                // 利益データ
                pl.Gross_Profit__c = parseDecimal(row.get('荒利高'));
                pl.Gross_Profit_Margin__c = parseDecimal(row.get('荒利率'));

                // ロス・廃棄データ
                pl.Loss_Rate__c = parseDecimal(row.get('ロス率'));
                pl.Discount_Rate__c = parseDecimal(row.get('値引率'));
                pl.Discount_Amount__c = parseDecimal(row.get('値引金額'));
                pl.Waste_Rate__c = parseDecimal(row.get('廃棄率'));
                pl.Waste_Amount__c = parseDecimal(row.get('廃棄金額'));

                // 在庫データ
                pl.Inventory_Days__c = parseDecimal(row.get('在庫日数'));

                records.add(pl);
            }

            // バルクインサート
            if (!records.isEmpty()) {
                Database.SaveResult[] saveResults = Database.insert(records, false);
                result = processSaveResults(saveResults, result);
            }

        } catch (Exception e) {
            result.success = false;
            result.errorMessage = 'PL import error: ' + e.getMessage();
        }

        return result;
    }

    /**
     * 単品売上データをインポート
     */
    private static ImportResult importProductSales(List<Map<String, String>> data, ImportResult result) {
        try {
            List<Weekly_Product_Sales__c> records = new List<Weekly_Product_Sales__c>();

            // マスターマップを事前取得
            Map<String, Id> storeMap = getStoreMap();
            Map<String, Id> productMap = getProductMap();

            for (Map<String, String> row : data) {
                Weekly_Product_Sales__c sales = new Weekly_Product_Sales__c();

                // 必須項目マッピング
                String storeCode = row.get('店舗コード');
                String productCode = row.get('商品コード');

                if (storeMap.containsKey(storeCode)) {
                    sales.Store__c = storeMap.get(storeCode);
                }
                if (productMap.containsKey(productCode)) {
                    sales.Product__c = productMap.get(productCode);
                }

                // 日付
                if (row.containsKey('日付')) {
                    sales.Date__c = Date.valueOf(row.get('日付'));
                }

                // 売上データ
                sales.Quantity__c = parseDecimal(row.get('数量'));
                sales.Sales_Amount__c = parseDecimal(row.get('金額'));
                sales.Customer_Count__c = parseDecimal(row.get('客数'));

                // 廃棄・値引
                sales.Discount_Quantity__c = parseDecimal(row.get('値引数'));
                sales.Discount_Amount__c = parseDecimal(row.get('値引額'));
                sales.Waste_Quantity__c = parseDecimal(row.get('廃棄数'));
                sales.Waste_Amount__c = parseDecimal(row.get('廃棄額'));
                sales.Loss_Rate__c = parseDecimal(row.get('ロス率'));

                // 前年データ
                sales.Prior_Year_Quantity__c = parseDecimal(row.get('前年数量'));
                sales.Prior_Year_Amount__c = parseDecimal(row.get('前年金額'));
                sales.YoY_Ratio__c = parseDecimal(row.get('前年比'));

                records.add(sales);
            }

            // バルクインサート
            if (!records.isEmpty()) {
                Database.SaveResult[] saveResults = Database.insert(records, false);
                result = processSaveResults(saveResults, result);
            }

        } catch (Exception e) {
            result.success = false;
            result.errorMessage = 'Sales import error: ' + e.getMessage();
        }

        return result;
    }

    // ヘルパーメソッド

    private static List<String> parseCSVLine(String line) {
        List<String> fields = new List<String>();
        Boolean inQuotes = false;
        String currentField = '';

        for (Integer i = 0; i < line.length(); i++) {
            String c = line.substring(i, i + 1);

            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                fields.add(currentField);
                currentField = '';
            } else {
                currentField += c;
            }
        }
        fields.add(currentField);

        return fields;
    }

    private static Decimal parseDecimal(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        try {
            return Decimal.valueOf(value.replace(',', ''));
        } catch (Exception e) {
            return null;
        }
    }

    private static Map<String, Id> getStoreMap() {
        Map<String, Id> storeMap = new Map<String, Id>();
        for (Store__c store : [SELECT Id, Store_Code__c FROM Store__c]) {
            storeMap.put(store.Store_Code__c, store.Id);
        }
        return storeMap;
    }

    private static Map<String, Id> getDepartmentMap() {
        Map<String, Id> deptMap = new Map<String, Id>();
        for (Department__c dept : [SELECT Id, Department_Code__c FROM Department__c]) {
            deptMap.put(dept.Department_Code__c, dept.Id);
        }
        return deptMap;
    }

    private static Map<String, Id> getProductMap() {
        Map<String, Id> productMap = new Map<String, Id>();
        for (Product__c product : [SELECT Id, Product_Code__c FROM Product__c]) {
            productMap.put(product.Product_Code__c, product.Id);
        }
        return productMap;
    }

    private static ImportResult processSaveResults(Database.SaveResult[] saveResults, ImportResult result) {
        Integer successCount = 0;
        Integer errorCount = 0;
        List<String> errors = new List<String>();

        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                successCount++;
            } else {
                errorCount++;
                for (Database.Error err : sr.getErrors()) {
                    errors.add(err.getMessage());
                }
            }
        }

        result.successCount = successCount;
        result.errorCount = errorCount;
        result.success = errorCount == 0;
        if (!errors.isEmpty()) {
            result.errorMessage = String.join(errors, '; ');
        }

        return result;
    }

    /**
     * インポート結果Wrapperクラス
     */
    public class ImportResult {
        @AuraEnabled public Boolean success = true;
        @AuraEnabled public String fileName;
        @AuraEnabled public Integer recordCount = 0;
        @AuraEnabled public Integer successCount = 0;
        @AuraEnabled public Integer errorCount = 0;
        @AuraEnabled public String errorMessage;
    }
}
