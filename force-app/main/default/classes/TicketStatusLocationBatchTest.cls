@isTest
public class TicketStatusLocationBatchTest {
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
        
 
        //Create Contact
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.RecordTypeId ='0124L000000C1muQAC';
        con.LastName = 'Seiketesting';
        con.FirstName = 'Amberttest';
        con.Email='asehhh@syneoshealth.test'; //syneoshealth
        con.Illingworth_External_ID_c__c ='asehh@syneoshealth.test'; //syneoshealth
        con.MailingCountry = 'UK';
        con.MailingState = 'New Mexico';
        con.MailingCity = 'Peterborough';
        con.Work_Country__c = 'USA';
        con.Candidate_ID__c = '1292';
        con.Illing_Licenced_in_States_Province__c='Alabama';
        Insert con;
        
        //Create Competency 
        sirenum__TicketType__c Competency = new sirenum__TicketType__c();
        Competency.Name = 'USA Lic';
        Competency.Competence_Category__c = 'Work Country';
        Competency.Work_Country__c='USA';
        Competency.Severity__c = 'Fatal';
        Insert Competency ;
        
        //Create Competency 
        sirenum__TicketType__c Competency1 = new sirenum__TicketType__c();
        Competency1.Name = 'Alabama Lic';
        Competency1.Competence_Category__c = 'Work State';
        Competency1.Work_Country__c='USA';
        Competency1.Work_State__c='Alabama';
        Competency1.Severity__c = 'Fatal';
        Insert Competency1 ;
        
        //Create CompetencyCondition
        sirenum__Sirenum_Condition_Membership__c CompetencyCondition = new sirenum__Sirenum_Condition_Membership__c();
        CompetencyCondition.sirenum__TicketType__c = Competency.Id;
        CompetencyCondition.sirenum__Severity__c = 'Fatal';
        CompetencyCondition.Work_Country__c='USA';
        CompetencyCondition.Inactive__c=False;
        Insert CompetencyCondition;        
        
        sirenum__Sirenum_Condition_Membership__c CompetencyCondition1 = new sirenum__Sirenum_Condition_Membership__c();
        CompetencyCondition1.sirenum__TicketType__c = Competency1.Id;
        CompetencyCondition1.sirenum__Severity__c = 'Fatal';
        CompetencyCondition1.Work_Country__c='USA';
        CompetencyCondition1.Work_State__c='Alabama';
        CompetencyCondition1.Inactive__c=False;
        Insert CompetencyCondition1;
        
        //Create Ticket 
        sirenum__Ticket__c Ticket = new sirenum__Ticket__c();
        Ticket.sirenum__TicketType__c = Competency.Id;
        Ticket.sirenum__Revoked__c = false;
        Ticket.Valid_Checkbox__c = true;
        Ticket.sirenum__Owner__c = con.Id;
        Ticket.sirenum__Valid_from__c = system.Today();
        Ticket.sirenum__Valid_until__c = system.today()+30;
        Insert Ticket;
        
        //Create Invalid Ticket 
        sirenum__Ticket__c ticketInvalid = new sirenum__Ticket__c();
        ticketInvalid.sirenum__TicketType__c = Competency.Id;
        ticketInvalid.sirenum__Revoked__c = true;
        ticketInvalid.Valid_Checkbox__c = false;
        ticketInvalid.sirenum__Owner__c = con.Id;
        ticketInvalid.sirenum__Valid_from__c = system.Today();
        ticketInvalid.sirenum__Valid_until__c = system.today()+20;
        Insert ticketInvalid;
        
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
        
        //Ticket Status with no tikcet 
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
        TicketStatusLocationBatch obj = new TicketStatusLocationBatch();
        DataBase.executeBatch(obj);
        Test.stopTest();
    }

}