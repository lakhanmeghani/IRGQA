global class createTicketsForWorkCountry implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id,Name,Work_Country__c,Valid_Until_from_Compact_License__c,Status_from_Compact_License__c from Contact where RecordType.Name = 'Resource' and Work_Country__c != null and Activity_Status__c IN ('Active','Paused','Training','Onboarding','Re-activated on Bank')]);
    }
    global void execute(Database.BatchableContext BC, List<Contact> contactList){
        List<sirenum__ticket__c> newTicketInsertList = new List<sirenum__ticket__c >();
        Map<String,list<sirenum__TicketType__c>> compNameMap=new Map<String,list<sirenum__TicketType__c>>();
        
        for(sirenum__Sirenum_Condition_Membership__c eachCountryComp : [select id, sirenum__TicketType__c ,sirenum__TicketType__r.Work_Country__c,sirenum__TicketType__r.Name,Work_Country__c from sirenum__Sirenum_Condition_Membership__c where Work_State__c = null and sirenum__TicketType__r.Work_State__c = null and Work_Country__c != null and sirenum__TicketType__r.Work_Country__c != null and sirenum__TicketType__r.Competence_Category__c = 'Work Country']){

            if(compNameMap.containsKey(eachCountryComp.Work_Country__c)){
                compNameMap.get(eachCountryComp.Work_Country__c).add(eachCountryComp.sirenum__TicketType__r);
            }
            else{
                compNameMap.put(eachCountryComp.Work_Country__c,new List<sirenum__TicketType__c>{eachCountryComp.sirenum__TicketType__r});
            }
        }
        
        list<sirenum__Ticket__c> listOfExistingTickets = [select id,sirenum__Owner__c,sirenum__TicketType__c from sirenum__Ticket__c where sirenum__Owner__c IN: contactList and Competency_Work_State__c = null and (Competence_category__c = 'Work Country') and sirenum__TicketType__r.Work_Country__c != null and sirenum__TicketType__r.Work_State__c = null];
        map<string,list<string>> mapOfConIdVsCompResource = new map<string,list<string>>();
        
        for(sirenum__Ticket__c tkt : listOfExistingTickets){
            if(mapOfConIdVsCompResource.containsKey(tkt.sirenum__Owner__c)){
                mapOfConIdVsCompResource.get(tkt.sirenum__Owner__c).add(tkt.sirenum__Owner__c +'#'+ tkt.sirenum__TicketType__c);
            }
            else{
                mapOfConIdVsCompResource.put(tkt.sirenum__Owner__c,new List<string>{tkt.sirenum__Owner__c +'#'+ tkt.sirenum__TicketType__c});
            }
        }
     
        set<id> compIds = new set<id>();
        for(Contact eachContact:contactList){
            if(compNameMap.containskey(eachContact.Work_Country__c)){
                for(sirenum__TicketType__c tkt: compNameMap.get(eachContact.Work_Country__c)){
                    if(!compIds.contains(tkt.id)){
                        compIds.add(tkt.id);
                        if(compIds.contains(tkt.id)){
                            sirenum__ticket__c newTicket = new sirenum__ticket__c();
                            newTicket.sirenum__TicketType__c = tkt.Id;
                            newTicket.sirenum__Owner__c = eachContact.Id;
                          //  newTicket.sirenum__Valid_until__c= system.today(); 
                          //  newTicket.sirenum__Valid_from__c    = system.today();
                            newTicket.SK_Status__c = 'Pending' ;
                            string matched = '';
                            if(mapOfConIdVsCompResource.containskey(eachContact.Id)){
                                for(string str : mapOfConIdVsCompResource.get(eachContact.Id)){
                        
                                    if(newTicket.sirenum__Owner__c+'#'+newTicket.sirenum__TicketType__c == str ){
                                        matched = str;
                                    }
                                }
                                
                            }
                            if(newTicket.sirenum__Owner__c+'#'+newTicket.sirenum__TicketType__c != matched)
                                newTicketInsertList.add(newTicket);
                            
                        }
                    }
                }
            }
        }  
        
        if(newTicketInsertList.size()>0){
            Insert newTicketInsertList;
            system.debug('newTicketInsertList=='+newTicketInsertList);
        }    
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }  
}