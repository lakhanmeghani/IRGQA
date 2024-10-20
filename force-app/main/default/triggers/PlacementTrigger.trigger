trigger PlacementTrigger on sirenum__Placement__c (before insert, before delete) {
    if( Label.Placement_Trigger =='True' || Test.isRunningTest() ){
        if(trigger.isBefore){
            
            if(trigger.isInsert){
                PlacementTriggerHandler.setJobType(Trigger.new);
                PlacementTriggerHandler.updateDateAndOffSiteActivities(Trigger.new);
            }
            if(trigger.isDelete){
                PlacementTriggerHandler.deleteAssociatedAssignments(Trigger.oldMap);
            }
        }
    }
}