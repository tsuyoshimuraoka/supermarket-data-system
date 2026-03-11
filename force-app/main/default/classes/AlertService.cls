/**
 * AlertService - アラート検出サービス
 * 部門別PL及び単品売上データのアラート条件をチェックし、アラートフラグを設定
 */
public with sharing class AlertService {

    /**
     * 部門別PLレコードのアラートチェック
     * @param plRecords チェック対象の部門別PLレコードリスト
     */
    public static void checkAlerts(List<Weekly_Department_PL__c> plRecords) {
        if (plRecords == null || plRecords.isEmpty()) {
            return;
        }

        // 関連する部門の閾値を取得
        Set<Id> departmentIds = new Set<Id>();
        for (Weekly_Department_PL__c pl : plRecords) {
            if (pl.Department__c != null) {
                departmentIds.add(pl.Department__c);
            }
        }

        Map<Id, Department__c> departmentMap = new Map<Id, Department__c>([
            SELECT Id, Waste_Rate_Threshold__c, Loss_Rate_Threshold__c,
                   Discount_Rate_Threshold__c, Profit_Margin_Min__c,
                   YoY_Decline_Threshold__c, Inventory_Days_Max__c
            FROM Department__c
            WHERE Id IN :departmentIds
        ]);

        // 各レコードをチェック
        for (Weekly_Department_PL__c pl : plRecords) {
            List<String> alerts = new List<String>();

            if (pl.Department__c != null && departmentMap.containsKey(pl.Department__c)) {
                Department__c dept = departmentMap.get(pl.Department__c);

                // 廃棄率チェック (High Waste Rate)
                if (pl.Waste_Rate__c != null && dept.Waste_Rate_Threshold__c != null &&
                    pl.Waste_Rate__c > dept.Waste_Rate_Threshold__c) {
                    alerts.add('HIGH_WASTE');
                }

                // ロス率チェック (High Loss Rate)
                if (pl.Loss_Rate__c != null && dept.Loss_Rate_Threshold__c != null &&
                    pl.Loss_Rate__c > dept.Loss_Rate_Threshold__c) {
                    alerts.add('HIGH_LOSS');
                }

                // 値引率チェック (High Discount Rate)
                if (pl.Discount_Rate__c != null && dept.Discount_Rate_Threshold__c != null &&
                    pl.Discount_Rate__c > dept.Discount_Rate_Threshold__c) {
                    alerts.add('HIGH_DISCOUNT');
                }

                // 荒利率チェック (Low Profit Margin)
                if (pl.Gross_Profit_Margin__c != null && dept.Profit_Margin_Min__c != null &&
                    pl.Gross_Profit_Margin__c < dept.Profit_Margin_Min__c) {
                    alerts.add('LOW_MARGIN');
                }

                // 前年比チェック (YoY Decline)
                if (pl.YoY_Ratio__c != null && dept.YoY_Decline_Threshold__c != null &&
                    pl.YoY_Ratio__c < dept.YoY_Decline_Threshold__c) {
                    alerts.add('YOY_DECLINE');
                }

                // 在庫日数チェック (High Inventory Days)
                if (pl.Inventory_Days__c != null && dept.Inventory_Days_Max__c != null &&
                    pl.Inventory_Days__c > dept.Inventory_Days_Max__c) {
                    alerts.add('HIGH_INVENTORY');
                }
            }

            // アラートフラグを設定
            if (!alerts.isEmpty()) {
                pl.Has_Alert__c = true;
                pl.Alert_Type__c = String.join(alerts, ';');
            } else {
                pl.Has_Alert__c = false;
                pl.Alert_Type__c = null;
            }
        }
    }

    /**
     * 単品売上レコードのアラートチェック
     * @param salesRecords チェック対象の単品売上レコードリスト
     */
    public static void checkAlerts(List<Weekly_Product_Sales__c> salesRecords) {
        if (salesRecords == null || salesRecords.isEmpty()) {
            return;
        }

        // 関連する部門の閾値を取得
        Set<Id> departmentIds = new Set<Id>();
        for (Weekly_Product_Sales__c sales : salesRecords) {
            if (sales.Department__c != null) {
                departmentIds.add(sales.Department__c);
            }
        }

        Map<Id, Department__c> departmentMap = new Map<Id, Department__c>([
            SELECT Id, Waste_Rate_Threshold__c, Loss_Rate_Threshold__c,
                   YoY_Decline_Threshold__c
            FROM Department__c
            WHERE Id IN :departmentIds
        ]);

        // 各レコードをチェック
        for (Weekly_Product_Sales__c sales : salesRecords) {
            List<String> alerts = new List<String>();

            if (sales.Department__c != null && departmentMap.containsKey(sales.Department__c)) {
                Department__c dept = departmentMap.get(sales.Department__c);

                // ロス率チェック (商品レベル)
                if (sales.Loss_Rate__c != null && dept.Loss_Rate_Threshold__c != null &&
                    sales.Loss_Rate__c > dept.Loss_Rate_Threshold__c) {
                    alerts.add('HIGH_LOSS');
                }

                // 前年比チェック (商品レベル)
                if (sales.YoY_Ratio__c != null && dept.YoY_Decline_Threshold__c != null &&
                    sales.YoY_Ratio__c < dept.YoY_Decline_Threshold__c) {
                    alerts.add('YOY_DECLINE');
                }
            }

            // アラートフラグを設定
            if (!alerts.isEmpty()) {
                sales.Has_Alert__c = true;
                sales.Alert_Type__c = String.join(alerts, ';');
            } else {
                sales.Has_Alert__c = false;
                sales.Alert_Type__c = null;
            }
        }
    }
}
