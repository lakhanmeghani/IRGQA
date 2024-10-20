public class AccountHandler implements TriggerInterface{

    public void beforeInsert(List<sObject> newList){}
    public void beforeUpdate(List<sObject> newList,List<sObject> oldList,Map<Id,sObject> newMap,Map<Id,sObject> oldMap){}
    public void beforeDelete(List<sObject> oldList,Map<Id,sObject> oldMap){}
    
    public void afterInsert(List<sObject> newList,Map<Id,sObject> newMap){}
    public void afterUpdate(List<sObject> newList,List<sObject> oldList,Map<Id,sObject> newMap,Map<Id,sObject> oldMap){}
    public void afterDelete(List<sObject> oldList,Map<Id,sObject> oldMap){}
    public void afterUndelete(List<sObject> newList,Map<Id,sObject> newMap){}
}