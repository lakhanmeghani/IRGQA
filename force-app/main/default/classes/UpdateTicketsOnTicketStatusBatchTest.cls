/**
* @author              : Akanksha Singh
* @since               : 5th Dec, 2023
* @description         : This Class Contains test methods for UpdateTicketsOnTicketStatusBatch
* -------------------------------------------------------------------------------------------------------
* Version      Date                Author                  Details
*    1         5th Dec, 2023        Akanksha Singh         Initial Developement
* -------------------------------------------------------------------------------------------------------
*/
@isTest
public class UpdateTicketsOnTicketStatusBatchTest {
    @isTest
    public static void createTestTickets(){
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
  		sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
        sirenum__TicketType__c CoveredCompetency = DataFactory.createCompetencyNewState(project);
        sirenum__Ticket__c ticket = DataFactory.createTicket(Competency,resource[0]); 
        sirenum__Ticket__c coveredTicket = DataFactory.createTicket (CoveredCompetency,resource[0]);
        
        //Create Ticket Status
        Illingworth_Ticket_Status__c TicketStatus = new Illingworth_Ticket_Status__c();
        TicketStatus.Resource__c = resource[1].Id;
        //TicketStatus.Competence_Condition__c = CompetencyCondition.Id;
        TicketStatus.Required_Competency__c = ticket.sirenum__TicketType__c;
        //TicketStatus.Job_Type__c = CompetencyCondition.sirenum__Job_Type__c;
        //TicketStatus.Severity__c = CompetencyCondition.sirenum__Severity__c;
        TicketStatus.Competence_Category__c = Competency.Competence_Category__c;
        TicketStatus.Ticket__c = Ticket.Id;
        TicketStatus.Valid__c=False;
        TicketStatus.Valid_Until__c=Ticket.sirenum__Valid_until__c;
       //TicketStatus.Related_Competency__c = RealtedCompetency.Id;
        TicketStatus.Covering_Competency__c = CoveredCompetency.Id;
        Insert TicketStatus;
        
      //   Create another Ticket Status with Valid_Until less than the ticket's Valid_Until
        Illingworth_Ticket_Status__c ticketStatus2 = new Illingworth_Ticket_Status__c();
        ticketStatus2.Resource__c = resource[1].Id;
        ticketStatus2.Required_Competency__c = ticket.sirenum__TicketType__c;
        ticketStatus2.Competence_Category__c = competency.Competence_Category__c;
        ticketStatus2.Ticket__c = null;
        ticketStatus2.Valid__c = false;
        ticketStatus2.Valid_Until__c = ticket.sirenum__Valid_until__c.addDays(-50);
        ticketStatus2.Covering_Competency__c = coveredCompetency.Id;
        insert ticketStatus2; 
    
        Project_Ticket_Status__c projectTicketStatus=new Project_Ticket_Status__c();
        projectTicketStatus.Resource__c=resource[0].Id;
        projectTicketStatus.Account__c=account.Id;
        projectTicketStatus.Required_Competency__c=Competency.Id;
        projectTicketStatus.Valid_Until__c=Ticket.sirenum__Valid_until__c;
        projectTicketStatus.Covering_Competency__c = CoveredCompetency.Id;
        Insert projectTicketStatus;  
        
        Test.startTest();
        UpdateTicketsOnTicketStatusBatch obj = new UpdateTicketsOnTicketStatusBatch();
        DataBase.executeBatch(obj);
        Test.stopTest();        
    }
    
