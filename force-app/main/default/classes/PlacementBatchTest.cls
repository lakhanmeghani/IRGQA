@isTest
private class PlacementBatchTest {
    
    @testSetup
    static void createData(){
        Account testaccount=DataFactory.createAccount();
        User recruitmentManager=DataFactory.createUser();
        Project_Team__c projectTeam=DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project=DataFactory.createProject(testaccount,recruitmentManager,projectTeam);
        sirenum__Site__c site=DataFactory.createSite(project);
        sirenum__Job_Type__c jobType=DataFactory.createJobType();
        List<sirenum__Team__c> visitTypeList=DataFactory.createVisitType(project, jobtype);
        sirenum__Team__c visitType=visitTypeList[0];
        List<Contact> contactList=DataFactory.createContact(recruitmentManager,testaccount,jobtype);
        Contact contact=contactList[0];
        
        //create parent placement from data factory
        sirenum__Placement__c parentPlacement=DataFactory.createPlacement(project, contact, visitType);
        parentPlacement.Name='test batch';
        parentPlacement.sirenum__Status__c='Active';
        parentPlacement.sirenum__Start_Date__c=Date.today().addDays(-3);       
        parentPlacement.sirenum__End_Date__c=Date.today().addDays(-1);
        parentPlacement.Reason_for_Completion__c = 'Project Complete';
        update parentPlacement;
        
        //create child placement from data factory
        sirenum__Placement__c childPlacement=DataFactory.createSitePlacement(project,contact,visitType,parentPlacement,site);
        childPlacement.Name = 'Test Child Placement';
        childPlacement.Project_Placement__c = parentPlacement.Id;
        childPlacement.sirenum__Status__c='Active';
        childPlacement.sirenum__Start_Date__c=Date.today().addDays(-3);
        childPlacement.sirenum__End_Date__c = Date.today().addDays(-1);
        childPlacement.Reason_for_Completion__c = 'Project Complete';
        update childPlacement;
    }
    
     @isTest
    	static void testBatchExecution() {
        Test.startTest();
        PlacementBatch batch = new PlacementBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        sirenum__Placement__c parentPlacement=[SELECT Id, Name, Parent_Child__c, sirenum__Status__c FROM sirenum__Placement__c WHERE Name='test batch'];
        sirenum__Placement__c childPlacement=[SELECT Id, Name, Parent_Child__c, sirenum__Status__c FROM sirenum__Placement__c WHERE Name='Test Child Placement'];
        System.assertEquals('Completed', parentPlacement.sirenum__Status__c, 'Placement status should be updated to Completed');
        System.assertEquals('Completed', childPlacement.sirenum__Status__c, 'Placement status should be updated to Completed');
    }  
    
    
}