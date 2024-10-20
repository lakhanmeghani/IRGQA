global class ProjectTicketStatusBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id,Job_Type__c,RecordType.Name,AccountId,Name from Contact where RecordType.Name = 'Resource']);
    }
    global void execute(Database.BatchableContext BC, List<Contact> conList){
        
        Set<id> contactIdSet= new Set<id>();
        Set<id> accountIdSet= new Set<id>();
        Set<id> projectIdSet= new Set<id>();
        Map<id,List<sirenum__Placement__c>> mapOfContactIdToPlacement= new Map<id,List<sirenum__Placement__c>>();
        //Map<id,Set<Id>> mapOfContactIdToProjectSet= new Map<id,Set<Id>>();
        
        Set<Id> contractsForContact = new Set<Id>();
        for(Contact con:conList){
            contactIdSet.add(con.id);
        }
        Map<Id, Set<Id>> contactToContractMap = new Map<Id, Set<Id>>();

        for (sirenum__Placement__c placement : [SELECT Id,Name, sirenum__Contact__c, sirenum__Contract__c, sirenum__Contract__r.sirenum__Client__c FROM sirenum__Placement__c WHERE sirenum__Contact__c IN :contactIdSet AND Project_Placement__c = Null AND (sirenum__Status__c='Active' OR sirenum__Status__c='Pending' ) ]) {
            accountIdSet.add(placement.sirenum__Contract__r.sirenum__Client__c);
            
            Id contactId = placement.sirenum__Contact__c;
            Id contractId = placement.sirenum__Contract__c;
            projectIdSet.add(contractId);
            List<sirenum__Placement__c> placementList = new List<sirenum__Placement__c>();
            // Check if the contact already has a Set of contract IDs
            if (contactToContractMap.containsKey(contactId)) {
                Set<Id> contractSet = contactToContractMap.get(contactId);
                
                // Check if the sirenum__Contract__c is not already in the set for this contact
                if (!contractSet.contains(contractId)) {
                    contractSet.add(contractId);
                    mapOfContactIdToPlacement.get(contactId).add(placement);
                }
            } else {
                // Create a new set for this contact and add the Project
                Set<Id> contractSet = new Set<Id>();
                contractSet.add(contractId);
                contactToContractMap.put(contactId, contractSet);
                
                
                placementList.add(placement);
                mapOfContactIdToPlacement.put(contactId, placementList);
                
            }
        }
        
        Map<Id,sirenum__Ticket__c> existingTicketsMap =new Map<Id,sirenum__Ticket__c> ([Select Id,Name,sirenum__Owner__c,sirenum__TicketType__c,sirenum__Valid_until__c,Valid_Checkbox__c,sirenum__Revoked__c,sirenum__Valid_from__c from sirenum__Ticket__c where sirenum__Owner__c  IN :contactIdSet]); 
        set<id> ValidTicketCompId = new set<id>();
        set<id> InValidTicketCompId = new set<id>();
        Map<id,id> mapOfTicketCompetencytoTicket= new Map<id,id>();
        
        Map<String,sirenum__Ticket__c> mapOfTicketResourceCompetencytoTicket= new Map<String,sirenum__Ticket__c>();
        for(sirenum__Ticket__c ticket:existingTicketsMap.values()){
            if(mapOfTicketResourceCompetencytoTicket.containsKey(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c)){
                sirenum__Ticket__c exitingTicket=mapOfTicketResourceCompetencytoTicket.get(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c);
                if(ticket.Valid_Checkbox__c==True){
                    ValidTicketCompId.add(ticket.sirenum__TicketType__c);
                    if( (exitingTicket.Valid_Checkbox__c==True 
                         && ticket.sirenum__Valid_until__c > exitingTicket.sirenum__Valid_until__c)
                       || exitingTicket.Valid_Checkbox__c==False
                      ){
                          mapOfTicketResourceCompetencytoTicket.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c,ticket);
                      }
                }
                //if upcoming ticket is Invalid
                Else if(ticket.Valid_Checkbox__c==False){
                    InValidTicketCompId.add(ticket.sirenum__TicketType__c);
                    if( (exitingTicket.Valid_Checkbox__c==False 
                         && ticket.sirenum__Valid_until__c > exitingTicket.sirenum__Valid_until__c)
                       
                      ){
                          mapOfTicketResourceCompetencytoTicket.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c,ticket);
                      }
                }
                
            }
            else{
                mapOfTicketResourceCompetencytoTicket.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c, ticket);                                 
            }
        }
        
        //map of Valid related competency 
        Map<id,id> mapOfCoverdTicketTypeToRelatedTicketType= new Map<id,id>();
        Map<id,id> mapOfCoveredTicketTypeToCoveringTicketType= new Map<id,id>();
        // get all the related competency when ticket is valid     
        for(sirenum__RelatedTicketType__c rel:[select id, sirenum__CoveringTicketType__c,sirenum__CoveredTicketType__c,sirenum__CoveredTicketType__r.Name from sirenum__RelatedTicketType__c where sirenum__CoveringTicketType__c  in: ValidTicketCompId]){
            mapOfCoveredTicketTypeToCoveringTicketType.put(rel.sirenum__CoveredTicketType__c,rel.sirenum__CoveringTicketType__c);
            mapOfCoverdTicketTypeToRelatedTicketType.put(rel.sirenum__CoveredTicketType__c, rel.Id);
        }
        //map of invalid related competency 
        Map<id,id> mapOfCoverdTicketTypeToRelatedInvalidTicketType= new Map<id,id>();
        Map<id,id> mapOfCoveredTicketTypeToCoveringInvalidTicketType= new Map<id,id>();
        //get all the related competency when ticket is valid 
        for(sirenum__RelatedTicketType__c rel:[select id, sirenum__CoveringTicketType__c,sirenum__CoveredTicketType__c,sirenum__CoveredTicketType__r.Name from sirenum__RelatedTicketType__c where sirenum__CoveringTicketType__c  in: InValidTicketCompId]){
            mapOfCoveredTicketTypeToCoveringInvalidTicketType.put(rel.sirenum__CoveredTicketType__c,rel.sirenum__CoveringTicketType__c);
            mapOfCoverdTicketTypeToRelatedInvalidTicketType.put(rel.sirenum__CoveredTicketType__c, rel.Id);
        }
        List<Project_Ticket_Status__c> projecttktstatus =new List<Project_Ticket_Status__c>(); 
        Map<Id,sirenum__Sirenum_Condition_Membership__c> accountCompetencyConditionMap= new Map<Id,sirenum__Sirenum_Condition_Membership__c>();
        Map<Id, List<sirenum__Sirenum_Condition_Membership__c>> clientConditionMap = new Map<Id, List<sirenum__Sirenum_Condition_Membership__c>>();
        
        for(sirenum__Sirenum_Condition_Membership__c compCond: [select Name,id,sirenum__Client__c,sirenum__TicketType__c,sirenum__Severity__c,Competence_category__c,Project__c  from sirenum__Sirenum_Condition_Membership__c where Project__c In :projectIdSet  and sirenum__Site__c =null AND Inactive__c =False]){
            
            accountCompetencyConditionMap.put(compCond.Project__c,compCond);
            Id clientId = compCond.Project__c;
            system.debug('compCond.Project__c>>>>'+compCond.Project__c);
            if (clientConditionMap.containsKey(clientId)) {
                // If the clientId is already in the map, add the compCond to the existing list
                clientConditionMap.get(clientId).add(compCond);
            } else {
                // If the clientId is not in the map, create a new list and add the compCond to it
                List<sirenum__Sirenum_Condition_Membership__c> conditionList = new List<sirenum__Sirenum_Condition_Membership__c>();
                conditionList.add(compCond);
                clientConditionMap.put(clientId, conditionList);
            }
        }
       
        
        // adding competency condition details 
        for(Contact con:conList){
            
            if(mapOfContactIdToPlacement.get(con.Id)!=null){
            for(sirenum__Placement__c placementId: mapOfContactIdToPlacement.get(con.Id)){
                if(clientConditionMap.get(placementId.sirenum__Contract__c)!=null){
                for(sirenum__Sirenum_Condition_Membership__c CompCond:clientConditionMap.get(placementId.sirenum__Contract__c)){
                    
                    Project_Ticket_Status__c obj = new Project_Ticket_Status__c();
                    
                    obj.Resource__c = con.Id;
                    obj.Project__c = placementId.sirenum__Contract__c;
                    obj.Account__c = CompCond.sirenum__Client__c;
                    obj.Competency_Condition__c=CompCond.Id;
                    obj.Required_Competency__c = CompCond.sirenum__TicketType__c;
                    obj.Severity__c = CompCond.sirenum__Severity__c;
                    obj.Competence_Category__c = CompCond.Competence_category__c;
                    projecttktstatus.add(obj);
                }
                
            } 
                }
                }
        }
        system.debug('1stprojecttktstatus>>'+projecttktstatus); 
        // ticket data 
        
        for(Project_Ticket_Status__c status: projecttktstatus){
            sirenum__Ticket__c ticket = new sirenum__Ticket__c();
            //if(mapOfTicketCompetencytoTicket.containsKey(status.Required_Competency__c) && existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).sirenum__Owner__c == status.Resource__c && existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).Valid_Checkbox__c == true && existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).sirenum__Revoked__c == false ){
            if(mapOfTicketResourceCompetencytoTicket.containsKey(status.Resource__c+'#'+status.Required_Competency__c) && mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c).Valid_Checkbox__c == true && mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c).sirenum__Revoked__c == False) {
            //ticket=existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) );
            	ticket=mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c); 
                        if(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
                        }
                        else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c);
                        }
            }
            //else if(mapOfCoveredTicketTypeToCoveringTicketType.containsKey(status.Required_Competency__c)&& existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c) )).sirenum__Owner__c == status.Resource__c){
            else if(mapOfCoveredTicketTypeToCoveringTicketType.containsKey(status.Required_Competency__c)&& mapOfTicketResourceCompetencytoTicket.containsKey(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c ) ){    
            	//ticket = existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c) ));
                ticket = mapOfTicketResourceCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c );
                status.Related_Competency__c = mapOfCoverdTicketTypeToRelatedTicketType.get(status.Required_Competency__c);
                status.Covering_Competency__c =mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
            }
            else if(mapOfTicketResourceCompetencytoTicket.containsKey(status.Resource__c+'#'+status.Required_Competency__c) && mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c).Valid_Checkbox__c == false && mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c).sirenum__Revoked__c == True) { 
            //else if(mapOfTicketCompetencytoTicket.containsKey(status.Required_Competency__c) && existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).sirenum__Owner__c == status.Resource__c && existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).Valid_Checkbox__c == false && existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).sirenum__Revoked__c == true){
                //ticket=existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) );
                ticket=mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c);
                    if(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
                        }
                        else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c);
                        }
            }
            //else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.containsKey(status.Required_Competency__c)&& existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c) )).sirenum__Owner__c == status.Resource__c ){
            else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.containsKey(status.Required_Competency__c)&& mapOfTicketResourceCompetencytoTicket.containsKey(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c ) ){    
            	//ticket = existingTicketsMap.get(mapOfTicketCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c) ));
                ticket = mapOfTicketResourceCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c );
                status.Related_Competency__c = mapOfCoverdTicketTypeToRelatedInvalidTicketType.get(status.Required_Competency__c);
                status.Covering_Competency__c =mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c);
            }
            if(ticket!=null){
                status.Ticket__c = ticket.Id;
                status.Revoked__c = ticket.sirenum__Revoked__c;
                status.Valid__c = ticket.Valid_Checkbox__c;
                status.Valid_From__c = ticket.sirenum__Valid_from__c;
                status.Valid_Until__c = ticket.sirenum__Valid_until__c;
            }
        }
        
        
        Set<String> existingCombinationSet = new Set<String>();
        for (Project_Ticket_Status__c existingRecord : [SELECT Competency_Condition__c, Resource__c FROM Project_Ticket_Status__c where Resource__c In : conList]) {
            existingCombinationSet.add(existingRecord.Competency_Condition__c +'#'+ existingRecord.Resource__c);
        }
        
        
        List<Project_Ticket_Status__c> newRecordsToInsert = new List<Project_Ticket_Status__c>();
        
        // Iterate through projecttktstatus and check for duplicacy
        for (Project_Ticket_Status__c status : projecttktstatus) {
            String combination = status.Competency_Condition__c +'#'+ status.Resource__c;
            if (!existingCombinationSet.contains(combination)) {
                newRecordsToInsert.add(status);
            }
        }
        
        // Insert the new records
        if (!newRecordsToInsert.isEmpty()) {
            insert newRecordsToInsert;
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    public void execute(SchedulableContext sc){
        ProjectTicketStatusBatch batch = new ProjectTicketStatusBatch();
        Database.executebatch(batch, 1);
    }
}