    @isTest
    static void testUpdateTicketStatusBatch(){
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam(); 
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = new 	sirenum__Job_Type__c();
        jobtype.Name = 'Research Nurse - UK';
        Insert jobtype;
        
        //Create Contact
        Contact con = new Contact();
        con.AccountId = account.Id;
        Id RecordTypeIdcontact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        con.RecordTypeId =RecordTypeIdcontact;
        con.LastName = 'Seiketesting';
        con.FirstName = 'Amberttest';
        con.Email='testresource@syneoshealth.com';
        con.Illingworth_External_ID_c__c ='testresource@syneoshealth.com';
        con.Job_Type__c = jobtype.Id;
        con.MailingCountry = 'UK';
        con.MailingState = 'New Mexico';
        con.MailingCity = 'Peterborough';
        con.Work_Country__c = 'UK';
        con.Candidate_ID__c = '1292';
        con.Active_Projects__c='NEW PROJECT ALERT1239';
        Insert con;
        
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='NEW PROJECT ALERT1239';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '189567';
        project.Illingworth_Protocol_ID__c='120578';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off sites';
        insert project;
               
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
        sirenum__TicketType__c CoveredCompetency = DataFactory.createCompetencyNewState(project);
       
        sirenum__Location__c location = DataFactory.CreateLocation();
        sirenum__RelatedTicketType__c relatedCompetency = DataFactory.createrelatedCompetency (project ,CoveredCompetency,Competency);
        List<sirenum__Sirenum_Condition_Membership__c> compCondList = DataFactory.createCompetencyCondition(RecruitmentManager1,account,jobtype, Competency, clinicalSite,Location);
       
        sirenum__Ticket__c Ticket = new sirenum__Ticket__c();
        Ticket.sirenum__TicketType__c = Competency.Id;
        Ticket.sirenum__Revoked__c = false;
        Ticket.sirenum__Owner__c = con.Id;
        Ticket.sirenum__Valid_from__c = system.Today();
        Ticket.sirenum__Valid_until__c = system.today()+50;
        Insert Ticket;
        
        //Create Ticket Status
        Illingworth_Ticket_Status__c TicketStatus = new Illingworth_Ticket_Status__c();
        TicketStatus.Resource__c = con.Id;
        TicketStatus.Required_Competency__c = ticket.sirenum__TicketType__c;
        TicketStatus.Competence_Category__c = Competency.Competence_Category__c;
        TicketStatus.Ticket__c = Ticket.Id;
        TicketStatus.Job_Type__c = compCondList[0].sirenum__Job_Type__c;
        TicketStatus.Severity__c = compCondList[0].sirenum__Severity__c;
        TicketStatus.Valid__c=False;
        TicketStatus.Valid_Until__c=Ticket.sirenum__Valid_until__c;
        TicketStatus.Covering_Competency__c = CoveredCompetency.Id;
        Insert TicketStatus;
        
        //Create Ticket Status
        Illingworth_Ticket_Status__c TicketStatus2 = new Illingworth_Ticket_Status__c();
        TicketStatus2.Resource__c = con.Id;
        TicketStatus2.Competence_Category__c = Competency.Competence_Category__c;
        TicketStatus2.Ticket__c = Ticket.Id;
        TicketStatus2.Job_Type__c = compCondList[0].sirenum__Job_Type__c;
        TicketStatus2.Severity__c = compCondList[0].sirenum__Severity__c;
        TicketStatus2.Valid__c=False;
        TicketStatus2.Valid_Until__c=Ticket.sirenum__Valid_until__c;
        TicketStatus2.Covering_Competency__c = Competency.Id;
        Insert TicketStatus2;
        
        Project_Ticket_Status__c projectTicketStatus=new Project_Ticket_Status__c();
        projectTicketStatus.Resource__c=con.Id;
        projectTicketStatus.Account__c=account.Id;
        projectTicketStatus.Required_Competency__c=Competency.Id;
        projectTicketStatus.Valid_Until__c=Ticket.sirenum__Valid_until__c;
        projectTicketStatus.Covering_Competency__c = CoveredCompetency.Id;
        Insert projectTicketStatus;       
        Project_Ticket_Status__c projectTicketStatus2=new Project_Ticket_Status__c();
        projectTicketStatus2.Resource__c=con.Id;
        projectTicketStatus2.Account__c=account.Id;
        //projectTicketStatus2.Required_Competency__c=Competency.Id;
        projectTicketStatus2.Valid_Until__c=Ticket.sirenum__Valid_until__c;
        projectTicketStatus2.Covering_Competency__c = Competency.Id;
        Insert projectTicketStatus2;
        
        Project_Ticket_Status__c projectTicketStatus3=new Project_Ticket_Status__c();
        projectTicketStatus3.Resource__c=con.Id;
        projectTicketStatus3.Account__c=account.Id;
        projectTicketStatus3.Valid_Until__c=Ticket.sirenum__Valid_until__c;
        projectTicketStatus3.Covering_Competency__c = Competency.Id;
        Insert projectTicketStatus3;
        
        Test.startTest();
        UpdateTicketsOnTicketStatusBatch obj = new UpdateTicketsOnTicketStatusBatch();
        DataBase.executeBatch(obj);
        Test.stopTest();    
    }

}