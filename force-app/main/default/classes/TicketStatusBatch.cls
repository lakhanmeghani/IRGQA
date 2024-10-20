global class TicketStatusBatch implements Database.Batchable<sObject>, Database.Stateful,schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id,Job_Type__c,RecordType.Name,Name from Contact where RecordType.Name = 'Resource' And Job_Type__c !=null]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> con){
        
        Set<Illingworth_Ticket_Status__c> ticketstatus = new Set<Illingworth_Ticket_Status__c>();
        List<sirenum__Sirenum_Condition_Membership__c> condition = [select id, sirenum__TicketType__c,sirenum__TicketType__r.Competence_Category__c,sirenum__Severity__c, sirenum__Job_Type__r.Name,sirenum__Job_Type__c,sirenum__Site__c,Inactive__c ,sirenum__Site__r.Id from sirenum__Sirenum_Condition_Membership__c where sirenum__Job_Type__c != null AND  Inactive__c  =False];
        
        Map <id,sirenum__Ticket__c> tickets =new Map<id,sirenum__Ticket__c> ([select id,Name,sirenum__Owner__c,sirenum__TicketType__c,sirenum__Valid_until__c,Valid_Checkbox__c ,sirenum__Revoked__c,sirenum__Valid_from__c from sirenum__Ticket__c where sirenum__Owner__c In : con]);
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
        
        if(con.size()>0 && !con.isempty()){
            For(Contact ce : con){
                if(condition.size()>0 && !condition.isempty()){
                    For(sirenum__Sirenum_Condition_Membership__c cons : condition){
                        if(ce.Job_Type__c == cons.sirenum__Job_Type__c){
                            Illingworth_Ticket_Status__c obj = new Illingworth_Ticket_Status__c();
                            obj.Competence_Condition__c = cons.id;
                            obj.Required_Competency__c = cons.sirenum__TicketType__r.id;
                            obj.Severity__c = cons.sirenum__Severity__c;
                            obj.Competence_Category__c=cons.sirenum__TicketType__r.Competence_Category__c;
                            obj.Resource__c = ce.id;
                            obj.Job_Type__c = cons.sirenum__Job_Type__r.id;
                            ticketstatus.add(obj);
                        }
                    }
                }
            }
        }
        system.debug('mapOfTicketResourceCompetencytoTicket>>>'+mapOfTicketResourceCompetencytoTicket);
        //Ticket data
        if(ticketstatus.size()>0){ 
            for(Illingworth_Ticket_Status__c status: ticketstatus){
                sirenum__Ticket__c ticket = new sirenum__Ticket__c();
                
                
                    if(mapOfTicketResourceCompetencytoTicket.containsKey(status.Resource__c+'#'+status.Required_Competency__c) && mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c).Valid_Checkbox__c == true) {   
                    
                    ticket=mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c); 
                        if(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
                        }
                        else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c);
                        }
                }
                
                else if(mapOfCoveredTicketTypeToCoveringTicketType.containsKey(status.Required_Competency__c)&& mapOfTicketResourceCompetencytoTicket.containsKey(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c ) ){
                   
                    
                    ticket = mapOfTicketResourceCompetencytoTicket.get(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c );
                    status.Related_Competency__c = mapOfCoverdTicketTypeToRelatedTicketType.get(status.Required_Competency__c);
                    status.Covering_Competency__c =mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
                    
                }
                
                   else if(mapOfTicketResourceCompetencytoTicket.containsKey(status.Resource__c+'#'+status.Required_Competency__c) && mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c).Valid_Checkbox__c == false) { 
                    
                    ticket=mapOfTicketResourceCompetencytoTicket.get(status.Resource__c+'#'+status.Required_Competency__c);
                    if(mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringTicketType.get(status.Required_Competency__c);
                        }
                        else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)!=null){
                            status.Covering_Competency__c=mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c);
                        }
                }
                
                else if(mapOfCoveredTicketTypeToCoveringInvalidTicketType.containsKey(status.Required_Competency__c)&& mapOfTicketResourceCompetencytoTicket.containsKey(mapOfCoveredTicketTypeToCoveringInvalidTicketType.get(status.Required_Competency__c)+'#'+status.Resource__c ) ){
                    
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
            for (Illingworth_Ticket_Status__c existingRecord : [SELECT Id , Name, Resource__c ,Job_Type__c, Required_Competency__c   FROM Illingworth_Ticket_Status__c where Resource__c In : con]) {
                existingCombinationSet.add(existingRecord.Resource__c +'#'+ existingRecord.Job_Type__c+'#'+existingRecord.Required_Competency__c);
            }
            
            Set<Illingworth_Ticket_Status__c> newRecordsToInsert = new Set<Illingworth_Ticket_Status__c>();
            
            //Iterate through Ticket Status and check for duplicacy
            for (Illingworth_Ticket_Status__c status : ticketstatus) {
                String combination = status.Resource__c +'#'+ status.Job_Type__c+'#'+status.Required_Competency__c;
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
    
    global void finish(Database.BatchableContext BC){
    }
    
    public void execute(SchedulableContext sc){
        TicketStatusBatch ticketStatusBatch = new TicketStatusBatch();
        Database.executebatch(ticketStatusBatch, 1);
        
    }
}