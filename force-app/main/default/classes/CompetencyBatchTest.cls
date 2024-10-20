@isTest
public class CompetencyBatchTest {
    
    @isTest
    static void testCompetencyBatch() {
        
        // Start the batch
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Site__c testClinicalSite = DataFactory.createSite(project);
        List<Contact> Resource  = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__TicketType__c Competency = new sirenum__TicketType__c();
        Competency.Name ='Test Project Activation';
        Competency.Competence_Category__c='Site Activation Resource';
        Competency.Illingworth_Project__c=project.id;
        Competency.Effective_From__c =system.today().addDays(-5);
        Competency.Date_Received_by_Illingworth__c=system.today().addDays(+20);
        competency.Severity__c = 'Low';
        Insert Competency;
        
		sirenum__TicketType__c Competency2 = new sirenum__TicketType__c();
        Competency2.Name ='Test Project Activation2';
        Competency2.Competence_Category__c='Site Activation Resource';
        Competency2.Illingworth_Project__c=project.id;
        Competency2.Severity__c = 'Low';
        Competency2.Effective_From__c =system.today().addDays(+5);
        Competency2.Date_Received_by_Illingworth__c=system.today().addDays(+20);
        Insert Competency2;
     /*   sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
        Competency.Effective_From__c =system.today().addDays(-5);
        Competency.Date_Received_by_Illingworth__c=system.today().addDays(-2);
        update Competency;
        sirenum__Location__c locaction = DataFactory.CreateLocation(); */
        sirenum__Location__c location=DataFactory.CreateLocation();
        sirenum__Location__c location2 = new sirenum__Location__c();
        location2.Name ='Canada';
        Insert location2;
        List<sirenum__Sirenum_Condition_Membership__c> CompCondition = DataFactory.createCompetencyCondition (RecruitmentManager1,account,jobtype,Competency,testClinicalSite,location); 
        List<sirenum__Sirenum_Condition_Membership__c> CompCondition2 = DataFactory.createCompetencyCondition (RecruitmentManager1,account,jobtype,Competency2,testClinicalSite,location2); 

        
        Test.startTest();
        CompetencyBatch batch = new CompetencyBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testSchedulerCompetencyBatch() {
        Test.startTest();
        CompetencyBatchScheduler sh1 = new CompetencyBatchScheduler();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
}