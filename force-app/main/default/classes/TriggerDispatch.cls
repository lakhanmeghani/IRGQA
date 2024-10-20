public class TriggerDispatch {

    public  void dispatch(String handler,String objectName){
        
        if(TriggerSettings__mdt.getInstance('AllTriggers').Running__c && TriggerSettings__mdt.getInstance(objectName)?.Running__c){
            
            Type handlerClass = Type.forName(handler);
            TriggerInterface triggerHandler = (TriggerInterface)handlerClass.newInstance();
            
            switch on Trigger.operationType{
            when BEFORE_INSERT{
                triggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE{
               triggerHandler.beforeUpdate(Trigger.old,Trigger.new,Trigger.oldMap,Trigger.newMap);
            }
            when BEFORE_DELETE{
               triggerHandler.beforeDelete(Trigger.old,Trigger.oldMap);
            }
            when AFTER_INSERT{
               triggerHandler.afterInsert(Trigger.new,Trigger.newMap);
            }
            when AFTER_UPDATE{
                triggerHandler.afterUpdate(Trigger.old,Trigger.new,Trigger.oldMap,Trigger.newMap);
            }
            when AFTER_DELETE{
                triggerHandler.afterDelete(Trigger.old,Trigger.oldMap);
            }
            when AFTER_UNDELETE{
                triggerHandler.afterUndelete(Trigger.new,Trigger.newMap);
            }
        }        
        }
    }
}