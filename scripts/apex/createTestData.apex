/**
 * Test Data Creation Script
 * Run this via Anonymous Apex to create test data for the system
 */

// 店舗作成 (5 stores)
List<Store__c> stores = new List<Store__c>();
for (Integer i = 1; i <= 5; i++) {
    stores.add(new Store__c(
        Name = 'テスト店舗 ' + i,
        Store_Code__c = 'S00' + i,
        Store_Type__c = 'ディオ',
        Region__c = '関東',
        Opening_Date__c = Date.today().addYears(-2),
        Status__c = 'Active'
    ));
}
insert stores;
System.debug('Stores created: ' + stores.size());

// 部門作成 (10 departments with thresholds)
List<Department__c> departments = new List<Department__c>();
String[] deptNames = new String[]{'青果', '精肉', '鮮魚', 'デイリー', '冷凍', '加工食品', '日配', '菓子', '飲料', '雑貨'};
for (Integer i = 1; i <= 10; i++) {
    departments.add(new Department__c(
        Name = deptNames[i-1],
        Department_Code__c = 'D00' + i,
        Category_Level__c = 1,
        Active__c = true,
        Waste_Rate_Threshold__c = 5.0,
        Loss_Rate_Threshold__c = 20.0,
        Discount_Rate_Threshold__c = 5.0,
        Profit_Margin_Min__c = 20.0,
        YoY_Decline_Threshold__c = -10.0,
        Inventory_Days_Max__c = 7
    ));
}
insert departments;
System.debug('Departments created: ' + departments.size());

// 商品作成 (50 products)
List<Product__c> products = new List<Product__c>();
for (Integer i = 1; i <= 50; i++) {
    products.add(new Product__c(
        Name = 'テスト商品 ' + i,
        Product_Code__c = 'P' + String.valueOf(10000 + i),
        Department__c = departments[Math.mod(i, 10)].Id,
        Category_Code__c = 'CAT' + String.valueOf(Math.mod(i, 10) + 1),
        Category_Name__c = '分類' + String.valueOf(Math.mod(i, 10) + 1),
        Unit_Price__c = 100 + (i * 10),
        Active__c = true
    ));
}
insert products;
System.debug('Products created: ' + products.size());

// 週間部門別PL作成 (100 records - 過去10日 × 5店舗 × 2部門)
List<Weekly_Department_PL__c> plRecords = new List<Weekly_Department_PL__c>();
for (Store__c store : stores) {
    for (Integer d = 0; d < 10; d++) {
        for (Integer dept = 0; dept < 2; dept++) {
            Boolean hasAlert = Math.mod(d, 3) == 0;  // Every 3rd day has alert
            plRecords.add(new Weekly_Department_PL__c(
                Store__c = store.Id,
                Department__c = departments[dept].Id,
                Date__c = Date.today().addDays(-d),
                Week__c = 'W' + String.valueOf(Date.today().addDays(-d).toStartOfWeek()),
                Sales_Amount__c = 1000000 + (d * 50000),
                Sales_Ratio__c = 15.0 + d,
                YoY_Ratio__c = hasAlert ? -15.0 : 5.0,
                Gross_Profit__c = 250000 + (d * 10000),
                Gross_Profit_Margin__c = hasAlert ? 15.0 : 25.0,
                Margin_Budget__c = 24.0,
                Loss_Rate__c = hasAlert ? 25.0 : 15.0,
                Discount_Rate__c = 3.0 + d * 0.5,
                Discount_Amount__c = 30000 + (d * 5000),
                Waste_Rate__c = hasAlert ? 8.0 : 3.0,
                Waste_Amount__c = 50000 + (d * 5000),
                Inventory_Days__c = 5.0 + d * 0.5
            ));
        }
    }
}
insert plRecords;
System.debug('PL Records created: ' + plRecords.size());

// AlertServiceで アラートチェック実行
AlertService.checkAlerts(plRecords);
update plRecords;
System.debug('Alerts checked and updated');

