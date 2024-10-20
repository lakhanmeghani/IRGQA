public class assetAssignmentTriggerHandler {
    public static Boolean fireError = true;
    
    //
    public static void populatedResource(list<Illingworth_Asset_Assignment__c> assetAssgmntList){
        List<Asset> updateAssets = new List<Asset>();
        set<Id> assetIds = new set<id>();
        map<id,list<Illingworth_Asset_Assignment__c>> assetvsAssignments = new map<id,list<Illingworth_Asset_Assignment__c>>();
        for(Illingworth_Asset_Assignment__c assgmnt : assetAssgmntList){
            assgmnt.Assignment_Active__c  = true; 
            assetIds.add(assgmnt.Assigned_Asset__c);
            Asset assetToUpdate = new Asset(
                Id = assgmnt.Assigned_Asset__c,
                Asset_Location_Resource__c = assgmnt.Asset_Location_Resource__c 
            );
            updateAssets.add(assetToUpdate);
        }
        if(updateAssets.size()>0){
            // fireError = true;
            update updateAssets;
        } 
        
        map<id,Illingworth_Asset_Assignment__c> assetVsAssgmnts = new map<id,Illingworth_Asset_Assignment__c>();
        list<Illingworth_Asset_Assignment__c> listOfExistingAssignments = new list<Illingworth_Asset_Assignment__c>();
        listOfExistingAssignments = [select id , Assignment_Active__c ,Assignment_End_Date__c,Assigned_Asset__c from Illingworth_Asset_Assignment__c where Assigned_Asset__c In: assetIds  order by createdDate Desc LIMIT 1];
        list<Illingworth_Asset_Assignment__c> listOfExistingAssignmentsUpdate = new list<Illingworth_Asset_Assignment__c>();
        if(listOfExistingAssignments.size()>0){
            for(Illingworth_Asset_Assignment__c assgmnt : listOfExistingAssignments){
                assetVsAssgmnts.put(assgmnt.Assigned_Asset__c,assgmnt);
            }
            
            for(Illingworth_Asset_Assignment__c assgmnt : assetAssgmntList){
                assgmnt.Assignment_Active__c = true;
                if(assetVsAssgmnts.containskey(assgmnt.Assigned_Asset__c)){
                    assetVsAssgmnts.get(assgmnt.Assigned_Asset__c).Assignment_End_Date__c = assgmnt.Assignment_Start_Date__c;
                    assetVsAssgmnts.get(assgmnt.Assigned_Asset__c).Assignment_Active__c  = false; 
                    listOfExistingAssignmentsUpdate.add(assetVsAssgmnts.values());
                }
            }
            if(listOfExistingAssignmentsUpdate.size()>0){
                fireError = false;
                update listOfExistingAssignmentsUpdate;
            }
        }
    }
    
    //
    public static void updateEndDateOnAssmnt(Map<Id, Illingworth_Asset_Assignment__c> oldMap, Map<Id, Illingworth_Asset_Assignment__c> newMap ){
        
        set<Id> assetIds = new set<id>();
        Map<Id, Date> oldDateMap = new Map<Id, Date>();
        for (Illingworth_Asset_Assignment__c asmnt : newMap.values()) {
            if (oldMap.get(asmnt.Id).Assignment_Start_Date__c != newMap.get(asmnt.Id).Assignment_Start_Date__c && asmnt.Assignment_Active__c == true) {
                assetIds.add(asmnt.Assigned_Asset__c);
                oldDateMap.put(asmnt.id,oldMap.get(asmnt.Id).Assignment_Start_Date__c);
            }
        } 
        
        list<Illingworth_Asset_Assignment__c> listOfExistingAssignments = new list<Illingworth_Asset_Assignment__c>();
        listOfExistingAssignments = [select id ,name, Assignment_End_Date__c,Assigned_Asset__c from Illingworth_Asset_Assignment__c where Assigned_Asset__c In: assetIds and Assignment_End_Date__c =:oldDateMap.values()];
        list<Illingworth_Asset_Assignment__c> listOfExistingAssignmentsUpdate = new list<Illingworth_Asset_Assignment__c>();
        
        map<id,Illingworth_Asset_Assignment__c> assetVsAssgmnts = new map<id,Illingworth_Asset_Assignment__c>();
        if(listOfExistingAssignments.size()>0){
            for(Illingworth_Asset_Assignment__c assgmnt : listOfExistingAssignments){
                assetVsAssgmnts.put(assgmnt.Assigned_Asset__c,assgmnt);
            }
            for(Illingworth_Asset_Assignment__c assgmnt : newMap.values()){
                if(assetVsAssgmnts.containskey(assgmnt.Assigned_Asset__c)){
                    assetVsAssgmnts.get(assgmnt.Assigned_Asset__c).Assignment_End_Date__c = assgmnt.Assignment_Start_Date__c;
                    listOfExistingAssignmentsUpdate.add(assetVsAssgmnts.values());
                }
            }
        }
        if(listOfExistingAssignmentsUpdate.size()>0){ 
            fireError = false;
            update listOfExistingAssignmentsUpdate;
        }
    }
    
    //
    public static void validationErrors(Map<Id, Illingworth_Asset_Assignment__c> oldMap, Map<Id, Illingworth_Asset_Assignment__c> newMap ){
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String proflieName = profileList[0].Name;
        for (Illingworth_Asset_Assignment__c asmnt : newMap.values()) {
            if( asmnt.Assignment_Active__c == false &&  (proflieName!='System Administrator' && proflieName!='Day to Day System Admin') &&
               ((oldMap.get(asmnt.Id).Assignment_Start_Date__c != newMap.get(asmnt.Id).Assignment_Start_Date__c )|| (oldMap.get(asmnt.Id).Assignment_End_Date__c  != newMap.get(asmnt.Id).Assignment_End_Date__c) ) ){
                   if(fireError){
                       asmnt.adderror('Start Date End date cannot be edited by the users for an inactive assignment.');
                   }
               } 
        } 
    }
    
    // Throw Validation on asset assignment when recource on the record is changed and that resource is correct resource
    public static void validationErrorsForResource( List<Illingworth_Asset_Assignment__c> assetAssignmentList, Map<Id,Illingworth_Asset_Assignment__c> oldAssetAssignmentMap ){
        Set<Id> contactIdSet=new Set<Id>();
        Map<Id, Illingworth_Asset_Assignment__c> assignmentMap = new Map<Id, Illingworth_Asset_Assignment__c>();
        List<String> contactStatusList=new List<String>{'Training','Hired','Onboarding','Active','Re-activated On Bank'};
            
            Id resourceRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        Id assetLocationRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Asset Location').getRecordTypeId();
        
        for(Illingworth_Asset_Assignment__c asmnt : assetAssignmentList){
            if((oldAssetAssignmentMap==null || asmnt.Asset_Location_Resource__c!=oldAssetAssignmentMap.get(asmnt.id).Asset_Location_Resource__c)){
                if(asmnt.Asset_Location_Resource__c !=null){
                    contactIdSet.add(asmnt.Asset_Location_Resource__c); 
                    assignmentMap.put(asmnt.Asset_Location_Resource__c, asmnt);
                }   
            }
        }
        //Get All Contact
        if(contactIdSet.size()>0){ 
            for (Contact contactRec : [Select id,name, Activity_Status__c,recordTypeId  from Contact where Id IN :contactIdSet]) {
                // Check if Activity_Status__c is not 'Training','Hired','Onboarding','Active Bank','Re-activated On Bank'
                if((contactRec.recordTypeId!= resourceRecordTypeId && contactRec.recordTypeId!= assetLocationRecordTypeId)){
                    Illingworth_Asset_Assignment__c assignmentWithError = assignmentMap.get(contactRec.Id);
                    if (assignmentWithError != null) {
                        assignmentWithError.addError('Choose a resource or a asset location.');
                    }
                }
                else if (!contactStatusList.contains(contactRec.Activity_Status__c)) {
                    Illingworth_Asset_Assignment__c assignmentWithError = assignmentMap.get(contactRec.Id);
                    if (assignmentWithError != null) {
                        assignmentWithError.addError('Resource must have a valid Activity Status for Asset Assignment.');
                    }
                }
            }
        }
    }
}