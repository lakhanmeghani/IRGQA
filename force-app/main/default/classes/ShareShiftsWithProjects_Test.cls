/*
 * Copyright Sirenum (c) 2021.
 */
@IsTest
private class ShareShiftsWithProjects_Test {
    @TestSetup
    public static void createVisitData(){
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User RecruitmentManager1=new User(firstname = 'ABC', 
                                          lastName = 'XYZ', 
                                          email ='jai.jethanandani99@areya.tech', 
                                          Username = 'mikes99.sampsons@illingworthresearch.com', 
                                          EmailEncodingKey = 'ISO-8859-1', 
                                          Alias = 'mikes', 
                                          TimeZoneSidKey = 'America/Los_Angeles', 
                                          LocaleSidKey = 'en_US', 
                                          LanguageLocaleKey = 'en_US', 
                                          ProfileId = pf.Id
                                         ); 
        insert RecruitmentManager1;
        //user 2
        User RecruitmentManager2=new User(firstname = 'ABC', 
                                          lastName = 'XYZ', 
                                          email = 'mike.sampsons299@illingworthresearch.com', 
                                          Username = 'mike.sampsons299@illingworthresearch.com', 
                                          EmailEncodingKey = 'ISO-8859-1', 
                                          Alias = 'mike', 
                                          TimeZoneSidKey = 'America/Los_Angeles', 
                                          LocaleSidKey = 'en_US', 
                                          LanguageLocaleKey = 'en_US', 
                                          ProfileId = pf.Id
                                         ); 
        insert RecruitmentManager2;
        // project team # 5
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'NEW PROJECT ALERTS12';
        insert projectTeam;
        //account # 4 
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCOUNT121';
        insert account;
        //project #3  
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='NEW PROJECT ALERT121';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '189712';
        //project.Protocol_Title__c = '12367';
        project.Illingworth_Protocol_ID__c='1257812';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off siteas';
        project.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        project.Illingworth_Recruitment_Manager_2__c = RecruitmentManager2.Id;
        insert project;
        
        //Clinical site 
        sirenum__Site__c clinicalSite = new sirenum__Site__c();
        Id RecordTypeIdClinicalSite = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Site – Clinical Trial').getRecordTypeId();
        clinicalSite.RecordTypeId = RecordTypeIdClinicalSite;
        clinicalSite.Name = 'New_Site_Test_Trigger121' ;
        clinicalSite.Site_Number__c = '1467';
        clinicalSite.Illingworth_Clinical_Site_Name__c = 'Test-Trigger_clinical site';
        clinicalSite.sirenum__Country__c = 'France';
        clinicalSite.sirenum__City__c = 'Pairs';
        clinicalSite.Project__c = project.Id;
        insert clinicalSite;
        //participant 
        Participant__c participant = new Participant__c();
        participant.Name = '001_10212';
        participant.Site_Clinical_Trial__c = clinicalSite.id;
        insert participant;
        //participant location
        sirenum__Site__c participantLocation = new sirenum__Site__c();
        Id RecordTypeIdParticipantLocation = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Participant Location').getRecordTypeId();
        participantLocation.RecordTypeId = RecordTypeIdParticipantLocation; 
        participantLocation.Name = 'TEST VISIT ALERT121';
        participantLocation.Participant__c = participant.Id;
        participantLocation.Location_Type__c = 'Off Site';
        participantLocation.sirenum__City__c = 'paris';
        participantLocation.sirenum__Country__c = 'France';
        insert participantLocation;
        
        // visit type
        sirenum__Team__c visitType = new sirenum__Team__c();
        visitType.Name = 'Test_Trigger_Visit type NewW1212';
        visitType.Requires_Confirmation_From_Site__c = true;
        visitType.sirenum__Account__c = project.Id;
        insert  visitType ;
        // visit 
        sirenum__Shift__c visit = new sirenum__Shift__c();
        Id RecordTypeIdvisit = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        visit.RecordTypeId = RecordTypeIdvisit ;
        visit.sirenum__Contract__c = project.id;
        visit.sirenum__Team__c = visitType.id;
        visit.Participant__c = participant.id;
        visit.Participant_Location__c = participantLocation.id;
        visit.sirenum__Scheduled_Start_Time__c = system.now()-7;
        visit.sirenum__Scheduled_End_Time__c = system.now();
        visit.Visit_Request_received_from_Site__c = true;
        visit.sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2021, 5, 1, 00, 0, 0);
        visit.sirenum__Scheduled_End_Time__c = Datetime.newInstance(2021, 5, 1, 23, 00, 0);
        insert visit ;
        
