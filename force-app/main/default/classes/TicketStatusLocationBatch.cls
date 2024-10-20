global class TicketStatusLocationBatch implements Database.Batchable<sObject>,Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id,RecordType.Name,Name,Illing_Licenced_in_States_Province__c,Work_Country__c from Contact where RecordType.Name = 'Resource' And (Work_Country__c !=null OR Illing_Licenced_in_States_Province__c!=null) ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> con){
        
        Set<Illingworth_Ticket_Status__c> ticketstatus = new Set<Illingworth_Ticket_Status__c>();
       
        
        Map <id,sirenum__Ticket__c> tickets =new Map<id,sirenum__Ticket__c> ([select id,Name,sirenum__Owner__c,sirenum__TicketType__c,sirenum__Valid_until__c,Valid_Checkbox__c ,sirenum__Revoked__c,sirenum__Valid_from__c from sirenum__Ticket__c where sirenum__Owner__c In : con And (Competence_category__c ='Work Country' OR Competence_category__c ='Work State' OR Competence_category__c ='RN Mandatory Training')]);
        set<id> ValidTicketId = new set<id>();
        set<id> InValidTicketId = new set<id>();
        for(id t:tickets.keySet()){
            if(tickets.get(t).Valid_Checkbox__c == true){
                ValidTicketId.add(tickets.get(t).sirenum__TicketType__c);
            }
            else if(tickets.get(t).Valid_Checkbox__c == false){
                InValidTicketId.add(tickets.get(t).sirenum__TicketType__c);
            }
        }
        
        // get all the related competency when ticket is valid 
        list<sirenum__RelatedTicketType__c> ValidrelatedComp =[select id, sirenum__CoveringTicketType__c,sirenum__CoveredTicketType__c,sirenum__CoveredTicketType__r.Name from sirenum__RelatedTicketType__c where sirenum__CoveringTicketType__c  in: ValidTicketId];
        
        //get all the related competency when ticket is valid 
        list<sirenum__RelatedTicketType__c> InValidrelatedComp =[select id, sirenum__CoveringTicketType__c,sirenum__CoveredTicketType__c,sirenum__CoveredTicketType__r.Name from sirenum__RelatedTicketType__c where sirenum__CoveringTicketType__c  in: InValidTicketId];
        
        //map of Valid related competency 
        Map<id,id> mapOfCoverdTicketTypeToRelatedTicketType= new Map<id,id>();
        Map<id,id> mapOfCoveredTicketTypeToCoveringTicketType= new Map<id,id>();
        for(sirenum__RelatedTicketType__c rel:ValidrelatedComp){
            mapOfCoveredTicketTypeToCoveringTicketType.put(rel.sirenum__CoveredTicketType__c,rel.sirenum__CoveringTicketType__c);
            mapOfCoverdTicketTypeToRelatedTicketType.put(rel.sirenum__CoveredTicketType__c, rel.Id);
        }
        
        //map of invalid related competency 
        Map<id,id> mapOfCoverdTicketTypeToRelatedInvalidTicketType= new Map<id,id>();
        Map<id,id> mapOfCoveredTicketTypeToCoveringInvalidTicketType= new Map<id,id>();
        for(sirenum__RelatedTicketType__c rel:InValidrelatedComp){
            mapOfCoveredTicketTypeToCoveringInvalidTicketType.put(rel.sirenum__CoveredTicketType__c,rel.sirenum__CoveringTicketType__c);
            mapOfCoverdTicketTypeToRelatedInvalidTicketType.put(rel.sirenum__CoveredTicketType__c, rel.Id);
        }
        
       
        Map<id,id> mapOfTicketCompetencytoTicket= new Map<id,id>();
        Map<String,sirenum__Ticket__c> mapOfTicketResourceCompetencytoTicket= new Map<String,sirenum__Ticket__c>();
        for(sirenum__Ticket__c ticket:tickets.values()){
            if(mapOfTicketResourceCompetencytoTicket.containsKey(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c)){
                sirenum__Ticket__c exitingTicket=mapOfTicketResourceCompetencytoTicket.get(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c);
                if(ticket.Valid_Checkbox__c==True){
             
                    if( (exitingTicket.Valid_Checkbox__c==True 
                         && ticket.sirenum__Valid_until__c > exitingTicket.sirenum__Valid_until__c)
                       || exitingTicket.Valid_Checkbox__c==False
                      ){
                          mapOfTicketResourceCompetencytoTicket.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c,ticket);
                      }
                }
                //if upcoming ticket is Invalid
                Else if(ticket.Valid_Checkbox__c==False){
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
        
        Map<String,List<String>> mapOfContactIdtoWorkCountriesList= new Map<String,List<String>>();
        Map<String,List<String>> mapOfContactIdtoWorkStateList= new Map<String,List<String>>();
        List<String> countryList=new List<String>();
        List<String> stateList=new List<String>();
        if(con.size()>0 && !con.isempty()){
            
            for(Contact ce : con){
                
                if(ce.Work_Country__c!=null){
                    countryList=ce.Work_Country__c.split(';');
                    mapOfContactIdtoWorkCountriesList.put(ce.Id,countryList);
                }
                if(ce.Illing_Licenced_in_States_Province__c!=null){
                	stateList=ce.Illing_Licenced_in_States_Province__c.split(';');
                    mapOfContactIdtoWorkStateList.put(ce.Id,stateList);
                }
                
				
            }
            
        }
        List<sirenum__Sirenum_Condition_Membership__c> countriesCompCond=getWorkCountryCompetencyCond(countryList);
        List<sirenum__Sirenum_Condition_Membership__c> stateCompCond=getWorkStateCompetencyCond(stateList);
        
       
        
        for(String contactId : mapOfContactIdtoWorkCountriesList.keySet()){
            Map<String,Illingworth_Ticket_Status__c> ticketStatusCompCountriesMap=new Map<String,Illingworth_Ticket_Status__c>();
           	List<String> countryListForContact = mapOfContactIdtoWorkCountriesList.get(contactId);
            for(String country:countryListForContact){
                for (sirenum__Sirenum_Condition_Membership__c compCond : countriesCompCond){
                    if(compCond.Work_Country__c==country && compCond.sirenum__TicketType__r.Work_state__c==Null){
                        String compName=compCond.sirenum__TicketType__r.Name;
                        if(!ticketStatusCompCountriesMap.containsKey(compName)){
                       		Illingworth_Ticket_Status__c ticketStatusObj = new Illingworth_Ticket_Status__c();
                            ticketStatusObj.Competence_Condition__c = compCond.Id;
                            ticketStatusObj.Required_Competency__c = compCond.sirenum__TicketType__c;
                            ticketStatusObj.Severity__c = compCond.sirenum__Severity__c;
                            ticketStatusObj.Competence_Category__c = compCond.Competence_Category__c;
                            ticketStatusObj.Resource__c = contactId;
                            ticketStatusObj.Work_Country__c=country;
                        	ticketStatusObj.Inactive__c = compCond.Inactive__c; 
                            ticketstatus.add(ticketStatusObj); 
                            ticketStatusCompCountriesMap.put(compName,ticketStatusObj);
                    }
                        else{
                            Illingworth_Ticket_Status__c existTS=ticketStatusCompCountriesMap.get(compName);
                           // existTS.Work_state__c+=';'+state;
                            existTS.Work_Country__c+=';'+country;
                            ticketstatus.add(existTS);
                        }
                        }
                    
                }
                
            }
            
        }
        for(String contactId : mapOfContactIdtoWorkStateList.keySet()){
            Map<String,Illingworth_Ticket_Status__c> ticketStatusCompMap=new Map<String,Illingworth_Ticket_Status__c>();
           	List<String> stateListForContact = mapOfContactIdtoWorkStateList.get(contactId);
            for(String state:stateListForContact){
                for (sirenum__Sirenum_Condition_Membership__c compCond : stateCompCond){
                    if(compCond.Work_state__c==state && compCond.sirenum__TicketType__r.Work_state__c!=Null){
                        String compName=compCond.sirenum__TicketType__r.Name;
                        if(!ticketStatusCompMap.containsKey(compName)){
                       		Illingworth_Ticket_Status__c ticketStatusObj = new Illingworth_Ticket_Status__c();
                            ticketStatusObj.Competence_Condition__c = compCond.Id;
                            ticketStatusObj.Required_Competency__c = compCond.sirenum__TicketType__c;
                            ticketStatusObj.Severity__c = compCond.sirenum__Severity__c;
                            ticketStatusObj.Competence_Category__c = compCond.Competence_Category__c;
                            ticketStatusObj.Resource__c = contactId;
                            ticketStatusObj.Work_state__c=state;
                            ticketStatusObj.Work_Country__c=compCond.Work_Country__c;
                            ticketStatusObj.Inactive__c = compCond.Inactive__c; 
                            ticketstatus.add(ticketStatusObj);
                            ticketStatusCompMap.put(compName,ticketStatusObj);
                            }
                        else{
                            Illingworth_Ticket_Status__c existTS=ticketStatusCompMap.get(compName);
                            existTS.Work_state__c+=';'+state;
                            existTS.Work_Country__c=compCond.Work_Country__c;
                            ticketstatus.add(existTS);
                        }
                    }
                    
                }
                
            }
            
        }

        
        //Ticket data
        if(ticketstatus.size()>0){ 
            for(Illingworth_Ticket_Status__c status: ticketstatus){
                sirenum__Ticket__c ticket = new sirenum__Ticket__c();
                
                //if(mapOfTicketCompetencytoTicket.containsKey(status.Required_Competency__c) && tickets.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).sirenum__Owner__c == status.Resource__c && tickets.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).Valid_Checkbox__c == true){
                    if(mapOfTicketResourceCompetencytoTicket.containsKey(status.Resource__c+'#'+status.Required_Competency__c) && mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c).Valid_Checkbox__c == true) {   
                    //ticket=tickets.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) );
                    ticket=mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c); 
                        if(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
                        }
                        else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c);
                        }
                }
                //else if(mapOfCoveredTicketTypeToCoveringTicketType.containsKey(status.Required_Competency__c)&& tickets.get(mapOfTicketCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c) )).sirenum__Owner__c == status.Resource__c ){
                else if(mapOfCoveredTicketTypeToCoveringTicketType.containsKey(status.Required_Competency__c)&& mapOfTicketResourceCompetencytoTicket.containsKey(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c ) ){
                    //ticket = tickets.get(mapOfTicketCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c) ));
                    
                    ticket = mapOfTicketResourceCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c );
                    status.Related_Competency__c = mapOfCoverdTicketTypeToRelatedTicketType.get(status.Required_Competency__c);
                    status.Covering_Competency__c =mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
                    
                }
                //else if(mapOfTicketCompetencytoTicket.containsKey(status.Required_Competency__c) && tickets.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).sirenum__Owner__c == status.Resource__c && tickets.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) ).Valid_Checkbox__c == false){
                   else if(mapOfTicketResourceCompetencytoTicket.containsKey(status.Resource__c+'#'+status.Required_Competency__c) && mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c).Valid_Checkbox__c == false) { 
                    //ticket=tickets.get(mapOfTicketCompetencytoTicket.get(status.Required_Competency__c) );
                    ticket=mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c);
                    if(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
                        }
                        else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c);
                        }
                }
                //else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.containsKey(status.Required_Competency__c)&& tickets.get(mapOfTicketCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c) )).sirenum__Owner__c == status.Resource__c ){
                else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.containsKey(status.Required_Competency__c)&& mapOfTicketResourceCompetencytoTicket.containsKey(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c ) ){
                    //ticket = tickets.get(mapOfTicketCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c) ));
                    ticket = mapOfTicketResourceCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c );
                    status.Related_Competency__c = mapOfCoverdTicketTypeToRelatedInvalidTicketType.get(status.Required_Competency__c);
                    status.Covering_Competency__c =mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c);
                    
                }
                if(ticket != null){
                    status.Ticket__c = ticket.Id;
                    status.Revoked__c = ticket.sirenum__Revoked__c;
                    status.Valid__c = ticket.Valid_Checkbox__c;
                    status.Valid_From__c = ticket.sirenum__Valid_from__c;
                    status.Valid_Until__c = ticket.sirenum__Valid_until__c;
                }
            }
            
            Set<String> existingCombinationSet = new Set<String>();
            for (Illingworth_Ticket_Status__c existingRecord : [SELECT Id , Name, Resource__c ,Job_Type__c,Work_Country__c,Work_State__c, Required_Competency__c   FROM Illingworth_Ticket_Status__c where Resource__c In : con]) {
                existingCombinationSet.add(existingRecord.Resource__c +'#'+existingRecord.Required_Competency__c);
            }
            
            Set<Illingworth_Ticket_Status__c> newRecordsToInsert = new Set<Illingworth_Ticket_Status__c>();
            
            //Iterate through Ticket Status and check for duplicacy
            for (Illingworth_Ticket_Status__c status : ticketstatus) {
                String combination = status.Resource__c +'#'+status.Required_Competency__c;
                if (!existingCombinationSet.contains(combination)) {
                    newRecordsToInsert.add(status);
                }
            }
            
            if(ticketstatus.size()>0 ){
                List<Illingworth_Ticket_Status__c> finalTicketStatusListInsert = new List<Illingworth_Ticket_Status__c>(newRecordsToInsert);
              
                insert finalTicketStatusListInsert;
            }
        } 
    }
    public static List<sirenum__Sirenum_Condition_Membership__c> getWorkCountryCompetencyCond(List<String> countriesList){
        return [Select id,Name,sirenum__TicketType__r.Work_state__c,Inactive__c,sirenum__TicketType__r.Name,Work_Country__c,Work_State__c,Competence_Category__c,sirenum__TicketType__c,sirenum__TicketType__r.Competence_Category__c,sirenum__Severity__c, sirenum__Job_Type__r.Name,sirenum__Job_Type__c,sirenum__Site__c,sirenum__Site__r.Id,sirenum__Location__c,sirenum__Location__r.Name from sirenum__Sirenum_Condition_Membership__c where  Work_Country__c IN:countriesList And Work_State__c='' AND Inactive__c =False ];
    }
    public static List<sirenum__Sirenum_Condition_Membership__c> getWorkStateCompetencyCond(List<String> statesList){
 
        return [Select id,Inactive__c,sirenum__TicketType__r.Work_state__c,sirenum__TicketType__r.Name,Name,Work_Country__c,Work_State__c,Competence_Category__c,sirenum__TicketType__c,sirenum__TicketType__r.Competence_Category__c,sirenum__Severity__c from sirenum__Sirenum_Condition_Membership__c where  Work_State__c IN :statesList and Competence_category__c!='Work Country' AND Inactive__c =False ];
    }
        
    
    global void finish(Database.BatchableContext BC){
    }
    public void execute(SchedulableContext sc){
        TicketStatusLocationBatch batch = new TicketStatusLocationBatch();
        Database.executebatch(batch, 1);
    }
}