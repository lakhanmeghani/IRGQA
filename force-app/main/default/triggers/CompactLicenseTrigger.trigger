trigger CompactLicenseTrigger on Compact_Licence__c (before insert, after insert){
    
    if(label.CompactLicenseTriggerflag == 'True' || Test.isRunningTest()){
        
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                CompactLicenseTriggerHandler.updateNewWorkStateRelatedTicket(Trigger.new); 
            }
        }
    }
}