         Group group1 = new Group(Name = 'Group 1', DeveloperName = 'Group1', Type = 'Queue');
        insert group1;
       /* sirenum__Shift__c shift1 = new sirenum__Shift__c(
                sirenum__Contract__c = contract1.Id,
                Participant__c = participant.Id,
                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2021, 5, 1, 9, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2021, 5, 1, 17, 0, 0)
        );
        if(shift1!=null){
        insert shift1;
        }*/
        //createVisitData();
        List<sirenum__Shift__Share> shiftShares = [SELECT ParentId, UserOrGroupId FROM sirenum__Shift__Share WHERE RowCause = 'Manual'];
        System.assertEquals(0, shiftShares.size());
    }
    @IsTest
    static void testNoContract() {
        Account acc1 = new Account(Name  = 'Test');
        insert acc1;
        Group group1 = new Group(Name = 'Group 5', DeveloperName = 'Group5', Type = 'Queue');
        insert group1;
        /*sirenum__Shift__c shift1 = new sirenum__Shift__c(
                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2021, 5, 1, 9, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2021, 5, 1, 17, 0, 0)
        );
        insert shift1;
		*/
        //createVisitData();
        List<sirenum__Shift__Share> shiftShares = [SELECT ParentId, UserOrGroupId FROM sirenum__Shift__Share WHERE RowCause = 'Manual'];
        System.assertEquals(0, shiftShares.size());
    }

   /* @IsTest
    static void testNoProjectTeam() {
         Profile pf= [Select Id from profile where Name='System Administrator']; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User RecruitmentManager1=new User(firstname = 'ABC', 
                                          lastName = 'XYZ', 
                                          email ='mikes.sampsons@illingworthresearch.com', 
                                          Username = 'mikes.sampsons@illingworthresearch.com', 
                                          EmailEncodingKey = 'ISO-8859-1', 
                                          Alias = 'mikes', 
                                          TimeZoneSidKey = 'America/Los_Angeles', 
                                          LocaleSidKey = 'en_US', 
                                          LanguageLocaleKey = 'en_US', 
                                          ProfileId = pf.Id
                                         ); 
        
        
        insert RecruitmentManager1;
        //user 2
        User RecruitmentManager2=new User(firstname = 'ABC', 
                                          lastName = 'XYZ', 
                                          email = 'mike.sampsons2@illingworthresearch.com', 
                                          Username = 'mike.sampsons2@illingworthresearch.com', 
                                          EmailEncodingKey = 'ISO-8859-1', 
                                          Alias = 'mike', 
                                          TimeZoneSidKey = 'America/Los_Angeles', 
                                          LocaleSidKey = 'en_US', 
                                          LanguageLocaleKey = 'en_US', 
                                          ProfileId = pf.Id
                                         ); 
        
        
        insert RecruitmentManager2;
        Account acc1 = new Account(Name  = 'Test');
        insert acc1;
        Project_Team__c projectTeam1 = new Project_Team__c(Name = 'Project Team 1');
        insert projectTeam1;
        sirenum__ProActiveContract__c contract1 = new sirenum__ProActiveContract__c();
        contract1.Name ='NEW PROJECT ALERTS12';
        contract1.sirenum__Client__c = acc1.Id;
        contract1.Opportunity_Number__c = '189744';
        //project.Protocol_Title__c = '12367';
        contract1.Illingworth_Protocol_ID__c='1257888';
        contract1.Project_Team__c = projectTeam1.Id; 
        contract1.Off_site_Activities__c = 'test off 56site';
        contract1.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        contract1.Illingworth_Recruitment_Manager_2__c = RecruitmentManager2.Id;
        insert contract1;
       
        //create visit 
        
        // project team # 5
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'NEW PROJECT ALERT';
        projectTeam.OwnerId = RecruitmentManager1.Id;
        insert projectTeam;
        //account # 4 
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCOUNT';
        insert account;
        //project #3  
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='NEW PROJECT ALERT';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '1897';
        //project.Protocol_Title__c = '12367';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off site';
        project.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        project.Illingworth_Recruitment_Manager_2__c = RecruitmentManager2.Id;
        insert project;
        
        //Clinical site # 2
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
        
        // visit type
        sirenum__Team__c visitType = new sirenum__Team__c();
        visitType.Name = 'Test_Trigger_Visit type New';
        visitType.Requires_Confirmation_From_Site__c = true;
        visitType.sirenum__Account__c = project.id;
        insert  visitType ;
        // visit 
        sirenum__Shift__c site1 = new sirenum__Shift__c();
        Id RecordTypeIdvisit = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        site1.RecordTypeId = RecordTypeIdvisit ;
        site1.sirenum__Contract__c = project.id;
        site1.sirenum__Team__c = visitType.id;
        site1.Participant__c = participant.id;
        site1.Participant_Location__c = participantLocation.id;
        site1.sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2021, 5, 1, 00, 0, 0);
        site1.sirenum__Scheduled_End_Time__c = Datetime.newInstance(2021, 5, 1, 23, 00, 0);
        site1.Visit_Request_received_from_Site__c = true;
        insert site1 ;
        Group group1 = new Group(Name = 'Group 1', DeveloperName = 'Group1', Type = 'Queue');
        insert group1;
    
        //createVisitData();
        List<sirenum__Shift__Share> shiftShares = [SELECT ParentId, UserOrGroupId FROM sirenum__Shift__Share WHERE RowCause = 'Manual'];
        System.assertEquals(0, shiftShares.size());
    }
*/
    
    /*
    @IsTest
    static void testQueues() {
        Test.startTest();
         Profile pf= [Select Id from profile where Name='System Administrator']; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User RecruitmentManager1=new User(firstname = 'ABCDa', 
                                          lastName = 'XYZYa', 
                                          email ='mike112.sampsons@illingworthresearch.com', 
                                          Username = 'mike112.sampsonsy@illingworthresearch.com', 
                                          EmailEncodingKey = 'ISO-8859-1', 
                                          Alias = 'miketest', 
                                          TimeZoneSidKey = 'America/Los_Angeles', 
                                          LocaleSidKey = 'en_US', 
                                          LanguageLocaleKey = 'en_US', 
                                          ProfileId = pf.Id
                                         ); 
        
        
        insert RecruitmentManager1;
        //user 2
        User RecruitmentManager2=new User(firstname = 'ABCD', 
                                          lastName = 'XYZY', 
                                          email = 'mikevc123.sampsons2@illingworthresearch.com', 
                                          Username = 'mikevc123.sampsons2@illingworthresearch.com', 
                                          EmailEncodingKey = 'ISO-8859-1', 
                                          Alias = 'mikevc', 
                                          TimeZoneSidKey = 'America/Los_Angeles', 
                                          LocaleSidKey = 'en_US', 
                                          LanguageLocaleKey = 'en_US', 
                                          ProfileId = pf.Id
                                         ); 
        
        
        insert RecruitmentManager2;
        Account acc1 = new Account(Name  = 'Test');
        insert acc1;
        Group group1 = new Group(Name = 'Group1', DeveloperName = 'Group11', Type = 'Queue');
        Group group2 = new Group(Name = 'Group2', DeveloperName = 'Group22', Type = 'Queue');
        insert new Group[]{group1, group2};
        // Must add Project Team and Shift to Queue Objects for this group
        
        createQueueSObjects(new Set<Id>{group1.Id, group2.Id});
        Test.stopTest();
        // project team # 5
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'NEW PROJECT Test';
        projectTeam.OwnerId = RecruitmentManager1.Id;
        insert projectTeam;
        //account # 4 
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCNT';
        insert account;
        //project #3  
        sirenum__ProActiveContract__c contract2 = new sirenum__ProActiveContract__c();
        contract2.Name ='NEW PROJECT ALERTS12399';
        contract2.sirenum__Client__c = account.Id;
        contract2.Opportunity_Number__c = '189799';
        //project.Protocol_Title__c = '12367';
        contract2.Illingworth_Protocol_ID__c='1257899';
        contract2.Project_Team__c = projectTeam.Id; 
        contract2.Off_site_Activities__c = 'test off site9';
        contract2.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        contract2.Illingworth_Recruitment_Manager_2__c = RecruitmentManager2.Id;
        insert contract2;
        //project #3  
        sirenum__ProActiveContract__c contract1 = new sirenum__ProActiveContract__c();
        contract1.Name ='NEW PROJECT ALERTS12392';
        contract1.sirenum__Client__c = account.Id;
        contract1.Opportunity_Number__c = '1897992';
        //project.Protocol_Title__c = '12367';
        contract1.Illingworth_Protocol_ID__c='1257892';
        contract1.Project_Team__c = projectTeam.Id; 
        contract1.Off_site_Activities__c = 'test off site92';
        contract1.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        contract1.Illingworth_Recruitment_Manager_2__c = RecruitmentManager2.Id;
        insert contract1;
        //project #3  
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='NEW PROJECT ALERTS108';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '1897108';
        //project.Protocol_Title__c = '12367';
        project.Illingworth_Protocol_ID__c='12578108';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off site108';
        project.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        project.Illingworth_Recruitment_Manager_2__c = RecruitmentManager2.Id;
        insert project;
        
        //Clinical site # 2
        sirenum__Site__c clinicalSite = new sirenum__Site__c();
        Id RecordTypeIdClinicalSite = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Site – Clinical Trial').getRecordTypeId();
        clinicalSite.RecordTypeId = RecordTypeIdClinicalSite;
        clinicalSite.Name = 'New_Site_Test_Trggr' ;
        clinicalSite.Site_Number__c = '1467';
        clinicalSite.Illingworth_Clinical_Site_Name__c = 'Test-Trigger_clinical site';
        clinicalSite.sirenum__Country__c = 'France';
        clinicalSite.sirenum__City__c = 'Pairs';
        clinicalSite.Project__c = project.Id;
        insert clinicalSite;
        //participant 
        Participant__c participant = new Participant__c();
        participant.Name = '001_1023';
        participant.Site_Clinical_Trial__c = clinicalSite.id;
        insert participant;
        //participant 1
        Participant__c participant1 = new Participant__c();
        participant1.Name = '001_102322';
        participant1.Illingworth_Project__c = contract1.id;
        participant1.Site_Clinical_Trial__c = clinicalSite.id;
        insert participant1;
        //participant 2
        Participant__c participant2 = new Participant__c();
        participant2.Name = '001_10232212';
      	participant2.Illingworth_Project__c = contract2.id;
        participant2.Site_Clinical_Trial__c = clinicalSite.id;
        insert participant2;
        //participant location
        sirenum__Site__c participantLocation = new sirenum__Site__c();
        Id RecordTypeIdParticipantLocation = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Participant Location').getRecordTypeId();
        participantLocation.RecordTypeId = RecordTypeIdParticipantLocation; 
        participantLocation.Name = 'TEST VISIT ALERTSq';
        participantLocation.Participant__c = participant1.Id;
        participantLocation.Location_Type__c = 'Off Site';
        participantLocation.sirenum__City__c = 'paris';
        participantLocation.sirenum__Country__c = 'France';
        insert participantLocation;
        //participant location2
        sirenum__Site__c participantLocation2 = new sirenum__Site__c();
        participantLocation2.RecordTypeId = RecordTypeIdParticipantLocation; 
        participantLocation2.Name = 'TEST VISIT ALERTSq';
        participantLocation2.Participant__c = participant2.Id;
        participantLocation2.Location_Type__c = 'Off Site';
        participantLocation2.sirenum__City__c = 'paris';
        participantLocation2.sirenum__Country__c = 'France';
        insert participantLocation2;
        // visit type
        sirenum__Team__c visitType = new sirenum__Team__c();
        visitType.Name = 'Test_Trigger_Visit type New199';
        visitType.Requires_Confirmation_From_Site__c = true;
        visitType.sirenum__Account__c = contract1.id;
        insert  visitType ;
        // visit 
        sirenum__Shift__c shift11 = new sirenum__Shift__c();
        Id RecordTypeIdvisit = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        shift11.RecordTypeId = RecordTypeIdvisit ;
        shift11.sirenum__Contract__c = contract1.id;
        shift11.sirenum__Team__c = visitType.id;
        shift11.Participant__c = participant1.id;
        shift11.Participant_Location__c = participantLocation.id;
        shift11.sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2021, 5, 1, 0, 0, 0);
        shift11.sirenum__Scheduled_End_Time__c = Datetime.newInstance(2021, 5, 1, 23, 0, 0);
        shift11.Visit_Request_received_from_Site__c = true;
        insert shift11 ;
        // visit 
        sirenum__Shift__c shift12 = new sirenum__Shift__c();
        shift12.RecordTypeId = RecordTypeIdvisit ;
        shift12.sirenum__Contract__c = contract1.id;
        shift12.sirenum__Team__c = visitType.id;
        shift12.Participant__c = participant1.id;
        shift12.Participant_Location__c = participantLocation.id;
        shift12.sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2021, 5, 1, 00, 00, 0);
        shift12.sirenum__Scheduled_End_Time__c = Datetime.newInstance(2021, 5, 1, 23, 00, 0);
        shift12.Visit_Request_received_from_Site__c = true;
        insert shift12 ;
        // visit 
        sirenum__Shift__c shift21 = new sirenum__Shift__c();
        shift21.RecordTypeId = RecordTypeIdvisit ;
        shift21.sirenum__Contract__c = contract1.id;
        shift21.sirenum__Team__c = visitType.id;
        shift21.Participant__c = participant1.id;
        shift21.Participant_Location__c = participantLocation.id;
        shift21.sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2021, 5, 1, 0, 0, 0);
        shift21.sirenum__Scheduled_End_Time__c = Datetime.newInstance(2021, 5, 1, 23, 0, 0);
        shift21.Visit_Request_received_from_Site__c = true;
        insert shift21 ;
        // visit 
        sirenum__Shift__c shift22 = new sirenum__Shift__c();
        shift22.RecordTypeId = RecordTypeIdvisit ;
        shift22.sirenum__Contract__c = contract1.id;
        shift22.sirenum__Team__c = visitType.id;
        shift22.Participant__c = participant1.id;
        shift22.Participant_Location__c = participantLocation.id;
        shift22.sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2021, 5, 1, 0, 0, 0);
        shift22.sirenum__Scheduled_End_Time__c = Datetime.newInstance(2021, 5, 1, 23, 0, 0);
        shift22.Visit_Request_received_from_Site__c = true;
        insert shift22 ;
        List<sirenum__Shift__Share> shiftShares = [SELECT ParentId, UserOrGroupId FROM sirenum__Shift__Share WHERE RowCause = 'Manual'];

        //System.assertEquals(4, shiftShares.size());
        for (sirenum__Shift__Share shiftShare : shiftShares) {
            if (shiftShare.ParentId  == shift11.Id || shiftShare.ParentId  == shift12.Id) {
                System.assertEquals(group1.Id, shiftShare.UserOrGroupId);
            } else {
                System.assertEquals(group2.Id, shiftShare.UserOrGroupId);
            }
        }
        shift11.sirenum__Contract__c = contract2.Id;
        shift11.Participant__c = participant2.Id;
        shift11.Participant_Location__c = participantLocation2.Id;
        shift12.sirenum__Contract__c = contract2.Id;
        shift12.Participant__c = participant2.Id;
        shift12.Participant_Location__c = participantLocation2.Id;
        shift21.sirenum__Contract__c = contract1.Id;
        shift21.Participant__c = participant1.Id;
        shift22.sirenum__Contract__c = contract1.Id;
        shift22.Participant__c = participant1.Id;
        update new sirenum__Shift__c[]{shift11, shift12, shift21, shift22};
        shiftShares = [SELECT ParentId, UserOrGroupId FROM sirenum__Shift__Share WHERE RowCause = 'Manual'];
        //System.assertEquals(4, shiftShares.size());
        for (sirenum__Shift__Share shiftShare : shiftShares) {
            if (shiftShare.ParentId  == shift11.Id || shiftShare.ParentId  == shift12.Id) {
                System.assertEquals(group2.Id, shiftShare.UserOrGroupId);
            } else {
                System.assertEquals(group1.Id, shiftShare.UserOrGroupId);
            }
        }
    }
   */
    // Must be a future method to avoid Mixed DML error
    @Future
    private static void createQueueSObjects(Set<Id> groupIds) {
        List<QueueSobject> queueObjects = new List<QueueSobject>();
        for (Id groupId : groupIds) {
            queueObjects.add(new QueueSobject(SobjectType='sirenum__Shift__c', QueueId=groupId));
            queueObjects.add(new QueueSobject(SobjectType='sirenum__Site__c', QueueId=groupId));
            queueObjects.add(new QueueSobject(SobjectType='Project_Team__c', QueueId=groupId));
            queueObjects.add(new QueueSobject(SobjectType='Participant__c', QueueId=groupId));
        }
        insert queueObjects;
    }

}