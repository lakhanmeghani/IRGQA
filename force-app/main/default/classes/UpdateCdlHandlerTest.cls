@isTest
public class UpdateCdlHandlerTest {
    
    private static testMethod void testCreate(){ 
        
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        //List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
        
        List<sirenum__Team__c> visitTypeList = DataFactory.createVisitType(project,jobtype);
        
        List<sirenum__Shift__c> normalResReqVisitList = DataFactory.createNormalAndRsrReqVisit(jobtype,clinicalSite,project,Participant,participantLocation,visitTypeList[0]); 
        
        Task tsk = DataFactory.createTask(normalResReqVisitList[0]);
        ContentVersion contentVersion_1 = DataFactory.createContentVersion('Test content','Penguins.jpg',True);
        ContentVersion contentVersion_2 = DataFactory.createContentVersion('Test File','Penguins.jpg',True);
        
        Id assetPoolRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Asset Pool').getRecordTypeId();
        Account acc= new Account();
        acc.Name='Test Account Asset Pool';
        acc.RecordTypeId=assetPoolRecordTypeId;
        acc.Type='Other';
        Insert acc;
        Asset assetRec=DataFactory.createAssetRecord('Test Asset',acc.Id,String.ValueOf(Math.random()),True);
        
        
        Test.startTest();
        
        ContentDocumentLink contentlinkAsset = DataFactory.createContentDocumentLink (contentVersion_2 ,assetRec,True);
       
        ContentDocumentLink contentlinktask = DataFactory.createContentDocumentLink (contentVersion_1 ,tsk,True);
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where Title='Test File'];
        Database.delete(cdList,false);

        Test.stopTest();
 
     }
}