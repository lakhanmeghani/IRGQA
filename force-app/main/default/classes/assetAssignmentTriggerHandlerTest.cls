@isTest
public class assetAssignmentTriggerHandlerTest{
    
    @isTest
    static void assetAssignmentTriggerHandler(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Account assetsAccount = DataFactory.createAssetsAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        List<Contact> Resource  = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        //List<Contact> Resource2  = DataFactory.createContact(RecruitmentManager1, account, null);
        
        Asset assetRec=DataFactory.createAssetRecord('Test Asset',assetsAccount.Id,String.ValueOf(Math.random()),True);
        
        List<Illingworth_Asset_Assignment__c> assetsAssignmentRecord = DataFactory.createAssetAssignment(1,assetRec,Resource[0],True);
        
        List<Illingworth_Asset_Assignment__c> assetsAssignmentRecord2 = DataFactory.createAssetAssignment(1,assetRec,Resource[0],True);
        
        assetsAssignmentRecord[0].Assignment_Start_Date__c = system.today();
        update assetsAssignmentRecord;
        
    }
}