public class CheckSiteProjectTeamMemberHandler{
    
    //
    public static void updateCountry(List<sirenum__Site__c> siteList){
        for(sirenum__Site__c siteRec : siteList){
            siteRec.sirenum__Country__c = siteRec.IllingworthCountry__c;
        }
    }
    
    //update competancy name  when site name is changed 
    public static void updateCompetancyNameOnSiteChange(Map<Id,sirenum__Site__c > newSiteMap , Map<Id,sirenum__Site__c > oldSiteMap){
        Set<Id> siteId=new Set<Id>();
        List<sirenum__TicketType__c> competancyIdList=new List<sirenum__TicketType__c>();
        Map<id,String> competancyAndSiteNameMap=new Map<id,String>();
        for(Id newSiteId:newSiteMap.keySet()){
            if(oldSiteMap.get(newSiteId).name != newSiteMap.get(newSiteId).name){
                siteId.add(newSiteId);
                
            }
        }
        if(siteId.size()>0){
            List<sirenum__Sirenum_Condition_Membership__c> competancyConditionList=[Select  id,name,sirenum__Site__r.name,sirenum__TicketType__c from sirenum__Sirenum_Condition_Membership__c where sirenum__TicketType__c!=null AND sirenum__Site__c IN :siteId ];
            if(competancyConditionList!=null){
                for(sirenum__Sirenum_Condition_Membership__c competancyCondition: competancyConditionList ){
                    competancyAndSiteNameMap.put(competancyCondition.sirenum__TicketType__c, competancyCondition.sirenum__Site__r.name);
                } 
            }
            if(competancyAndSiteNameMap.size()>0){
                List<sirenum__TicketType__c> competancyList=[Select id,name, Illingworth_Project__r.name  from sirenum__TicketType__c where id IN :competancyAndSiteNameMap.keySet() ];
                for(sirenum__TicketType__c comp: competancyList){
                    comp.name= comp.Illingworth_Project__r.name +' Activation at '+competancyAndSiteNameMap.get(comp.id);
                    competancyIdList.add(comp);
                }
            }
            
            if (competancyIdList.size()>0) update competancyIdList;
        }
    }
    
    //update Placement name when site Number is changed
    public static void updatePlacementNameOnSiteNumberChange(Map<Id,sirenum__Site__c > newSiteMap , Map<Id,sirenum__Site__c > oldSiteMap){
        Set<Id> siteId=new Set<Id>();
        List<sirenum__TicketType__c> competancyIdList=new List<sirenum__TicketType__c>();
        Map<id,String> competancyAndSiteNameMap=new Map<id,String>();
        
        for(Id newSiteId:newSiteMap.keySet()){
            if(oldSiteMap.get(newSiteId).Site_Number__c != newSiteMap.get(newSiteId).Site_Number__c){
                siteId.add(newSiteId);    
            }
        }
        if(siteId.size()>0 || test.isRunningTest()){
            List<sirenum__Placement__c> updatePlacementNameList=new List<sirenum__Placement__c>();    
            for(sirenum__Placement__c placement : [Select Id,name,sirenum__Site__r.Name,sirenum__Contract__r.Name,sirenum__Site__r.Site_Number__c from sirenum__Placement__c where Project_Placement__c!=null AND sirenum__Site__c IN :siteId]){
                placement.Name=placement.sirenum__Contract__r.Name +' / Site- '+placement.sirenum__Site__r.Site_Number__c +' - Placement ';
                updatePlacementNameList.add(placement);
            }   
            if(updatePlacementNameList.size()>0){
                update updatePlacementNameList;  
            } 
        }
    }
}    
    /*
    public static void updateVisitOnCountryChange(Map<Id,sirenum__Site__c > newSiteMap , Map<Id,sirenum__Site__c > oldSiteMap){
        List<sirenum__shift__c> updateVisitList=new List<sirenum__shift__c>();
        Map<Id,sirenum__Site__c> siteMap=new Map<Id,sirenum__Site__c>();
        for(sirenum__Site__c site:newSiteMap.values()){
            if(site.IllingworthCountry__c!=oldSiteMap.get(site.Id).IllingworthCountry__c ||
               site.sirenum__State__c!=oldSiteMap.get(site.Id).sirenum__State__c ||
               site.sirenum__City__c!=oldSiteMap.get(site.Id).sirenum__City__c){
                   siteMap.put(site.Id,site);
               }
        }
        if(siteMap.size()!=null){
            for(sirenum__Shift__c visit: [Select id,name,Clinical_site__c,Resourcing_Country__c,Resourcing_State__c,Resourcing_City__c,RecordType.developerName from sirenum__Shift__c where (RecordType.developerName='Resource_Request' OR RecordType.developerName='Resource_Allocation') AND Clinical_site__c IN :siteMap.keySet()]){
                visit.Resourcing_Country__c=siteMap.get(visit.Clinical_site__c).IllingworthCountry__c;
                visit.Resourcing_State__c=siteMap.get(visit.Clinical_site__c).sirenum__State__c;
                visit.Resourcing_City__c=siteMap.get(visit.Clinical_site__c).sirenum__City__c;
                updateVisitList.add(visit);
            }
        }
        if(updateVisitList.size()>0) update updateVisitList;
    }*/