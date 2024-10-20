global class LogEntriesBatchForLocation implements Database.Batchable<sObject>,Database.Stateful {
  /*  set<Id> failedRecords; // To store information about failed records
    set<Id> successRecords; // To store information about success records
    set<Id> vstsForEachTransaction; 
    
    global LogEntriesBatchForLocation() {
        failedRecords = new set<Id>();
        successRecords = new set<Id>();
        vstsForEachTransaction = new set<id>();
    }*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query='';
        
      /*  String scheduleTime = Label.Scheduled_Start_Time + 'T00:00:00.000+0000';
        datetime scheduleDT = DateTime.Valueof(scheduleTime.replace('T', ' '));
        
        if(Label.Log_Entry_Visit_Name.startsWithIgnoreCase('SHFT') ){
            List<String> nameList = Label.Log_Entry_Visit_Name.split(',');
            query = 'SELECT Id, sirenum__Location__c,sirenum__Location__r.name, sirenum__Contact__c FROM sirenum__Shift__c WHERE sirenum__Contact__c != null and sirenum__Location__c != null and Name IN :nameList and sirenum__Scheduled_Start_Time__c  >= :scheduleDT';
        }
        else {
            query = 'SELECT Id, sirenum__Location__c,sirenum__Location__r.name, sirenum__Contact__c FROM sirenum__Shift__c WHERE sirenum__Contact__c != null and sirenum__Location__c != null and sirenum__Scheduled_Start_Time__c  >= :scheduleDT'; //Hardcoded Id here for testing purpose
        }*/
        if(test.isRunningTest()){
            query='SELECT Id, sirenum__Location__c,sirenum__Location__r.name, sirenum__Contact__c FROM sirenum__Shift__c where sirenum__Contact__c!=null';
        }
       // system.debug('QUERY===='+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sirenum__Shift__c> scope) {
      /*  List<sirenum__LogEntry__c> finalLogEntriesToInsert = new List<sirenum__LogEntry__c>();
      //  system.debug('scope==='+scope);
        Set<Id> vstLocations = new Set<Id>();
        for (sirenum__Shift__c vstLoc : scope) {
            vstLocations.add(vstLoc.sirenum__Location__c);
            vstsForEachTransaction.add(vstLoc.Id);
        }
        
        list<sirenum__Sirenum_Condition_Membership__c> cmptncyCondition = new list<sirenum__Sirenum_Condition_Membership__c>();
        cmptncyCondition = [select id,sirenum__TicketType__r.name,sirenum__Severity__c, sirenum__Location__c  from sirenum__Sirenum_Condition_Membership__c where 	sirenum__Location__c IN:vstLocations and sirenum__Kind__c = 'Required'];
        
  
        Map<string,List<sirenum__LogEntry__c>> compIdLogentryListMap = new Map<string,List<sirenum__LogEntry__c>>();
        Map<string,sirenum__Ticket__c> compIdVsTicketMap = new Map<string,sirenum__Ticket__c>();
        Set<Id> resourceIdSet = new Set<Id>();
        for(sirenum__Shift__c vstLoc : scope){
            for(sirenum__Sirenum_Condition_Membership__c cmpConds : cmptncyCondition){
                if(vstLoc.sirenum__Location__c == cmpConds.sirenum__Location__c){
                    sirenum__LogEntry__c entry = new sirenum__LogEntry__c();
                    entry.sirenum__Contact__c = vstLoc.sirenum__Contact__c;
                    entry.sirenum__Category__c = 'Missing Tickets';
                    entry.sirenum__Details__c = 'Missing Qualification: ' + cmpConds.sirenum__TicketType__r.name;
                    entry.sirenum__Severity__c = cmpConds.sirenum__Severity__c;
                    entry.sirenum__Location__c = vstLoc.sirenum__Location__c;
                    entry.sirenum__Shift__c = vstLoc.Id;
                    entry.Competency__c = cmpConds.sirenum__TicketType__c; 
                    entry.Batch_record__c  = true;
                    entry.Batch_Class_Name__c = 'LogEntriesBatchForLocation';
                    resourceIdSet.add(vstLoc.sirenum__Contact__c);
                    if(compIdLogentryListMap.containsKey(cmpConds.sirenum__TicketType__c + '#' + vstLoc.sirenum__Contact__c)){
                        compIdLogentryListMap.get(cmpConds.sirenum__TicketType__c + '#' + vstLoc.sirenum__Contact__c).add(entry);
                    }
                    else{
                        compIdLogentryListMap.put(cmpConds.sirenum__TicketType__c + '#' + vstLoc.sirenum__Contact__c,new List<sirenum__LogEntry__c>{entry});    
                    }
                    
                }
            }
        }
      //  system.debug('compIdLogentryListMap===='+compIdLogentryListMap);
        for(sirenum__Ticket__c loopTicket :[SELECT Id, Name,sirenum__Revoked__c,sirenum__Owner__c,sirenum__TicketType__c
                                            FROM sirenum__Ticket__c 
                                            WHERE sirenum__Owner__c IN :resourceIdSet order by sirenum__Valid_until__c Asc]){
                                                If(compIdLogentryListMap.containsKey(loopTicket.sirenum__TicketType__c + '#' + loopTicket.sirenum__Owner__c)){
                                                    compIdVsTicketMap.put(loopTicket.sirenum__TicketType__c + '#' + loopTicket.sirenum__Owner__c,loopTicket); 
                                                 //   System.debug('loopTicket '+loopTicket.name+' comp Id '+loopTicket.sirenum__TicketType__c);
                                                }
                                                
                                            }
      //  System.debug('compIdVsTicketMap '+compIdVsTicketMap);
        
        //for(sirenum__Ticket__c loopTicket :compIdVsTicketMap.values()){
            //system.debug('loopTicket====='+loopTicket);
            //If(compIdLogentryListMap.containsKey(loopTicket.sirenum__TicketType__c + '#' + loopTicket.sirenum__Owner__c)){
                //system.debug('loopTicket====='+loopTicket);
        	for(List<sirenum__LogEntry__c> logEntryList : compIdLogentryListMap.values()){
              //  System.debug('logEntryList '+logEntryList);
                for(sirenum__LogEntry__c logEntry : logEntryList){
                   // System.debug('all logEntry comp ->'+logEntry.Competency__c);
                    if(compIdVsTicketMap.containsKey(logEntry.Competency__c + '#' + logEntry.sirenum__Contact__c)){
                      //  System.debug('Inside if logEntry '+logEntry.Competency__c);
                      //  System.debug(' Ticket '+compIdVsTicketMap.get(logEntry.Competency__c + '#' + logEntry.sirenum__Contact__c));
                        //for(sirenum__Ticket__c loopTicket :compIdVsTicketMap.values()){
                            sirenum__Ticket__c loopTicket = compIdVsTicketMap.get(logEntry.Competency__c + '#' + logEntry.sirenum__Contact__c);
                        if(loopTicket != null){	
                            logEntry.Qualification__c = loopTicket.Id;
                         //   system.debug('loopTicket.Id==='+loopTicket.Id);
                            if(loopTicket.sirenum__Revoked__c == false){
                                logEntry.sirenum__Created_By_Saving__c = false;
                            }   
                        }
                    }
                    
                    finalLogEntriesToInsert.add(logEntry);  
                }
        	}
            //}
            
        //}
        
     //   system.debug('finalLogEntriesToInsert==='+finalLogEntriesToInsert);
     //   system.debug('finalLogEntriesToInsert Size==='+finalLogEntriesToInsert.size());
        if(finalLogEntriesToInsert.size()>0){ 
            try {
                Database.SaveResult[] result = database.insert(finalLogEntriesToInsert);
                for (Database.SaveResult res : result) {
                    if (res.isSuccess()) {
                       
                        successRecords.add(res.getId()); 
                    }
                    else {
                        failedRecords.add(res.getId()); 
                    }
                }
            } catch (exception e) {
                emailSend.exceptionEmailSend(failedRecords, e.getMessage(), e.getStackTraceString(),vstsForEachTransaction,successRecords);
            }
        }*/
    }
    
    global void finish(Database.BatchableContext BC) {
       
      /*  if(successRecords.size()>0){
            emailSend.successEmailSend(successRecords);
        }*/
    }
    /*  public void execute(SchedulableContext sc){
CreateLogEntriesDataForLegacyData batch = new CreateLogEntriesDataForLegacyData();
Database.executebatch(batch, 3);
} */
}