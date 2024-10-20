trigger DutyTrigger on Duty__c (before insert,before update, before delete) {
    
    if((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore){
        DutyAndExpenseTriggerHandler.updateDutyOwner(Trigger.new,Trigger.OldMap);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        DutyAndExpenseTriggerHandler.dutyDateValidation(Trigger.new,Trigger.OldMap);
    }
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            DutyAndExpenseTriggerHandler.preventLockedDuties(Trigger.old);
        }
    }
}