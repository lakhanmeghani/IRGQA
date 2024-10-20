/**
* 
* @since               : 19th Feb, 2024
* @description         : This Class Contains test methods for TicketStatusBatch
*/
@isTest
public class TicketStatusBatchTest {
    public static void createStaticData(){
        
        //Create Account
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Resource Pool -UK';
        acc.RecordTypeId = RecordTypeIdaccount;
        Insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Test Project Account';
        acc1.RecordTypeId = RecordTypeIdaccount;
        Insert acc1;
        
        Project_Team__c projectTeam = new Project_Team__c ();
        projectTeam.Name = 'Test Project Team';
        Insert projectTeam; 
        
        
        sirenum__ProActiveContract__c  project = new sirenum__ProActiveContract__c();
        project.Name = '123: Test Project';
        project.sirenum__Client__c = acc1.id;
        project.Project_Team__c = projectTeam.Id;
       // project.Illingworth_Recruitment_Manager_1__c = user1.Id;
        project.Opportunity_Number__c = '123';
        project.Illingworth_Protocol_ID__c = '12345';
        project.Off_site_Activities__c = 'Test';
        Insert project;
        
        
        //Create Job Type
        sirenum__Job_Type__c jobtype = new 	sirenum__Job_Type__c();
        jobtype.Name = 'Research Nurse - UK';
        Insert jobtype;
        
        //Create Contact
        Id RecordTypeIdcontact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.RecordTypeId =RecordTypeIdcontact;
        con.LastName = 'Seiketesting';
        con.FirstName = 'Amberttest';
        con.Email='asehhh@syneoshealth.test'; //syneoshealth
        con.Illingworth_External_ID_c__c ='asehh@syneoshealth.test'; //syneoshealth
        con.Job_Type__c = jobtype.Id;
        con.MailingCountry = 'UK';
        con.MailingState = 'New Mexico';
        con.MailingCity = 'Peterborough';
        con.Work_Country__c = 'UK';
        con.Candidate_ID__c = '1292';
        Insert con;
        
        //Create Competency 
        sirenum__TicketType__c Competency = new sirenum__TicketType__c();
        Competency.Name = 'Background Check Declaration (Annual)';
        Competency.Competence_Category__c = 'Compliance Documentation';
        Competency.Job_Type__c='Research Nurse';
        Competency.Severity__c = 'Fatal';
        Insert Competency ;
        
        //Create CompetencyCondition
        sirenum__Sirenum_Condition_Membership__c CompetencyCondition = new sirenum__Sirenum_Condition_Membership__c();
        CompetencyCondition.sirenum__Job_Type__c = jobtype.Id;
        CompetencyCondition.sirenum__TicketType__c = Competency.Id;
        CompetencyCondition.sirenum__Severity__c = 'Fatal';
        Insert CompetencyCondition;        
        

        
        //Create Ticket 
        sirenum__Ticket__c Ticket = new sirenum__Ticket__c();
        Ticket.sirenum__TicketType__c = Competency.Id;
        Ticket.sirenum__Revoked__c = True;
        Ticket.Valid_Checkbox__c= false;
        Ticket.sirenum__Owner__c = con.Id;
        Ticket.sirenum__Valid_from__c = system.Today();
        Ticket.sirenum__Valid_until__c = system.today()+30;
        //Insert Ticket;
        
        //Create Ticket 
        sirenum__Ticket__c Ticket2 = new sirenum__Ticket__c();
        Ticket2.sirenum__TicketType__c = Competency.Id;
        Ticket2.SK_Status__c = 'Confirmed';
        Ticket2.Valid_Checkbox__c=True;
        Ticket2.sirenum__Owner__c = con.Id;
        Ticket2.sirenum__Valid_from__c = system.Today();
        Ticket2.sirenum__Valid_until__c = system.today()+40;
        
        sirenum__Ticket__c Ticket3 = new sirenum__Ticket__c();
        Ticket3.sirenum__TicketType__c = Competency.Id;
        Ticket3.sirenum__Revoked__c = True;
        Ticket3.Valid_Checkbox__c= false;
        Ticket3.sirenum__Owner__c = con.Id;
        Ticket3.sirenum__Valid_from__c = system.Today();
        Ticket3.sirenum__Valid_until__c = system.today()+70;
        

        
        List<sirenum__Ticket__c> ticketListToInsert=new List<sirenum__Ticket__c>();
        ticketListToInsert.add(Ticket);
        ticketListToInsert.add(Ticket2);
        ticketListToInsert.add(Ticket3);
        
        Insert ticketListToInsert;
        
        //Create CoveredCompetency
        sirenum__TicketType__c CoveredCompetency = new sirenum__TicketType__c();
        CoveredCompetency.Name = 'Valid Background Check';
        CoveredCompetency.Competence_Category__c = 'Compliance Documentation';
        CoveredCompetency.Job_Type__c='Research Nurse';
        Insert CoveredCompetency ;
        
        //Create Related Competency
        sirenum__RelatedTicketType__c RealtedCompetency = new sirenum__RelatedTicketType__c();
        RealtedCompetency.sirenum__CoveredTicketType__c = CoveredCompetency.Id;
        RealtedCompetency.sirenum__CoveringTicketType__c = Competency.Id;
        Insert RealtedCompetency;
        
        //Create Ticket Status
        Illingworth_Ticket_Status__c TicketStatus = new Illingworth_Ticket_Status__c();
        TicketStatus.Resource__c = con.Id;
        TicketStatus.Competence_Condition__c = CompetencyCondition.Id;
        TicketStatus.Required_Competency__c = CompetencyCondition.sirenum__TicketType__c;
        TicketStatus.Job_Type__c = CompetencyCondition.sirenum__Job_Type__c;
        TicketStatus.Severity__c = CompetencyCondition.sirenum__Severity__c;
        TicketStatus.Competence_Category__c = Competency.Competence_Category__c;
        TicketStatus.Ticket__c = Ticket.Id;
        TicketStatus.Related_Competency__c = RealtedCompetency.Id;
        TicketStatus.Covering_Competency__c = RealtedCompetency.sirenum__CoveringTicketType__c;
        Insert TicketStatus;
        
        //Ticket Status with no ticket 
        Illingworth_Ticket_Status__c TicketStatusTicketNull = new Illingworth_Ticket_Status__c();
        TicketStatusTicketNull.Resource__c = con.Id;
        TicketStatusTicketNull.Competence_Condition__c = CompetencyCondition.Id;
        TicketStatusTicketNull.Required_Competency__c = CompetencyCondition.sirenum__TicketType__c;
        TicketStatusTicketNull.Job_Type__c = CompetencyCondition.sirenum__Job_Type__c;
        TicketStatusTicketNull.Severity__c = CompetencyCondition.sirenum__Severity__c;
        TicketStatusTicketNull.Competence_Category__c = Competency.Competence_Category__c;
        Insert TicketStatusTicketNull;
    }
    
    static testMethod void start() 
    {
        createStaticData();
        Test.startTest();
        TicketStatusBatch obj = new TicketStatusBatch();
        DataBase.executeBatch(obj);
        Test.stopTest();
    }
}