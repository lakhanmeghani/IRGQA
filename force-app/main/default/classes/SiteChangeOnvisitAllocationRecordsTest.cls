@isTest 
public class SiteChangeOnvisitAllocationRecordsTest{
    
    static testMethod void testMethod1(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource1 = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        List<sirenum__Team__c> visitType = DataFactory.createVisitType(project,jobtype);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
        
        //Visit
        List<sirenum__Shift__c> visitList = New List<sirenum__Shift__c>();
        sirenum__Shift__c visit1 = new sirenum__Shift__c();
        Id RecordTypeIdvisit1 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        visit1.RecordTypeId = RecordTypeIdvisit1 ;
        visit1.sirenum__Contract__c = project.id;
        visit1.sirenum__Team__c = visitType[0].id;
        visit1.Participant__c = participant.id;
        visit1.Participant_Location__c = participantLocation.id;
        Time nullTime = Time.newInstance(00, 00, 00 ,0000); 
        Time endTime = Time.newInstance(23, 59, 00 ,0000);
        visit1.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit1.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit1.Visit_Request_received_from_Site__c = true;
        visit1.Target_Date__c = Date.parse('02/02/22');
        visit1.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit1.Clinical_Site__c = clinicalSite.id;
        visit1.sirenum__Broadcasts__c = 3;
        visit1.Project_Approval_Status__c='Approved';
        visit1.PM_Approved_Date__c =Date.parse('02/09/22');
        visit1.Illingworth_Site_Decline_date__c=Date.parse('07/09/22');
        visit1.Resource_Decline_Reason__c='Other';
        visit1.Resource_Decline_Text__c='Resource Did not Accepted';
        visit1.Outcome__c='Completed In Full';
        visit1.Illingworth_Outcome_Reason__c='Nurse Not Available';
        visitList.add(visit1);
        Insert  visitList;
        
        Test.startTest();
        
        SiteChangeOnvisitAllocationRecords cb = New SiteChangeOnvisitAllocationRecords();
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,visitList);
        cb.Finish(null);
        
        Test.stopTest();
    }
}













