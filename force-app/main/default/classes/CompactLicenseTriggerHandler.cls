public class CompactLicenseTriggerHandler {
    
    //When we Insert new Record in Compact License It Should Check the State in Contact Work State
    //And Update the Work State Related Ticket with Contact's Compact License Ticket
    public static void updateNewWorkStateRelatedTicket(List<Compact_Licence__c> compactLicenceList){
        
        List<String> stateName = new List<String>();
        List<Contact> contactList = new List<Contact>();
        List<sirenum__Ticket__c> workStateTicketList =new List<sirenum__Ticket__c>();
        Set<sirenum__Ticket__c> ticketToBeUpdated =new Set<sirenum__Ticket__c>();
        
        for(Compact_Licence__c newRecord :compactLicenceList){ 
            if(newRecord.Country__c != null && newRecord.Name != null ){
                stateName.add(newRecord.Name);
            }
        } 
        
        String query = 'SELECT Id, Name, Compact_Licence__c, Status_from_Compact_License__c, ' +
            'Valid_Until_from_Compact_License__c, Illing_Licenced_in_States_Province__c ' +
            'FROM Contact ' +
            'WHERE Compact_Licence__c = TRUE AND ' +
            'Status_from_Compact_License__c = \'Confirmed\' AND ' +
            'Illing_Licenced_in_States_Province__c INCLUDES (\'' + String.join(new List<String>(stateName), '\',\'') + '\')';
        
        contactList = Database.query(query);
        
        workStateTicketList = [Select Id , Name ,sirenum__TicketType__c ,Competence_category__c,sirenum__Owner__c,sirenum__Owner__r.name,sirenum__TicketType__r.Licensed_In_State_Competency__c
                               from sirenum__Ticket__c 
                               where Competence_category__c = 'Work State' AND sirenum__TicketType__r.Licensed_In_State_Competency__c = true AND sirenum__Owner__c In :contactList  ];
        
        if(contactList.size() > 0 && workStateTicketList.size() > 0){
            for(Contact eachContact:contactList){
                for(sirenum__Ticket__c eachTicket:workStateTicketList){
                    if(eachContact.Name == eachTicket.sirenum__Owner__r.name){
                        eachTicket.sirenum__Valid_until__c = eachContact.Valid_Until_from_Compact_License__c;
                        eachTicket.SK_Status__c = eachContact.Status_from_Compact_License__c;
                        ticketToBeUpdated.add(eachTicket);
                    }
                }
            }
        } 
        if(ticketToBeUpdated.size()>0){
            List<sirenum__Ticket__c> FinalticketListToBeUpdated = new List<sirenum__Ticket__c>(ticketToBeUpdated);
            update FinalticketListToBeUpdated;
        }
    }
}