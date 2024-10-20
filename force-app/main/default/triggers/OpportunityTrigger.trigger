trigger OpportunityTrigger on Opportunity (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
   // if(TriggerSettings.runTrigger()){
    if(Org_Specific_Setting__mdt.getInstance('Run_All_Triggers')?.Value__c==true){
        TDispatch.TContext tc = new TDispatch.TContext(Trigger.isExecuting,Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isBefore, Trigger.isAfter,Trigger.isUndelete,
		Trigger.new,Trigger.newMap,Trigger.old,Trigger.oldMap,Trigger.size,'OpportunityTriggerHandler');
		TDispatch.dispatchTriggerHandler(tc);
    }
}