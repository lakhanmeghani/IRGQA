trigger AlertsTrigger on sirenum__Alert__c (before insert) {
    if( ( Label.LogEntry_Trigger_Flag =='True')){
        If(trigger.isInsert){
            If(trigger.isBefore){
                AlertsTriggerHandler.beforeInsertHandler(trigger.new);  
            }
        }  
    }
}