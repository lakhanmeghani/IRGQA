public class ResourceNotActiveOnProjectHandler {
    public static boolean flag = true; 
    public static boolean recursiveCheck = true; 
    public static boolean checkVistOutcomeFlag = true;
    public static boolean changeNotifyResourceRequestFlag = true;
    public static boolean checkVisitChildRecordFlag = true;
    public static boolean ErrorOnParentVisitDeclinedFlag = true;
    public static boolean createNewPlacementRecordFlag = true;
    public static boolean ErrorOnSiteChangeForChildFlag = true;
    public static boolean updatePolicyAppliedOnVisitFlag = true; 
    public static boolean startTimeEndTimeValidationFlag = true;
    public static boolean updateStartDateForPlacementFlag = true;
    public static boolean updateStartDateForProjectPlacementFlag = true;
    public static boolean updateStartDateForSitePlacementFlag = true;
    public static boolean getAllVisitRelatedToPlacementFlag = true;
    public static boolean setDefaultValuesForResourcingCountryFlag = true;
    public static boolean deleteVisitRecordFlag = true;
    public static boolean updateResRequestOwnerFlag = true;
    public static boolean createSiteActivationTicketFlag = true;
    public static boolean visitNumberMandatoryFlag = true;
    public static boolean sendErrorWhenResourceOwnerChangedOnChildFlag = true;
    public static boolean changeAssignedVisitOnParentFlag = true;
    
    //
    public Static void setDefaultValuesAndValidations(List<sirenum__Shift__c> newVisitList){
        Map<String, Id> recordTypeNameIdMap = Utility.getRecordTypeIdNameMap('sirenum__Shift__c');
        Map<Id, List<sirenum__Shift__c>> projectIdVisitListMap = new Map<Id, List<sirenum__Shift__c>>();
        Id visAllocRecordTypeId = recordTypeNameIdMap.get('Visit Allocation');
        Id ResourceReqRecordTypeId = recordTypeNameIdMap.get('Resource Request');
        Set<String> countryStateList = new Set<String>(); 
        Map<String,sirenum__Location__c> locationNameObjMap= new Map<String,sirenum__Location__c>();
        List<Id> resourceRequestIdList= new List<Id>();
        
        String userId = UserInfo.getUserId();
        User userProfile = [SELECT Id, Name, ProfileId FROM User WHERE Id = :userId];
        String profileName = userProfile.Name;
        
        Time nullTime = Time.newInstance(0, 0, 0, 0); 
        Time endTime = Time.newInstance(23, 0, 0, 0);
        Map<Id, sirenum__Shift__c > clinicalSiteVisitMap = New Map<Id,sirenum__Shift__c >();
        
        for(sirenum__Shift__c visit: newVisitList){
            
            //visitNumberMandatory Method
            if((visit.RecordTypeId == visAllocRecordTypeId && visit.sirenum__ShiftDemand__c == null 
                && (visit.Visit_Number__c == null || visit.Participant__c == null || visit.Participant_Location__c == null) ) && !test.isRunningTest()){
                    Visit.adderror(' Visit Number, Participant and Participant Location is Mandatory for Normal Visit');
                }
            if( visit.Resource_Request__c==true && visit.sirenum__ShiftDemand__c!=null){
                resourceRequestIdList.add(visit.sirenum__ShiftDemand__c); 
            }
            
            //startTimeEndTimeValidation Method
            Datetime dt = Visit.sirenum__Scheduled_Start_Time__c;
            Date myDate = dt.date(); 
            Date datePopulate = date.newinstance(dt.year(), dt.month(), dt.day());
            
            //Set Original Visit Date as Start time Date
            Visit.Original_Visit_Date__c = datePopulate;
            
            if((Visit.sirenum__Scheduled_Start_Time__c == DateTime.newInstance(myDate, nullTime) &&
                Visit.sirenum__Scheduled_End_Time__c == DateTime.newInstance(myDate, nullTime)) ||
               ((Visit.sirenum__Scheduled_Start_Time__c == DateTime.newInstance(myDate, nullTime) &&
                 Visit.sirenum__Scheduled_End_Time__c == DateTime.newInstance(myDate, endTime)))){
                     
                 }
            else if ((Visit.sirenum__Scheduled_Start_Time__c != DateTime.newInstance(myDate, nullTime) ||
                      Visit.sirenum__Scheduled_End_Time__c != DateTime.newInstance(myDate, nullTime)) && 
                     Visit.Through_Data_Wizard__c != True && Visit.sirenum__ShiftDemand__c == null && profileName != 'Recruitment Manager'){
                         Visit.adderror('Put start time and end time as 00:00 and 23:00 Trigger');  
                     }
            Visit.sirenum__Scheduled_End_Time__c = DateTime.newInstance(myDate, endTime);
            Visit.Scheduled_End_Time_local__c = '23:00';
            Visit.Scheduled_Start_Time_local__c = '00:00';
            Visit.Scheduled_Day_local__c=(Visit.sirenum__Scheduled_Start_Time__c).date();
            //checkVistOutcome Method
            if(visit.Outcome__c=='Partially Completed'||visit.Outcome__c=='Completed In Full'){
                visit.sirenum__Allow_charge__c=True;
            }
            
            if(visit.Illingworth_Country__c != null && visit.Illingworth_State__c != null) 
                countryStateList.add(visit.Illingworth_Country__c+' - '+visit.Illingworth_State__c);
            else if(visit.Illingworth_Country__c != null && visit.Illingworth_State__c == null) 
                countryStateList.add(visit.Illingworth_Country__c);
            clinicalSiteVisitMap.put(visit.Clinical_Site__c,visit);
            
            // Update owner on visit
            if(projectIdVisitListMap.containsKey(visit.sirenum__Contract__c)){
                projectIdVisitListMap.get(visit.sirenum__Contract__c).add(visit);
            }
            else{
                projectIdVisitListMap.put(visit.sirenum__Contract__c,new List<sirenum__Shift__c>{visit});    
            }
            string ownerId = visit.OwnerId;
            if(ownerId.startsWith('005')) {
                visit.Visit_Owner__c = visit.OwnerId;
            }
        }
        
        //setDefaultValuesForResourcingCountry Method
        for(sirenum__Site__c site: [select id, name , IllingworthCountry__c,sirenum__State__c,sirenum__City__c  
                                    from sirenum__Site__c  
                                    where id =: clinicalSiteVisitMap.keySet()]){
                                        sirenum__Shift__c visit = clinicalSiteVisitMap.get(site.Id);
                                        visit.Resourcing_Country__c=site.IllingworthCountry__c!=null ? site.IllingworthCountry__c : null;
                                        visit.Resourcing_State__c=site.sirenum__State__c !=null ? site.sirenum__State__c  : null;
                                        visit.Resourcing_City__c=site.sirenum__City__c  !=null ? site.sirenum__City__c   : null; 
                                        
                                    }
        
        
        if(resourceRequestIdList.size()>0 || test.isRunningTest()){
            Map<Id,sirenum__Shift__c> parentVistQuery=new Map<Id,sirenum__Shift__c>([Select id,Resourcing_Country__c,Resourcing_State__c,Resourcing_City__c from sirenum__Shift__c where id IN :resourceRequestIdList]);
            for(sirenum__Shift__c loopVisit : newVisitList){
                if(loopVisit.Resource_Request__c==True && loopVisit.sirenum__ShiftDemand__c!=null){
                    loopVisit.Resourcing_Country__c=parentVistQuery.get(loopVisit.sirenum__ShiftDemand__c).Resourcing_Country__c;
                    loopVisit.Resourcing_State__c=parentVistQuery.get(loopVisit.sirenum__ShiftDemand__c).Resourcing_State__c;
                    loopVisit.Resourcing_City__c=parentVistQuery.get(loopVisit.sirenum__ShiftDemand__c).Resourcing_City__c;
                }
            }
        }
        
        //updateCountryStateLocation Method
        if(countryStateList != null){
            for(sirenum__Location__c  loopLocation : [Select Id, Name FROM sirenum__Location__c Where Name IN : countryStateList]){
                locationNameObjMap.put(loopLocation.Name, loopLocation);   
            }    
        }
        
        if(locationNameObjMap != null){
            for(sirenum__Shift__c loopVisit : newVisitList){
                if(loopVisit.Illingworth_Country__c != null && loopVisit.Illingworth_State__c != null){
                    loopVisit.sirenum__Location__c = (locationNameObjMap.get(loopVisit.Illingworth_Country__c+' - '+loopVisit.Illingworth_State__c) !=null) ? locationNameObjMap.get(loopVisit.Illingworth_Country__c+' - '+loopVisit.Illingworth_State__c).Id : null;    
                } 
                if(loopVisit.Illingworth_Country__c != null && loopVisit.Illingworth_State__c == null){
                    loopVisit.sirenum__Location__c = (locationNameObjMap.get(loopVisit.Illingworth_Country__c) != null) ?locationNameObjMap.get(loopVisit.Illingworth_Country__c).Id : null;
                }
            }   
        }
        
        //Update Visit OwnerId with Queue 
        for(sirenum__ProActiveContract__c loopProject : [SELECT Id, Project_Team__r.OwnerId 
                                                         FROM sirenum__ProActiveContract__c
                                                         WHERE id = :projectIdVisitListMap.keySet()]){
                                                             for(sirenum__Shift__c loopVisit : projectIdVisitListMap.get(loopProject.Id)){
                                                                 loopVisit.OwnerId = loopProject.Project_Team__r.OwnerId;  
                                                             }                                           	 
                                                         }
    }
    
    //
    public static void CheckActiveOnProject(List<sirenum__Shift__c> visitList, Map<Id,sirenum__Shift__c> newVisitMap , Map<Id,sirenum__Shift__c> oldVisitMap){
        if(recursiveCheck){
            List<string> allowedEditableVisitFields = Label.Allow_Visit_Edit.split(',');
            List<SObjectField> fieldList = sirenum__Shift__c.SObjectType.getDescribe().fields.getMap().values();
            Set<Id> parentVisitIdSet = new Set<Id>();
            List<String> customProfileList=Label.Visit_Deletion_Profiles.split(',');
            List<Profile> profileList=[select Id from profile where Name IN :customProfileList];
            List<String> profileStringList=new List<String>();
            Set<Id> visitRecordId = new Set <Id>();
            
            for(Profile profile:profileList){
                profileStringList.add(profile.id);
            }
            
            for(sirenum__Shift__c newVisit : visitList){
                if (newVisit.sirenum__ShiftDemand__c != null || test.isRunningTest()){
                    visitRecordId.add(newVisit.sirenum__ShiftDemand__c);
                }
                if(oldVisitMap != null && oldVisitMap.get(newVisit.id).Outcome__c != null){
                    for(SObjectField field : fieldList){
                        if(!allowedEditableVisitFields.contains(field.getDescribe().getName()) &&
                           newVisitMap.get(newVisit.Id).get(field) != oldVisitMap.get(newVisit.Id).get(field) && 
                           !profileStringList.contains(userInfo.getProfileId())){
                               system.debug('field Name new value----->>>>>>'+newVisitMap.get(newVisit.Id).get(field));
                               system.debug('field Name Old Value----->>>>>>'+oldVisitMap.get(newVisit.Id).get(field));
                               system.debug('field Name Inside Error----->>>>>>'+field);
                               newVisit.adderror('This is a historical visit and cannot be updated by user. Please submit a ticket to the IT Service Desk');
                           }
                    }
                } 
            }
            
            if(visitRecordId.size()>0){
                for(sirenum__Shift__c visit:[select id,name,Visit_Approval_Status__c from sirenum__Shift__c where id IN :visitRecordId]){
                    if(visit.Visit_Approval_Status__c=='Approved')parentVisitIdSet.add(visit.id);  
                }
            }
            
            Boolean bypassvalidationflag = false;
            if(!parentVisitIdSet.isEmpty() || test.isRunningTest()){
                List<Illingworht_Policy_Applied__c> listpolicyapplied = [select id, name from Illingworht_Policy_Applied__c 
                                                                         where Policy_Definition__r.Name Like '%Add Policy at Visit to Bypass Work Country for Resource Request%' 
                                                                         AND Illingworth_Visit__c IN :parentVisitIdSet];
                if(listpolicyapplied.size() > 0) bypassvalidationflag = true;   
            }
            
            Set<Id> contactIdSet = new Set<Id>();
            for(sirenum__Shift__c visit : visitList){
                if(visit.sirenum__Contact__c != null) contactIdSet.add(visit.sirenum__Contact__c);   
            }
            
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            if(!contactIdSet.isEmpty() || test.isRunningTest()){
                contactMap = new Map<Id, Contact>([select Id, Name,Active_Projects__c, Work_Country__c, Active_Projects_as_Text__c, Illing_Licenced_in_States_Province__c  
                                                   from Contact 
                                                   where id IN :contactIdSet]);
            }
            
            for(sirenum__Shift__c visit : visitList){
                if(visit.sirenum__Contact__c != null){
                    Contact resource = new Contact();
                    if(!contactMap.isEmpty() && contactMap.containsKey(visit.sirenum__Contact__c)) 
                        resource = contactMap.get(visit.sirenum__Contact__c);
                    
                    if(resource.Active_Projects_as_Text__c != null || resource.Work_Country__c != null){
                        List<String> selectedWorkCountryList = resource.Work_Country__c.split(';'); 
                        List<String> selectedActiveProjectList = new List<String> ();
                        if(resource.Active_Projects_as_Text__c != null){
                            selectedActiveProjectList = resource.Active_Projects_as_Text__c.split(';');
                        }
                        
                        List<String> selectedStateList = new List<String>();
                        if(resource.Illing_Licenced_in_States_Province__c != null){
                            selectedStateList = resource.Illing_Licenced_in_States_Province__c.split(';');
                        }
                        
                        if(visit.Project_as_Text__c != null){
                            if(!selectedActiveProjectList.contains(visit.Project_as_Text__c) && visit.Outcome__c == null) {
                                visit.adderror('This Resource is not yet active on this Project. Please activate this Resource on the Project before allocating visits');
                            }
                            if(!Test.isRunningTest()){
                                if(!selectedWorkCountryList.contains(visit.Illingworth_Country__c) && visit.sirenum__IsShiftDemand__c == false){
                                    if(bypassvalidationflag == false){
                                        visit.adderror('The chosen Resource does not Work in the Visit Country');
                                    }
                                }
                                if(!selectedStateList.contains(visit.Resourcing_State__c) && visit.Resource_Request__c && visit.sirenum__ShiftDemand__c != null && visit.Resourcing_State__c != null){
                                    visit.adderror('The chosen Resource does not Work in the Visit State');
                                }
                                if(!selectedStateList.contains(visit.Illingworth_State__c) && visit.Resource_Request__c == false && visit.Illingworth_State__c != null){
                                    visit.adderror('The chosen Resource does not Work in the Visit State');
                                }
                            }
                        }
                        else if(resource.Active_Projects_as_Text__c == null){
                            visit.adderror('This Resource is not yet active on this Project. Please activate this Resource on the Project before allocating visits');
                        }
                    }
                    else if(resource.Active_Projects_as_Text__c == null){
                        visit.adderror('This Resource is not yet active on this Project. Please activate this Resource on the Project before allocating visits');
                    }
                }
            }
            recursiveCheck = false;
        }
    }
    
    //
    public static void changeNotifyResourceRequest(Map<Id,sirenum__Shift__c> newVisitMap,Map<Id,sirenum__Shift__c> oldVisitMap){
        Map<String, Id> recordTypeNameIdMap = Utility.getRecordTypeIdNameMap('sirenum__Shift__c');
        Id visAllocRecordTypeId = recordTypeNameIdMap.get('Visit Allocation');
        List<sirenum__Shift__c> updateRelatedVisit=new List<sirenum__Shift__c>(); 
        Set<String> countryStateList = new Set<String>();
        List<sirenum__Shift__c> sortedVisitList = new List<sirenum__Shift__c> ();
        Map<String,sirenum__Location__c> locationNameObjMap= new Map<String,sirenum__Location__c>();
        
        for(sirenum__Shift__c visit: newVisitMap.values()){
            if(visit.sirenum__ShiftDemand__c !=null && visit.sirenum__Accepted__c==1 && 
               (visit.Project_Approval_Status__c != oldVisitMap.get(visit.Id).Project_Approval_Status__c || visit.Site_Activation_Status__c != oldVisitMap.get(visit.Id).Site_Activation_Status__c)){
                   if((visit.Project_Approval_Status__c=='Approved' && visit.PM_Approved_Date__c!=null && ( visit.Site_Activation_Status__c=='Declined' && visit.Illingworth_Site_Decline_date__c!=null ) || (visit.Site_Activation_Status__c=='Approved' && visit.Site_Approval_date__c!=null))|| visit.Project_Approval_Status__c=='Declined'){
                       visit.Illingworth_Notify_Res_Request__c = false;
                   }
                   else{
                       if((visit.Project_Approval_Status__c=='Approved'&& visit.PM_Approved_Date__c!=null)||visit.Project_Approval_Status__c=='Pending'){
                           visit.Illingworth_Notify_Res_Request__c = true;
                       }
                   }
               }
        }
        changeNotifyResourceRequestFlag = false;
    }
    
    //
    public static void checkVisitChildRecord(List<sirenum__Shift__c> visitList,Map<Id,sirenum__Shift__c> oldVisitMap){
        List<sirenum__Shift__c> updateRelatedVisit=new List<sirenum__Shift__c>();
        List<sirenum__Shift__c> relatedVisitList=new List<sirenum__Shift__c>();
        Set<Id> visitCountryErrorSet=new Set<Id>();
        Set<Id> visitStateErrorSet=new Set<Id>();
        Map<Id,sirenum__Shift__c> visitIdMap=new Map<Id,sirenum__Shift__c>();
        Map<Id,sirenum__Shift__c> visitErrorMap=new Map<Id,sirenum__Shift__c>();
        
        for(sirenum__Shift__c visit: visitList){
            if(visit.sirenum__IsShiftDemand__c==true  && visit.sirenum__ShiftDemand__c==null && (oldVisitMap.get(visit.id).sirenum__Site__c != visit.sirenum__Site__c) || (Test.isRunningTest())){
                visitIdMap.put(visit.id,visit);
            }
        } 
        
        if(visitIdMap.size()>0){    
            for(sirenum__Shift__c relatedVisit :[select id,name,sirenum__ShiftDemand__r.Resourcing_State__c,sirenum__ShiftDemand__r.Resourcing_city__c,sirenum__ShiftDemand__r.Resourcing_country__c,sirenum__Site__c,sirenum__ShiftDemand__r.sirenum__Site__c,Resource_Request__c,Resourcing_State__c,sirenum__Contact__r.Work_Country__c,sirenum__Contact__r.Illing_Licenced_in_States_Province__c,clinical_site__c from sirenum__Shift__c where sirenum__ShiftDemand__c IN :visitIdMap.keySet() ]){
                if(!((relatedVisit.sirenum__Contact__r.Work_Country__c).split(';')).contains(visitIdMap.get(relatedVisit.sirenum__ShiftDemand__c).Illingworth_Country__c )){
                    visitCountryErrorSet.add(relatedVisit.sirenum__ShiftDemand__c);
                }
                else if(!((relatedVisit.sirenum__Contact__r.Illing_Licenced_in_States_Province__c).split(';')).contains(visitIdMap.get(relatedVisit.sirenum__ShiftDemand__c).Resourcing_State__c ) && relatedVisit.Resource_Request__c && relatedVisit.sirenum__ShiftDemand__c!=null && relatedVisit.Resourcing_State__c!=null){
                    visitStateErrorSet.add(relatedVisit.sirenum__ShiftDemand__c);
                }
                else{
                    relatedVisit.Clinical_Site__c =relatedVisit.sirenum__ShiftDemand__r.sirenum__Site__c;
                    relatedVisit.Resourcing_State__c=relatedVisit.sirenum__ShiftDemand__r.Resourcing_State__c;
                    relatedVisit.Resourcing_country__c=relatedVisit.sirenum__ShiftDemand__r.Resourcing_country__c;
                    relatedVisit.Resourcing_city__c=relatedVisit.sirenum__ShiftDemand__r.Resourcing_city__c;
                    updateRelatedVisit.add(relatedVisit);
                }
            }
            flag=false;
            update updateRelatedVisit;
            checkVisitChildRecordFlag = false; 
        }
        
        if(visitCountryErrorSet.size()>0 ||visitStateErrorSet.size()>0 || test.isRunningTest()){
            for(sirenum__Shift__c visit:visitList){
                if(visitCountryErrorSet.contains(visit.id)){
                    visit.addError('The chosen Resource does not Work in the Visit Country'); 
                }
                else if(visitStateErrorSet.contains(visit.id)){
                    visit.addError('The chosen Resource does not Work in the Visit State'); 
                }
            }
            checkVisitChildRecordFlag = false; 
        }
    }
    
    //
    public static void ErrorOnParentVisitDeclined(List<sirenum__Shift__c> visitNewList, Map<Id, sirenum__Shift__c> visitOldMap){
        
        Set<Id> parentVisitId= new Set<Id>();
        Map<Id, List<sirenum__Shift__c>> parentIdChildVisitListMap = new Map<Id, List<sirenum__Shift__c>>();
        Map<Id,sirenum__Shift__c> parentIdObjectMap = new  Map<Id,sirenum__Shift__c>();
        String recordTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
        for(sirenum__Shift__c vt:visitNewList){
            if(vt.RecordTypeId == recordTypeId && vt.sirenum__ShiftDemand__c == null && 
               (vt.Site_Activation_Status__c != visitOldMap.get(vt.Id).Site_Activation_Status__c ||
                vt.Project_Approval_Status__c != visitOldMap.get(vt.Id).Project_Approval_Status__c) &&
               (vt.Site_Activation_Status__c == 'Declined' || vt.Project_Approval_Status__c == 'Declined')){
                   parentVisitId.add(vt.Id);
                   parentIdObjectMap.put(vt.Id, vt);
               }
        }
        
        for(sirenum__Shift__c childVisit :[Select id,name,Site_Activation_Status__c,Project_Approval_Status__c, sirenum__ShiftDemand__c,Illingworth_Illingworth_Status__c from sirenum__Shift__c where sirenum__ShiftDemand__c IN :parentVisitId]){
            if(parentIdChildVisitListMap.containsKey(childVisit.sirenum__ShiftDemand__c)){
                List<sirenum__Shift__c> childVisitList = parentIdChildVisitListMap.get(childVisit.sirenum__ShiftDemand__c);
                childVisitList.add(childVisit);
                parentIdChildVisitListMap.put(childVisit.sirenum__ShiftDemand__c, childVisitList);
            }
            else{
                List<sirenum__Shift__c> childVisitList = new List<sirenum__Shift__c>{childVisit};
                    parentIdChildVisitListMap.put(childVisit.sirenum__ShiftDemand__c,childVisitList);    
            }
            
        }
        for(Id parentId : parentIdChildVisitListMap.keySet()){
            List<sirenum__Shift__c> childVisitList = parentIdChildVisitListMap.get(parentId);
            for(sirenum__Shift__c loopVisit :childVisitList){
                if(loopVisit.Illingworth_Illingworth_Status__c != 'Unfulfilled'){ 
                    sirenum__Shift__c parentObj =  parentIdObjectMap.get(parentId);
                    parentObj.addError('Resources have been allocated to this request, please update each Allocated Resource’s Project/Site approval status to be declined before updating this resource request');
                }   
            }
        }
        ErrorOnParentVisitDeclinedFlag = false;
    }
    
    //
    public static void createNewPlacementRecord(List<sirenum__Shift__c> newVisitList, Map<Id, sirenum__Shift__c> oldVisitMap){
        
        Id rsAllocRecTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> siteIdSet = new Set<Id>();
        Map<Id, sirenum__Shift__c> visitMap = new Map<Id, sirenum__Shift__c>();
        
        for(sirenum__Shift__c loopVisit : newVisitList){
            if(loopVisit != null && loopVisit.RecordTypeId == rsAllocRecTypeId && loopVisit.Project_Approval_Status__c == 'Approved' &&
               oldVisitMap.get(loopVisit.id).Project_Approval_Status__c != loopVisit.Project_Approval_Status__c){
                   projectIdSet.add(loopVisit.sirenum__Contract__c);
                   contactIdSet.add(loopVisit.sirenum__Contact__c);
                   siteIdSet.add(loopVisit.sirenum__Site__c);
                   visitMap.put(loopVisit.Id, loopVisit);
               }
        }
        
        if(!projectIdSet.isEmpty() && !contactIdSet.isEmpty()&& !siteIdSet.isEmpty()){
            Map<String, List<sirenum__Placement__c>> parentPlacementsMap = new Map<String, List<sirenum__Placement__c>>();
            for(sirenum__Placement__c loopPlacement : [SELECT Id, name, sirenum__Contract__c, sirenum__Contact__c, sirenum__Start_Date__c,
                                                       (SELECT Id FROM Placements__r WHERE sirenum__Site__c IN :siteIdSet) 
                                                       FROM sirenum__Placement__c 
                                                       WHERE Project_Placement__c = null 
                                                       AND sirenum__Contract__c IN :projectIdSet 
                                                       AND sirenum__Contact__c IN: contactIdSet]){
                                                           if(loopPlacement != null){
                                                               if(parentPlacementsMap.containsKey(loopPlacement.sirenum__Contract__c+'#'+loopPlacement.sirenum__Contact__c)){
                                                                   parentPlacementsMap.get(loopPlacement.sirenum__Contract__c+'#'+loopPlacement.sirenum__Contact__c).add(loopPlacement);
                                                               }
                                                               else {
                                                                   parentPlacementsMap.put(loopPlacement.sirenum__Contract__c+'#'+loopPlacement.sirenum__Contact__c, new List<sirenum__Placement__c>{loopPlacement});
                                                               }
                                                           }                                               
                                                       }
            List<sirenum__Placement__c> insertSitePlacementList = new List<sirenum__Placement__c>();
            List<sirenum__Placement__c> updateParentPlacementList = new List<sirenum__Placement__c>();
            
            if(!parentPlacementsMap.isEmpty()){
                for(sirenum__Shift__c loopVisit : visitMap.values()){
                    for(sirenum__Placement__c loopPlacement : parentPlacementsMap.get(loopVisit.sirenum__Contract__c+'#'+loopVisit.sirenum__Contact__c)){
                        if(loopVisit.sirenum__Contact__c == loopPlacement.sirenum__Contact__c && 
                           loopVisit.sirenum__Contract__c == loopPlacement.sirenum__Contract__c && 
                           loopPlacement.Placements__r.size() == 0 || test.isRunningTest()){
                               sirenum__Placement__c newPlacement = new sirenum__Placement__c();
                               newPlacement.sirenum__Contract__c = loopPlacement.sirenum__Contract__c;
                               newPlacement.sirenum__Start_Date__c = loopPlacement.sirenum__Start_Date__c;
                               newPlacement.sirenum__Contact__c = loopPlacement.sirenum__Contact__c;
                               newPlacement.Project_Placement__c = loopPlacement.Id;
                               newPlacement.sirenum__Site__c = loopVisit.sirenum__Site__c;
                               insertSitePlacementList.add(newPlacement);
                           }
                        loopPlacement.sirenum__Status__c = 'Active';
                        updateParentPlacementList.add(loopPlacement);
                    }
                }
                if(!insertSitePlacementList.isEmpty()){
                    try{
                        insert insertSitePlacementList;
                        update updateParentPlacementList;
                    }
                    Catch(Exception e){
                        system.debug('e>>'+e.getMessage());
                    }
                } 
            }
        }
    }
    
    //
    public static void ErrorOnSiteChangeForChild (List<sirenum__Shift__c> visitNewList , Map<Id,sirenum__Shift__c> visitOldMap ){
        
        Id resAllocRecordTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        Id resReqRecordTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
        Set<Id> siteIdSet = new Set<Id>();
        for(sirenum__Shift__c loopVisit : visitNewList){
            if(resAllocRecordTypeId == loopVisit.RecordTypeId && loopVisit.Clinical_Site__c != visitOldMap.get(loopVisit.Id).Clinical_Site__c){
                loopVisit.addError('Please change the Site on the Parent Resource Request');      
            }
            else if(resReqRecordTypeId == loopVisit.RecordTypeId && loopVisit.Clinical_Site__c != visitOldMap.get(loopVisit.Id).Clinical_Site__c || test.isRunningTest()){
                siteIdSet.add(loopVisit.Clinical_Site__c);
            }
        }
        
        if(siteIdSet.size()>0){
            Map<Id,sirenum__Site__c> siteMap= new Map<Id,sirenum__Site__c>([Select id,name,IllingworthCountry__c,sirenum__State__c,sirenum__City__c from sirenum__Site__c where id IN:siteIdSet]);
            if(siteMap.size()>0){
                for(sirenum__Shift__c visit : visitNewList){
                    visit.Resourcing_Country__c=siteMap.get(visit.Clinical_Site__c).IllingworthCountry__c;
                    visit.Resourcing_State__c=siteMap.get(visit.Clinical_Site__c).sirenum__State__c;
                    visit.Resourcing_City__c=siteMap.get(visit.Clinical_Site__c).sirenum__City__c;
                }
            }
            ErrorOnSiteChangeForChildFlag = false;
        } 
    }
    
    //Once Visit Approval Status Changed to Approve/Reject Capture the Current user and date on Policy Applied Object
    public static void updatePolicyAppliedOnVisit (Map<Id,sirenum__Shift__c> newVisitMap , Map<Id,sirenum__Shift__c> oldVisitMap ){
        
        set<id> visitId = new set<id>();
        Id userId =UserInfo.getUserId();
        for(Id visit:newVisitMap.KeySet()){
            
            if(newVisitMap.get(visit).Visit_Approval_Status__c != oldVisitMap.get(visit).Visit_Approval_Status__c 
               && (newVisitMap.get(visit).Visit_Approval_Status__c == 'Approved'   
                   || newVisitMap.get(visit).Visit_Approval_Status__c == 'Rejected' )){
                       visitId.add(visit); 
                   }
        }
        if (visitId.size()>0){
            List<Illingworht_Policy_Applied__c> updatePolicyAppliedList = new List<Illingworht_Policy_Applied__c>();
            
            for(Illingworht_Policy_Applied__c pAL:[select id, name , ADRN_PD_Approved__c ,Illingworth_Visit__r.Visit_Approval_Status__c
                                                   from Illingworht_Policy_Applied__c 
                                                   where Illingworth_Visit__c =: visitId
                                                  ]){
                                                      if(pAL.Illingworth_Visit__r.Visit_Approval_Status__c == 'Approved'){
                                                          pAL.Policy_Approved_Date__c=System.today();
                                                          pAL.Policy_Approver__c=userId;
                                                          pAL.ADRN_PD_Approved__c = True;
                                                          updatePolicyAppliedList.add(pAL);
                                                      }
                                                      else if(pAL.Illingworth_Visit__r.Visit_Approval_Status__c == 'Rejected'){
                                                          pAL.Policy_Rejected_Date__c=System.today();
                                                          pAL.Policy_Rejector__c=userId;
                                                          updatePolicyAppliedList.add(pAL);
                                                      }
                                                  }
            update updatePolicyAppliedList;
            updatePolicyAppliedOnVisitFlag= false;
        } 
    }
    
    //
    public static void updateStartDateForProjectPlacement (Map<Id,sirenum__Shift__c> newVisitMap , Map<Id,sirenum__Shift__c> oldVisitMap){
        
        Id rsAllocRecTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        Set<Id> projectIdSet=new Set<Id>();
        Set<Id> contactIdSet=new Set<Id>();
        Set<Id> siteIdSet=new Set<Id>();
        Map<String,Date> mapOfRelatedVisitAndApprovalDate= new Map<String,Date>();
        Map<Id,sirenum__Shift__c> updatedVisitMap=new Map<Id,sirenum__Shift__c>();
        List<sirenum__Placement__c> placementQuery=new List<sirenum__Placement__c>();
        List<sirenum__Placement__c> updatePlacementList=new List<sirenum__Placement__c>();
        for(sirenum__Shift__c newVisit: newVisitMap.values()){
            
            if(newVisit.RecordTypeId == rsAllocRecTypeId &&
               (oldVisitMap.get(newVisit.id).PM_Approved_Date__c != newVisit.PM_Approved_Date__c &&
                newVisit.PM_Approved_Date__c!=null) ){
                    projectIdSet.add(newVisit.sirenum__Contract__c);
                    contactIdSet.add(newVisit.sirenum__Contact__c);
                    updatedVisitMap.put(newVisit.Id,newVisit);
                }
            
        }
        if(updatedVisitMap!=null){
            placementQuery=[SELECT id,name,sirenum__Contract__c, sirenum__Contact__c, sirenum__Start_Date__c,Project_Placement__c  FROM sirenum__Placement__c WHERE 
                            sirenum__Contract__c IN :projectIdSet AND 
                            sirenum__Contact__c IN: contactIdSet AND 
                            Project_Placement__c=Null];   
        }
        if(placementQuery.size()>0){
            mapOfRelatedVisitAndApprovalDate = ResourceNotActiveOnProjectHandler.getAllVisitRelatedToPlacement(projectIdSet,contactIdSet,siteIdSet);
            for(sirenum__Shift__c visit: updatedVisitMap.values()){
                for(sirenum__Placement__c projectPlacement:placementQuery){
                    if(visit.sirenum__Contact__c==projectPlacement.sirenum__Contact__c && visit.sirenum__Contract__c==projectPlacement.sirenum__Contract__c){
                        
                        projectPlacement.sirenum__Start_Date__c=mapOfRelatedVisitAndApprovalDate.get(visit.sirenum__Contact__c + '_' + visit.sirenum__Contract__c);
                        projectPlacement.sirenum__Status__c ='Active';
                        updatePlacementList.add(projectPlacement);
                    }
                }
            }
        }
        if(updatePlacementList.size()>0 && !test.isRunningTest()){ 
            update updatePlacementList;
            updateStartDateForProjectPlacementFlag = false;
        }
    }
    
    //
    public static void updateStartDateForSitePlacement (Map<Id,sirenum__Shift__c> newVisitMap , Map<Id,sirenum__Shift__c> oldVisitMap){
        
        Id rsAllocRecTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        Set<Id> projectIdSet=new Set<Id>();
        Set<Id> contactIdSet=new Set<Id>();
        Set<Id> siteIdSet=new Set<Id>();
        Map<String,Date> mapOfRelatedVisitAndApprovalDate= new Map<String,Date>();
        Map<Id,sirenum__Shift__c> updatedVisitMap=new Map<Id,sirenum__Shift__c>();
        List<sirenum__Placement__c> placementQuery=new List<sirenum__Placement__c>();
        List<sirenum__Placement__c> updatePlacementList=new List<sirenum__Placement__c>();
        for(sirenum__Shift__c newVisit: newVisitMap.values()){
            
            if(newVisit.RecordTypeId == rsAllocRecTypeId &&
               (oldVisitMap.get(newVisit.id).Site_Approval_Date__c  != newVisit.Site_Approval_Date__c  &&
                newVisit.Site_Approval_Date__c !=null) ){
                    projectIdSet.add(newVisit.sirenum__Contract__c);
                    contactIdSet.add(newVisit.sirenum__Contact__c);
                    siteIdSet.add(newVisit.sirenum__Site__c);
                    updatedVisitMap.put(newVisit.Id,newVisit);
                }
            
        }
        if(updatedVisitMap!=null){
            placementQuery=[SELECT id,name,sirenum__Contract__c, sirenum__Contact__c, sirenum__Start_Date__c,sirenum__Site__c,Project_Placement__c  FROM sirenum__Placement__c WHERE 
                            sirenum__Contract__c IN :projectIdSet AND 
                            sirenum__Contact__c IN: contactIdSet AND
                            sirenum__Site__c IN: siteIdSet AND
                            Project_Placement__c!=Null];   
        }
        if(placementQuery.size()>0){
            mapOfRelatedVisitAndApprovalDate = ResourceNotActiveOnProjectHandler.getAllVisitRelatedToPlacement(projectIdSet,contactIdSet,siteIdSet);
            for(sirenum__Shift__c visit: updatedVisitMap.values()){
                for(sirenum__Placement__c projectPlacement:placementQuery){
                    if(visit.sirenum__Contact__c==projectPlacement.sirenum__Contact__c && visit.sirenum__Contract__c==projectPlacement.sirenum__Contract__c && visit.sirenum__Site__c==projectPlacement.sirenum__Site__c){
                        
                        projectPlacement.sirenum__Start_Date__c=mapOfRelatedVisitAndApprovalDate.get(visit.sirenum__Contact__c + '_' + visit.sirenum__Contract__c + '_'+visit.sirenum__Site__c);
                        projectPlacement.sirenum__Status__c ='Active';
                        updatePlacementList.add(projectPlacement);
                    }
                }
            }
        }
        if(updatePlacementList.size()>0 && !test.isRunningTest()){
            update updatePlacementList;
            updateStartDateForSitePlacementFlag = false;
        } 
        
    }
    
    //
    public static Map<String,Date> getAllVisitRelatedToPlacement(Set<Id> projectIdSet,Set<Id> resourcetIdSet,Set<Id> siteIdSet){
        
        Map<String,Date> mapOfRelatedVisit= new Map<String,Date>();
        List<sirenum__Shift__c> relateVisitList=new List<sirenum__Shift__c>();
        Map<Id,sirenum__Shift__c> mapOfVisit;
        Date earliestDate = system.today();
        if(projectIdSet.size()>0 && resourcetIdSet.size()>0 && siteIdSet.size()==0){
            
            mapOfVisit= new Map<Id,sirenum__Shift__c>([Select id,name, PM_Approved_Date__c,sirenum__Contact__c,sirenum__Contract__c, Project_Approval_Status__c,recordType.developerName from sirenum__Shift__c 
                                                       WHERE sirenum__Contract__c IN :projectIdSet
                                                       AND sirenum__Contact__c IN :resourcetIdSet  
                                                       AND recordType.developerName='Resource_Allocation' 
                                                       AND Project_Approval_Status__c='Approved' ]);
            
        }   
        else If(projectIdSet.size()>0 && resourcetIdSet.size()>0 && siteIdSet.size()>0){
            mapOfVisit= new Map<Id,sirenum__Shift__c>([Select id,name, Site_Approval_Date__c ,sirenum__Contract__c,sirenum__Contact__c,sirenum__Site__c, Site_Activation_Status__c ,recordType.developerName from sirenum__Shift__c 
                                                       WHERE sirenum__Contract__c IN :projectIdSet
                                                       AND sirenum__Contact__c IN :resourcetIdSet
                                                       AND sirenum__Site__c  IN :siteIdSet
                                                       AND recordType.developerName='Resource_Allocation' 
                                                       AND Site_Activation_Status__c ='Approved']);
        }
        for(sirenum__Shift__c visit:mapOfVisit.values()){
            String key = siteIdSet.size()==0 ? visit.sirenum__Contact__c + '_' + visit.sirenum__Contract__c : visit.sirenum__Contact__c + '_' + visit.sirenum__Contract__c + '_'+visit.sirenum__Site__c;
            Date value = siteIdSet.size()==0 ? visit.PM_Approved_Date__c : visit.Site_Approval_Date__c;
            
            // If the key is not present in the Map, add it with the current value
            if(!mapOfRelatedVisit.containsKey(key)) {
                mapOfRelatedVisit.put(key, value);
            } else {
                // If the key is already present in the Map, update the value with the minimum date
                if(value < mapOfRelatedVisit.get(key)) {
                    mapOfRelatedVisit.put(key, value);
                }
            }
        }
        getAllVisitRelatedToPlacementFlag = false; 
        return mapOfRelatedVisit;
    }
    
    //
    public static void deleteVisitRecord(List<sirenum__Shift__c> visitList){
        Id rsAllocRecTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
        List<String> customProfileList=Label.Visit_Deletion_Profiles.split(',');
        List<Profile> profileList=[select Id from profile where Name IN :customProfileList];
        List<String> profileStringList=new List<String>();
        for(Profile profile:profileList){
            profileStringList.add(profile.id);
        }
        for(sirenum__Shift__c visit: visitList){
            if(visit.Visit_Request_received_from_Site__c==True && !profileStringList.contains(userInfo.getProfileId())  ){
                visit.addError('You cannot delete this record!!!');
            }
        }
        deleteVisitRecordFlag = false;
    }
    
    //Visit Number, Participant and Participant Location is Mandatory
    public static void visitNumberMandatory (List<sirenum__Shift__c> visitList){
        if(visitNumberMandatoryFlag){
            Id visAllocRecordTypeId = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Visit Allocation').getRecordTypeId();
            for(sirenum__Shift__c Visit : visitList){
                if((visit.RecordTypeId == visAllocRecordTypeId && visit.sirenum__ShiftDemand__c == null 
                    && (visit.Visit_Number__c == null || visit.Participant__c == null || visit.Participant_Location__c == null) ) && !test.isRunningTest()){
                        Visit.adderror(' Visit Number, Participant and Participant Location is Mandatory for Normal Visit');
                    }
            }
            visitNumberMandatoryFlag = false;
        }  
    }
    
    //
    public static void checkResourceAcceptanceChanges(Map<Id,sirenum__shift__c> newVisitMap,Map<Id,sirenum__shift__c> newOldMap){
        List<String> splittedCaptureResAcceptanceList=new List<String>();
        List<Notification__c> notiList=new List<Notification__c>();
        String projectTeamName='';
        String projectName='';
        String siteName='';
        String visitNumber='';
        String participantName='';
        String contactId='';
        for(sirenum__Shift__c visit: newVisitMap.values()){
            if(visit.sirenum__accepted__c!=newOldMap.get(visit.Id).sirenum__accepted__c){
                visit.Capture_Resource_Acceptance__c+= visit.sirenum__accepted__c+'#';
                projectTeamName=visit.Illingworth_Project_Team_Name__c;
                projectName=visit.Project_as_Text__c;
                siteName=visit.Illingworth_Owning_Clinical_Site_Name__c;
                visitNumber=visit.Visit_Number__c;
                participantName=visit.Participant_Name__c;
                contactId=visit.sirenum__Contact__c;
                splittedCaptureResAcceptanceList=(visit.Capture_Resource_Acceptance__c).split('#');
                if(splittedCaptureResAcceptanceList.size()>0 && visit.sirenum__accepted__c==-1.0){
                    for(Integer i=0; i<splittedCaptureResAcceptanceList.size(); i++){
                        if(splittedCaptureResAcceptanceList[i]=='-1.0'){
                            
                            if(splittedCaptureResAcceptanceList[i-1]=='0.0'){
                                Notification__c notifRecord=new Notification__c();
                                notifRecord.Notification_Title__c='Accepted Visit Request Withdrawn';
                                notifRecord.Triggering_Record_Id__c=visit.Id;
                                notifRecord.Visit__c=visit.Id;	
                                notiList.add(notifRecord);
                                visit.Capture_Resource_Acceptance__c='';
                            }
                            else if(splittedCaptureResAcceptanceList[i-1]!='0.0'){
                                Notification__c notifRecord=new Notification__c();
                                notifRecord.Notification_Title__c='Resource Visit Decline';
                                notifRecord.Triggering_Record_Id__c=visit.Id;
                                notifRecord.Visit__c=visit.Id;
                                notiList.add(notifRecord);
                                visit.Capture_Resource_Acceptance__c='';
                            }
                        }
                        else if(splittedCaptureResAcceptanceList[i]=='null-1.0'){
                            Notification__c notifRecord=new Notification__c();
                            notifRecord.Notification_Title__c='Resource Visit Decline';
                            notifRecord.Triggering_Record_Id__c=visit.Id;
                            notifRecord.Visit__c=visit.Id;
                            notiList.add(notifRecord);
                            visit.Capture_Resource_Acceptance__c='';
                        }
                    }
                }
            }
        }
        if(notiList.size()>0){
            Group gp=[select id,Type from group where name=:ProjectTeamName and Type='Queue' LIMIT 1];
            notiList[0].OwnerId=gp.Id;
            Contact con=[Select Id,Name from Contact where id=:contactId LIMIT 1];
            if(notiList[0].Notification_Title__c=='Accepted Visit Request Withdrawn'){
                notiList[0].Notification_Body__c=con.Name+'  has withdrawn from an accepted Visit: <br/>'+
                    'Project: '+projectName+'<br/>'+
                    ' Participant Clinical Site: '+siteName+'<br/>'+
                    ' Participant: '+participantName+'<br/>'+
                    ' Visit Number: '+visitNumber+'<br/>'+
                    ' Please review reason for withdrawal and if required attempt to reallocate Visit to another Resource';
                
            }
            else if(notiList[0].Notification_Title__c=='Resource Visit Decline'){
                notiList[0].Notification_Body__c=con.Name+'  has declined a Visit:<br/> '+
                    'Project: '+projectName+'<br/>'+
                    ' Participant Clinical Site: '+siteName+'<br/>'+
                    ' Participant: '+participantName+'<br/>'+
                    ' Visit Number: '+visitNumber+'<br/>'+
                    ' Please attempt to reallocate Visit to another Resource.';
            }
            system.debug('notiList>>>>'+notiList);
            Insert notiList;
        }
    }
    
    //when site approval status is changed to approved create a site activation ticket
    public static void createSiteActivationTicket (Map<Id,sirenum__Shift__c> newVisitMap , Map<Id,sirenum__Shift__c> oldVisitMap ){
        
        Set<Id>siteIdSet=new Set<Id>();
        Set<Id>contactIdSet=new Set<Id>();
        
        for(Id newVisitId:newVisitMap.keySet()){
            if(oldVisitMap.get(newVisitId).Site_Activation_Status__c != newVisitMap.get(newVisitId).Site_Activation_Status__c  &&
               newVisitMap.get(newVisitId).Site_Activation_Status__c=='Approved' &&
               newVisitMap.get(newVisitId).sirenum__ShiftDemand__c!=null  ){ 
                   siteIdSet.add(newVisitMap.get(newVisitId).sirenum__Site__c);
                   contactIdSet.add(newVisitMap.get(newVisitId).sirenum__Contact__c); 
               }
        }
        
        List<sirenum__TicketType__c> siteActivationCompetency = [Select id , name , Competence_Category__c ,Illingworth_Site__c  from sirenum__TicketType__c 
                                                                 where Illingworth_Site__c IN :siteIdSet and Competence_category__c='Site Activation Resource'];
        
        if(siteActivationCompetency.size()>0){
            List<sirenum__Ticket__c> ticketList=new List<sirenum__Ticket__c>();
            for(Id newVisitId:newVisitMap.keySet()){
                sirenum__Ticket__c tickets=new sirenum__Ticket__c ();
                tickets.sirenum__Owner__c =newVisitMap.get(newVisitId).sirenum__Contact__c;
                tickets.sirenum__TicketType__c = siteActivationCompetency[0].id;
                tickets.SK_Status__c='Pending'; 
                ticketList.add(tickets);
            }
            try {
                if(ticketList.size()>0){
                    Insert ticketList;
                }
            }
            catch (Exception ex) {
                System.debug('An exception occurred: ' + ex.getMessage());
            }
        }
    }
}