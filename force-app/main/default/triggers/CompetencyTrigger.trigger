//Trigger for CompetencyTriggerHandler 
trigger CompetencyTrigger on sirenum__TicketType__c (before insert,before update,after update,after insert){
    
    if( Label.CompetencyTrigger =='True' || Test.isRunningTest()){ 
        
        if(trigger.isBefore){
            if(trigger.isInsert){
                CompetencyTriggerHandler.validationforNonProjectMembers(Trigger.new);
                CompetencyTriggerHandler.setCompetencyCourseTitle(Trigger.new);
                CompetencyTriggerHandler.stateMandatory(Trigger.new);
                CompetencyTriggerHandler.workCountryMandatory(Trigger.new);
            }
            if(trigger.isupdate){
                CompetencyTriggerHandler.checkExpires(Trigger.new);
                CompetencyTriggerHandler.stateMandatory(Trigger.new);
                CompetencyTriggerHandler.workCountryMandatory(Trigger.new);
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                CompetencyTriggerHandler.createCompConditionOnNewCompetancyCreation(Trigger.newMap,Null);
                CompetencyTriggerHandler.createCompConditionOnNewStateCompetancyCreation(Trigger.newMap,null);
                CompetencyTriggerHandler.createTicketOnNewCompetancyCreation(Trigger.newMap);
                CompetencyTriggerHandler.createTicketforJobType(Trigger.newMap,null);
            }
            if(trigger.isupdate){
                CompetencyTriggerHandler.validationforNonProjectMembers(Trigger.new);
                CompetencyTriggerHandler.createCompConditionOnNewCompetancyCreation(Trigger.newMap,Trigger.oldMap);
                CompetencyTriggerHandler.createCompConditionOnNewStateCompetancyCreation(Trigger.newMap,Trigger.oldMap);
                CompetencyTriggerHandler.createTicketforJobType(Trigger.newMap,Trigger.oldMap);
                CompetencyTriggerHandler.createCompetencyConditionForProjectTrainingComp(Trigger.newMap,Trigger.oldMap);
            }
        }
    }
}