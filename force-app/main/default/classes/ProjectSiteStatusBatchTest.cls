/**
* @since               : 5th Dec, 2023
* @description         : This Class Contains test methods for ProjectSiteStatusBatch
*/
@isTest
public class ProjectSiteStatusBatchTest {
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
        con.Active_Projects__c='NEW PROJECT ALERT1239';
        Insert con;
        

            
        sirenum__Site__c testClinicalSite = DataFactory.createSite(project);
        List<sirenum__Team__c> testVisitType = DataFactory.createVisitType(project,jobtype);
            
        sirenum__Shift__c visit = new sirenum__Shift__c();
        Id RecordTypeIdvisit = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
        visit.RecordTypeId = RecordTypeIdvisit ;
        visit.sirenum__Site__c = testClinicalSite.Id;
        visit.sirenum__Team__c = testVisitType[0].Id;
        visit.sirenum__Contact__c = con.id;
        visit.sirenum__Contract__c = project.id;
        visit.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit.Visit_Request_received_from_Site__c = true;
        visit.Target_Date__c = Date.parse('02/02/22');
        visit.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit.Clinical_Site__c = testClinicalSite.id;
        visit.sirenum__Accepted__c= 1;
        visit.Site_Approval_Date__c=Date.parse('02/10/28');
        insert visit;
        
      
        //Create Competency 
        sirenum__TicketType__c Competency = new sirenum__TicketType__c();
        Competency.Name = 'Background Check Declarations12 (Annual)';
        Competency.Competence_Category__c = 'Compliance Documentation';
        Competency.Job_Type__c='Research Nurse';
        Competency.Severity__c = 'Fatal';    
        Insert Competency ;
        Test.startTest();
        //Create CompetencyCondition
        sirenum__Sirenum_Condition_Membership__c CompetencyCondition = new sirenum__Sirenum_Condition_Membership__c();
        CompetencyCondition.sirenum__TicketType__c = Competency.Id;
        CompetencyCondition.sirenum__Severity__c = 'Fatal';
        CompetencyCondition.sirenum__Site__c = testClinicalSite.id;
        CompetencyCondition.Inactive__c=False;
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
        

  ProjectSiteStatusBatch obj = new ProjectSiteStatusBatch();
        DataBase.executeBatch(obj);
    Test.stopTest();

      
    }
    
  /*  static testMethod void start() 
    {
        createStaticData();
        Test.startTest();
        ProjectSiteStatusBatch obj = new ProjectSiteStatusBatch();
        DataBase.executeBatch(obj);
    Test.stopTest();
}*/

}