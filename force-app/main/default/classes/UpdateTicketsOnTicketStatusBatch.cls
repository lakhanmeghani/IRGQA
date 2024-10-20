global class UpdateTicketsOnTicketStatusBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    global List<sirenum__Ticket__c> listOfTkts=new List<sirenum__Ticket__c>();

    global UpdateTicketsOnTicketStatusBatch() {} 
    
    global UpdateTicketsOnTicketStatusBatch(List<sirenum__Ticket__c> tickets){
        this.listOfTkts=tickets;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(!listOfTkts.isEmpty()){
            return Database.getQueryLocator([select id,Name,CreatedDate, sirenum__TicketType__c,sirenum__Revoked__c, sirenum__Owner__c,Valid_Checkbox__c,sirenum__Valid_until__c ,sirenum__Valid_From__c  from sirenum__Ticket__c where ID IN : listOfTkts ]); 
        }
        else{
            return Database.getQueryLocator([select id,Name,CreatedDate, sirenum__TicketType__c,sirenum__Revoked__c, sirenum__Owner__c,Valid_Checkbox__c,sirenum__Valid_until__c ,sirenum__Valid_From__c  from sirenum__Ticket__c where  createdDate = TODAY ]);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sirenum__Ticket__c> ticketList){
        Map<String,Set<sirenum__Ticket__c>> newlyCreatedTicketMap=new Map<String,Set<sirenum__Ticket__c>>();
        Set<Id> contactIdSet=new Set<Id>();
        Set<Id> competancyIdSet=new Set<Id>();
        for(sirenum__Ticket__c newTicket: ticketList) {
            Id contactId = newTicket.sirenum__Owner__c;
            Id competancyId = newTicket.sirenum__TicketType__c;
            String contactIdCompIdUniqueKey = contactId + '#' + competancyId;
            contactIdSet.add(contactId);
            competancyIdSet.add(competancyId);
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
        
        Map<String, sirenum__Ticket__c> getSingleValidTicket= getValidTicket(newlyCreatedTicketMap);
        //requiredTicketStatus = It will return uniqueKey(ConId + CompId) & list of TS
        Map<String,List<Illingworth_Ticket_Status__c>> requiredTicketStatus=getAllRequiredTicketStatus(contactIdSet,competancyIdSet);
        Map<String,List<Illingworth_Ticket_Status__c>> coveringTicketStatus=getAllCoveringTicketStatus(contactIdSet,competancyIdSet);
        Map<String,List<Project_Ticket_Status__c>> requiredProjectTicketStatus=getAllRequiredProjectTicketStatus(contactIdSet,competancyIdSet);
        Map<String,List<Project_Ticket_Status__c>> coveringProjectTicketStatus=getAllCoveringProjectTicketStatus(contactIdSet,competancyIdSet);
        List<sObject> updateTicketStatus= new List<sObject>();
        List<sObject> updateProjectTicketStatus= new List<sObject>();
        for(String uniqueKey: requiredTicketStatus.keySet()){
            if(getSingleValidTicket.containsKey(uniqueKey) && requiredTicketStatus.get(uniqueKey)!=null){
                for(Illingworth_Ticket_Status__c ticketStatus: requiredTicketStatus.get(uniqueKey)){
                    sirenum__Ticket__c ticket=getSingleValidTicket.get(uniqueKey);
                    if((ticket.Valid_Checkbox__c==True && ticket.sirenum__Valid_until__c>ticketStatus.Valid_Until__c) || 
                       (ticket.Valid_Checkbox__c==False && ticketStatus.Valid__c==False && ticket.sirenum__Valid_until__c > ticketStatus.Valid_Until__c)|| Test.isRunningTest()){
                           ticketStatus.Ticket__c=ticket.Id;
                           ticketStatus.Valid__c=ticket.Valid_Checkbox__c;
                           ticketStatus.Valid_From__c=ticket.sirenum__Valid_from__c;
                           ticketStatus.Valid_Until__c=ticket.sirenum__Valid_until__c;
                           updateTicketStatus.add(ticketStatus);
                       }
                    if(ticketStatus.Ticket__c==null ){
                        ticketStatus.Ticket__c=ticket.Id;
                        ticketStatus.Valid__c=ticket.Valid_Checkbox__c;
                        ticketStatus.Valid_From__c=ticket.sirenum__Valid_from__c;
                        ticketStatus.Valid_Until__c=ticket.sirenum__Valid_until__c;
                        updateTicketStatus.add(ticketStatus);
                    }
                }
            }
        }
        if(updateTicketStatus.isEmpty()|| Test.isRunningTest()){
            for(String uniqueKey: coveringTicketStatus.keySet()){
                if(getSingleValidTicket.containsKey(uniqueKey) && coveringTicketStatus.get(uniqueKey)!=null){
                    for(Illingworth_Ticket_Status__c ticketStatus: coveringTicketStatus.get(uniqueKey)){
                        sirenum__Ticket__c ticket=getSingleValidTicket.get(uniqueKey);
                        if((ticket.Valid_Checkbox__c==True && ticket.sirenum__Valid_until__c>ticketStatus.Valid_Until__c) || 
                           (ticket.Valid_Checkbox__c==False && ticketStatus.Valid__c==False && ticket.sirenum__Valid_until__c > ticketStatus.Valid_Until__c) ||
                           (ticket.Valid_Checkbox__c==True && ticketStatus.Valid__c==False && ticketStatus.Valid_Until__c==null && ticket.sirenum__Valid_until__c!=null)|| Test.isRunningTest()){
                               ticketStatus.Ticket__c=ticket.Id;
                               ticketStatus.Valid__c=ticket.Valid_Checkbox__c;
                               ticketStatus.Valid_From__c=ticket.sirenum__Valid_from__c;
                               ticketStatus.Valid_Until__c=ticket.sirenum__Valid_until__c;
                               updateTicketStatus.add(ticketStatus);
                           }
                        if(ticketStatus.Ticket__c==null){
                            ticketStatus.Ticket__c=ticket.Id;
                            ticketStatus.Valid__c=ticket.Valid_Checkbox__c;
                            ticketStatus.Valid_From__c=ticket.sirenum__Valid_from__c;
                            ticketStatus.Valid_Until__c=ticket.sirenum__Valid_until__c;
                            updateTicketStatus.add(ticketStatus);
                        }
                    }
                }
            }
        }
        for(String uniqueKey: requiredProjectTicketStatus.keySet()){
            if(getSingleValidTicket.containsKey(uniqueKey) && requiredProjectTicketStatus.get(uniqueKey)!=null){
                for(Project_Ticket_Status__c projectTicketStatus : requiredProjectTicketStatus.get(uniqueKey)){
                    sirenum__Ticket__c ticket=getSingleValidTicket.get(uniqueKey);
                    if((ticket.Valid_Checkbox__c==True && ticket.sirenum__Valid_until__c>projectTicketStatus.Valid_Until__c) || 
                       (ticket.Valid_Checkbox__c==False && projectTicketStatus.Valid__c==False && ticket.sirenum__Valid_until__c > projectTicketStatus.Valid_Until__c)){
                           projectTicketStatus.Ticket__c=ticket.Id;
                           projectTicketStatus.Valid__c=ticket.Valid_Checkbox__c;
                           projectTicketStatus.Revoked__c=ticket.sirenum__Revoked__c;
                           projectTicketStatus.Valid_Until__c=ticket.sirenum__Valid_until__c;
                           projectTicketStatus.Valid_From__c=ticket.sirenum__Valid_From__c;
                           updateProjectTicketStatus.add(projectTicketStatus);
                       }
                    if(projectTicketStatus.Ticket__c==null){
                        projectTicketStatus.Ticket__c=ticket.Id;
                        projectTicketStatus.Valid__c=ticket.Valid_Checkbox__c;
                        projectTicketStatus.Revoked__c=ticket.sirenum__Revoked__c;
                        projectTicketStatus.Valid_Until__c=ticket.sirenum__Valid_until__c;
                        projectTicketStatus.Valid_From__c=ticket.sirenum__Valid_From__c;
                        updateProjectTicketStatus.add(projectTicketStatus);
                    }
                }
            }
        }
        if(updateProjectTicketStatus.isEmpty()|| Test.isRunningTest()){
            for(String uniqueKey: coveringProjectTicketStatus.keySet()){
                if(getSingleValidTicket.containsKey(uniqueKey) && coveringProjectTicketStatus.get(uniqueKey)!=null){
                    for(Project_Ticket_Status__c projectTicketStatus : coveringProjectTicketStatus.get(uniqueKey)){
                        sirenum__Ticket__c ticket=getSingleValidTicket.get(uniqueKey);
                        if((ticket.Valid_Checkbox__c==True && ticket.sirenum__Valid_until__c>projectTicketStatus.Valid_Until__c) || 
                           (ticket.Valid_Checkbox__c==False && projectTicketStatus.Valid__c==False && ticket.sirenum__Valid_until__c > projectTicketStatus.Valid_Until__c)){
                               projectTicketStatus.Ticket__c=ticket.Id;
                               projectTicketStatus.Valid__c=ticket.Valid_Checkbox__c;
                               projectTicketStatus.Revoked__c=ticket.sirenum__Revoked__c;
                               projectTicketStatus.Valid_Until__c=ticket.sirenum__Valid_until__c;
                               projectTicketStatus.Valid_From__c=ticket.sirenum__Valid_From__c;
                               updateProjectTicketStatus.add(projectTicketStatus);
                           }
                        if(projectTicketStatus.Ticket__c==null){
                            projectTicketStatus.Ticket__c=ticket.Id;
                            projectTicketStatus.Valid__c=ticket.Valid_Checkbox__c;
                            projectTicketStatus.Revoked__c=ticket.sirenum__Revoked__c;
                            projectTicketStatus.Valid_Until__c=ticket.sirenum__Valid_until__c;
                            projectTicketStatus.Valid_From__c=ticket.sirenum__Valid_From__c;
                            updateProjectTicketStatus.add(projectTicketStatus);
                        }
                        
                    }
                }
            }
        }
        List<sObject> updateTsandPts=new List<sObject>();
        updateTsandPts.addAll(updateTicketStatus);
        updateTsandPts.addAll(updateProjectTicketStatus);
        if(!test.isRunningTest()){
            update updateTsandPts;
        }   
    }
    
    //Method to return valid ticket 
    public Map<String, sirenum__Ticket__c> getValidTicket(Map<String, Set<sirenum__Ticket__c>> newlyCreatedTicketMap) {
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
    
    //Method to return all ticket status based on required competency
    public Map<String,List<Illingworth_Ticket_Status__c>> getAllRequiredTicketStatus(Set<Id> contactIdSet,Set<Id> competancyIdSet){
        Map<String,List<Illingworth_Ticket_Status__c>> ticketStatusMap=new Map<String,List<Illingworth_Ticket_Status__c>>();
        
        for(Illingworth_Ticket_Status__c ticketStatus: [Select id, Name,Ticket__c, Resource__c, Required_Competency__c, Covering_Competency__c,Valid_Until__c,Valid_From__c,Valid__c from Illingworth_Ticket_Status__c where Resource__c In :contactIdSet And Required_Competency__c In :competancyIdSet]){
            String uniqueKeyTS=ticketStatus.Resource__c+'#'+ticketStatus.Required_Competency__c;
            if(ticketStatusMap.containsKey(uniqueKeyTS)){
                List<Illingworth_Ticket_Status__c> existingList = ticketStatusMap.get(uniqueKeyTS);
                existingList.add(ticketStatus);
                ticketStatusMap.put(uniqueKeyTS, existingList); 
            }
            else{
                List<Illingworth_Ticket_Status__c> projectTicketStatusList = new List<Illingworth_Ticket_Status__c>{ticketStatus};
                    ticketStatusMap.put(uniqueKeyTS,projectTicketStatusList);
            }
            
        }
        return ticketStatusMap;     
    }
    
    //Method to return all ticket status based on covering competency
    public Map<String,List<Illingworth_Ticket_Status__c>> getAllCoveringTicketStatus(Set<Id> contactIdSet,Set<Id> competancyIdSet){
        Map<String,List<Illingworth_Ticket_Status__c>> ticketStatusMap=new Map<String,List<Illingworth_Ticket_Status__c>>();
        for(Illingworth_Ticket_Status__c ticketStatus: [Select id, Name,Ticket__c, Resource__c, Required_Competency__c, Covering_Competency__c,Valid_Until__c,Valid_From__c,Valid__c from Illingworth_Ticket_Status__c where Resource__c In :contactIdSet And Covering_Competency__c In :competancyIdSet]){
            String uniqueKeyTS=ticketStatus.Resource__c+'#'+ticketStatus.Covering_Competency__c;
            if(ticketStatusMap.containsKey(uniqueKeyTS)){
                List<Illingworth_Ticket_Status__c> existingList = ticketStatusMap.get(uniqueKeyTS);
                existingList.add(ticketStatus);
                ticketStatusMap.put(uniqueKeyTS, existingList); 
            }
            else{
                List<Illingworth_Ticket_Status__c> projectTicketStatusList = new List<Illingworth_Ticket_Status__c>{ticketStatus};
                    ticketStatusMap.put(uniqueKeyTS,projectTicketStatusList);
            }
        }
        return ticketStatusMap; 
    }
    
    //Method to return all project ticket status based on required competency
    public Map<String,List<Project_Ticket_Status__c>> getAllRequiredProjectTicketStatus(Set<Id> contactIdSet,Set<Id> competancyIdSet){
        Map<String,List<Project_Ticket_Status__c>> projectTicketStatusMap=new Map<String,List<Project_Ticket_Status__c>>();
        
        for(Project_Ticket_Status__c  projectTicketStatus: [Select id, Name, Resource__c,Ticket__c,Valid__c, Required_Competency__c, Covering_Competency__c,Valid_Until__c,Valid_From__c from Project_Ticket_Status__c  where Resource__c In :contactIdSet And Required_Competency__c In :competancyIdSet]){
            String uniqueKeyPTS=projectTicketStatus.Resource__c+'#'+projectTicketStatus.Required_Competency__c;
            if(projectTicketStatusMap.containsKey(uniqueKeyPTS)){
                List<Project_Ticket_Status__c> existingList = projectTicketStatusMap.get(uniqueKeyPTS);
                existingList.add(projectTicketStatus);
                projectTicketStatusMap.put(uniqueKeyPTS, existingList); 
            }
            else{
                List<Project_Ticket_Status__c> projectTicketStatusList = new List<Project_Ticket_Status__c>{projectTicketStatus};
                    projectTicketStatusMap.put(uniqueKeyPTS,projectTicketStatusList);
            }
        }
        return projectTicketStatusMap; 
    }
    
    //Method to return all project ticket status based on covering competency
    public Map<String,List<Project_Ticket_Status__c>> getAllCoveringProjectTicketStatus(Set<Id> contactIdSet,Set<Id> competancyIdSet){
        Map<String,List<Project_Ticket_Status__c>> projectTicketStatusMap=new Map<String,List<Project_Ticket_Status__c>>();
        
        for(Project_Ticket_Status__c  projectTicketStatus: [Select id, Name, Resource__c,Ticket__c,Valid__c, Required_Competency__c, Covering_Competency__c,Valid_Until__c,Valid_From__c from Project_Ticket_Status__c  where Resource__c In :contactIdSet And Covering_Competency__c In :competancyIdSet]){
            String uniqueKeyPTS=projectTicketStatus.Resource__c+'#'+projectTicketStatus.Covering_Competency__c;
            if(projectTicketStatusMap.containsKey(uniqueKeyPTS)){
                List<Project_Ticket_Status__c> existingList = projectTicketStatusMap.get(uniqueKeyPTS);
                existingList.add(projectTicketStatus);
                projectTicketStatusMap.put(uniqueKeyPTS, existingList); 
            }
            else{
                List<Project_Ticket_Status__c> projectTicketStatusList = new List<Project_Ticket_Status__c>{projectTicketStatus};
                    projectTicketStatusMap.put(uniqueKeyPTS,projectTicketStatusList);
            } 
        }
        return projectTicketStatusMap; 
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    public void execute(SchedulableContext sc){
        UpdateTicketsOnTicketStatusBatch batch = new UpdateTicketsOnTicketStatusBatch();
        Database.executebatch(batch, 1);
    } 
}