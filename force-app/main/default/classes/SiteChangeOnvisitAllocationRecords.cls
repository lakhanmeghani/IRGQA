global class SiteChangeOnvisitAllocationRecords implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id vtAllocrecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType Where DeveloperName='Visit_Allocation' limit 1].Id;
        String query = 'SELECT Participant__c,Id, Name, Clinical_Site__c, Participant__r.Site_Clinical_Trial__c,sirenum__Site__c FROM sirenum__Shift__c where RecordTypeId = :vtAllocrecordTypeId'   ;
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<sirenum__Shift__c> visitList) {
        List<sirenum__Shift__c> updateVisitList = new List<sirenum__Shift__c>();
        Savepoint sp = Database.setSavepoint();
        for(sirenum__Shift__c vt : visitList) {        
             if(vt.Clinical_Site__c != Null){
                    vt.sirenum__Site__c = vt.Clinical_Site__c;
                    }
             else if(vt.Participant__c != Null){
                 vt.sirenum__Site__c = vt.Participant__r.Site_Clinical_Trial__c;
                    }
                    updateVisitList.add(vt);
        }
        try {
           if(updateVisitList.size() >0)         
                update updateVisitList;
         
        } catch(Exception e) {
                Database.rollback( sp );
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}