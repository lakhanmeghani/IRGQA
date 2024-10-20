public class LogEntryTriggerHandler {
    
    //Method to map valid ticket and competency on new log entries
    public static void beforeInsertHandler(List<sirenum__LogEntry__c> logEntryList){
        
        List<sirenum__LogEntry__c> newLogEntryList = new List<sirenum__LogEntry__c>();
        Set<Id> contactIdSet = new Set<Id>();
        
        Set<String> competencySet = new Set<String>();
        Map<String,sirenum__LogEntry__c> logEntryMap = new Map<String,sirenum__LogEntry__c> ();
        Map<Id,sirenum__Ticket__c> ticketIdObjMap = new Map<Id,sirenum__Ticket__c> ();
        
        for(sirenum__LogEntry__c loopLogEntry :logEntryList){
            
            String contactId = loopLogEntry.sirenum__Contact__c;
            String competencyName ;
            if(loopLogEntry.sirenum__Details__c.contains('Missing')){
                competencyName = loopLogEntry.sirenum__Details__c.removeStart('Missing Qualification:').trim(); 
                competencySet.add(competencyName);
            }
            logEntryMap.put(contactId+'#'+competencyName,loopLogEntry);
            contactIdSet.add(loopLogEntry.sirenum__Contact__c);
        }
        Map<String,sirenum__TicketType__c> comptencyMap=new Map<String,sirenum__TicketType__c>();
        for(sirenum__TicketType__c comp:[Select id,Name from sirenum__TicketType__c where Name In:competencySet]){
            comptencyMap.put(comp.Name,comp);
        }
        Map<String,Set<sirenum__Ticket__c>> newlyCreatedTicketMap=new Map<String,Set<sirenum__Ticket__c>>();
        for(sirenum__Ticket__c newTicket: [select id,Name,sirenum__TicketType__r.Name,sirenum__Owner__r.Name,sirenum__Owner__c,sirenum__TicketType__c,sirenum__Valid_until__c,Valid_Checkbox__c ,sirenum__Revoked__c,sirenum__Valid_from__c from sirenum__Ticket__c where sirenum__Owner__c In : contactIdSet]) {
            
            String contactIdCompIdUniqueKey = newTicket.sirenum__Owner__c + '#' + newTicket.sirenum__TicketType__r.Name;
            
            // Check if the ticket already has a Set of unique key
            if(newlyCreatedTicketMap.containsKey(contactIdCompIdUniqueKey)) {
                Set<sirenum__Ticket__c> ticketSet = newlyCreatedTicketMap.get(contactIdCompIdUniqueKey);
                // Check if the ticket is not already in the set for this contact
                if (!ticketSet.contains(newTicket)) {
                    ticketSet.add(newTicket);   
                }
            }else{
                Set<sirenum__Ticket__c> ticketSet = new Set<sirenum__Ticket__c>{newTicket};
                    newlyCreatedTicketMap.put(contactIdCompIdUniqueKey, ticketSet);
            }
        }
        Map<String, sirenum__Ticket__c> singleValidTicketMap= getValidTicket(newlyCreatedTicketMap);
        system.debug('singleValidTicketMap>>>>'+singleValidTicketMap);
        
        for(sirenum__LogEntry__c logEntry :logEntryList){
            String contactId = logEntry.sirenum__Contact__c;
            String competencyName ;
            if(logEntry.sirenum__Details__c.contains('Missing')){
                competencyName = logEntry.sirenum__Details__c.removeStart('Missing Qualification:').trim();    
            }
            
            String uniqueMergedKey=contactId+'#'+competencyName;
            
            if(singleValidTicketMap.containsKey(uniqueMergedKey)) {
                sirenum__Ticket__c ticket=singleValidTicketMap.get(contactId+'#'+competencyName);
                logEntry.Qualification__c =ticket.Id;
                logEntry.Competency__c =ticket.sirenum__TicketType__c;
                
            }
            else{
                if(comptencyMap.get(competencyName)!=null)
                    logEntry.Competency__c =comptencyMap.get(competencyName).Id;
            }
        }
        
    }
    //Method to get valid ticket based on maximum valid until date
    public static Map<String, sirenum__Ticket__c> getValidTicket(Map<String, Set<sirenum__Ticket__c>> newlyCreatedTicketMap) {
        Map<String, sirenum__Ticket__c> resultMap = new Map<String, sirenum__Ticket__c>();
        
        for(String uniqueKey : newlyCreatedTicketMap.keySet()) {
            Set<sirenum__Ticket__c> ticketSet = newlyCreatedTicketMap.get(uniqueKey);
            sirenum__Ticket__c maxUntilDateValidTicket = null;
            
            for(sirenum__Ticket__c ticket : ticketSet) {
                if (ticket.Valid_Checkbox__c) {
                    if (maxUntilDateValidTicket == null || ticket.sirenum__Valid_until__c > maxUntilDateValidTicket.sirenum__Valid_until__c) {
                        maxUntilDateValidTicket = ticket;
                    }
                }
            }
            
            if (maxUntilDateValidTicket != null) {
                resultMap.put(uniqueKey, maxUntilDateValidTicket);
            } else {
                
                // If there is no valid ticket, add the ticket with the maximum valid until date among invalid tickets
                sirenum__Ticket__c maxUntilDateInvalidTicket = null;
                for (sirenum__Ticket__c ticket : ticketSet) {
                    if (maxUntilDateInvalidTicket == null || ticket.sirenum__Valid_until__c > maxUntilDateInvalidTicket.sirenum__Valid_until__c) {
                        maxUntilDateInvalidTicket = ticket;
                    }
                }
                resultMap.put(uniqueKey, maxUntilDateInvalidTicket);
            }
        }
        return resultMap;
    }
}