trigger TaskTrigger on Task (before insert, before update, after insert, after update, after delete) {
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        TaskTriggerHandler.checkTaskCount(trigger.new,Trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isInsert){
        TaskTriggerHandler.updateFieldsOnTask(trigger.new);
    }
    if(trigger.isAfter && trigger.isDelete){
        TaskTriggerHandler.checkTaskCount(trigger.old,Trigger.oldMap);
    } 
}