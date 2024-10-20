@isTest
public class ProjectTriggerHandlerTest {
    
    @isTest
    public static void updateDateAndOffSiteActivitiesUpdate(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__SirenumGroup__c sirenumGroup = DataFactory.createSirenumGroup(project);
        sirenum__GroupCriterion__c criteria = DataFactory.createSirenumGroupCriterion(sirenumGroup);
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource1 = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        List<sirenum__Team__c> visitType = DataFactory.createVisitType(project,jobtype);
        sirenum__Placement__c projectPlacement = DataFactory.createPlacement(project,resource1[0],visitType[0]);
        
        //Update Project
        project.Id = project.Id;
        project.Name ='612: DNLI-E-0001';
        project.Off_site_Activities__c = 'Test off site Activities Update';
        update project;
        
    }
}