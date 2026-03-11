// Test Store__c field access
Store__c s = new Store__c(
    Name = 'Test Store',
    Store_Code__c = 'TEST001'
);

System.debug('Creating store with Name and Store_Code__c');
insert s;
System.debug('Store created: ' + s.Id);

// Query it back
Store__c queried = [SELECT Id, Name, Store_Code__c, Store_Type__c, Region__c, Status__c FROM Store__c WHERE Id = :s.Id];
System.debug('Queried store: ' + queried.Name);
System.debug('Store_Type__c: ' + queried.Store_Type__c);
System.debug('Region__c: ' + queried.Region__c);
System.debug('Status__c: ' + queried.Status__c);
