public class ProjectTriggerHandler {
    
    public static void updateDateAndOffSiteActivitiesUpdate(Map<Id,sirenum__ProActiveContract__c> newProMap , Map<Id,sirenum__ProActiveContract__c> oldProMap ){
        set<id> projectId = new set<id>();
        List<sirenum__Placement__c> updatePlacementList = new List<sirenum__Placement__c>();
        for(Id project:newProMap.keySet()){
            if(newProMap.get(project).Work_Order_Final_Execution_Date__c != oldProMap.get(project).Work_Order_Final_Execution_Date__c
               || newProMap.get(project).Illingworth_Work_Order_End_Date__c != oldProMap.get(project).Illingworth_Work_Order_End_Date__c
               || newProMap.get(project).Off_site_Activities__c != oldProMap.get(project).Off_site_Activities__c|| newProMap.get(project).Name != oldProMap.get(project).Name) 
              {
                projectId.add(project);  
              }
        }
        if(projectId.size()>0){
            for(sirenum__Placement__c placement : [select id, name,sirenum__Contract__r.name,sirenum__Contract__c,sirenum__Status__c,sirenum__Site__r.Name,sirenum__Site__r.Site_Number__c,Project_Placement__c from sirenum__Placement__c where sirenum__Contract__c =: projectId ] ){
                placement.Study_Start_Date__c=newProMap.get(placement.sirenum__Contract__c).Work_Order_Final_Execution_Date__c;
                placement.Study_End_Date__c=newProMap.get(placement.sirenum__Contract__c).Illingworth_Work_Order_End_Date__c;
                if(placement.Project_Placement__c==null){
                   placement.Name=newProMap.get(placement.sirenum__Contract__c).Name +'  -  Placement '; 
                }
                else{
                    placement.Name=newProMap.get(placement.sirenum__Contract__c).Name +'  / Site- '+placement.sirenum__Site__r.Site_Number__c +' - Placement ';
                    
                }
                updatePlacementList.add(placement);
                
                    
            }
            
            if(updatePlacementList.size()>0){
                update updatePlacementList;
            }
        }
        
    }

}