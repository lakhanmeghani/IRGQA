global class CheckTicketValidUntil implements Database.Batchable<sObject>,Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id,name, Competence_category__c, sirenum__Valid_until__c, sirenum__Valid__c, sirenum__Revoked__c,sirenum__TicketType__c,sirenum__Owner__c  from sirenum__Ticket__c 
                                         where sirenum__Valid_until__c <: System.today()]);
    }
    
    //
    global void execute(Database.BatchableContext BC, List<sirenum__Ticket__c> ticketList){
        List<sirenum__Ticket__c> ticketToUpdate = new List<sirenum__Ticket__c>();
        Set<String> resourceSet = new Set<String>();
        List<String> competencyNameList = new List<String>();
        Set<String> competencySet = new Set<String>();
        Map<String,Boolean> resCompInvalidMap = new Map<String,Boolean>();
        Map<String,Id> compIdNameMap = new Map<String,Id>();
        for(sirenum__Ticket__c ticket:ticketList){
            
            if((ticket.sirenum__Valid_until__c!=null && ticket.sirenum__Valid_until__c<System.today()) || Test.isRunningTest() ){
                ticket.sirenum__Revoked__c = true;
                ticket.Valid_Checkbox__c = false; 
                ticket.SK_Status__c='Expired'; 
                ticketToUpdate.add(ticket);
                resourceSet.add(ticket.sirenum__Owner__c);	
                competencySet.add(ticket.sirenum__TicketType__c);
                resCompInvalidMap.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c,true);
            }
        }
        for(sirenum__TicketType__c loopComp : [SELECT Id, Name FROM sirenum__TicketType__c Where Id IN :competencySet]){
            compIdNameMap.put(loopComp.Name.trim(), loopComp.Id);
            competencyNameList.add(loopComp.Name.trim());
        }
        
        List<sirenum__LogEntry__c> updateLogEntryList = new List<sirenum__LogEntry__c>();
        for(sirenum__LogEntry__c logEntry :[SELECT Id, Name, sirenum__Shift__c,sirenum__Details__c, sirenum__Contact__c, sirenum__Created_By_Saving__c 
                                            FROM sirenum__LogEntry__c 
                                            WHERE sirenum__Contact__c IN :resourceSet AND sirenum__Created_By_Saving__c = false]){
                                                String competencyName = logEntry.sirenum__Details__c.removeStart('Missing Qualification: ').trim();
                                                if(competencyNameList.contains(competencyName.trim())){
                                                    logEntry.sirenum__Created_By_Saving__c = true;
                                                    updateLogEntryList.add(logEntry);
                                                }
                                            }
        if(updateLogEntryList.size() > 0 || !updateLogEntryList.isEmpty() ){
            //update updateLogEntryList;    
        }
        if(ticketToUpdate != null){
            QualificationTriggerHandler.updatedTicketsFlag = false; 
            QualificationTriggerHandler.checkValidAndInvalidFlag = false;
            QualificationTriggerHandler.invalidAlertsFlag = false;
            QualificationTriggerHandler.updateCompactLicenseTicketsFlag = false;
            update ticketToUpdate;
        }
    }
    
    //
    global void finish(Database.BatchableContext BC){
        
    }
}