//Trigger for ContactTriggerHandler
trigger Contact on Contact (before insert, before update, after update,after Insert){
    
    if( Label.ContactTrigger =='True' || Test.isRunningTest()){ 
        
        if(trigger.isBefore){ 
            
            if(trigger.isInsert){
                ContactTriggerHandler.stateMandatory(Trigger.new);
                ContactTriggerHandler.workCountryMandatory(Trigger.new);
                ContactTriggerHandler.ValidCompactLicence(Trigger.new);
            }
            
            if(trigger.isUpdate){
                ContactTriggerHandler.onboardingCompletionDateUpdate(Trigger.newMap, Trigger.oldMap);
                ContactTriggerHandler.stateMandatory(Trigger.new);
                ContactTriggerHandler.workCountryMandatory(Trigger.new);
                ContactTriggerHandler.ValidCompactLicence(Trigger.new);
                ContactTriggerHandler.updateTsWhenContactIsUpdated(Trigger.newMap,Trigger.oldMap);
            }
        }
        
        if(Trigger.isAfter){
            
            if(Trigger.isUpdate){
                ContactTriggerHandler.createPlacementRecord(Trigger.newMap, Trigger.oldMap);
                ContactTriggerHandler.updateUserEmail(Trigger.new, Trigger.oldMap);
                if(ContactTriggerHandler.sendTrainingStatusNotificationFlag){
                    ContactTriggerHandler.sendTrainingStatusNotification(Trigger.new, Trigger.oldMap);    
                }
                ContactTriggerHandler.createTicketRecordWhenCountryIsChanged(Trigger.newMap, Trigger.oldMap);
                ContactTriggerHandler.createTicketRecordWhenStateIsChanged(Trigger.newMap, Trigger.oldMap);
                ContactTriggerHandler.createTicketRecordOnJobTypeChange(Trigger.newMap,Trigger.oldMap);
                ContactTriggerHandler.createTicketForCompactLicense(Trigger.newMap,Trigger.oldMap);
                ContactTriggerHandler.inactiveContactProjectRecord(Trigger.newMap,Trigger.oldMap);
            }
            
            if(Trigger.isInsert){
                ContactTriggerHandler.createTicketRecordNewContactCreated(Trigger.newMap);
                ContactTriggerHandler.createContactProject(Trigger.newMap);
            }
        }
    }  
}