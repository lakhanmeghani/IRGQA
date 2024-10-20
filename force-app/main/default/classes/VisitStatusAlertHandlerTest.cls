@isTest(SeeAllData=true)
public class VisitStatusAlertHandlerTest {  
    @isTest
    public static void visitAlert(){
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
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
        
        //Project team
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'NEW PROJECT ALERT';
        insert projectTeam;
        
        //Account
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCOUNT';
        insert account;
        
        //Project
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='NEW PROJECT ALERT';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off site';
        project.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        insert project;
        
        //Clinical site 
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
        
        //Participant 
        Participant__c participant = new Participant__c();
        participant.Name = '001_102';
        participant.Site_Clinical_Trial__c = clinicalSite.id;
        insert participant;
        
        //Participant location
        sirenum__Site__c participantLocation = new sirenum__Site__c();
        Id RecordTypeIdParticipantLocation = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Participant Location').getRecordTypeId();
        participantLocation.RecordTypeId = RecordTypeIdParticipantLocation; 
        participantLocation.Name = 'TEST VISIT ALERT';
        participantLocation.Participant__c = participant.Id;
        participantLocation.Location_Type__c = 'Off Site';
        participantLocation.sirenum__City__c = 'paris';
        participantLocation.sirenum__Country__c = 'France';
        insert participantLocation;
        
        //Visit type
        sirenum__Team__c visitType = new sirenum__Team__c();
        visitType.Name = 'Test_Trigger_Visit type NewW';
        visitType.Requires_Confirmation_From_Site__c = true;
        visitType.sirenum__Account__c = project.Id;
        insert  visitType ;
        
        //Visit 
        sirenum__Shift__c visit = new sirenum__Shift__c();
        Id RecordTypeIdvisit = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        visit.RecordTypeId = RecordTypeIdvisit ;
        visit.sirenum__Contract__c = project.id;
        visit.sirenum__Team__c = visitType.id;
        visit.Participant__c = participant.id;
        visit.Participant_Location__c = participantLocation.id;
        Time nullTime = Time.newInstance(00, 00, 00 ,0000); 
        Time endTime = Time.newInstance(23, 00, 00 ,0000);
        visit.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit.Visit_Request_received_from_Site__c = true;
        insert visit ;
        
        //Create group 
        Group gp            = new Group();
        gp.Name             = 'NEW PROJECT ALERT';
        gp.DeveloperName    = 'NEW_PROJECT_ALERT';
        gp.Type             = 'Queue';
        insert gp;
        
        //Group member 
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = gp.Id, UserOrGroupId = RecruitmentManager1.Id);
            insert gm;
        }
        List<id> visitIds = new List<id>();
        visitIds.add(visit.id);
        VisitStatusAlertHandler.visitAlert(visitIds);
    }
}

 
        /*User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        Contact resource = DataFactory.createContact(RecruitmentManager1,account,jobtype);
        List<sirenum__Team__c> visitTypeList = DataFactory.createVisitType(project);
        sirenum__Site__c clinicalSite = DataFactory.createSite(project);
        Participant__c participant = DataFactory.createParticipant(clinicalSite);
        sirenum__Site__c participantLocation = DataFactory.createParticipantLocation(participant);
        
        // visit 
        sirenum__Shift__c visit = new sirenum__Shift__c();
        Id RecordTypeIdvisit = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        visit.RecordTypeId = RecordTypeIdvisit ;
        visit.sirenum__Contract__c = project.id;
        visit.sirenum__Team__c = visitTypeList[0].id;
        visit.Participant__c = participant.id;
        visit.Participant_Location__c = participantLocation.id;
        Time nullTime = Time.newInstance(00, 00, 00 ,0000); 
        Time endTime = Time.newInstance(23, 59, 00 ,0000);
        visit.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 59, 00);
        visit.Visit_Request_received_from_Site__c = true;
        insert visit;
        
        // create group 
        Group gp            = new Group();
        gp.Name             = 'NEW PROJECT ALERT';
        gp.DeveloperName    = 'NEW_PROJECT_ALERT';
        gp.Type             = 'Queue';
        insert gp;
        
        // group member 
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = gp.Id, UserOrGroupId = RecruitmentManager1.Id);
            insert gm;
        }
        List<id> visitIds = new List<id>();
        visitIds.add(visit.id);
        VisitStatusAlertHandler.visitAlert(visitIds);
        
    }
}*/