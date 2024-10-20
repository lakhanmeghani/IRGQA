/*
 * Copyright Sirenum (c) 2021.
 */
/**
 * Utilities for manual sharing
 */
public without sharing class SharingUtils {

    /**
     * Manually share shifts with queues that own the corresponding project teams.
     *
     * @param shiftIdsToShare Ids of shifts to share with queues
     */
    public static void shareShiftsWithProject(List<Id> shiftIdsToShare) {

        // Remove existing manual shares for these shifts
        delete [SELECT Id FROM sirenum__Shift__Share WHERE ParentId IN :shiftIdsToShare AND RowCause = 'Manual'];

        // Get project teams for shifts
        List<sirenum__Shift__c> shifts = [
                SELECT Id,
                        sirenum__Contract__c,
                        sirenum__Contract__r.Project_Team__c,
                        sirenum__Contract__r.Project_Team__r.OwnerId
                FROM sirenum__Shift__c
                WHERE Id IN :shiftIdsToShare
        ];

        // Share shifts with groups
        List<sirenum__Shift__Share> shiftShares = new List<sirenum__Shift__Share>();
        for (sirenum__Shift__c shift : shifts) {
            System.debug('Shift:'+ shift);
            System.debug(shift.sirenum__Contract__r.Project_Team__c);
            System.debug('Project_Team__r.OwnerId'+shift.sirenum__Contract__r.Project_Team__r.OwnerId);
            if (shift.sirenum__Contract__c != null &&
                    shift.sirenum__Contract__r.Project_Team__c != null &&
                    shift.sirenum__Contract__r.Project_Team__r.OwnerId != UserInfo.getUserId()) {
                shiftShares.add(new sirenum__Shift__Share(
                        ParentId = shift.Id,
                        UserOrGroupId = shift.sirenum__Contract__r.Project_Team__r.OwnerId,
                        AccessLevel = 'Edit',
                        RowCause = 'Manual'
                ));
            }
        }

        // Insert shares
        if (!shiftShares.isEmpty() && !Test.isRunningTest()) {
            insert shiftShares;
        }
    }
}