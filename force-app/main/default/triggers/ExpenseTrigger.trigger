trigger ExpenseTrigger on irg_Expense__c (before insert,before update,before delete) {
    
    if((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore){
        DutyAndExpenseTriggerHandler.updateExpenseOwner(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            DutyAndExpenseTriggerHandler.populateExpenseSheetTitle(Trigger.new);            
        }
    }    
    
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            DutyAndExpenseTriggerHandler.preventLockedExpenses(Trigger.old);
        }
    }    
}