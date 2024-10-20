//Test Class for ContactTriggerHandler

@isTest
public class ContactTriggerHandlerTest {
    @isTest
    
    public static void contactAccountUpdate(){
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;
        
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account, RecruitmentManager1, projectTeam);
        Contact resource = new Contact();
        Id RecordTypeIdResource = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        resource.RecordTypeId = RecordTypeIdResource;
        resource.FirstName='Class';
        resource.LastName ='Test Resource Name';
        resource.Start_Date__c = Date.parse('02/02/22');
        resource.AccountId =account.id;
        resource.Activity_Status__c = 'Onboarding';
        resource.Job_Type__c = jobtype.Id;
        resource.Candidate_ID__c = '12987';
        resource.Email='testvalidation@syneoshealth.com';
        resource.Illingworth_Line_Manager__c=RecruitmentManager1.id;
        resource.Active_Projects__c='6112: DNLI-E-0001';
        resource.Work_Country__c='USA;Canada';
        resource.Active_Projects_as_Text__c='611: DNLI-E-0001';
        resource.Illingworth_Work_Country_Text__c='USA';
        resource.MailingCity='paris';
        resource.MailingCountry='France';
        resource.MailingState = 'Alaska';
        resource.Compact_Licence__c=False;
        resource.Illing_Licenced_in_States_Province__c='Alaska;Alberta;California;Alabama';
        Insert resource;
        
        // Contact Project Record
        Contact_Project__c contactProject=new  Contact_Project__c();
        contactProject.Project__c=project.id;
        contactProject.Contact__c=resource.id;
        contactProject.Active__c = True;
        
        Test.startTest();
        sirenum__ProActiveContract__c projectNew = new sirenum__ProActiveContract__c();
        projectNew.Name ='123: KSP-01';
        projectNew.sirenum__Client__c = account.Id;
        projectNew.Opportunity_Number__c = '123';
        projectNew.Illingworth_Protocol_ID__c='BAN232323456';
        projectNew.Project_Team__c = projectTeam.Id; 
        projectNew.Off_site_Activities__c = 'test off site';
        projectNew.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        insert projectNew;
        sirenum__TicketType__c competencyComp = new sirenum__TicketType__c();
        competencyComp.Name = 'Compact License';
        competencyComp.Competence_Category__c = 'Compact License';
        Insert competencyComp ;
        sirenum__TicketType__c competencyComp2 = new sirenum__TicketType__c();
        competencyComp2.Name = 'Alaska License';
        competencyComp2.Work_State__c='Alaska';
        competencyComp2.Work_Country__c='USA';
        competencyComp2.Competence_Category__c = 'Work State';
        Insert competencyComp2 ;
        
        //Update Contact
        resource.Illingworth_External_ID_c__c='newtestvalidation@syneoshealth.com';// syneoshealth
        resource.Active_Projects__c='123: KSP-01';
        resource.AccountId =account.id;
        resource.Job_Type__c = jobtype.Id;
        resource.Illingworth_Work_Country_Text__c='USA';
        resource.Email='testvalidation123@syneoshealth.com';
        resource.Activity_Status__c='Onboarding';
        resource.Illing_Licenced_in_States_Province__c ='California;British Columbia;Australian Capital Territory';
        resource.Work_Country__c='USA;Canada;Australia';
        resource.Compact_Licence__c = true;
        resource.Illing_Licenced_in_States_Province__c ='California;Australian Capital Territory';
        resource.Work_Country__c='USA;Australia';
        
        try{
            update resource;
        }
        catch(exception e){}
        
        Test.stopTest();
    }
    
    @isTest
    public static void contactActiveOnProjectUpdate(){
        
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = new Project_Team__c();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        projectTeam.Name = '6112: DNLI-E-0001';
        insert projectTeam;
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='6112: DNLI-E-0001';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '611';
        project.Illingworth_Protocol_ID__c='BAN23456';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off site';
        insert project;
        sirenum__Job_Type__c jobtypenew = new sirenum__Job_Type__c();
        jobtype.name = 'Research Nurse';
        insert jobtypenew;
        Contact resource = new Contact();
        Id RecordTypeIdResource = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        resource.RecordTypeId = RecordTypeIdResource;
        resource.FirstName='Class';
        resource.LastName ='Test Resource Name';
        resource.Start_Date__c = Date.parse('02/02/22');
        resource.AccountId =account.id;
        resource.Activity_Status__c = 'Onboarding';
        resource.Job_Type__c = jobtype.Id;
        resource.Candidate_ID__c = '12987';
        resource.Email='testvalidation@syneoshealth.com';
        resource.Active_Projects__c='6112: DNLI-E-0001';
        resource.Work_Country__c='USA;Canada';
        resource.Active_Projects_as_Text__c='611: DNLI-E-0001';
        resource.Illingworth_Work_Country_Text__c='USA';
        resource.MailingCity='paris';
        resource.MailingCountry='France';
        resource.MailingState = 'Alaska';
        resource.Illing_Licenced_in_States_Province__c='Alaska;Alberta;California;Alabama';
        Insert resource;
        
        List<sObject> sObjectInsertList=new List<sObject>();
        
        //Ticket Status with no tikcet 
        Illingworth_Ticket_Status__c ticketStatus = new Illingworth_Ticket_Status__c();
        ticketStatus.Resource__c = resource.Id;
        
        sObjectInsertList.add(ticketStatus);
        
        Insert sObjectInsertList;
        Test.startTest();
        resource.Active_Projects__c='';
        resource.Job_Type__c = jobtypenew.Id;
        resource.Illing_Licenced_in_States_Province__c='Alaska';
        resource.Work_Country__c='USA';
        try{
            update resource;
        }
        catch(exception e){}
        Test.stopTest();
    } 
}