/*Profile pf= [Select Id from profile where Name='System Administrator']; 
String orgId=UserInfo.getOrganizationId(); 
String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
String uniqueName=orgId+dateString+RandomId; 
User RecruitmentManager1=new User(firstname = 'ABC', 
lastName = 'XYZ', 
email ='jai.jethanandani@areya.tech', 
Username = 'mikes.sampsons@illingworthresearch.com', 
EmailEncodingKey = 'ISO-8859-1', 
Alias = 'mikes', 
TimeZoneSidKey = 'America/Los_Angeles', 
LocaleSidKey = 'en_US', 
LanguageLocaleKey = 'en_US', 
ProfileId = pf.Id
); 
insert RecruitmentManager1;

// project team
Project_Team__c projectTeam = new Project_Team__c();
projectTeam.Name = '611: DNLI-E-0001';
insert projectTeam;

//account
Account account = new Account();
Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
account.RecordTypeId = RecordTypeIdaccount;
account.Name = 'NEW PROJECT ALERT ACCOUNT';
insert account;

//job type
sirenum__Job_Type__c jobtype = new sirenum__Job_Type__c();
jobtype.name = 'Test Job Type';
insert jobtype; 

List<Contact> contactList = new List<Contact>();

//Resource contact 
Contact resource = new Contact();
Id RecordTypeIdResource = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
resource.RecordTypeId = RecordTypeIdResource;
resource.FirstName='Class';
resource.LastName ='Test Resource Name';
resource.Start_Date__c = Date.parse('02/02/22');
resource.AccountId =account.id;
resource.Job_Type__c = jobtype.Id;
resource.Candidate_ID__c = '12987';
resource.Email='testvalidation@syneoshealth.com';// syneoshealth
resource.Illingworth_Line_Manager__c=RecruitmentManager1.id;
resource.Active_Projects__c='611: DNLI-E-0001';
resource.Active_Projects_as_Text__c='611: DNLI-E-0001';
resource.Work_Country__c='France';
resource.MailingCity='paris';
resource.MailingCountry='France';
contactList.add(resource);

//Resource contact 
Contact resourceNew = new Contact();
Id RecordTypeIdresourceNew = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
resourceNew.RecordTypeId = RecordTypeIdresourceNew;
resourceNew.FirstName='Class New';
resourceNew.LastName ='Test Resource New';
resourceNew.Start_Date__c = Date.parse('10/03/22');
resourceNew.AccountId =account.id;
resourceNew.Job_Type__c = jobtype.Id;
resourceNew.Candidate_ID__c = '125987';
resourceNew.Email='testvalidationnew@syneoshealth.com';// syneoshealth
resourceNew.Illingworth_Line_Manager__c=RecruitmentManager1.id;
resourceNew.Active_Projects__c='611: DNLI-E-0001';
resourceNew.Active_Projects_as_Text__c='611: DNLI-E-0001';
resourceNew.Work_Country__c='France';
resourceNew.MailingCity='London';
resourceNew.MailingCountry='France';
contactList.add(resourceNew);
Insert contactList;

//project
sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
project.Name ='611: DNLI-E-0001';
project.sirenum__Client__c = account.Id;
project.Opportunity_Number__c = '611';
project.Illingworth_Protocol_ID__c='BAN23456';
project.Project_Team__c = projectTeam.Id; 
project.Off_site_Activities__c = 'test off site';
project.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
insert project;

//Clinical site 
List<sirenum__Site__c> clinicalSiteList = new List<sirenum__Site__c>();
sirenum__Site__c clinicalSite = new sirenum__Site__c();
Id RecordTypeIdClinicalSite = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Site – Clinical Trial').getRecordTypeId();
clinicalSite.RecordTypeId = RecordTypeIdClinicalSite;
clinicalSite.Name = 'New_Site_Test_Trigger1' ;
clinicalSite.Site_Number__c = '1467';
clinicalSite.Illingworth_Clinical_Site_Name__c = 'Test-Trigger_clinical site';
clinicalSite.sirenum__Country__c = 'France';
clinicalSite.sirenum__City__c = 'Pairs';
clinicalSite.Project__c = project.Id;
insert clinicalSite;

//participant 
Participant__c participant = new Participant__c();
participant.Name = '001_102';
participant.Site_Clinical_Trial__c = clinicalSite.id;
insert participant;

//participant location
sirenum__Site__c participantLocation = new sirenum__Site__c();
Id RecordTypeIdParticipantLocation = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Participant Location').getRecordTypeId();
participantLocation.RecordTypeId = RecordTypeIdParticipantLocation; 
participantLocation.Name = 'TEST VISIT ALERT';
participantLocation.Participant__c = participant.Id;
participantLocation.Location_Type__c = 'Off Site';
participantLocation.sirenum__City__c = 'paris';
participantLocation.sirenum__Country__c = 'France';
insert participantLocation;

List<sirenum__Team__c> visitTypeList = new List<sirenum__Team__c>();

// visit type
sirenum__Team__c visitType = new sirenum__Team__c();
visitType.Name = 'Test Visit Type';
visitType.Requires_Confirmation_From_Site__c = true;
visitType.Illingworth_Days_Before_Window__c =3;
visitType.Illingworth_Days_After_Window__c = 2;
visitType.sirenum__Account__c=project.id;
visitTypeList.add(visitType);

// visit type Resource Request
sirenum__Team__c visitType1 = new sirenum__Team__c();
visitType1.Name = 'Resource Request-Canada';
visitType1.sirenum__Account__c=project.id;
visitTypeList.add(visitType1);
Insert visitTypeList;

List<sirenum__Shift__c> visitList = New List<sirenum__Shift__c>();

// visit
sirenum__Shift__c visit1 = new sirenum__Shift__c();
Id RecordTypeIdvisit1 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
visit1.RecordTypeId = RecordTypeIdvisit1 ;
visit1.sirenum__Contract__c = project.id;
visit1.sirenum__Team__c = visitType.id;
visit1.Participant__c = participant.id;
visit1.Participant_Location__c = participantLocation.id;
Time nullTime = Time.newInstance(00, 00, 00 ,0000); 
Time endTime = Time.newInstance(23, 59, 00 ,0000);
visit1.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
visit1.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 59, 00);
//visit1.sirenum__Scheduled_Start_Time__c = system.now()-1;
//visit1.sirenum__Scheduled_End_Time__c = system.now();
visit1.Visit_Request_received_from_Site__c = true;
visit1.Target_Date__c = Date.parse('02/02/22');
visit1.Reason_for_Target_Date__c = 'Project agreed SLA';
visit1.Clinical_Site__c = clinicalSite.id;
visit1.sirenum__Broadcasts__c = 3;
visit1.Project_Approval_Status__c='Approved';
visit1.PM_Approved_Date__c =Date.parse('02/09/22');
visit1.Illingworth_Site_Decline_date__c=Date.parse('07/09/22');
visit1.Resource_Decline_Reason__c='Other';
visit1.Resource_Decline_Text__c='Resource Did not Accepted';
visit1.Outcome__c='Completed In Full';
visit1.Illingworth_Outcome_Reason__c='Nurse Not Available';
visitList.add(visit1);

Insert  visitList;

Test.startTest();

SiteChangeOnvisitAllocationRecords cb = New SiteChangeOnvisitAllocationRecords();
Database.QueryLocator ql = cb.start(null);
cb.execute(null,visitList);
cb.Finish(null);
Test.stopTest();*/