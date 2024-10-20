trigger LogEntryTrigger on sirenum__LogEntry__c (before insert, after insert,before update, after update,before delete, after delete){
    
    if( ( Label.LogEntry_Trigger_Flag =='True')){
        if(UserInfo.getUserId() != label.Bypass_Trigger_To_Run_Batches){
            
            If(trigger.isInsert){
                
                If(trigger.isBefore){
                    LogEntryTriggerHandler.beforeInsertHandler(trigger.new);  
                }
            }    
        }
    }
}