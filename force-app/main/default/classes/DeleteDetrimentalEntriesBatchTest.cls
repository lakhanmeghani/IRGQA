@IsTest
public class DeleteDetrimentalEntriesBatchTest {
    @isTest
    static void UpdateExistingLogEntriesTestData() {
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        List<Contact> Resource  = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
     //   List<sirenum__Team__c> visitTypeList = DataFactory.createVisitType(project,jobtype);
     //   Participant__c participant = DataFactory.createParticipant(clinicalSite);
     //   sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
     //   List<sirenum__Ticket__c> Qualification = DataFactory.createQualifications(Resource[0],Competency);
      //  sirenum__Location__c locaction = DataFactory.CreateLocation();
       // List<sirenum__Shift__c> normalResReqVisitList = DataFactory.createNormalAndRsrReqVisit(jobtype,clinicalSite,project,Participant,participantLocation,visitTypeList[0]); 
     //   List<sirenum__Shift__c> resAllocationVisitList = DataFactory.CreateVisitResAlloc(project,visitTypeList[0],Participant ,participantLocation,clinicalSite,resource,normalResReqVisitList[0],locaction);
     //   resAllocationVisitList[0].sirenum__Scheduled_Start_Time__c = Date.newInstance(2024, 1, 1);
        
       // sirenum__LogEntry__c LogEntry = DataFactory.CreateLogEntry(Competency,resource[0],resAllocationVisitList[0]);
        
        sirenum__LogEntry__c newlog = new sirenum__LogEntry__c();
        newlog.sirenum__Category__c ='Missing Tickets';
        newlog.sirenum__Details__c = 'Missing Qualification: France';
        newlog.sirenum__Severity__c = 'High';
        newlog.sirenum__Created_By_Saving__c = true;
        newlog.sirenum__Contact__c = resource[0].Id; 
        newlog.Competency__c =Competency.id;
        Insert newlog;
        
      //  List<sirenum__Sirenum_Condition_Membership__c> CompCondition = DataFactory.createCompetencyCondition (RecruitmentManager1,account,jobtype,Competency,clinicalSite,locaction);
     //   Illingworth_Ticket_Status__c Ticket = DataFactory.TicketStatus(Resource,CompCondition[0],Competency);   
        
        DeleteDetrimentalEntriesBatch batch= new DeleteDetrimentalEntriesBatch();
        Database.executeBatch(batch);
    }
}