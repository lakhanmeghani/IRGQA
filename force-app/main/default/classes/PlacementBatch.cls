global class PlacementBatch implements Database.Batchable<SObject>, Database.Stateful,Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = Date.today();
        
        String q = 'Select Id, name,sirenum__Status__c,Reason_for_Completion__c,sirenum__End_Date__c,(Select Id,sirenum__Status__c, Reason_for_Completion__c,sirenum__End_Date__c from Placements__r where Parent_Child__c = \'Child\' AND sirenum__Status__c != \'Completed\') from sirenum__Placement__c where Parent_Child__c = \'Parent\' AND sirenum__Status__c != \'Completed\' ';
        return Database.getQueryLocator(q);
    }
    
    global void execute(Database.BatchableContext BC, List<sirenum__Placement__c> scope) {
        List<sirenum__Placement__c> updatePlacements = new List<sirenum__Placement__c>();
        
        for(sirenum__Placement__c placement : scope){
            Boolean allAdded = true;
            List<sirenum__Placement__c> placementChildren = new List<sirenum__Placement__c> ();
            for(sirenum__Placement__c child : placement.Placements__r){
                
                if(child.Reason_for_Completion__c != null && child.sirenum__End_Date__c <= System.Today() && child.sirenum__Status__c != 'Completed'){
                    child.sirenum__Status__c = 'Completed';
                    placementChildren.add(child);
                }else{
                    allAdded = false; 
                }
            }
            updatePlacements.addAll(placementChildren);
         
            if(allAdded && placement.Reason_for_Completion__c != null && placement.sirenum__End_Date__c <= System.Today() && placement.sirenum__Status__c != 'Completed'){
                placement.sirenum__Status__c = 'Completed';
                updatePlacements.add(placement);
            }
            
        }
        
        if(!updatePlacements.isEmpty()){
            update updatePlacements;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    public void execute(SchedulableContext sc){
        PlacementBatch batch = new PlacementBatch();
        Database.executebatch(batch, 50);
    }
}