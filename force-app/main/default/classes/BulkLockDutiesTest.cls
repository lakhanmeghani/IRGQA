@isTest
public class BulkLockDutiesTest {
	@isTest
    static void testBulkLock(){
        
        Integer noOfDutiesToInsert=10;
        User RecruitmentManager1 = DataFactory.createUser();
        
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
        sirenum__TicketType__c testCompetencyNurReg = DataFactory.createCompetencyNurReg(project);
        List<sirenum__Team__c> visitTypeList = DataFactory.createVisitType(project,jobtype);
        
        sirenum__Location__c locaction = DataFactory.CreateLocation();
        List<sirenum__Shift__c> normalResReqVisitList = DataFactory.createNormalAndRsrReqVisit(jobtype,clinicalSite,project,Participant,participantLocation,visitTypeList[0]); 
        List<sirenum__Shift__c> resAllocationVisitList = DataFactory.CreateVisitResAlloc(project,visitTypeList[0],Participant ,participantLocation,clinicalSite,resource, normalResReqVisitList[1],locaction);
        
        list<Duty__c> duty = DataFactory.createDutyTypeDuty(noOfDutiesToInsert,FALSE,normalResReqVisitList[0],project);
        for(Duty__c dt:duty){
            dt.Date_of_Duty__c=System.today().addDays(-10);
            dt.Locked__c=False;
        }
        insert duty;
        List<Date> inputDateList = new List<Date>{System.today()};
        List<Integer> updatedDutiesCountList = BulkLockDuties.BulkLockDuty(inputDateList);
        }
}