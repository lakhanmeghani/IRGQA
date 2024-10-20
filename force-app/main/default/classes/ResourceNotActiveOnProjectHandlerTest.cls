@isTest
public class ResourceNotActiveOnProjectHandlerTest {
    @testSetup
    public  static void dataSetup(){
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
        //Visit1.Visit_Approval_Status__c = 'Approved';
        visit1.Resource_Decline_Reason__c='Other';
        visit1.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit1.Resource_Decline_Text__c='Resource Did not Accepted';
        visit1.Site_Approval_Date__c=Date.parse('02/10/22');
        Insert visit1;
        
        sirenum__Shift__c visit3 = new sirenum__Shift__c();
        Id RecordTypeIdvisit3 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        visit3.RecordTypeId = RecordTypeIdvisit3 ;
        visit3.sirenum__Contract__c = project.id;
        visit3.sirenum__Team__c = visitType.id;
        visit3.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit3.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit3.Visit_Request_received_from_Site__c = true;
        visit3.Target_Date__c = Date.parse('02/02/22');
        visit3.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit3.Project_Approval_Status__c='pending ';
        visit3.Illingworth_Project_Decline_Date__c= Date.parse('02/09/22');
        visit3.Resource_Decline_Reason__c='Other';
        visit3.Resource_Decline_Text__c='Resource Did not Accepted';
        visit3.sirenum__Contact__c=contact.Id;
        visit3.Illingworth_Notify_Res_Request__c=true;
        visit3.sirenum__ShiftDemand__c=visit1.Id;
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
        Test.startTest();
        Insert visit3;
        
        Illingworht_Policy_Applied__c policyApp=new Illingworht_Policy_Applied__c();
        policyApp.Illingworth_Visit__c=visit3.Id;
        policyApp.Policy_Definition__c=PolicyDefination.Id;
        Insert policyApp;
        
        try{
        visit3.Project_Approval_Status__c='Approved';
        visit3.Site_Activation_Status__c='Approved';
        visit3.Visit_Approval_Status__c='Approved';
        visit3.PM_Approved_Date__c=system.today();
        visit3.Site_Approval_Date__c=system.today();
        update visit3;
            }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        Test.stopTest();
        
    }
    @isTest
    public static void updateVisitTest(){
        sirenum__ProActiveContract__c project =[Select id,Name,Project_Team__r.Owner.Id from sirenum__ProActiveContract__c ];
        Contact contact =[Select id,Name from contact ];
        sirenum__Team__c visitType =[Select id,Name from sirenum__Team__c ];
        sirenum__Site__c participantLocation =[Select id,Name from sirenum__Site__c where recordType.Name='Participant Location'];
        Participant__c participant =[Select id,Name from Participant__c ];
        sirenum__Site__c clinicalSite =[Select id,Name from sirenum__Site__c where recordType.Name='Site – Clinical Trial'];
        
        Group testGroup = new Group(Name='6112: DNLI-E-0001', DeveloperName='DNLI',Type='Queue');
		insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Notification__c');
    	System.runAs(new User(Id = UserInfo.getUserId()))
		{insert testQueue;}
        
        
        
        sirenum__Shift__c visit3 = new sirenum__Shift__c();
        Id RecordTypeIdvisit3 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Visit Allocation').getRecordTypeId();
        visit3.RecordTypeId = RecordTypeIdvisit3 ;
        visit3.sirenum__Contract__c = project.id;
        visit3.sirenum__Team__c = visitType.id;
        visit3.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit3.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit3.Visit_Request_received_from_Site__c = true;
        visit3.Target_Date__c = Date.parse('02/02/22');
        visit3.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit3.Project_Approval_Status__c='pending ';
        visit3.Illingworth_Project_Decline_Date__c= Date.parse('02/09/22');
        visit3.Resource_Decline_Reason__c='Other';
        visit3.Resource_Decline_Text__c='Resource Did not Accepted';
        visit3.sirenum__Contact__c=contact.Id;
        visit3.Illingworth_Notify_Res_Request__c=true;
        //visit3.sirenum__ShiftDemand__c=visit1.Id;
        visit3.Project_Approval_Status__c = 'Pending';
        visit3.Site_Activation_Status__c  = 'Declined';
        Visit3.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit3.PM_Approved_Date__c = Date.parse('02/02/22');
        visit3.Site_Approval_Date__c=Date.parse('02/10/22');
        Visit3.Visit_Number__c = Null;
        Visit3.sirenum__Accepted__c = 1;
        //Visit3.Visit_Approval_Status__c = 'Approved';
        visit3.Illingworth_Outcome_Reason__c ='Nurse Not Available';
        visit3.Visit_Number__c = Null;
        visit3.Actual_Other_Travel_Expenses__c ='test';
        visit3.sirenum__Site__c = clinicalSite.id;
        visit3.Clinical_Site__c = clinicalSite.id;
        
        
        Insert visit3;
        
        
        try{
            Test.startTest();
        visit3.sirenum__accepted__c=-1.0;
        
        update visit3;
            
             Test.stopTest();
         }
        catch(Exception e){
           system.debug(e.getMessage()); 
        }
       
    }
    @isTest
    public static void deleteVisitRecordTest(){
        sirenum__ProActiveContract__c project =[Select id,Name,Project_Team__r.Owner.Id from sirenum__ProActiveContract__c ];
        
        sirenum__Site__c clinicalSite =[Select id,Name from sirenum__Site__c where recordType.Name='Site – Clinical Trial'];
        
		sirenum__Team__c visitType = new sirenum__Team__c();
        visitType.Name = 'Resource Request-Canada';
        visitType.sirenum__Account__c=project.id;
        Insert visitType;       
        
        List<sirenum__Shift__c> visitList = New List<sirenum__Shift__c>();
        
        
        // visit 2
        sirenum__Shift__c visit2 = new sirenum__Shift__c();
        Id RecordTypeIdvisit2 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
        visit2.RecordTypeId = RecordTypeIdvisit2 ;
        visit2.sirenum__Contract__c = project.id;
        visit2.Request_Type__c ='Resource Request'; 
        visit2.sirenum__Team__c = visitType.Id;
        
        visit2.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00 );
        visit2.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit2.Visit_Request_received_from_Site__c = true;
        visit2.Target_Date__c = Date.parse('02/02/22');
        visit2.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit2.Clinical_Site__c = clinicalSite.id;
        visit2.sirenum__Broadcasts__c = 3;
        visit2.PM_Approved_Date__c =Date.parse('02/09/21');
        visit2.Illingworth_Project_Decline_Date__c= Date.parse('09/09/22');
        visit2.Resource_Decline_Reason__c='Other';
        visit2.Resource_Decline_Text__c='Resource Did not Accepted';
        visit2.sirenum__Site__c = clinicalSite.id;
        visit2.Site_Activation_Status__c ='Declined';
        visit2.Resource_Decline_Reason__c='Other';
        visit2.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit2.Resource_Decline_Text__c='Resource Did not Accepted';
        visit2.Site_Approval_Date__c=Date.parse('02/10/22');
        visitList.add(visit2);
        
        
        
