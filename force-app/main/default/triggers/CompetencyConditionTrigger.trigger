trigger CompetencyConditionTrigger on sirenum__Sirenum_Condition_Membership__c (before insert,after update,before update) {
    
    if( Label.Competency_Condition_trigger_Flag =='True' || Test.isRunningTest()){
        
        if(trigger.isBefore ){
            if(trigger.isInsert){
                CompetencyConditionTriggerHandler.checkUniqueCompetency(trigger.new);
                CompetencyConditionTriggerHandler.polpulateLocationOnCreation(Trigger.new);
                CompetencyConditionTriggerHandler.validationforNonProjectMembers(trigger.new);
            }
            else if(trigger.isUpdate){
                CompetencyConditionTriggerHandler.polpulateLocationOnUpdation(trigger.newMap,trigger.oldMap);
            }
        }
        
        else if(trigger.isAfter && trigger.isUpdate){
            CompetencyConditionTriggerHandler.validationforNonProjectMembers(trigger.new);
            CompetencyConditionTriggerHandler.updateTSAndPTS(trigger.newMap,trigger.oldMap);
            CompetencyConditionTriggerHandler.updateTSAndPTSWhenLookupChanges(trigger.newMap,trigger.oldMap);
        }
    }
}