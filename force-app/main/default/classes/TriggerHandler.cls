public interface TriggerHandler {
	void beforeInsert(List<SObject> newRecords);
    void beforeUpdate(List<SObject> oldRecords,List<SObject> newRecords,Map<Id,SObject>oldRecordMap,Map<Id,SObject>newRecordMap);
    void beforeDelete(List<SObject> oldRecords,Map<Id,SObject>oldRecordMap);
    void afterInsert(List<SObject> newRecords,Map<Id,SObject>newRecordMap);
    void afterUpdate(List<SObject> oldRecords,List<SObject>newRecords,Map<Id,SObject>oldRecordMap,Map<Id,SObject>newRecordMap);
    void afterDelete(List<SObject> oldRecords,Map<Id,SObject>oldRecordMap);
    void afterUndelete(List<SObject> newRecords,Map<Id,SObject>newRecordMap);
}