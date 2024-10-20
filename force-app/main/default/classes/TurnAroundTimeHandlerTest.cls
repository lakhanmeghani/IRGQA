@isTest
public class TurnAroundTimeHandlerTest {
    @isTest
    public static void createTestTickets(){
        User systemAdminUser = DataFactory.createUser();
        Project_Team__c prjTeam = DataFactory.createProjectTeam();
        Account testAccount = DataFactory.createAccount();
        sirenum__ProActiveContract__c testProject = DataFactory.createProject(testAccount, systemAdminUser, prjTeam);
        sirenum__Site__c testClinicalSite = DataFactory.createSite(testProject);
        sirenum__Job_Type__c jobType=DataFactory.createJobType();
        List<sirenum__Team__c> testVisitType = DataFactory.createVisitType(testProject,jobType);
        
        //Visit2
        sirenum__Shift__c visit2 = new sirenum__Shift__c();
        Id RecordTypeIdvisit2 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
        visit2.RecordTypeId = RecordTypeIdvisit2 ;
        visit2.sirenum__Contract__c = testProject.id;
        visit2.Request_Type__c ='Resource Request'; 
        visit2.sirenum__Team__c = testVisitType[0].id;
        visit2.sirenum__Scheduled_Start_Time__c = system.now()-1;
        visit2.sirenum__Scheduled_End_Time__c = system.now();
        visit2.Visit_Request_received_from_Site__c = true;
        visit2.Target_Date__c = Date.parse('02/02/22');
        visit2.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit2.Clinical_Site__c = testClinicalSite.id;
        visit2.sirenum__Broadcasts__c = 3;
        visit2.Project_Approval_Status__c='Approved';
        visit2.PM_Approved_Date__c =Date.parse('02/09/22');
        visit2.Illingworth_Project_Decline_Date__c= Date.parse('09/09/22');
        visit2.Resource_Decline_Reason__c='Other';
        visit2.Resource_Decline_Text__c='Resource Did not Accepted';
        visit2.sirenum__Site__c = testClinicalSite.id;
        visit2.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00 );
        visit2.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit2.Resourcing_Status__c ='Pending Resource Allocation';
        visit2.Through_Data_Wizard__c=true;
        
        Insert visit2;
        visit2.Resourcing_Status__c ='Recruitment Required';
        update visit2;
    }
}