trigger assetAssignmentTrigger on Illingworth_Asset_Assignment__c (after insert, after update, before insert, before update) {
    if( Label.Asset_Assignment_Trigger_Flag =='True' || Test.isRunningTest() ) { 
        if(trigger.isBefore && (trigger.isInsert)){
            assetAssignmentTriggerHandler.populatedResource(trigger.new);
           assetAssignmentTriggerHandler.validationErrorsForResource(trigger.new,null);
        }
        if(trigger.isBefore && (trigger.isUpdate)){
            if(assetAssignmentTriggerHandler.fireError || test.IsRunningTest()){
                assetAssignmentTriggerHandler.updateEndDateOnAssmnt(Trigger.oldMap, Trigger.newMap);
            }
            assetAssignmentTriggerHandler.validationErrors(Trigger.oldMap, Trigger.newMap);
            assetAssignmentTriggerHandler.validationErrorsForResource(Trigger.new,Trigger.oldMap);
        }
    }
}