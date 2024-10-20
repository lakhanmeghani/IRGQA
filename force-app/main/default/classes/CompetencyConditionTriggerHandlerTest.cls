@isTest
public class CompetencyConditionTriggerHandlerTest {
    
    @TestSetup
    static void setDataUp(){
        Group p = [Select Id from Group where Name = 'FIONA'  AND Type = 'Queue' limit 1];
        GroupMember gm = new GroupMember(GroupId = p.Id,UserOrGroupId = UserInfo.getUserId());
        insert gm;
    }
    @isTest 
    public static void createTestCompetencyConditions(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        List<Contact> resource1 = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        List<sirenum__Team__c> visitType = DataFactory.createVisitType(project,jobtype);
        sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
        sirenum__Location__c location = DataFactory.CreateLocation();
        List<sirenum__Sirenum_Condition_Membership__c> compCondList = DataFactory.createCompetencyCondition(RecruitmentManager1,account,jobtype, Competency, clinicalSite,Location);
        
        Illingworth_Ticket_Status__c TicketStatus = new Illingworth_Ticket_Status__c();
        TicketStatus.Resource__c = resource1[0].Id;
        TicketStatus.Competence_Condition__c = compCondList[0].Id;
        TicketStatus.Required_Competency__c = compCondList[0].sirenum__TicketType__c;
        TicketStatus.Job_Type__c = compCondList[0].sirenum__Job_Type__c;
        TicketStatus.Severity__c = compCondList[0].sirenum__Severity__c;
        TicketStatus.Competence_Category__c = compCondList[0].Competence_Category__c;
        Insert TicketStatus;
        
        Project_Ticket_Status__c ProjectTicketStatus = new Project_Ticket_Status__c();
        ProjectTicketStatus.Account__c = account.id;
        ProjectTicketStatus.Resource__c = resource1[0].Id;
        ProjectTicketStatus.Competency_Condition__c = compCondList[0].Id;
        ProjectTicketStatus.Required_Competency__c = compCondList[0].sirenum__TicketType__c;
        ProjectTicketStatus.Severity__c = compCondList[0].sirenum__Severity__c;
        ProjectTicketStatus.Competence_Category__c = compCondList[0].Competence_Category__c;
        Insert ProjectTicketStatus;
        
        sirenum__Location__c loc = new sirenum__Location__c();
        loc.Name ='USA - Alabama';
        Insert loc;
        
        //Create Competency 
        sirenum__TicketType__c competency1 = new sirenum__TicketType__c();
        competency1.Name = 'Alabama Lic';
        competency1.Competence_Category__c = 'RN Mandatory Training';
        competency1.Work_Country__c='USA';
        competency1.Work_State__c='Alabama';
        competency1.sirenum__Searchable_Name__c='Test';
        competency1.LMS_Course_Title__c='Test';
        competency1.Severity__c='Fatal';
        Insert competency1 ;
        
        //Create CompetencyCondition
        sirenum__Sirenum_Condition_Membership__c CompetencyConditionNew = new sirenum__Sirenum_Condition_Membership__c();
        CompetencyConditionNew.sirenum__TicketType__c = competency1.Id;
        CompetencyConditionNew.sirenum__Severity__c = 'Fatal';
        CompetencyConditionNew.Work_Country__c='USA';
        CompetencyConditionNew.Work_State__c='Alabama';
        Insert CompetencyConditionNew;
        
        compCondList[0].Inactive__c=True;
        CompetencyConditionNew.work_State__c='Colorado';
        List<sirenum__Sirenum_Condition_Membership__c> comCondition=new List<sirenum__Sirenum_Condition_Membership__c>();
        comCondition.add(CompetencyConditionNew);
        comCondition.add(compCondList[0]);
        
        Update comCondition;
    }
}