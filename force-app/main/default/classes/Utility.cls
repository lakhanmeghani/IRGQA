public class Utility {
    
    public Static Map<String, Id> recordTypeNameIdMap; 
    public static Map<String, Id> getRecordTypeIdNameMap(String objectAPIName){
        if(recordTypeNameIdMap == null){
            recordTypeNameIdMap = new Map<String, Id>();
            for(Schema.RecordTypeInfo recordType : Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getRecordTypeInfos()){
                recordTypeNameIdMap.put(recordType.getName(), recordType.getRecordTypeId());
            }
            return recordTypeNameIdMap;
        }
        else {
            return recordTypeNameIdMap;   
        }
    }  
}