@isTest 
public class createTicketsForWorkCountryTest {
    
    @isTest
    static void createTicketsForWorkCountry_class() {
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        List<Contact> Resource  = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        Resource[0].Illing_Licenced_in_States_Province__c = 'California';
        Resource[0].Work_Country__c = 'USA';
        update Resource[0];
        
        sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
        Competency.Work_State__c ='';
        Competency.Work_Country__c='USA'; 
        Competency.Competence_Category__c = 'Work Country';
        Competency.Generate_Competency_Condition__c = false;
        update Competency;
        
       // List<sirenum__Team__c> visitTypeList = DataFactory.createVisitType(project,jobtype);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
       // sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
       // List<sirenum__Ticket__c> Qualification = DataFactory.createQualifications(Resource[0],Competency);
        sirenum__Location__c locaction = DataFactory.CreateLocation();
       
        List<sirenum__Sirenum_Condition_Membership__c> CompCondition = DataFactory.createCompetencyCondition (RecruitmentManager1,account,jobtype,Competency,clinicalSite,locaction);
        CompCondition[0].Work_Country__c = 'USA';   
        CompCondition[0].Work_State__c = '';
        update CompCondition[0];
        
        createTicketsForWorkCountry batch= new createTicketsForWorkCountry();
        Database.executeBatch(batch);
        
    }
}