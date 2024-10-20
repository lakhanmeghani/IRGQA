/**
* @since               : 5th Dec, 2023
* @description         : This Class Contains test methods for ProjectTicketStatusBatch
*/
@isTest
public class ProjectTicketStatusBatchTest {
    @isTest
    
    public static void createStaticData(){
        
        //project team
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'NEW PROJECT ALERTS12';
        insert projectTeam;
        
        //account
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCOUNTS12';
        insert account;
        
        //project
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='NEW PROJECT ALERT1239';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '189567';
        project.Illingworth_Protocol_ID__c='120578';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off sites';
        //project.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        insert project;
        
        //Create Job Type
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
        Insert con;
        
        // visit type 
        sirenum__Team__c JobRole = new sirenum__Team__c();
        JobRole.Name='Test Project';
        JobRole.sirenum__Account__c = project.id;
        insert JobRole;
        
        //Placement 
        sirenum__Placement__c placement = new 	sirenum__Placement__c();
        placement.Name = 'Test ProjectTicket Status Batch';
        placement.sirenum__Status__c = 'Active';
        placement.sirenum__Job_Role__c = JobRole.Id ;
        placement.sirenum__Start_Date__c = system.Today();
        placement.sirenum__Contact__c = con.id;
        placement.sirenum__Contract__c = project.Id;
        insert placement;
        
        //Create Competency 
        sirenum__TicketType__c Competency = new sirenum__TicketType__c();
        Competency.Name = 'Background Check Declarations12 (Annual)';
        Competency.Competence_Category__c = 'Compliance Documentation';
        Competency.Job_Type__c='Research Nurse';
        Competency.Severity__c = 'Fatal';
        Insert Competency ;
        
        //Create CompetencyCondition
        sirenum__Sirenum_Condition_Membership__c CompetencyCondition = new sirenum__Sirenum_Condition_Membership__c();
        CompetencyCondition.sirenum__Job_Type__c = jobtype.Id;
        CompetencyCondition.sirenum__TicketType__c = Competency.Id;
        CompetencyCondition.sirenum__Severity__c = 'Fatal';
        CompetencyCondition.sirenum__Client__c = account.id;
        CompetencyCondition.Inactive__c=False;
        CompetencyCondition.Project__c=project.Id;
        Insert CompetencyCondition;
        
        //Create Ticket 
        sirenum__Ticket__c Ticket = new sirenum__Ticket__c();
        Ticket.sirenum__TicketType__c = Competency.Id;
        Ticket.sirenum__Revoked__c = false;
        Ticket.sirenum__Owner__c = con.Id;
        Ticket.sirenum__Valid_from__c = system.Today();
        Ticket.sirenum__Valid_until__c = system.today()+30;
        
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
        Ticket3.SK_Status__c = 'Pending';
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
        CoveredCompetency.Name = 'Valid Background Checks12';
        CoveredCompetency.Competence_Category__c = 'Compliance Documentation';
        CoveredCompetency.Job_Type__c='Research Nurse';
        Insert CoveredCompetency ;
        
        //Create Related Competency
        sirenum__RelatedTicketType__c RealtedCompetency = new sirenum__RelatedTicketType__c();
        RealtedCompetency.sirenum__CoveredTicketType__c = CoveredCompetency.Id;
        RealtedCompetency.sirenum__CoveringTicketType__c = Competency.Id;
        Insert RealtedCompetency;
        


      
    }
    
    static testMethod void start() 
    {
        createStaticData();
        Test.startTest();
        ProjectTicketStatusBatch obj = new ProjectTicketStatusBatch();
        DataBase.executeBatch(obj);
    Test.stopTest();
}
}