@IsTest
public class TimesheetFusionServiceTest {

    @TestSetup
    static void setupTestData() {
        // Create sample records for Duty__c and Contact from datafactory
        User RecruitmentManager1 = DataFactory.createUser();
        
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype); // Create contact
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
        sirenum__TicketType__c testCompetencyNurReg = DataFactory.createCompetencyNurReg(project);
        List<sirenum__Team__c> visitTypeList = DataFactory.createVisitType(project, jobtype);
        sirenum__Location__c locaction = DataFactory.CreateLocation();
        List<sirenum__Shift__c> normalResReqVisitList = DataFactory.createNormalAndRsrReqVisit(jobtype, clinicalSite, project, Participant, participantLocation, visitTypeList[0]); 
        List<sirenum__Shift__c> resAllocationVisitList = DataFactory.CreateVisitResAlloc(project, visitTypeList[0], Participant, participantLocation, clinicalSite, resource, normalResReqVisitList[1], locaction);
        List<Duty__c> duty = DataFactory.createDutyTypeDuty(1, true, normalResReqVisitList[0], project); // create duty
    }

    @IsTest
    static void testPostTimesheet() {
        // Simulate the RestRequest for POST
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"timesheetRange":[{"startDate":"2023-01-01","endDate":"2023-12-31"}]}');
        RestContext.request = req;

        // Execute the POST method
        List<Duty__c> resultList = TimesheetFusionService.getTimesheet();
        
        // Assert that the result list is not null and contains expected data
        System.assertNotEquals(null, resultList, 'Duty list should not be null');
     //   System.assert(resultList.size() > 0, 'Duty list should contain records');
        
        /* Assert specific field values for the returned Duty__c records
        System.assertEquals('Approved', resultList[0].Status__c, 'Duty Status should be Approved');
        System.assertEquals(true, resultList[0].Locked__c, 'Duty should be locked'); */
    }

    @IsTest
    static void testGetContactDetails() {
        // Simulate the RestRequest for GET
        RestRequest req = new RestRequest();
        RestContext.request = req;
        
        // Execute the GET method
        List<Contact> resultList = TimesheetFusionService.getContactDetails();
        
        // Assert that the result list is not null and contains expected data
        System.assertNotEquals(null, resultList, 'Contact list should not be null');
        System.assert(resultList.size() > 0, 'Contact list should contain records');
        
        // Assert specific field values for the returned Contact records
        System.assertNotEquals(null, resultList[0].Illingworth_HR_ID_Number__c, 'HR ID should not be null');
    }
}