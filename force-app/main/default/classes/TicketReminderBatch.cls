/**
 * © Sirenum By Bullhorn 2024
 * PS-927 Scheduled Job to send Expiring Ticket notifications
 *
 * Creates sirenum__PushNotificationEvent__e Platform Events and updates Tickets with audit information when:
 * Tickets are 14 days (at time of writing) from expiry and/or
 * Tickets are 0 days from expiry
 */

public class TicketReminderBatch implements Database.Batchable<SObject>, Database.Stateful{

    //Declare stateful variable, this will be used by the starting querylocator
    public final Set<Id> contactIds;

    /**
     * Batch constructor to set stateful final variable
     *
     * @param contactIds  A Set of ContactIds which should be processed in batches, creating notifications
     */
    public TicketReminderBatch(Set<Id> contactIds){
        this.contactIds = contactIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT Id ' +
                'FROM Contact ' +
                'Where Id IN :contactIds'
        );
    }

    public void execute(Database.BatchableContext context, List<Contact> scope) {
        Set<Id> contactIdsInScope = new Set<Id>(); //The Contact Ids to handle in this batch

        for (Contact contact : scope){
            contactIdsInScope.add(contact.Id);
        }

        //Prepare maps of the tickets by Contact Id (to reduce no. of notifications sent)
        Map<Id,List<sirenum__Ticket__c>> TicketsFor14dReminderByContactId = new Map<Id, List<sirenum__Ticket__c>>();
        Map<Id,List<sirenum__Ticket__c>> TicketsFor0dReminderByContactId = new Map<Id, List<sirenum__Ticket__c>>();
        Set<Id> ticketsWith0dNotification = new Set<Id>(); //To ensure that if tickets are given a 0d notification, they are not also given a 14d notification
        Date today = Date.today();

        //Get all tickets due for 1 or more notifications for contacts in batch scope
        List<sirenum__Ticket__c> ticketsForReminders = [
                SELECT Id, sirenum__Valid_until__c, X14DayReminderSent__c, LastDayReminderSent__c, sirenum__Owner__c, sirenum__TicketType__r.Name
                FROM sirenum__Ticket__c
                WHERE Show_in_TrialGo__c = TRUE
                AND sirenum__Owner__c IN :contactIdsInScope
                AND (
                        (sirenum__Valid_until__c <= :Date.today().addDays(14) AND X14DayReminderSent__c = NULL)
                        OR
                        (sirenum__Valid_until__c <= :Date.today().addDays(1) AND LastDayReminderSent__c = NULL)
                )
        ];

        //Loop all tickets due for 1+ reminders within scope and sort into maps accordingly
        for (sirenum__Ticket__c ticket : ticketsForReminders){
            //0 Day reminder required
            if (ticket.sirenum__Valid_until__c <= today.addDays(1) && ticket.LastDayReminderSent__c == null){
                List<sirenum__Ticket__c> tickets = TicketsFor0dReminderByContactId.get(ticket.sirenum__Owner__c);
                if (tickets == null){
                    TicketsFor0dReminderByContactId.put(ticket.sirenum__Owner__c, new List<sirenum__Ticket__c>{ticket});
                } else {
                    tickets.add(ticket);
                }
                ticket.LastDayReminderSent__c = today;
                ticketsWith0dNotification.add(ticket.Id);
            }
            //14 Day reminder required
            if (ticket.sirenum__Valid_until__c <= today.addDays(14) && ticket.X14DayReminderSent__c == null && !ticketsWith0dNotification.contains(ticket.Id)){
                List<sirenum__Ticket__c> tickets = TicketsFor14dReminderByContactId.get(ticket.sirenum__Owner__c);
                if (tickets == null){
                    TicketsFor14dReminderByContactId.put(ticket.sirenum__Owner__c, new List<sirenum__Ticket__c>{ticket});
                } else {
                    tickets.add(ticket);
                }
                ticket.X14DayReminderSent__c = today;
            }
        }

        //Process the set of Contact Ids in the scope, preparing notifications to be sent
        List<sirenum__PushNotificationEvent__e> pushNotifications = new List<sirenum__PushNotificationEvent__e>();
        for (Id contactId : contactIdsInScope){
            List<sirenum__Ticket__c> tickets14d = ticketsFor14dReminderByContactId.get(contactId);
            if (tickets14d != null) {
                if (tickets14d.size() == 1) {
                    String message = String.format(Label.TicketsReminderText14DaysSingle, new Object[]{
                            tickets14d[0].sirenum__TicketType__r.Name
                    });
                    pushNotifications.add(CreateNotification(contactId, message));
                } else {
                    String message = String.format(Label.TicketsReminderText14DaysMulti, new Object[]{
                            String.valueOf(tickets14d.size())
                    });
                    pushNotifications.add(CreateNotification(contactId, message));
                }
            }
            List<sirenum__Ticket__c> tickets0d = ticketsFor0dReminderByContactId.get(contactId);
            if (tickets0d != null) {
                if (tickets0d.size() == 1) {
                    String message = String.format(Label.TicketsReminderText0DaysSingle, new Object[]{
                            tickets0d[0].sirenum__TicketType__r.Name
                    });
                    pushNotifications.add(CreateNotification(contactId, message));
                } else {
                    String message = String.format(Label.TicketsReminderText0DaysMulti, new Object[]{
                            String.valueOf(tickets0d.size())
                    });
                    pushNotifications.add(CreateNotification(contactId, message));
                }
            }
        }

        //Handle platform events to be created
        EventBus.publish(pushNotifications);

        //Update tickets to indicate the push notifications were submitted to be sent
        update ticketsForReminders;
    }

    public void finish(Database.BatchableContext bc){
        //do nothing
    }

    /**
     * @param contactId The Id of the contact who the notification should be sent to
     * @param message The (detailed) message to provide to the contact in the notification
     *
     * @return a transient Push Notification platform event ready to be inserted
     */
    public sirenum__PushNotificationEvent__e CreateNotification(Id contactId, String message){
        sirenum__PushNotificationEvent__e notification = new sirenum__PushNotificationEvent__e(
                sirenum__WhoId__c = contactId,
                sirenum__Message__c = message,
                sirenum__Title__c = Label.TicketsReminderTitle
        );
        return notification;
    }
}