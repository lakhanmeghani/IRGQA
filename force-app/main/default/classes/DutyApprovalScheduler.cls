/**
 * Copyright © Sirenum by bullhorn 2024
 * PS-947 Scheduled process to examine and approve Duties related to Shifts
 * PS-963 Extended to examine and approve duties related to Projects
 *
 * This is intended to be run by the platform on a schedule, but can be manually called using the following:
 * new DutyApprovalScheduler().execute(null);
 */

public class DutyApprovalScheduler implements Schedulable {

    /**
     * Identifies Duties (for Shifts/ Projects) which should be examined for automatic approval, and passes to batch class
     * to handle checks and approvals.
     *
     * @param context the Context of the schedulable class (not used by customisation)
     */
    public void execute(SchedulableContext context) {
        //Build list of Shift Ids which require handling
        Set<Id> shiftIds = new Set<Id>();
        AggregateResult[] aggregateResultsByShift = [
                SELECT Visit__c, COUNT(Id)
                FROM Duty__c
                WHERE Status__c = 'Submitted'
                AND Manual_Review_Required__c = FALSE
                AND Visit__c != NULL
                AND Deleted_by_Worker__c = FALSE
                AND Relates_To__c  = 'Visit_Type'
                GROUP BY Visit__c
        ];

        //If there are Visit Duties to handle, handle them
        if (!aggregateResultsByShift.isEmpty()){
            for (AggregateResult ar : aggregateResultsByShift){
                shiftIds.add((Id)ar.get('Visit__c'));
            }

            Database.executeBatch(
                    new DutyApprovalBatch(shiftIds, 'sirenum__Shift__c'),(Integer)DutyApprovalSettingProvider.getSetting('default').Batch_Size__c
            );
        }

        //Build list of Project Ids which require handling
        Set<Id> projectIds = new Set<Id>();
        AggregateResult[] aggregateResultsByProject = [
                SELECT Project__c, COUNT(Id)
                FROM Duty__c
                WHERE Status__c = 'Submitted'
                AND Manual_Review_Required__c = FALSE
                AND Visit__c = NULL
                AND Project__c != NULL
                AND Deleted_by_Worker__c = FALSE
                AND Relates_To__c  = 'Project'
                GROUP BY Project__c
        ];

        //If there are Project Duties to handle, handle them
        if (!aggregateResultsByProject.isEmpty()){
            for (AggregateResult ar : aggregateResultsByProject){
                projectIds.add((Id)ar.get('Project__c'));
            }

            Database.executeBatch(
                    new DutyApprovalBatch(projectIds, 'sirenum__ProActiveContract__c'),(Integer)DutyApprovalSettingProvider.getSetting('default').Batch_Size__c
            );
        }
    }
}