// 週間単品売上作成 (500 records - 過去10日 × 5店舗 × 10商品)
List<Weekly_Product_Sales__c> salesRecords = new List<Weekly_Product_Sales__c>();
for (Store__c store : stores) {
    for (Integer d = 0; d < 10; d++) {
        for (Integer p = 0; p < 10; p++) {
            Boolean hasAlert = Math.mod(p, 5) == 0;
            salesRecords.add(new Weekly_Product_Sales__c(
                Store__c = store.Id,
                Product__c = products[p].Id,
                Department__c = departments[Math.mod(p, 10)].Id,
                Date__c = Date.today().addDays(-d),
                Period__c = String.valueOf(Date.today().addDays(-d)),
                Quantity__c = 100 + (d * 10),
                Sales_Amount__c = 50000 + (d * 5000),
                Customer_Count__c = 500 + (d * 50),
                Daily_Sales_Qty__c = 10 + d,
                Discount_Quantity__c = 5 + d,
                Discount_Amount__c = 2500 + (d * 250),
                Waste_Quantity__c = 3 + d,
                Waste_Amount__c = 1500 + (d * 150),
                Loss_Rate__c = hasAlert ? 25.0 : 10.0,
                Prior_Year_Quantity__c = 90 + (d * 10),
                Prior_Year_Amount__c = 45000 + (d * 5000),
                YoY_Ratio__c = hasAlert ? -15.0 : 10.0
            ));
        }
    }
}
insert salesRecords;
System.debug('Sales Records created: ' + salesRecords.size());

// AlertServiceでアラートチェック実行
AlertService.checkAlerts(salesRecords);
update salesRecords;
System.debug('Sales alerts checked and updated');

// 店舗レビュー作成 (10 reviews)
List<Store_Review__c> reviews = new List<Store_Review__c>();
for (Integer i = 0; i < 10; i++) {
    reviews.add(new Store_Review__c(
        Store__c = stores[Math.mod(i, 5)].Id,
        Review_Date__c = Date.today().addDays(-i),
        Supervisor__c = UserInfo.getUserId(),
        Review_Status__c = i < 3 ? 'Draft' : 'Submitted',
        Summary__c = 'テストレビュー ' + i + ' のサマリー',
        Key_Issues__c = '主要課題: 廃棄率の改善が必要',
        Recommendations__c = '推奨事項: 発注精度の向上',
        Action_Items__c = 'アクション: 週次ミーティングで進捗確認'
    ));
}
insert reviews;
System.debug('Reviews created: ' + reviews.size());

// レビューコメント作成 (30 comments - 3 per review)
List<Review_Comment__c> comments = new List<Review_Comment__c>();
for (Store_Review__c review : reviews) {
    comments.add(new Review_Comment__c(
        Store_Review__c = review.Id,
        Comment__c = 'SVからのアドバイス: 廃棄率が高いです。発注量を見直してください。',
        Comment_Type__c = 'SV Advice',
        Comment_Date__c = System.now().addDays(-2),
        Commenter__c = UserInfo.getUserId()
    ));
    comments.add(new Review_Comment__c(
        Store_Review__c = review.Id,
        Comment__c = '店長からの回答: 承知しました。明日から発注量を調整します。',
        Comment_Type__c = 'Manager Response',
        Comment_Date__c = System.now().addDays(-1),
        Commenter__c = UserInfo.getUserId()
    ));
    comments.add(new Review_Comment__c(
        Store_Review__c = review.Id,
        Comment__c = '進捗確認: 廃棄率が改善されました。引き続き注視します。',
        Comment_Type__c = 'General',
        Comment_Date__c = System.now(),
        Commenter__c = UserInfo.getUserId()
    ));
}
insert comments;
System.debug('Comments created: ' + comments.size());

System.debug('=== Test Data Creation Complete ===');
System.debug('Stores: ' + stores.size());
System.debug('Departments: ' + departments.size());
System.debug('Products: ' + products.size());
System.debug('PL Records: ' + plRecords.size());
System.debug('Sales Records: ' + salesRecords.size());
System.debug('Reviews: ' + reviews.size());
System.debug('Comments: ' + comments.size());

// アラート数確認
Integer plAlertCount = [SELECT COUNT() FROM Weekly_Department_PL__c WHERE Has_Alert__c = true];
Integer salesAlertCount = [SELECT COUNT() FROM Weekly_Product_Sales__c WHERE Has_Alert__c = true];
System.debug('PL Alerts: ' + plAlertCount);
System.debug('Sales Alerts: ' + salesAlertCount);
