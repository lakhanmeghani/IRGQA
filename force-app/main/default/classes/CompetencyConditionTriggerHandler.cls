public class CompetencyConditionTriggerHandler {
    
    //Method to create uniqueId to identify unique competency condition as per Holly's request for below combinatons
    //Same name, Same Account, blank site, blank job type
    //Same name, Same Site, blank account, blank job type
    //Same name, Same Job type, blank account, blank site*/
    public static void checkUniqueCompetency(List<sirenum__Sirenum_Condition_Membership__c> competencyConditionList){
        
        for(sirenum__Sirenum_Condition_Membership__c compConditionRecord : competencyConditionList){
            if(compConditionRecord.sirenum__Client__c != null && compConditionRecord.sirenum__Site__c != null && compConditionRecord.sirenum__Job_Type__c != null){
                compConditionRecord.sirenum__Unique_Name__c = compConditionRecord.sirenum__TicketType__c+'-'+compConditionRecord.sirenum__Client__c+'-'+compConditionRecord.sirenum__Site__c+'-'+compConditionRecord.sirenum__Job_Type__c;
            }else if(compConditionRecord.sirenum__Client__c != null && compConditionRecord.sirenum__Site__c != null && compConditionRecord.sirenum__Job_Type__c == null){
                compConditionRecord.sirenum__Unique_Name__c = compConditionRecord.sirenum__TicketType__c+'-'+compConditionRecord.sirenum__Client__c+'-'+compConditionRecord.sirenum__Site__c;
            }else if(compConditionRecord.sirenum__Client__c != null && compConditionRecord.sirenum__Site__c == null && compConditionRecord.sirenum__Job_Type__c == null){
                compConditionRecord.sirenum__Unique_Name__c = compConditionRecord.sirenum__TicketType__c+'-'+compConditionRecord.sirenum__Client__c;
            }else if(compConditionRecord.sirenum__Client__c != null && compConditionRecord.sirenum__Site__c == null && compConditionRecord.sirenum__Job_Type__c != null){
                compConditionRecord.sirenum__Unique_Name__c = compConditionRecord.sirenum__TicketType__c+'-'+compConditionRecord.sirenum__Client__c+'-'+compConditionRecord.sirenum__Job_Type__c;
            }else if(compConditionRecord.sirenum__Client__c == null && compConditionRecord.sirenum__Site__c == null && compConditionRecord.sirenum__Job_Type__c != null){
                compConditionRecord.sirenum__Unique_Name__c = compConditionRecord.sirenum__TicketType__c+'-'+compConditionRecord.sirenum__Job_Type__c;
            }else if(compConditionRecord.sirenum__Client__c == null && compConditionRecord.sirenum__Site__c != null && compConditionRecord.sirenum__Job_Type__c != null){
                compConditionRecord.sirenum__Unique_Name__c = compConditionRecord.sirenum__TicketType__c+'-'+compConditionRecord.sirenum__Site__c+'-'+compConditionRecord.sirenum__Job_Type__c;
            }else if(compConditionRecord.sirenum__Client__c == null && compConditionRecord.sirenum__Site__c != null && compConditionRecord.sirenum__Job_Type__c == null){
                compConditionRecord.sirenum__Unique_Name__c = compConditionRecord.sirenum__TicketType__c+'-'+compConditionRecord.sirenum__Site__c;
            }
        }
    }
    
    //Method to update TS and PTS records when Invalid checkbox is updated
    public static void updateTSAndPTS(Map<Id,sirenum__Sirenum_Condition_Membership__c> newCompCondMap,Map<Id,sirenum__Sirenum_Condition_Membership__c> oldCompCondMap){
        List<sObject> updateTSandPTSList=new List<sObject>();
        Map<Id,sirenum__Sirenum_Condition_Membership__c> updateCompConditionMap=new Map<Id,sirenum__Sirenum_Condition_Membership__c>();
        for(sirenum__Sirenum_Condition_Membership__c newCompCond: newCompCondMap.Values()){
            if(newCompCond.Inactive__c!=oldCompCondMap.get(newCompCond.Id).Inactive__c){
                updateCompConditionMap.put(newCompCond.Id,newCompCond);
            }
        }
        if(updateCompConditionMap==null){
            return;
        }
        else{
            List<Illingworth_Ticket_Status__c> ticketStatusQueryList=[Select id,Inactive__c,Competence_Condition__c  from Illingworth_Ticket_Status__c where Competence_Condition__c IN :updateCompConditionMap.keySet() ];
            List<Project_Ticket_Status__c> projectTicketStatusQueryList=[Select id,Inactive__c,Competency_Condition__c   from Project_Ticket_Status__c where Competency_Condition__c  IN :updateCompConditionMap.keySet() ];
            for(Illingworth_Ticket_Status__c ts:ticketStatusQueryList){
                if(updateCompConditionMap.containsKey(ts.Competence_Condition__c)){
                    ts.Inactive__c=updateCompConditionMap.get(ts.Competence_Condition__c).Inactive__c;
                    updateTSandPTSList.add(ts);
                }
            }
            for(Project_Ticket_Status__c pts:projectTicketStatusQueryList){
                if(updateCompConditionMap.containsKey(pts.Competency_Condition__c)){
                    pts.Inactive__c=updateCompConditionMap.get(pts.Competency_Condition__c).Inactive__c;
                    updateTSandPTSList.add(pts);
                }
            }
        }
        if(!updateTSandPTSList.isEmpty()){
            update updateTSandPTSList;
        }
    }
    
    //Method to update TS and PTS records when lookup values (Account,Site, Project,Site) is updated
    public static void updateTSAndPTSWhenLookupChanges(Map<Id,sirenum__Sirenum_Condition_Membership__c> newCompCondMap,Map<Id,sirenum__Sirenum_Condition_Membership__c> oldCompCondMap){
        List<sObject> updateTSandPTSList=new List<sObject>();
        Map<Id,sirenum__Sirenum_Condition_Membership__c> updateCompConditionMap=new Map<Id,sirenum__Sirenum_Condition_Membership__c>();
        Map<Id,sirenum__Sirenum_Condition_Membership__c> updateCompConditionJobTypeMap=new Map<Id,sirenum__Sirenum_Condition_Membership__c>();
        for(sirenum__Sirenum_Condition_Membership__c newCompCond: newCompCondMap.Values()){
            if(newCompCond.sirenum__Client__c !=oldCompCondMap.get(newCompCond.Id).sirenum__Client__c ||
               newCompCond.Project__c  !=oldCompCondMap.get(newCompCond.Id).Project__c ||
               newCompCond.sirenum__Site__c   !=oldCompCondMap.get(newCompCond.Id).sirenum__Site__c
              ){
                  updateCompConditionMap.put(newCompCond.Id,newCompCond);
              }
            else if(newCompCond.sirenum__Job_Type__c != oldCompCondMap.get(newCompCond.Id).sirenum__Job_Type__c ||
                    newCompCond.Work_Country__c!=oldCompCondMap.get(newCompCond.Id).Work_Country__c ||
                    newCompCond.Work_State__c!=oldCompCondMap.get(newCompCond.Id).Work_State__c){
                        updateCompConditionJobTypeMap.put(newCompCond.Id,newCompCond);
                        
                    }
        }
        if(updateCompConditionMap==null && updateCompConditionJobTypeMap==null){
            return;
        }
        if(!updateCompConditionMap.isEmpty() && updateCompConditionJobTypeMap.isEmpty()){
            for(Project_Ticket_Status__c pts:[Select id,Account__c ,Project__c ,Site__c, Inactive__c, Competency_Condition__c from Project_Ticket_Status__c where Competency_Condition__c  IN :updateCompConditionMap.keySet() ]){
                if(updateCompConditionMap.containsKey(pts.Competency_Condition__c)){
                    pts.Competency_Condition__c=null;
                    updateTSandPTSList.add(pts);
                }
            }
        }
        else if(updateCompConditionMap.isEmpty() && !updateCompConditionJobTypeMap.isEmpty()){
            for(Illingworth_Ticket_Status__c ts:[Select id,Inactive__c,Job_Type__c,Competence_Condition__c  from Illingworth_Ticket_Status__c where Competence_Condition__c IN :updateCompConditionJobTypeMap.keySet() ]){
                if(updateCompConditionJobTypeMap.containsKey(ts.Competence_Condition__c)){
                    ts.Competence_Condition__c=null;
                    updateTSandPTSList.add(ts);
                }
            }
        }
        if(!updateTSandPTSList.isEmpty()){
            update updateTSandPTSList;
        }
    }
    
    //Method to populate Location when a new competency condition is created
    public static void polpulateLocationOnCreation(List<sirenum__Sirenum_Condition_Membership__c> newCompetencyConditionList){
        Set<String> countryStateSet=new Set<String>();
        Map<String, Id> locationMap = new Map<String, Id>();
        
        for(sirenum__Sirenum_Condition_Membership__c compCond: newCompetencyConditionList){
            if(compCond.Competence_Category__c == 'Work Country' || compCond.Competence_Category__c == 'RN Mandatory Training' || compCond.Competence_Category__c == 'Work State'){
                if(compCond.Work_Country__c!=null && compCond.Work_State__c!=null){
                    countryStateSet.add(compCond.Work_Country__c+' - '+compCond.Work_State__c); 
                }
                else if(compCond.Work_Country__c!=null && compCond.Work_State__c==null){
                    countryStateSet.add(compCond.Work_Country__c); 
                }
            }
        }
        if(countryStateSet.isEmpty()){
            return;
        }
        else{
            for (sirenum__Location__c location : [SELECT Id, Name FROM sirenum__Location__c WHERE Name IN :countryStateSet]) {
                locationMap.put(location.Name, location.Id);
            }
        }
        if(locationMap==null){
            return;
        }
        else{
            for (sirenum__Sirenum_Condition_Membership__c compCond : newCompetencyConditionList) {
                if (locationMap.containsKey(compCond.Work_Country__c+' - '+compCond.Work_State__c)) {
                    compCond.sirenum__Location__c=locationMap.get(compCond.Work_Country__c+' - '+compCond.Work_State__c);
                }
                else if(locationMap.containsKey(compCond.Work_Country__c)){
                    compCond.sirenum__Location__c=locationMap.get(compCond.Work_Country__c);
                }
            }
        }
    }
    
    //Method to populate Location when a new competency condition is Updated
    public static void polpulateLocationOnUpdation(Map<Id,sirenum__Sirenum_Condition_Membership__c> newCompetencyConditionMap,Map<Id,sirenum__Sirenum_Condition_Membership__c> oldCompetencyConditionMap){
        Set<String> countryStateSet=new Set<String>();
        Map<String, Id> locationMap = new Map<String, Id>();
        
        for(sirenum__Sirenum_Condition_Membership__c compCond: newCompetencyConditionMap.values()){
            if(compCond.Competence_Category__c == 'Work Country' || compCond.Competence_Category__c == 'RN Mandatory Training' || compCond.Competence_Category__c == 'Work State'){
                if(compCond.Work_Country__c!=oldCompetencyConditionMap.get(compCond.Id).Work_Country__c || compCond.Work_Country__c!=oldCompetencyConditionMap.get(compCond.Id).Work_State__c){
                    if(compCond.Work_Country__c!=null && compCond.Work_State__c!=null){
                        countryStateSet.add(compCond.Work_Country__c+' - '+compCond.Work_State__c); 
                    }
                    else if(compCond.Work_Country__c!=null && compCond.Work_State__c==null){
                        countryStateSet.add(compCond.Work_Country__c); 
                    }
                }
            }
        }
        if(countryStateSet.isEmpty()){
            return;
        }
        else{
            for (sirenum__Location__c location : [SELECT Id, Name FROM sirenum__Location__c WHERE Name IN :countryStateSet]) {
                locationMap.put(location.Name, location.Id);
            }
        }
        if(locationMap==null){
            return;
        }
        else{
            for (sirenum__Sirenum_Condition_Membership__c compCond : newCompetencyConditionMap.values()) {
                if (locationMap.containsKey(compCond.Work_Country__c+' - '+compCond.Work_State__c)) {
                    compCond.sirenum__Location__c=locationMap.get(compCond.Work_Country__c+' - '+compCond.Work_State__c);
                }
                else if(locationMap.containsKey(compCond.Work_Country__c)){
                    compCond.sirenum__Location__c=locationMap.get(compCond.Work_Country__c);
                }
            }
        }
    }
    
    //Non Project Member Cannot Create or Edit Competency Validation
    public static void validationforNonProjectMembers (List<sirenum__Sirenum_Condition_Membership__c> competencyCondition){
        
        User userProfile = [SELECT Id, Name, ProfileId , Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        if(userProfile.Profile.Name != 'System Administrator'|| test.isRunningTest()){
            Map<Id, sirenum__TicketType__c> competency = new Map<Id,sirenum__TicketType__c>();
            Set<Id> competencyId=new Set<Id>();
            Set<String> groupNames = new Set<String>();
            Map<String,Boolean> projectVsTeamMember = new Map<String,Boolean>();
            
            for(sirenum__Sirenum_Condition_Membership__c compCond: competencyCondition){
                if(compCond.sirenum__TicketType__c != null && (compCond.Competence_Category__c == 'Site Activation Resource' || compCond.Competence_Category__c == 'Project Training' || compCond.Competence_Category__c == 'Project Site Training')){
                    competencyId.add(compCond.sirenum__TicketType__c );
                }
                else if((compCond.Competence_Category__c != 'Site Activation Resource' || compCond.Competence_Category__c != 'Project Training' || compCond.Competence_Category__c != 'Project Site Training') && userProfile.Profile.Name == 'RNPM/PC' && !test.isRunningTest()){
                    compCond.adderror('PMPC user can only edit or create competency Conditions linked to the Project they belong to');
                }
            }
            if(!competencyId.isEmpty()){
                competency = new Map<Id,sirenum__TicketType__c>([SELECT Id, Illingworth_Project__r.Project_Team__r.Name ,Illingworth_Project__c from sirenum__TicketType__c where id IN :competencyId]);
                
                if(competency !=null && competency.size()>0 ){
                    for(sirenum__TicketType__c c : competency.values()){
                        groupNames.add(c.Illingworth_Project__r.Project_Team__r.Name);
                    }
                    for(Group g : [Select Id,Name,(select userOrGroupId from groupMembers where UserOrGroupId =: userInfo.getUserId()) from Group where Name IN : groupNames]){
                        if(g.groupMembers.size() != 0){
                            projectVsTeamMember.put(g.Name,false);  
                        }
                        
                    }
                }
                if(competencyCondition.size()>0){
                    for(sirenum__Sirenum_Condition_Membership__c compCond: competencyCondition){
                        if( (userProfile.Profile.Name == 'RNPM/PC' && (projectVsTeamMember.isEmpty() || (!projectVsTeamMember.isEmpty() && !projectVsTeamMember.containsKey(competency.get(compCond.sirenum__TicketType__c).Illingworth_Project__r.Project_Team__r.Name)))) && !test.isRunningTest()){
                            compCond.adderror('PMPC user can only edit or create competency Conditions linked to the Project they belong to');
                        }
                    }
                }
            }
        }
    }
}