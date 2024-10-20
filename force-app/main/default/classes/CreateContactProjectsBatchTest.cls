@isTest
private class CreateContactProjectsBatchTest {
    @isTest
    static void testBatchExecution() {
        // Create test data
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);

        List<Contact> resource1 = DataFactory.createContact(RecruitmentManager1, account, jobtype);

        
        Test.startTest();
        CreateContactProjectsBatch batchJob = new CreateContactProjectsBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();

        
        Contact_Project__c createdContactProject = [SELECT Contact__c, Project__c FROM Contact_Project__c LIMIT 1];
        System.assertEquals(resource1[0].Id, createdContactProject.Contact__c, 'Contact Id should match.');
        System.assertEquals(project.Id, createdContactProject.Project__c, 'Project Id should match.');
    }
}