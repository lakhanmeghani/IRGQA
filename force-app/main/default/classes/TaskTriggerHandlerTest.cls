@isTest
public class TaskTriggerHandlerTest {
    @isTest
    public static void ActiveOnProjectTest(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource1 = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        List<sirenum__Team__c> visitType = DataFactory.createVisitType(project,jobtype);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
        
        Test.startTest();
        
        //Visit
        sirenum__Shift__c visit1 = new sirenum__Shift__c();
        Id RecordTypeIdvisit1 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        visit1.RecordTypeId = RecordTypeIdvisit1 ;
        visit1.sirenum__Contract__c = project.id;
        visit1.sirenum__Team__c = visitType[0].id;
        visit1.Participant__c = participant.id;
        visit1.Participant_Location__c = participantLocation.id;
        Time nullTime = Time.newInstance(00, 00, 00 ,0000); 
        Time endTime = Time.newInstance(23, 59, 00 ,0000);
        visit1.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit1.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit1.Visit_Request_received_from_Site__c = true;
        visit1.Target_Date__c = Date.parse('02/02/22');
        visit1.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit1.Clinical_Site__c = clinicalSite.id;
        insert visit1;
        
        Task tsk = DataFactory.createTask(visit1);
        
        Test.stopTest();
    }
}