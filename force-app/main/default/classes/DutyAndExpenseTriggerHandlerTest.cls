@IsTest
public class DutyAndExpenseTriggerHandlerTest {
@isTest
    public static void ActiveOnProjectTest(){
        
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
        
        list<Duty__c> duty = DataFactory.createDutyTypeDuty(1,true,normalResReqVisitList[0],project);
        List <irg_Expense__c> expenses=DataFactory.createExpenses(5,true,normalResReqVisitList[0],project);
        
        duty[0].date_of_duty__c = system.today();
        update duty[0];
        
        duty[0].Locked__c=true;
        delete duty[0];
        
        expenses[0].Locked__c=true;
        delete expenses[0]; 
        
        expenses[1].Expense_Owner__c=resource[1].id;
        update expenses[1];
        
        irg_Expense__c exp=new irg_Expense__c();
        exp.Project__c = project.Id;
        exp.Expense_Owner__c=resource[1].id;
        exp.Expense_Task__c = 'Equipment';
        exp.Expenditure_type__c = 'Equipment';
        insert exp;
    }      
}