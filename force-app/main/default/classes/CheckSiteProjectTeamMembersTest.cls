@isTest
public class CheckSiteProjectTeamMembersTest {  
    
    static testMethod void CheckSiteTeam(){
        
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
        
        projectPlacement.sirenum__Site__c = clinicalSite.id;
        update projectPlacement;
        
        //Update Site Name
        clinicalSite.Name = 'Update Site Name';
        clinicalSite.IllingworthCountry__c='USA';
        clinicalSite.sirenum__State__c='Alaska';
        Update clinicalSite;
        
        List<sirenum__Site__c> listOfSite = new List<sirenum__Site__c>();
        listOfSite.add(clinicalSite);
        
        //Create Parent Group
		Group grp = new Group();
		grp.name = projectTeam.Name;
		grp.Type = 'Regular'; 
		Insert grp; 

		/*Create Group Member
		GroupMember grpMem1 = new GroupMember();
		grpMem1.UserOrGroupId = UserInfo.getUserId();
		grpMem1.GroupId = grp.Id;
		Insert grpMem1;

	    CheckSiteProjectTeamMemberHandler.fakeMethod();*/
    }
}