        try{
            Test.startTest();
        	Insert  visitList;
        	Delete visitList;
             Test.stopTest();
            List<sirenum__Shift__c> deletedVisitList=[Select id from sirenum__Shift__c];
            system.assertEquals(True,deletedVisitList.size()==0);
         }
        catch(Exception e){
           system.debug(e.getMessage()); 
        }
        VisitHelper.fakeMethod();
    }
    /*@isTest
    public static void updateVisitApprovalStatusTest(){
        sirenum__ProActiveContract__c project =[Select id,Name,Project_Team__r.Owner.Id from sirenum__ProActiveContract__c ];
        Contact contact =[Select id,Name from contact ];
        sirenum__Team__c visitType =[Select id,Name from sirenum__Team__c ];
        sirenum__Site__c participantLocation =[Select id,Name from sirenum__Site__c where recordType.Name='Participant Location'];
        Participant__c participant =[Select id,Name from Participant__c ];
        sirenum__Site__c clinicalSite =[Select id,Name from sirenum__Site__c where recordType.Name='Site – Clinical Trial'];
        
       
        
        
        sirenum__Shift__c visit3 = new sirenum__Shift__c();
        Id RecordTypeIdvisit3 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Visit Allocation').getRecordTypeId();
        visit3.RecordTypeId = RecordTypeIdvisit3 ;
        visit3.sirenum__Contract__c = project.id;
        visit3.sirenum__Team__c = visitType.id;
        visit3.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit3.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit3.Visit_Request_received_from_Site__c = true;
        visit3.Target_Date__c = Date.parse('02/02/22');
        visit3.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit3.Project_Approval_Status__c='pending ';
        visit3.Illingworth_Project_Decline_Date__c= Date.parse('02/09/22');
        visit3.Resource_Decline_Reason__c='Other';
        visit3.Resource_Decline_Text__c='Resource Did not Accepted';
        visit3.sirenum__Contact__c=contact.Id;
        visit3.Illingworth_Notify_Res_Request__c=true;
        //visit3.sirenum__ShiftDemand__c=visit1.Id;
        visit3.Project_Approval_Status__c = 'Pending';
        visit3.Site_Activation_Status__c  = 'Declined';
        visit3.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit3.PM_Approved_Date__c = Date.parse('02/02/22');
        visit3.Site_Approval_Date__c=Date.parse('02/10/22');
        visit3.Visit_Number__c = Null;
        visit3.sirenum__Accepted__c = 1;
        visit3.Visit_Approval_Status__c = 'Applied For Approval';
        visit3.Illingworth_Outcome_Reason__c ='Nurse Not Available';
        visit3.Visit_Number__c = Null;
        visit3.Actual_Other_Travel_Expenses__c ='test';
        visit3.sirenum__Site__c = clinicalSite.id;
        visit3.Clinical_Site__c = clinicalSite.id;
        
        
        Insert visit3;
        
        
        //try{
            Test.startTest();
        visit3.Visit_Approval_Status__c = 'Approved';
        
        update visit3;
             Test.stopTest();
         //}
        //catch(Exception e){
           //system.debug(e.getMessage()); 
        //}
       
    }*/
    /*@isTest
    public  static void ActiveOnProjectTest(){
        
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
        sirenum__Placement__c projectPlacement= DataFactory.createPlacement(project,resource[0],visitTypeList[0]);
        sirenum__Placement__c SitePlacement= DataFactory.createSitePlacement(project,resource[0],visitTypeList[0],projectPlacement,clinicalSite);
        
        resAllocationVisitList[0].Project_Approval_Status__c='Approved';
        resAllocationVisitList[0].Site_Activation_Status__c ='Approved';
        resAllocationVisitList[0].PM_Approved_Date__c = Date.parse('02/02/28');
        
        try{
            update resAllocationVisitList;
        }
        catch(exception e){}
        Delete resAllocationVisitList[0];
    }*/   
    
    /*@isTest
    public static void callMethodsResourceNotActiveOnProjectHandler(){
        Map<Id,sirenum__Shift__c> newVisitMap = new Map<Id,sirenum__Shift__c>();
        Map<Id,sirenum__Shift__c> oldVisitMap = new Map<Id,sirenum__Shift__c>();
        
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
        sirenum__Placement__c projectPlacement= DataFactory.createPlacement(project,resource[0],visitTypeList[0]);
        sirenum__Placement__c SitePlacement= DataFactory.createSitePlacement(project,resource[0],visitTypeList[0],projectPlacement,clinicalSite);
        
        sirenum__Shift__c visit = new sirenum__Shift__c(id = resAllocationVisitList[0].id);
        visit.Site_Approval_Date__c = System.today() + 10;
        visit.PM_Approved_Date__c = System.today() + 12;
        Id RecordTypeIdvisit3 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        visit.RecordTypeId = RecordTypeIdvisit3 ;
        visit.sirenum__Contract__c = resAllocationVisitList[0].sirenum__Contract__c;
        visit.sirenum__Contact__c = resAllocationVisitList[0].sirenum__Contact__c;
        visit.sirenum__Site__c = null;
        visit.Visit_Approval_Status__c = 'Approved';
        update visit;
        oldVisitMap.put(visit.id,visit);
        
        sirenum__Shift__c visit1 = new sirenum__Shift__c(id = visit.id);
        visit1.Site_Approval_Date__c = System.today() + 5;
        visit1.PM_Approved_Date__c = System.today() + 6;
        visit1.RecordTypeId = RecordTypeIdvisit3 ;
        visit1.sirenum__Contract__c = resAllocationVisitList[0].sirenum__Contract__c;
        visit1.sirenum__Contact__c = resAllocationVisitList[0].sirenum__Contact__c;
        visit1.Outcome__c = 'Completed In Full';
        visit1.sirenum__Site__c = Null;
        visit1.Visit_Approval_Status__c = 'Rejected';
        visit1.sirenum__Contact__c = resource[0].Id;
        update visit1;
        newVisitMap.put(visit1.Id,visit1);
        
        List<sirenum__Shift__c> visitList = new List<sirenum__Shift__c>();
        visitList.add(visit1);
        
        sirenum__Placement__c plcmnt = new sirenum__Placement__c(id = SitePlacement.id);
        plcmnt.sirenum__Contract__c = resAllocationVisitList[0].sirenum__Contract__c;
        plcmnt.sirenum__Contact__c = resAllocationVisitList[0].sirenum__Contact__c;
        plcmnt.sirenum__Site__c = resAllocationVisitList[0].sirenum__Site__c;
        update plcmnt;
        
        Set<Id> projectIdSet = new set<id>();
        Set<Id> resourcetIdSet = new set<id>();
        Set<Id> siteIdSet = new set<id>();
        projectIdSet.add(participantLocation.Id);
        resourcetIdSet.add(resource[0].Id);
        
        ResourceNotActiveOnProjectHandler.getAllVisitRelatedToPlacement(projectIdSet,resourcetIdSet,siteIdSet);
        ResourceNotActiveOnProjectHandler.updateStartDateForSitePlacement(newVisitMap, oldVisitMap);
        ResourceNotActiveOnProjectHandler.updateStartDateForProjectPlacement(newVisitMap, oldVisitMap);
        ResourceNotActiveOnProjectHandler.updatePolicyAppliedOnVisit(newVisitMap,oldVisitMap);
        ResourceNotActiveOnProjectHandler.CheckActiveOnProject(visitList,newVisitMap,oldVisitMap);
        
        sirenum__Shift__c visitn = new sirenum__Shift__c(id = resAllocationVisitList[0].id);
        visitn.sirenum__Site__c = resAllocationVisitList[0].sirenum__Site__c;
        update visitn;
        oldVisitMap.put(visitn.id,visitn);
        VisitHelper.updateCountryStateLocation(visitList,oldVisitMap);
        
        VisitHelper.fillRateCalculation(visitList,oldVisitMap);
        
        sirenum__Shift__c visit3 = new sirenum__Shift__c(id = visit1.id);
        visit3.Visit_Approval_Status__c = 'Approved';
        
        /*VisitHelper.fakeMethod();
        ResourceNotActiveOnProjectHandler.coveringCoverageMethod();*/
   // }   
    
   /* @isTest
    public static void callMethodsResourceNotActiveOnProjectHandler1(){
        Map<Id,sirenum__Shift__c> newVisitMap = new Map<Id,sirenum__Shift__c>();
        Map<Id,sirenum__Shift__c> oldVisitMap = new Map<Id,sirenum__Shift__c>();
        
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
        sirenum__Placement__c projectPlacement= DataFactory.createPlacement(project,resource[0],visitTypeList[0]);
        sirenum__Placement__c SitePlacement= DataFactory.createSitePlacement(project,resource[0],visitTypeList[0],projectPlacement,clinicalSite);
        
        sirenum__Shift__c visit = new sirenum__Shift__c(id = resAllocationVisitList[0].id);
        visit.Site_Approval_Date__c = System.today() + 10;
        visit.PM_Approved_Date__c = System.today() + 12;
        Id RecordTypeIdvisit3 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        visit.RecordTypeId = RecordTypeIdvisit3 ;
        visit.sirenum__Contract__c = resAllocationVisitList[0].sirenum__Contract__c;
        visit.sirenum__Contact__c = resAllocationVisitList[0].sirenum__Contact__c;
        visit.sirenum__Site__c = resAllocationVisitList[0].sirenum__Site__c;
        visit.Visit_Approval_Status__c = 'Approved';
        visit.Project_Approval_Status__c = '';
        update visit;
        oldVisitMap.put(visit.id,visit);
        
        sirenum__Shift__c visit1 = new sirenum__Shift__c(id = visit.id);
        visit1.Site_Approval_Date__c = System.today() + 5;
        visit1.PM_Approved_Date__c = System.today() + 6;
        visit1.RecordTypeId = RecordTypeIdvisit3 ;
        visit1.sirenum__Contract__c = resAllocationVisitList[0].sirenum__Contract__c;
        visit1.sirenum__Contact__c = resAllocationVisitList[0].sirenum__Contact__c;
        visit1.sirenum__Site__c = resAllocationVisitList[0].sirenum__Site__c;
        visit1.Outcome__c = 'Completed In Full';
        visit1.Visit_Approval_Status__c = 'Rejected';
        visit1.sirenum__Contact__c = resource[0].Id;
        update visit1;
        newVisitMap.put(visit1.Id,visit1);
        
        List<sirenum__Shift__c> visitList = new List<sirenum__Shift__c>();
        visitList.add(visit1);
        
        sirenum__Placement__c plcmnt = new sirenum__Placement__c(id = SitePlacement.id);
        plcmnt.sirenum__Contract__c = resAllocationVisitList[0].sirenum__Contract__c;
        plcmnt.sirenum__Contact__c = resAllocationVisitList[0].sirenum__Contact__c;
        plcmnt.sirenum__Site__c = resAllocationVisitList[0].sirenum__Site__c;
        update plcmnt; 
        
        Set<Id> projectIdSet = new set<id>();
        Set<Id> resourcetIdSet = new set<id>();
        Set<Id> siteIdSet = new set<id>();
        projectIdSet.add(participantLocation.Id);
        resourcetIdSet.add(resource[0].Id);
        
        ResourceNotActiveOnProjectHandler.setDefaultValuesForResourcingCountry(visitList);
        ResourceNotActiveOnProjectHandler.visitNumberMandatory(visitList);
        ResourceNotActiveOnProjectHandler.sendErrorWhenResourceOwnerChangedOnChild(oldVisitMap,newVisitMap);
        ResourceNotActiveOnProjectHandler.createSiteActivationTicket(newVisitMap,oldVisitMap);
        
        sirenum__Shift__c visit3 = new sirenum__Shift__c(id = visit1.id);
        visit3.Visit_Approval_Status__c = 'Approved';
        
    }  */ 
}