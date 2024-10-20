/**
* 
* @since               : 1st Mar, 2024
* @description         : This Class Contains test methods for AlertsTriggerHandler
*/
@isTest
public class AlertsTriggerHandlerTest {
    
    @isTest
    public static void createLogEntry(){
        
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
     //   List<sirenum__Shift__c> normalResReqVisitList = DataFactory.createNormalAndRsrReqVisit(jobtype,clinicalSite,project,Participant,participantLocation,visitTypeList[0]); 

    
        
        
        //Create Competency 
        sirenum__TicketType__c competency = new sirenum__TicketType__c();
        competency.Name = 'Background Check Declaration (Annual)';
        competency.Competence_Category__c = 'Compliance Documentation';
        competency.Job_Type__c='Research Nurse';
        Insert competency ;
        
        //Create Ticket 
       /* sirenum__Ticket__c Ticket = new sirenum__Ticket__c();
        Ticket.sirenum__TicketType__c = competency.Id;
        Ticket.sirenum__Revoked__c = True;
        Ticket.Valid_Checkbox__c= false;
        Ticket.sirenum__Owner__c = resource[0].Id;
        Ticket.sirenum__Valid_from__c = system.Today();
        Ticket.sirenum__Valid_until__c = system.today()+30;
        Insert Ticket; */
        
        Test.startTest();
        
        sirenum__Shift__c visit3 = new sirenum__Shift__c();
        Id RecordTypeIdvisit3 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        visit3.RecordTypeId = RecordTypeIdvisit3 ;
        visit3.sirenum__Contract__c = project.id;
        visit3.sirenum__Team__c = visitTypeList[0].id;
        visit3.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit3.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit3.Visit_Request_received_from_Site__c = true;
        visit3.Target_Date__c = Date.parse('02/02/22');
        visit3.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit3.Project_Approval_Status__c='pending ';
        visit3.Illingworth_Project_Decline_Date__c= Date.parse('02/09/22');
        visit3.Resource_Decline_Reason__c='Other';
        visit3.Resource_Decline_Text__c='Resource Did not Accepted';
        visit3.sirenum__Contact__c=resource[0].Id;
        visit3.Illingworth_Notify_Res_Request__c=true;
     //   visit3.sirenum__ShiftDemand__c=visit1.Id;
        visit3.Project_Approval_Status__c = 'Pending';
        visit3.Site_Activation_Status__c  = 'Declined';
        Visit3.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit3.PM_Approved_Date__c = Date.parse('02/02/22');
        visit3.Site_Approval_Date__c=Date.parse('02/10/22');
        Visit3.Visit_Number__c = Null;
        Visit3.sirenum__Accepted__c = 1;
        Visit3.Visit_Approval_Status__c = 'Applied For Approval';
        visit3.Illingworth_Outcome_Reason__c ='Nurse Not Available';
        visit3.Visit_Number__c = Null;
        visit3.Actual_Other_Travel_Expenses__c ='test';
        visit3.sirenum__Site__c = clinicalSite.id;
        visit3.Clinical_Site__c = clinicalSite.id;
        //visit3.sirenum__Location__c = Location.id;
        Insert visit3;
        
        sirenum__Ticket__c ticket=DataFactory.createTicket(competency,resource[0]);
        ticket.Valid_Checkbox__c=false;
        ticket.sirenum__Revoked__c = True;
        update ticket;
        sirenum__Alert__c newLogEntry=new sirenum__Alert__c();
        newLogEntry.sirenum__Shift__c = visit3.id;
        newLogEntry.sirenum__ConstraintType__c='Job Type';
        newLogEntry.sirenum__RuleValue4__c =  'Background Check Declaration (Annual)';
        
        Insert newLogEntry;
        Test.stopTest();

        
        
        
      /*  List<sirenum__Alert__c> logEntryRecordList=[Select id from sirenum__Alert__c limit 1];
        system.assertEquals(True,logEntryRecordList.size()>0); */
        
    }
}