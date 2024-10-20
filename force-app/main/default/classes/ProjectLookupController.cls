public class ProjectLookupController {
    @AuraEnabled
    
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        try {
            if(inputWrapper != null){
                String fieldsToQuery = 'SELECT Id, ';
                if(string.isNotBlank(inputWrapper.fieldApiName)){
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                }
                if(string.isNotBlank(inputWrapper.otherFieldApiName)){
                    fieldsToQuery = fieldsToQuery + ', ' + inputWrapper.otherFieldApiName;
                }
                String query = fieldsToQuery + ' FROM '+ inputWrapper.objectApiName;
                String filterCriteria = inputWrapper.fieldApiName + ' LIKE ' + '\'' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\' LIMIT 10';
                if(String.isNotBlank(inputWrapper.selectedRecordId)) {
                    query += ' WHERE Id = \''+ inputWrapper.selectedRecordId + '\'';
                }else if(String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)){
                    query += ' WHERE '+ inputWrapper.parentFieldApiName+ ' = \''+ inputWrapper.parentRecordId + '\'';
                    query += ' AND ' + filterCriteria;
                } 
                else {
                    query += ' WHERE '+ filterCriteria;
                }
                List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
                for(SObject s : Database.query(query)) {
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.mainField = (String)s.get(inputWrapper.fieldApiName);
                    wrap.subField = (String)s.get(inputWrapper.otherFieldApiName);
                    wrap.id = (String)s.get('id');
                    returnWrapperList.add(wrap);
                }
                return returnWrapperList;
            }
            return null;
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<sirenum__site__c> getRelatedSites(Object selectedProject){
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(selectedProject));
        
        String projectId=String.valueOf(jsonMap.get('id'));
        List<sirenum__site__c> sites=[SELECT Id, Name, IllingworthCountry__c, Project__c FROM sirenum__site__c where Project__c = :projectId];
        return sites;
    }
    
    @AuraEnabled
    public static Map<String,Object> createCompetency(Map<String,String> selectedProject,Boolean isChecked,Map<String,String> siteMap,String selectedCategoryValue,String compName, String searchableName,String courseTitle,String severity){
        Map<String,Object> resultMap=new Map<String,Object>();
        String message='';
        try{
            List<sirenum__TicketType__c> competencyList=new List<sirenum__TicketType__c>();
            List<sirenum__Sirenum_Condition_Membership__c> competencyConditionList=new List<sirenum__Sirenum_Condition_Membership__c>();
            Set<Id> projectSet=new Set<Id>();
            
            if(selectedCategoryValue=='ProjectTraining'){
                sirenum__TicketType__c comp=new sirenum__TicketType__c();
                comp.Competence_Category__c ='Project Training';
                comp.Illingworth_Project__c =selectedProject.get('id');
                comp.Name=compName;
                comp.sirenum__Searchable_Name__c=searchableName;
                comp.Severity__c=severity; 
                if(courseTitle!=''){
                    comp.LMS_Course_Title__c= courseTitle; 
                }
                comp.Generate_Competency_Condition__c = isChecked==true ? True : False;
                competencyList.add(comp);
            }
            else if(selectedCategoryValue=='ProjectSiteTraining'){
                sirenum__TicketType__c comp=new sirenum__TicketType__c();
                comp.Competence_Category__c ='Project Site Training';
                comp.Illingworth_Project__c =selectedProject.get('id');
                comp.Name=compName;
                String sites = String.join(siteMap.values(), '; ');
                comp.Site__c=sites;
                comp.sirenum__Searchable_Name__c=searchableName;
                if(courseTitle!=''){
                    comp.LMS_Course_Title__c= courseTitle; 
                }
                comp.Severity__c=severity;
                comp.Generate_Competency_Condition__c = isChecked==true ? True : False;
                competencyList.add(comp);
            }
            if(competencyList.size()>0){
                Insert competencyList;
                resultMap.put('compId',competencyList[0].Id);
                resultMap.put('message','Success');
                
                for(sirenum__TicketType__c comp: competencyList){
                    projectSet.add(comp.Illingworth_Project__c); 
                    
                }
                String compLink=(competencyList[0].Id!=null) ? Label.Competency_Record_Link+'/'+competencyList[0].Id+'/view':'';
                resultMap.put('compLink',compLink);
                
                //message='Success';
                if(isChecked==True && selectedCategoryValue=='ProjectTraining'){
                    List<sirenum__ProActiveContract__c> projectAccountQueryList=[Select id,name, sirenum__Client__c,sirenum__Client__r.Name from sirenum__ProActiveContract__c where id=:projectSet];
                    Map<Id,Id> ProjectIdAccIdMap=new Map<Id,Id>();
                    for(sirenum__ProActiveContract__c proj:[Select id,name, sirenum__Client__c,sirenum__Client__r.Name from sirenum__ProActiveContract__c where id=:projectSet]){
                        ProjectIdAccIdMap.put(proj.Id,proj.sirenum__Client__c);
                    }
                    for(sirenum__TicketType__c competency: competencyList){
                        sirenum__Sirenum_Condition_Membership__c compCondition=new sirenum__Sirenum_Condition_Membership__c();
                        compCondition.Project__c =competency.Illingworth_Project__c;
                        compCondition.sirenum__TicketType__c=competency.Id;
                        compCondition.sirenum__Client__c =ProjectIdAccIdMap.get(competency.Illingworth_Project__c);
                        compCondition.sirenum__Severity__c=competency.Severity__c;
                        competencyConditionList.add(compCondition);
                    }
                }
                else if(isChecked==True && selectedCategoryValue=='ProjectSiteTraining'){
                    Map<String, String> swappedSiteMap = new Map<String, String>();
                    for(String site: siteMap.keySet()){
                        swappedSiteMap.put(siteMap.get(site), site);
                    }
                    for(sirenum__TicketType__c competency: competencyList){
                        String s=competency.Site__c;
                        List<String> sites=s.split('; ');
                        for(String site:sites){
                            sirenum__Sirenum_Condition_Membership__c compCondition=new sirenum__Sirenum_Condition_Membership__c();
                            compCondition.Project__c =competency.Illingworth_Project__c;
                            compCondition.sirenum__TicketType__c=competency.Id;
                            compCondition.sirenum__Severity__c=competency.Severity__c;
                            compCondition.sirenum__Site__c=swappedSiteMap.get(site);
                            competencyConditionList.add(compCondition);
                        }
                    }
                }
            }
            if(competencyConditionList.size()>0){
                Insert competencyConditionList;
                message='Success';
                resultMap.put('messageCompCond','Success');
                
            } 
        }
        catch(Exception e){
            resultMap.put('message','Failed-:'+e.getMessage());
        }
        return resultMap;
    }
    
    public class ResultWrapper{
        @AuraEnabled public String mainField{get;set;}
        @AuraEnabled public String subField{get;set;}
        @AuraEnabled public String id{get;set;}
    }
    
    public class SearchWrapper {
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String otherFieldApiName{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}
        @AuraEnabled public String parentRecordId{get;set;}
        @AuraEnabled public String parentFieldApiName{get;set;}
    }
}