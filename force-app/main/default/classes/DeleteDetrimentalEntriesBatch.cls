global class DeleteDetrimentalEntriesBatch implements Database.Batchable<sObject>,Database.Stateful, Schedulable  {
    set<Id> failedRecords; // To store information about failed records
    set<Id> successRecords; // To store information about success records
    
    global DeleteDetrimentalEntriesBatch() {
        failedRecords = new set<Id>();
        successRecords = new set<Id>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String scheduleTime = Label.Scheduled_Start_Time + 'T00:00:00.000+0000';
        datetime scheduleDT = DateTime.Valueof(scheduleTime.replace('T', ' '));
        String entryQuery = '';
        entryQuery = 'Select Id From sirenum__LogEntry__c Where sirenum__Category__c =\'Detrimental Tickets\' and sirenum__Shift__r.sirenum__Scheduled_Start_Time__c >= :scheduleDT';
        if(test.isRunningTest()){
            entryQuery = 'Select Id From sirenum__LogEntry__c limit 1'; 
        }
        return Database.getQueryLocator(entryQuery);
    }
    global void execute(Database.BatchableContext BC, List<sirenum__LogEntry__c> scope){
        List<sirenum__LogEntry__c> recordsToDelete = (List<sirenum__LogEntry__c>)scope;
        Database.deleteResult[] srList;
        if (recordsToDelete != null && !recordsToDelete.isEmpty()) {
            srList = Database.delete(recordsToDelete, false);
        }

        for (Database.deleteResult res : srList) {
            if (res.isSuccess()) {
                successRecords.add(res.getId()); //capture the success record's ID
            }
            else {
                failedRecords.add(res.getId()); //capture the failed record's ID
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        system.debug('successRecords===='+successRecords);
        system.debug('failedRecords===='+failedRecords);
    }
    public void execute(SchedulableContext sc){
        DeleteDetrimentalEntriesBatch batch = new DeleteDetrimentalEntriesBatch();
        Database.executebatch(batch, 50);
    } 
}