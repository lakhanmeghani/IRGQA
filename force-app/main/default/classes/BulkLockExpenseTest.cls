@isTest
public class BulkLockExpenseTest {
	@isTest
    static void testBulkLock(){
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
        
        irg_Expense__c exp=new irg_Expense__c();
        exp.Project__c = project.Id;
        exp.Expenditure_type__c='Equipment';
        exp.Expense_Task__c='Equipment';
        exp.Locked__c=FALSE;
        insert exp;
        
		List<Date> inputDateList = new List<Date>{System.today()};
        List<String> updatedDutiesCountList = BulkLockExpenses.BulkLockExpense(inputDateList);
    }
    
   /* @isTest
    static void testNegativeBulkLock(){
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
        List<irg_Expense__c> expenseList=new List<irg_Expense__c>();
        for(Integer i=1;i <15000; i++){
        irg_Expense__c exp=new irg_Expense__c(Project__c = project.Id,
                                              Expenditure_type__c='Equipment',
                                              Expense_Task__c='Equipment',
                                              Locked__c=FALSE);
            expenseList.add(exp);
        }
        try{
            insert expenseList;
        }catch(DmlException e){
            System.debug('Exception occured while processing'+e.getMessage());
        }
        
		List<Date> inputDateList = new List<Date>{System.today()};
        List<String> updatedDutiesCountList = BulkLockExpenses.BulkLockExpense(inputDateList);
    } */
}