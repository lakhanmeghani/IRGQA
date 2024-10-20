public class TurnAroundTimeHandler {
    public static boolean tatFlag = true;
    
    public static void creatResourcingStatusTat(Map<Id, sirenum__Shift__c> newVisitMap, Map<Id, sirenum__Shift__c> oldVisitMap){
        calculateFieldValueChangeTime(newVisitMap, oldVisitMap, 'Visit__c', 'Resourcing_Status__c', 'Pending Resource Allocation');
    }
    
    //Resourcing_Status__c
    public static void calculateFieldValueChangeTime(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, 
                                                     String objectAPIName, String fieldAPIName, String startFieldValue){
                                                         Set<String> allRecordFieldValuesSet = new Set<String>();
                                                         Id resRequestRecordTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
                                                         if(oldMap != null){
                                                             System.debug('old Map '+oldMap);
                                                             for(SObject loopRecord : oldMap.values()){
                                                                 System.debug('old Map loopRecord '+loopRecord);
                                                                 if((loopRecord.get(fieldAPIName) != newMap.get(loopRecord.Id).get(fieldAPIName)) && (resRequestRecordTypeId == loopRecord.get('RecordTypeId'))) 
                                                                     allRecordFieldValuesSet.add((String)loopRecord.get(fieldAPIName));    
                                                             }    
                                                         }
                                                         
                                                         Set<String> fromFieldValueSet = new Set<String>();
                                                         List<TAT_Field_Setting__mdt> tatFieldSettingList = new List<TAT_Field_Setting__mdt>();
                                                         String tatFieldSettingQuery = 'SELECT Id, Object__c, To__c, From__c, Calculated_TAT_Field__c, Include_Multiple_Status__c'+ 
                                                             +' FROM TAT_Field_Setting__mdt WHERE Object__c = :objectAPIName';
                                                         for(TAT_Field_Setting__mdt loopTatMdt : database.query(tatFieldSettingQuery)){ 
                                                             if(loopTatMdt.Include_Multiple_Status__c == true) fromFieldValueSet.add(loopTatMdt.From__c);
                                                             tatFieldSettingList.add(loopTatMdt);
                                                         }
                                                         Map<Id, Map<String, Turn_Around_Time__c>> latestFieldValueTatMap = new Map<Id, Map<String, Turn_Around_Time__c>>();
                                                         Map<Id, Map<String, Turn_Around_Time__c>> oldestFieldValueTatMap = new Map<Id, Map<String, Turn_Around_Time__c>>();
                                                         
                                                         if(oldMap != null && !allRecordFieldValuesSet.isEmpty()){
                                                             Set<Id> oldKeySet = new Set<Id>();
                                                             oldKeySet.addAll(oldMap.keySet());
                                                             String latestTatQuery = 'SELECT Id, New_Status__c, Previous_Status__c, Changed_Date__c, Visit__c'+
                                                                 +' FROM Turn_Around_Time__c'+
                                                                 +' WHERE '+objectAPIName+' IN :oldKeySet'+
                                                                 +' AND New_Status__c = :allRecordFieldValuesSet'+
                                                                 +' Order By Changed_Date__c DESC';
                                                             for(Turn_Around_Time__c loopTat : database.query(latestTatQuery)){
                                                                 if(loopTat != null){
                                                                     if(!latestFieldValueTatMap.containsKey((String)loopTat.get(objectAPIName))){
                                                                         Map<String, Turn_Around_Time__c> statusTatMap = new Map<String, Turn_Around_Time__c>();
                                                                         statusTatMap.put(loopTat.New_Status__c, loopTat);
                                                                         latestFieldValueTatMap.put((String)loopTat.get(objectAPIName), statusTatMap);
                                                                     }
                                                                     else if(!latestFieldValueTatMap.get((String)loopTat.get(objectAPIName)).containsKey(loopTat.New_Status__c)){
                                                                         latestFieldValueTatMap.get((String)loopTat.get(objectAPIName)).put(loopTat.New_Status__c, loopTat);     
                                                                     }                                   
                                                                 } 
                                                             }
                                                             
                                                             String oldestTatQuery = 'SELECT Id, New_Status__c, Previous_Status__c, Changed_Date__c, Visit__c'+
                                                                 +' FROM Turn_Around_Time__c'+
                                                                 +' WHERE '+objectAPIName+' IN :oldKeySet'+
                                                                 +' AND New_Status__c = :fromFieldValueSet'+
                                                                 +' Order By Changed_Date__c ASC';
                                                             for(Turn_Around_Time__c loopTat : database.query(oldestTatQuery)){
                                                                 if(!oldestFieldValueTatMap.containsKey((String)loopTat.get(objectAPIName))){
                                                                     Map<String, Turn_Around_Time__c> statusTatMap = new Map<String, Turn_Around_Time__c>();
                                                                     statusTatMap.put(loopTat.New_Status__c, loopTat);
                                                                     oldestFieldValueTatMap.put((String)loopTat.get(objectAPIName), statusTatMap);
                                                                 }
                                                                 else if(!oldestFieldValueTatMap.get((String)loopTat.get(objectAPIName)).containsKey(loopTat.New_Status__c)){
                                                                     oldestFieldValueTatMap.get((String)loopTat.get(objectAPIName)).put(loopTat.New_Status__c, loopTat);     
                                                                 } 
                                                             }
                                                         }
                                                         
                                                         List<Turn_Around_Time__c> newInsertTatList = new List<Turn_Around_Time__c>();
                                                         for(SObject loopRecord : newMap.values()){
                                                             System.debug('Inside loopRecord -->'+loopRecord.get(fieldAPIName));
                                                             if((oldMap == null || (oldMap != null && loopRecord.get(fieldAPIName) != oldMap.get(loopRecord.Id).get(fieldAPIName))) && (resRequestRecordTypeId == loopRecord.get('RecordTypeId'))){
                                                                
                                                                 Turn_Around_Time__c newTat = new Turn_Around_Time__c();
                                                                 newTat.Changed_Date__c = System.now(); 
                                                                 newTat.put(objectAPIName, loopRecord.Id);
                                                                 newTat.New_Status__c = (oldMap == null) ? startFieldValue : (String)loopRecord.get(fieldAPIName);            
                                                                 if(oldMap != null && oldMap.containsKey(loopRecord.Id)){
                                                                     newTat.Previous_Status__c = (String)(oldMap.get(loopRecord.Id)).get(fieldAPIName);
                                                                     for(TAT_Field_Setting__mdt loopTatMdt : tatFieldSettingList){
                                                                         if(loopTatMdt.Include_Multiple_Status__c == true && loopTatMdt.To__c == newTat.New_Status__c){
                                                                             Turn_Around_Time__c oldestTat = oldestFieldValueTatMap?.get(loopRecord.Id)?.get(loopTatMdt.From__c);
                                                                             System.debug('Inside If oldestTat '+oldestTat+'-- newTat  -- '+newTat);
                                                                             Decimal totalTimeSeconds;
                                                                             if(oldestTat != null){
                                                                                 totalTimeSeconds = ((newTat.Changed_Date__c.getTime() - oldestTat?.Changed_Date__c?.getTime())/1000);    
                                                                             }
                                                                             else {
                                                                                 totalTimeSeconds = (newTat.Changed_Date__c.getTime())/1000;   
                                                                             }
                                                                             loopRecord.put(loopTatMdt.Calculated_TAT_Field__c, formatTime(totalTimeSeconds));	   
                                                                         }
                                                                         else if(loopTatMdt.From__c == newTat.Previous_Status__c && loopTatMdt.To__c == newTat.New_Status__c){
                                                                             System.debug('Inside else if --> Previous '+newTat.Previous_Status__c+'  new '+newTat.New_Status__c);
                                                                             Turn_Around_Time__c previousTat = (latestFieldValueTatMap.get(loopRecord.Id) != null) ? latestFieldValueTatMap.get(loopRecord.Id).get(newTat.Previous_Status__c) : null;
                                                                             if(previousTat != null){
                                                                             	Decimal currentTotalTime = (loopRecord.get(loopTatMdt.Calculated_TAT_Field__c) != null) ? convertTimeStringToDecimal((String)loopRecord.get(loopTatMdt.Calculated_TAT_Field__c)) : 0;
                                                                                 system.debug('Existing converted time  -- '+currentTotalTime);
                                                                                 Decimal newTatTime = newTat.Changed_Date__c.getTime()/1000;
                                                                                 Decimal previousTime = previousTat.Changed_Date__c.getTime()/1000;
                                                                                 Decimal totalTimeSeconds = ((newTat.Changed_Date__c.getTime() - previousTat.Changed_Date__c.getTime())/1000); 
                                                                                 System.debug('totalTimeSeconds --> '+totalTimeSeconds);
                                                                                 Decimal totalTime = (currentTotalTime != null)?
                                                                                     (currentTotalTime + totalTimeSeconds) : totalTimeSeconds;
                                                                                 System.debug('totalTime '+totalTime);
                                                                                 String formatedTime = formatTime(totalTime);
                                                                                 System.debug('formatedTime '+formatedTime);
                                                                                 loopRecord.put(loopTatMdt.Calculated_TAT_Field__c, formatedTime);   
                                                                             }    
                                                                         }    
                                                                     }            
                                                                 }
                                                                 System.debug('before List '+newTat);
                                                                 newInsertTatList.add(newTat);  
                                                             }    
                                                         }
                                                         
                                                         if(!newInsertTatList.isEmpty()){
                                                             System.debug('newInsertTatList '+newInsertTatList);
                                                             tatFlag = false;
                                                             insert newInsertTatList;  
                                                         } 
                                                     }
    
    private Static String formatTime(Decimal totalTimeSeconds){
        Integer days = Integer.valueOf(totalTimeSeconds/(60*60*24));
        Integer hours = Integer.valueOf((totalTimeSeconds -(days*60*60*24))/(60*60));
        //Integer mins = Integer.valueOf((totalTimeSeconds -(days*60*60*24)-(hours*60*60))/(60));
        //String formattedTime = days+' Days '+hours+' Hours '+mins+' Minutes';
        String formattedTime = days+' Days '+hours+' Hours ';
        return formattedTime;
    }
    
    private Static Decimal convertTimeStringToDecimal(String currentTime){
        List<String> splittedList = currentTime.split(' ');
        Decimal daySeconds = (Decimal.valueOf(splittedList[0])*24*60*60);
        Decimal hourSeconds = (Decimal.valueOf(splittedList[2])*60*60);
        //Decimal minuteSeconds = (Decimal.valueOf(splittedList[4])*60);
        //return daySeconds+hourSeconds+minuteSeconds;
        return daySeconds+hourSeconds;
    }
}