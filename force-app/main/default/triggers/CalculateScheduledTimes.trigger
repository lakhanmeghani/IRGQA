/**
 * IRG2-80 Provide a mechanism of converting between a date & time (in Shift.Site timezone) and UTC
 */

trigger CalculateScheduledTimes on sirenum__Shift__c (before insert, before update) {
    CalculateScheduledTimesHelper.HandleConversion(Trigger.oldMap, Trigger.new);
}