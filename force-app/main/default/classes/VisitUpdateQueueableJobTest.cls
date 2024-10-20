@isTest
public class VisitUpdateQueueableJobTest {
    @TestSetup
    public  static void testVisits(){
        
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = '6112: DNLI-E-0001';
        projectTeam.OwnerId=userInfo.getUserId();
        insert projectTeam;
        
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCOUNT';
        insert account;
        
        sirenum__Job_Type__c jobtype = new sirenum__Job_Type__c();
        jobtype.name = 'Research Nurse';
        insert jobtype;
        
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
        
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='6112: DNLI-E-0001';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '611';
        project.Illingworth_Protocol_ID__c='BAN23456';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off site';
        insert project;
        
        sirenum__Site__c clinicalSite = new sirenum__Site__c();
        Id RecordTypeIdClinicalSite = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Site – Clinical Trial').getRecordTypeId();
        clinicalSite.RecordTypeId = RecordTypeIdClinicalSite;
        clinicalSite.Name = 'Test Project Activation' ;
        clinicalSite.Site_Number__c = '1467';
        clinicalSite.Illingworth_Clinical_Site_Name__c ='Test-Trigger_clinical site';
        clinicalSite.sirenum__Country__c = 'France';
        clinicalSite.sirenum__City__c = 'Pairs';
        clinicalSite.Project__c = project.Id;
        insert clinicalSite;
        
        Participant__c participant = new Participant__c();
        participant.Name ='001_102';
        participant.Site_Clinical_Trial__c = clinicalSite.id;
        insert participant;
        
        sirenum__Site__c participantLocation = new sirenum__Site__c();
        Id RecordTypeIdParticipantLocation = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Participant Location').getRecordTypeId();
        participantLocation.RecordTypeId = RecordTypeIdParticipantLocation; 
        participantLocation.Name = 'TEST VISIT ALERT';
        participantLocation.Participant__c = participant.Id;
        participantLocation.Location_Type__c = 'Off Site';
        participantLocation.sirenum__City__c = 'paris';
        participantLocation.sirenum__Country__c = 'France';
        participantLocation.sirenum__State__c ='Alabama';
        insert participantLocation;
        
        sirenum__Team__c visitType = new sirenum__Team__c();
        visitType.Name = 'Test Visit Type';
        visitType.Requires_Confirmation_From_Site__c = true;
        visitType.Illingworth_Days_Before_Window__c =3;
        visitType.Illingworth_Days_After_Window__c = 2;
        visitType.sirenum__Account__c=project.id;
        visitType.sirenum__Job_Type__c = jobtype.id;
        Insert visitType;
        
        sirenum__Placement__c projectPlacement = new sirenum__Placement__c();
        projectPlacement.sirenum__Contract__c =project.Id;
        projectPlacement.sirenum__Start_Date__c=system.today();
        projectPlacement.sirenum__Contact__c=resource.Id;
        projectPlacement.sirenum__Status__c='Inactive';
        projectPlacement.sirenum__Job_Role__c=visitType.Id; 
        insert projectPlacement;
        
        
    }
    @isTest
    public static void ActiveOnProjectTest(){
        sirenum__ProActiveContract__c project =[Select id,Name,Project_Team__r.Owner.Id from sirenum__ProActiveContract__c ];
        Contact contact =[Select id,Name from contact ];
        sirenum__Team__c visitType =[Select id,Name from sirenum__Team__c ];
        sirenum__Site__c participantLocation =[Select id,Name from sirenum__Site__c where recordType.Name='Participant Location'];
        Participant__c participant =[Select id,Name from Participant__c ];
        sirenum__Site__c clinicalSite =[Select id,Name from sirenum__Site__c where recordType.Name='Site – Clinical Trial'];
        
        Illingworth_Policy_Definition__c  PolicyDefination = new Illingworth_Policy_Definition__c();
        PolicyDefination.Name='Add Policy Exception at Visit to Bypass Work Country for Resource Request';
        Insert PolicyDefination;
        
        
        sirenum__Shift__c visit1 = new sirenum__Shift__c();
        Id RecordTypeIdvisit1 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        visit1.RecordTypeId = RecordTypeIdvisit1 ;
        visit1.sirenum__Contract__c = project.id;
        visit1.sirenum__Team__c = visitType.id;
        visit1.Participant__c = participant.id;
        visit1.Participant_Location__c = participantLocation.id;
        Time nullTime = Time.newInstance(00, 00, 00 ,0000); 
        Time endTime = Time.newInstance(23, 00, 00 ,0000);
        visit1.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit1.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit1.Visit_Request_received_from_Site__c = true;
        visit1.Target_Date__c = Date.parse('02/02/22');
        visit1.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit1.Clinical_Site__c = clinicalSite.id;
        visit1.sirenum__Broadcasts__c = 3;
        visit1.Project_Approval_Status__c='Pending';
        visit1.PM_Approved_Date__c =Date.parse('02/09/26');
        visit1.Illingworth_Site_Decline_date__c=Date.parse('07/09/22');
        visit1.Illingworth_Project_Decline_Date__c = Date.parse('07/09/22');
        visit1.Resource_Decline_Reason__c='Other';
        visit1.Resource_Decline_Text__c='Resource Did not Accepted';
        visit1.Outcome__c='Completed In Full';
        visit1.Outcome_Reason__c ='Cancelled Client';
        visit1.Illingworth_Outcome_Reason__c='Nurse Not Available';
        visit1.Site_Activation_Status__c ='Declined';
        visit1.Resource_Decline_Reason__c='Other';
        visit1.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit1.Resource_Decline_Text__c='Resource Did not Accepted';
        visit1.Site_Approval_Date__c=Date.parse('02/10/22');
        Insert visit1;
        
        List<sirenum__Shift__c> visitList = new List<sirenum__Shift__c>([select id from sirenum__Shift__c]);
        Test.startTest();
        system.enqueuejob(new VisitUpdateQueueableJob(visitList));
        Test.stopTest();
    }
}