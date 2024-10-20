/**
 * © Sirenum By Bullhorn 2024
 * PS-927 Scheduled Job to send Expiring Ticket notifications
 *
 * Creates sirenum__PushNotificationEvent__e Platform Events and updates Tickets with audit information when:
 * Tickets are 14 days (at time of writing) from expiry ...and/or...
 * Tickets are 0 days from expiry
 */

public class TicketReminderScheduler implements Schedulable{

    /**
     * Identifies Contacts/tickets which are applicable for Notifications and passes to batch to handle
     * creation of notifications and update of tickets
     *
     * @param context The Context of the schedulable class (not used by customisation)
     */
    public void execute(SchedulableContext context) {
        //Build List of ContactIds which require handling
        Set<Id> contactIds = new Set<Id>();
        AggregateResult[] aggregateResults = [
                SELECT sirenum__Owner__c, COUNT(Id)
                FROM sirenum__Ticket__c
                WHERE Show_in_TrialGo__c = TRUE
                AND (
                        (sirenum__Valid_until__c <= :Date.today().addDays(14) AND X14DayReminderSent__c = NULL)
                        OR
                        (sirenum__Valid_until__c <= :Date.today().addDays(1) AND LastDayReminderSent__c = NULL)
                )
                GROUP BY sirenum__Owner__c
        ];

        if (!aggregateResults.isEmpty()){
            for (AggregateResult ar : aggregateResults)  {
                contactIds.add((Id)ar.get('sirenum__Owner__c'));
            }

            //Use batch to deal with creation of platform events and update of tickets
            Database.executeBatch(
                    new TicketReminderBatch(contactIds),(Integer)TicketReminderSettingProvider.getSetting('default').Batch_Size__c
            );
        }

    }
}