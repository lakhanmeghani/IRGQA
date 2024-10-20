public class PlacementTriggerHandler {
    
    //
    public static void setJobType (List <sirenum__Placement__c> placementList){
        List<sirenum__Team__c> visitType = [Select id , Name from sirenum__Team__c where name ='Test Visit Type'];
        for(sirenum__Placement__c pl:placementList){
            if(visitType != null){
                for(sirenum__Team__c jobrole:visitType){
                    pl.sirenum__Job_Role__c=jobrole.id;
                }
            }
        }
    }
    
    //
    public static void updateDateAndOffSiteActivities(List<sirenum__Placement__c> placementList){
        set<id> projectId = new set<id>();
        Map<Id,sirenum__Placement__c> projectPlacementMap=new Map<Id,sirenum__Placement__c>(); 
        for(sirenum__Placement__c pt:placementList){
            if(pt.sirenum__Contract__c != null){
                projectId.add(pt.sirenum__Contract__c);
                projectPlacementMap.put(pt.sirenum__Contract__c,pt);
            }    
        }
        List<sirenum__ProActiveContract__c > projectName = [select id, name,Work_Order_Final_Execution_Date__c,Illingworth_Work_Order_End_Date__c,Off_site_Activities__c from sirenum__ProActiveContract__c  where id IN :projectId];
        if(projectName.size()>0 ){
            for(sirenum__ProActiveContract__c project : projectName){
                {projectPlacementMap.get(project.Id).Study_Start_Date__c=project.Work_Order_Final_Execution_Date__c;
                 projectPlacementMap.get(project.Id).Study_End_Date__c=project.Illingworth_Work_Order_End_Date__c;
                 projectPlacementMap.get(project.Id).Scope_of_Service__c=project.Off_site_Activities__c;
                }
            }
        } 
    }
    
    //
    public static void deleteAssociatedAssignments(Map<Id,sirenum__Placement__c> newPlacementMap){
        List< sirenum__Assignment__c> deleteAssignmentList = [Select Id FROM sirenum__Assignment__c Where sirenum__Placement__c IN :newPlacementMap.keySet()];
        System.debug('Size '+deleteAssignmentList.size());
        Delete deleteAssignmentList;
    }
}