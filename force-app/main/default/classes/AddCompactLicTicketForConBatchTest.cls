@isTest
private class AddCompactLicTicketForConBatchTest {
	
    static testMethod void testBatchJob(){
    User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        Contact resource = DataFactory.createContactForCompactLicense(RecruitmentManager1,account,jobtype);
        
        sirenum__TicketType__c workStateCompetency = new sirenum__TicketType__c();
        workStateCompetency.Name ='California';
        workStateCompetency.Competence_Category__c='Work State';
        workStateCompetency.Work_Country__c = 'USA';
        workStateCompetency.Work_State__c  = 'California';
        workStateCompetency.Licensed_In_State_Competency__c = true;
        Insert workStateCompetency;
        
        Compact_Licence__c compactLicense = DataFactory.createCompactLicenseRecord();
        Test.startTest();
        AddCompactLicTicketForConBatch batchJob = new AddCompactLicTicketForConBatch();
        Database.executeBatch(batchJob);
        
        sirenum__ticket__c[] createdTickets = [SELECT Id, sirenum__TicketType__c, sirenum__Owner__c, sirenum__Valid_until__c, SK_Status__c FROM sirenum__ticket__c];
        System.assertEquals(1, createdTickets.size(), 'Expected one ticket to be created');

        Test.stopTest();
    }
}