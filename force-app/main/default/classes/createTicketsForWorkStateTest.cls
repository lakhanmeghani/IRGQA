@isTest
public class createTicketsForWorkStateTest {
    

    @TestSetUp
    private static void setTestData(){
     User RecruitmentManager1 = DataFactory.createUser(); 
	 Account acc = DataFactory.createAccount();
     Project_Team__c projectTeam = DataFactory.createProjectTeam();
     DataFactory.createJobType();  
     sirenum__ProActiveContract__c project = DataFactory.createProject(acc,RecruitmentManager1,projectTeam);  
     sirenum__Site__c clinicalSite = DataFactory.createSite(project);  
     sirenum__Job_Type__c jobType = [Select Id from sirenum__Job_Type__c limit 1];
        //user RecruitmentManager1 = [Select Id from user limit 1];
        List<Contact> Resource  = DataFactory.createContact(RecruitmentManager1, acc, jobtype);
        Resource[0].Illing_Licenced_in_States_Province__c = 'California';
        Resource[0].Work_Country__c = 'USA';
        update Resource[0]; 
        
        sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
        Competency.Work_State__c ='California';
        Competency.Work_Country__c='USA'; 
        Competency.Competence_Category__c = 'Work State';
        Competency.Generate_Competency_Condition__c = false;
        update Competency;
        
        /*List<sirenum__Team__c> visitTypeList = DataFactory.createVisitType(project,jobtype);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
        List<sirenum__Ticket__c> Qualification = DataFactory.createQualifications(Resource[0],Competency);
        sirenum__Location__c locaction = DataFactory.CreateLocation();*/
    }
    @isTest
    static void createTicketsForWorkState_class() {
       /* Account account = [select Id from Account limit 1];
        sirenum__Job_Type__c jobType = [Select Id from sirenum__Job_Type__c limit 1];
        List<Contact> Resource = [Select Id from Contact limit 1];
        user RecruitmentManager1 = [Select Id from user limit 1];
        sirenum__ProActiveContract__c project = [Select Id from sirenum__ProActiveContract__c limit 1];
        sirenum__TicketType__c Competency = [Select Id from sirenum__TicketType__c limit 1];
        
        sirenum__Site__c clinicalSite = [Select Id from sirenum__Site__c limit 1];
        sirenum__Location__c locaction = [Select Id from sirenum__Location__c limit 1];
       
       List<sirenum__Sirenum_Condition_Membership__c> CompCondition = DataFactory.createCompetencyCondition (RecruitmentManager1,account,jobtype,Competency,clinicalSite,locaction);
        CompCondition[0].Work_Country__c = '';   
        CompCondition[0].Work_State__c = 'California';
        update CompCondition[0];*/
        
        Test.startTest();
        createTicketsForWorkState batch= new createTicketsForWorkState();
        Database.executeBatch(batch);
        Test.stopTest();
        
    }
}