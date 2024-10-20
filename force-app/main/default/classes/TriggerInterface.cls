public interface TriggerInterface {

    
    void beforeInsert(List<sObject> newList);
    void beforeUpdate(List<sObject> newList,List<sObject> oldList,Map<Id,sObject> newMap,Map<Id,sObject> oldMap);
    void beforeDelete(List<sObject> oldList,Map<Id,sObject> oldMap);
    
    void afterInsert(List<sObject> newList,Map<Id,sObject> newMap);
    void afterUpdate(List<sObject> newList,List<sObject> oldList,Map<Id,sObject> newMap,Map<Id,sObject> oldMap);
    void afterDelete(List<sObject> oldList,Map<Id,sObject> oldMap);
    void afterUndelete(List<sObject> newList,Map<Id,sObject> newMap);
    
}