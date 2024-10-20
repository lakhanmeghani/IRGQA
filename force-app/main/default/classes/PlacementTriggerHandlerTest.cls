@isTest
public class PlacementTriggerHandlerTest {
    @isTest
    public static void setJobType(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        List<Contact> resource1 = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        List<sirenum__Team__c> visitType = DataFactory.createVisitType(project,jobtype);
        sirenum__Placement__c projectPlacement = DataFactory.createPlacement(project,resource1[0],visitType[0]);
        
        delete projectPlacement;
    }
}