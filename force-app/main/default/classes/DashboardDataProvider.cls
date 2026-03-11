/**
 * DashboardDataProvider - ダッシュボードデータ提供サービス
 * KPI集計データをダッシュボード用に提供
 */
public with sharing class DashboardDataProvider {

    /**
     * KPIデータ取得
     * @param storeId 店舗ID（nullの場合は全店舗）
     * @param startDate 開始日
     * @param endDate 終了日
     * @return KPIデータマップ
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getKPIData(Id storeId, Date startDate, Date endDate) {
        Map<String, Object> kpiData = new Map<String, Object>();

        try {
            // 日付デフォルト設定
            if (startDate == null) {
                startDate = Date.today().addDays(-30);
            }
            if (endDate == null) {
                endDate = Date.today();
            }

            // 売上サマリー
            kpiData.put('salesSummary', getSalesSummary(storeId, startDate, endDate));

            // 利益サマリー
            kpiData.put('profitSummary', getProfitSummary(storeId, startDate, endDate));

            // アラートサマリー
            kpiData.put('alertSummary', getAlertSummary(storeId, startDate, endDate));

            // トップ/ボトム店舗
            kpiData.put('topStores', getTopStores(startDate, endDate, 5));
            kpiData.put('bottomStores', getBottomStores(startDate, endDate, 5));

            // トレンドデータ
            kpiData.put('salesTrend', getSalesTrend(storeId, startDate, endDate));

        } catch (Exception e) {
            throw new AuraHandledException('KPIデータの取得に失敗しました: ' + e.getMessage());
        }

        return kpiData;
    }

    /**
     * 売上サマリー取得
     */
    private static Map<String, Object> getSalesSummary(Id storeId, Date startDate, Date endDate) {
        String query = 'SELECT SUM(Sales_Amount__c) totalSales, AVG(YoY_Ratio__c) avgYoY, COUNT(Id) recordCount ' +
                       'FROM Weekly_Department_PL__c ' +
                       'WHERE Date__c >= :startDate AND Date__c <= :endDate';

        if (storeId != null) {
            query += ' AND Store__c = :storeId';
        }

        AggregateResult result = Database.query(query);

        Map<String, Object> summary = new Map<String, Object>();
        summary.put('totalSales', result.get('totalSales'));
        summary.put('avgYoY', result.get('avgYoY'));
        summary.put('recordCount', result.get('recordCount'));

        return summary;
    }

    /**
     * 利益サマリー取得
     */
    private static Map<String, Object> getProfitSummary(Id storeId, Date startDate, Date endDate) {
        String query = 'SELECT AVG(Gross_Profit_Margin__c) avgMargin, ' +
                       'AVG(Waste_Rate__c) avgWaste, AVG(Loss_Rate__c) avgLoss ' +
                       'FROM Weekly_Department_PL__c ' +
                       'WHERE Date__c >= :startDate AND Date__c <= :endDate';

        if (storeId != null) {
            query += ' AND Store__c = :storeId';
        }

        AggregateResult result = Database.query(query);

        Map<String, Object> summary = new Map<String, Object>();
        summary.put('avgMargin', result.get('avgMargin'));
        summary.put('avgWaste', result.get('avgWaste'));
        summary.put('avgLoss', result.get('avgLoss'));

        return summary;
    }

    /**
     * アラートサマリー取得
     */
    private static Map<String, Object> getAlertSummary(Id storeId, Date startDate, Date endDate) {
        String query = 'SELECT COUNT(Id) totalAlerts ' +
                       'FROM Weekly_Department_PL__c ' +
                       'WHERE Has_Alert__c = true AND Date__c >= :startDate AND Date__c <= :endDate';

        if (storeId != null) {
            query += ' AND Store__c = :storeId';
        }

        AggregateResult result = Database.query(query);

        Map<String, Object> summary = new Map<String, Object>();
        summary.put('totalAlerts', result.get('totalAlerts'));

        // アラートタイプ別集計
        String typeQuery = 'SELECT Alert_Type__c, COUNT(Id) count ' +
                           'FROM Weekly_Department_PL__c ' +
                           'WHERE Has_Alert__c = true AND Date__c >= :startDate AND Date__c <= :endDate';

        if (storeId != null) {
            typeQuery += ' AND Store__c = :storeId';
        }
        typeQuery += ' GROUP BY Alert_Type__c';

        List<AggregateResult> typeResults = Database.query(typeQuery);
        Map<String, Integer> alertTypes = new Map<String, Integer>();
        for (AggregateResult ar : typeResults) {
            String alertType = (String)ar.get('Alert_Type__c');
            Integer count = (Integer)ar.get('count');
            if (alertType != null) {
                // 複数アラートタイプを分解
                for (String type : alertType.split(';')) {
                    if (alertTypes.containsKey(type)) {
                        alertTypes.put(type, alertTypes.get(type) + count);
                    } else {
                        alertTypes.put(type, count);
                    }
                }
            }
        }
        summary.put('alertTypes', alertTypes);

        return summary;
    }

    /**
     * トップ店舗取得（売上順）
     */
    private static List<Map<String, Object>> getTopStores(Date startDate, Date endDate, Integer limitCount) {
        List<AggregateResult> results = [
            SELECT Store__r.Name storeName, SUM(Sales_Amount__c) totalSales
            FROM Weekly_Department_PL__c
            WHERE Date__c >= :startDate AND Date__c <= :endDate
            GROUP BY Store__r.Name
            ORDER BY SUM(Sales_Amount__c) DESC
            LIMIT :limitCount
        ];

        return convertAggregateResults(results);
    }

    /**
     * ボトム店舗取得（売上順）
     */
    private static List<Map<String, Object>> getBottomStores(Date startDate, Date endDate, Integer limitCount) {
        List<AggregateResult> results = [
            SELECT Store__r.Name storeName, SUM(Sales_Amount__c) totalSales
            FROM Weekly_Department_PL__c
            WHERE Date__c >= :startDate AND Date__c <= :endDate
            GROUP BY Store__r.Name
            ORDER BY SUM(Sales_Amount__c) ASC
            LIMIT :limitCount
        ];

        return convertAggregateResults(results);
    }

    /**
     * 売上トレンド取得（日別）
     */
    private static List<Map<String, Object>> getSalesTrend(Id storeId, Date startDate, Date endDate) {
        String query = 'SELECT Date__c, SUM(Sales_Amount__c) dailySales ' +
                       'FROM Weekly_Department_PL__c ' +
                       'WHERE Date__c >= :startDate AND Date__c <= :endDate';

        if (storeId != null) {
            query += ' AND Store__c = :storeId';
        }

        query += ' GROUP BY Date__c ORDER BY Date__c ASC';

        List<AggregateResult> results = Database.query(query);
        return convertAggregateResults(results);
    }

    /**
     * 部門別パフォーマンス取得
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getDepartmentPerformance(Id storeId, Date startDate, Date endDate) {
        String query = 'SELECT Department__r.Name deptName, ' +
                       'SUM(Sales_Amount__c) totalSales, AVG(Gross_Profit_Margin__c) avgMargin, ' +
                       'AVG(Waste_Rate__c) avgWaste ' +
                       'FROM Weekly_Department_PL__c ' +
                       'WHERE Date__c >= :startDate AND Date__c <= :endDate';

        if (storeId != null) {
            query += ' AND Store__c = :storeId';
        }

        query += ' GROUP BY Department__r.Name ORDER BY SUM(Sales_Amount__c) DESC';

        List<AggregateResult> results = Database.query(query);
        return convertAggregateResults(results);
    }

    /**
     * アクティブアラート取得
     */
    @AuraEnabled(cacheable=true)
    public static List<AlertWrapper> getActiveAlerts(Id storeId, Integer limitCount) {
        if (limitCount == null) {
            limitCount = 10;
        }

        String query = 'SELECT Id, Store__r.Name, Department__r.Name, Date__c, ' +
                       'Alert_Type__c, Waste_Rate__c, Loss_Rate__c, Gross_Profit_Margin__c ' +
                       'FROM Weekly_Department_PL__c ' +
                       'WHERE Has_Alert__c = true';

        if (storeId != null) {
            query += ' AND Store__c = :storeId';
        }

        query += ' ORDER BY Date__c DESC LIMIT :limitCount';

        List<Weekly_Department_PL__c> alerts = Database.query(query);

        List<AlertWrapper> wrappers = new List<AlertWrapper>();
        for (Weekly_Department_PL__c alert : alerts) {
            wrappers.add(new AlertWrapper(alert));
        }

        return wrappers;
    }

    // ヘルパーメソッド

    private static List<Map<String, Object>> convertAggregateResults(List<AggregateResult> results) {
        List<Map<String, Object>> converted = new List<Map<String, Object>>();
        for (AggregateResult result : results) {
            Map<String, Object> dataPoint = new Map<String, Object>();
            for (String alias : result.getPopulatedFieldsAsMap().keySet()) {
                dataPoint.put(alias, result.get(alias));
            }
            converted.add(dataPoint);
        }
        return converted;
    }

    /**
     * アラートWrapperクラス
     */
    public class AlertWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String storeName;
        @AuraEnabled public String departmentName;
        @AuraEnabled public Date alertDate;
        @AuraEnabled public String alertType;
        @AuraEnabled public Decimal wasteRate;
        @AuraEnabled public Decimal lossRate;
        @AuraEnabled public Decimal profitMargin;

        public AlertWrapper(Weekly_Department_PL__c alert) {
            this.id = alert.Id;
            this.storeName = alert.Store__r.Name;
            this.departmentName = alert.Department__r.Name;
            this.alertDate = alert.Date__c;
            this.alertType = alert.Alert_Type__c;
            this.wasteRate = alert.Waste_Rate__c;
            this.lossRate = alert.Loss_Rate__c;
            this.profitMargin = alert.Gross_Profit_Margin__c;
        }
    }
}
