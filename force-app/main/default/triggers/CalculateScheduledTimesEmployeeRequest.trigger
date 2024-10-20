/**
 * Created by scott.nicol on 04/03/2024.
 */

trigger CalculateScheduledTimesEmployeeRequest on sirenum__Employee_Request__c (before insert, before update) {
    CalculateScheduledTimesHelper.HandleConversion(Trigger.oldMap, Trigger.new);
}