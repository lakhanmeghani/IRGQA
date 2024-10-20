/**
 * L2SUP-1208 Onboarding path ticket assignment
 * Checks to ensure a Contact has the require tickets assigned
 *
 * Copyright Sirenum 2022
 */

public class OnboardingTicketCheck {
    @InvocableMethod(Label='CheckTickets')
    public static void CheckTickets(List<List<Id>> contactIdList){
        List<Id> contactIds = new List<Id>(contactIdList[0]);
        Id contactId = contactIds[0];

        Contact contact = [
                SELECT Id, Onboarding_Path__c, Illing_Licenced_in_States_Province__c  
                FROM Contact WHERE Id = :contactId
        ];

        String onboardingPathSearch = '(\'' + contact.Onboarding_Path__c + '\')';
        
        //Tickets ALREADY assigned to Contact
        List<sirenum__Ticket__c> assignedTickets = [
                SELECT Id, sirenum__TicketType__c, sirenum__TicketType__r.Applicable_Oboarding_Paths__c
                FROM sirenum__Ticket__c
                WHERE sirenum__Owner__c = :contactId
        ];

        Set<Id> assignedTicketTypeIds = new Set<Id>();

        for (sirenum__Ticket__c ticket : assignedTickets){
            assignedTicketTypeIds.add(ticket.sirenum__TicketType__c);
        }
		String query;
        //Tickets which SHOULD be assigned to the contact
        if(contact.Illing_Licenced_in_States_Province__c !=null){
       List<String> state=  (contact.Illing_Licenced_in_States_Province__c).split(';');
             query = 'SELECT Id ' +
    'FROM sirenum__TicketType__c ' +
    'WHERE Applicable_Oboarding_Paths__c INCLUDES (\'' + contact.Onboarding_Path__c + '\') OR Licenced_in_States_Province__c IN :state ';
		system.debug('query>>>'+query);
        }
        else{
            query = 'SELECT Id ' +
    'FROM sirenum__TicketType__c ' +
    'WHERE Applicable_Oboarding_Paths__c INCLUDES (\'' + contact.Onboarding_Path__c + '\') ';
        }
        
        List<sirenum__TicketType__c> applicableTicketTypes = Database.query(query);

        List<sirenum__Ticket__c> ticketsToCreate = new List<sirenum__Ticket__c>();

        //For each applicable ticket type, ensure a ticket exists
        for (sirenum__TicketType__c applicableTicketType : applicableTicketTypes){
            if (!assignedTicketTypeIds.contains(applicableTicketType.Id)){
                ticketsToCreate.add(new sirenum__Ticket__c(
                        sirenum__Owner__c = contactId,
                        sirenum__TicketType__c = applicableTicketType.Id,
                        sirenum__Revoked__c = true,
                        SK_Status__c = 'Pending'
                ));
            }
        }

        if (ticketsToCreate.size() > 0){
            insert ticketsToCreate;
        }
    }
}