/**
 * © Sirenum By Bullhorn 2024
 * PS-927 Scheduled Job to send Expiring Ticket notifications
 *
 * Provides settings for TicketReminderScheduler
 */

public with sharing class TicketReminderSettingProvider {
    private static Ticket_Reminder_Setting__mdt ticketReminderSetting;

    public static Ticket_Reminder_Setting__mdt getSetting(String name){
        Ticket_Reminder_Setting__mdt setting = ticketReminderSetting;
        if (setting == null){
            List<Ticket_Reminder_Setting__mdt> settings = [
                    SELECT Id, Batch_Size__c
                    FROM Ticket_Reminder_Setting__mdt
                    WHERE DeveloperName = :name
            ];

            ticketReminderSetting = !settings.isEmpty() ? settings[0] : new Ticket_Reminder_Setting__mdt(DeveloperName=name,Batch_Size__c=200);

            setting = ticketReminderSetting;
        }
        return setting;
    }
}