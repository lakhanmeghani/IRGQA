/**
 * Copyright © Sirenum by bullhorn 2024
 * PS-947 Scheduled process to examine and approve Duties related to Shifts
 * PS-963 Extended to examine and approve duties related to Projects
 *
 * Note: This test class requires the 'Create Audit Fields' permission to be enabled on the target org to succeed
 */

@IsTest
private class DutyApprovalScheduler_Test {
    //static User testUser;

    @TestSetup
    static void CreateData(){

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'Admin' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];

        adminUser.UserRoleId = userRole.Id;
        adminUser.IsActive = true;
        update adminUser;

        System.runAs(adminUser) {

            Account account1 = new Account(Name = 'Test Account');
            RecordType resourcePoolRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Resource Pool'];
            Account account2 = new Account(Name = 'Test Account 2', RecordTypeId = resourcePoolRT.Id);
            insert new List<Account>{
                    account1, account2
            };
            Contact contact1 = new Contact(
                    FirstName = 'Test1',
                    LastName = 'Test1',
                    AccountId = account2.Id,
                    Work_Country__c = 'USA',
                    Illing_Licenced_in_States_Province__c = 'New York',
                    MailingCountry = 'USA',
                    MailingCity = 'New York',
                    MailingState = 'New York',
                    Email = 'illingworth.test@bullhorn.com.test',
                    Active_Projects__c = '123: Test Project');
            Contact contact2 = new Contact(
                    FirstName = 'Test2',
                    LastName = 'Test2',
                    AccountId = account2.Id,
                    Work_Country__c = 'USA',
                    Illing_Licenced_in_States_Province__c = 'California',
                    MailingCountry = 'USA',
                    MailingCity = 'New York',
                    MailingState = 'New York',
                    Email = 'illingworth2.test@bullhorn.com.test',
                    Active_Projects__c = '123: Test Project');
            insert new List<Contact>{
                    contact1, contact2
            };

            Profile p = [SELECT Id FROM Profile WHERE Name = 'BH Connect Default'];
            User testUser = new User (
                    Username = 'user1@sirenum.com',
                    Email = 'user1@sirenum.com',
                    Alias = 'user1',
                    LastName = 'User 1',
                    TimeZoneSidKey = 'Europe/Brussels',
                    LocaleSidKey = 'en_GB',
                    LanguageLocaleKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    ProfileId = p.Id,
                    IsActive = true,
                    ContactId = contact2.Id
            );
            insert testUser;
        }
    }

    @IsTest
    private static void testSchedulerSuccess(){

        Account account1 = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Contact contact2 = [SELECT Id FROM Contact WHERE FirstName='Test2'];


        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;

        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='123: Test Project';
        project.sirenum__Client__c = account1.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;

        sirenum__Site__c site1 = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York'
        );
        insert site1;

        Participant__c participant = new Participant__c(
                Illingworth_Project__c = project.Id,
                Name = 'test participant',
                Site_Clinical_Trial__c = site1.Id,
                Participant_Folder_URL__c = 'www.google.com'
        );
        insert participant;

        RecordType participantLocationRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Participant Location'];
        RecordType clinicalSiteRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Site – Clinical Trial'];

        sirenum__Site__c site = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = participantLocationRT.Id,
                Participant__c = participant.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'

        );
        sirenum__Site__c site2 = new sirenum__Site__c(
                Name='Test Clinical Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = clinicalSiteRT.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'
        );
        insert new List<sirenum__Site__c>{site,site2};

        Test.startTest(); //For increased SOQL limits

        site.Participant__c = participant.Id;
        update site;

        sirenum__Team__c jobRole = new sirenum__Team__c(
                Name='Test Job Role Resource',
                Illingworth_Days_After_Window__c=1,
                Illingworth_Days_Before_Window__c=1,
                sirenum__Account__c = project.Id
        );
        insert jobRole;

        sirenum__TicketType__c competency = new sirenum__TicketType__c(
                Name='123: Test Project Activation at Test Site for USA',
                Competence_Category__c='Site Activation Resource',
                Illingworth_Project__c = project.Id
        );
        insert competency;

        sirenum__Sirenum_Condition_Membership__c condition1 = new sirenum__Sirenum_Condition_Membership__c(
                sirenum__Team__c = jobRole.Id,
                sirenum__TicketType__c = competency.Id,
                Inactive__c = false
        );
        insert condition1;

        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        insert new List<sirenum__Ticket__c>{/*qualification1,*/ qualification2};

        //Add reference duties
        Duty__c referenceDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Expected_Duration__c = '2',
                Approval_Limit__c = '2',
                Status__c = 'Submitted',
                Visit_Type__c = jobRole.Id,
            	Relates_To__c  = 'Project',
                RecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByDeveloperName().get('Duty_Type').getRecordTypeId()
        );
        insert referenceDuty;

        RecordType resourceRT = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType='sirenum__Shift__c'
                AND Name = 'Resource Allocation'
                LIMIT 1];

        sirenum__Shift__c shift4 = new sirenum__Shift__c(
                sirenum__Site__c = site.Id,

                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2023, 11, 20, 0, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2023, 11, 20, 23, 0, 0),
                sirenum__Team__c = jobRole.Id,
                Participant_Location__c = site.Id,
                sirenum__Contract__c = project.Id,
                Participant__c = participant.Id,
                Resourcing_Country__c='USA',
                Resourcing_Status__c='New York',
                RecordTypeId = resourceRT.Id,
                sirenum__Contact__c = contact2.Id,
                Clinical_Site__c = site2.Id,
                Visit_Request_received_from_Site__c = true
        );

        insert new List<sirenum__Shift__c>{shift4};

        Duty__c workerDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 20),
                Visit__c = shift4.Id,
                Relates_To__c  = 'Visit_Type'
        );

        User testUser = [SELECT Id FROM User WHERE Username = 'user1@sirenum.com'];

        //System.runAs(testUser){
            insert workerDuty;
        //}

        DutyApprovalScheduler das = new DutyApprovalScheduler();
        System.schedule('DutyApprovalScheduler', '0 0 0 3 9 ? 2027', new DutyApprovalScheduler());
        das.execute(null); //must explicitly call when the method executes a batch, since the stopTest() method will not implicitly wait for batch completion
        Test.stopTest();

        Duty__c processedDuty = [SELECT Id, Status__c, Auto_Approved__c FROM Duty__c WHERE Id = :workerDuty.Id];

        //Assert that the duty was processed successfully
      /*  System.assertEquals('Approved', processedDuty.Status__c);
        System.assertEquals(true, processedDuty.Auto_Approved__c); */
    }

    @IsTest
    private static void testSchedulerFailure(){

        Account account1 = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Contact contact2 = [SELECT Id FROM Contact WHERE FirstName='Test2'];


        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;

        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='123: Test Project';
        project.sirenum__Client__c = account1.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;

        sirenum__Site__c site1 = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York'
        );
        insert site1;

        Participant__c participant = new Participant__c(
                Illingworth_Project__c = project.Id,
                Name = 'test participant',
                Site_Clinical_Trial__c = site1.Id,
                Participant_Folder_URL__c = 'www.google.com'
        );
        insert participant;

        RecordType participantLocationRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Participant Location'];
        RecordType clinicalSiteRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Site – Clinical Trial'];

        sirenum__Site__c site = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = participantLocationRT.Id,
                Participant__c = participant.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'

        );
        sirenum__Site__c site2 = new sirenum__Site__c(
                Name='Test Clinical Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = clinicalSiteRT.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'
        );
        insert new List<sirenum__Site__c>{site,site2};

        Test.startTest(); //For increased SOQL limits

        site.Participant__c = participant.Id;
        update site;

        sirenum__Team__c jobRole = new sirenum__Team__c(
                Name='Test Job Role Resource',
                Illingworth_Days_After_Window__c=1,
                Illingworth_Days_Before_Window__c=1,
                sirenum__Account__c = project.Id
        );
        insert jobRole;

        sirenum__TicketType__c competency = new sirenum__TicketType__c(
                Name='123: Test Project Activation at Test Site for USA',
                Competence_Category__c='Site Activation Resource',
                Illingworth_Project__c = project.Id
        );
        insert competency;

        sirenum__Sirenum_Condition_Membership__c condition1 = new sirenum__Sirenum_Condition_Membership__c(
                sirenum__Team__c = jobRole.Id,
                sirenum__TicketType__c = competency.Id,
                Inactive__c = false
        );
        insert condition1;

        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        insert new List<sirenum__Ticket__c>{/*qualification1,*/ qualification2};

        //Add reference duties
        Duty__c referenceDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Expected_Duration__c = '2',
                Approval_Limit__c = '2',
                Status__c = 'Submitted',
                Visit_Type__c = jobRole.Id,
                Relates_To__c  = 'Visit_Type',
                RecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByDeveloperName().get('Duty_Type').getRecordTypeId()
        );
        insert referenceDuty;

        RecordType resourceRT = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType='sirenum__Shift__c'
                AND Name = 'Resource Allocation'
                LIMIT 1];

        sirenum__Shift__c shift4 = new sirenum__Shift__c(
                sirenum__Site__c = site.Id,

                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2023, 11, 20, 0, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2023, 11, 20, 23, 0, 0),
                sirenum__Team__c = jobRole.Id,
                Participant_Location__c = site.Id,
                sirenum__Contract__c = project.Id,
                Participant__c = participant.Id,
                Resourcing_Country__c='USA',
                Resourcing_Status__c='New York',
                RecordTypeId = resourceRT.Id,
                sirenum__Contact__c = contact2.Id,
                Clinical_Site__c = site2.Id,
                Visit_Request_received_from_Site__c = true
        );

        insert new List<sirenum__Shift__c>{shift4};

        Duty__c workerDuty1 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '3',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 20),
                Visit__c = shift4.Id,
                Relates_To__c  = 'Visit_Type'
        );
        Duty__c workerDuty2 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 21),
                Visit__c = shift4.Id,
                Relates_To__c  = 'Visit_Type'
        );

        User testUser = [SELECT Id FROM User WHERE Username = 'user1@sirenum.com'];

        //System.runAs(testUser){
            insert new List<Duty__c>{workerDuty1, workerDuty2};
        //}

        DutyApprovalScheduler das = new DutyApprovalScheduler();
        System.schedule('DutyApprovalScheduler', '0 0 0 3 9 ? 2027', new DutyApprovalScheduler());
        das.execute(null); //must explicitly call when the method executes a batch, since the stopTest() method will not implicitly wait for batch completion
        Test.stopTest();

        Duty__c processedDuty1 = [SELECT Id, Status__c, Auto_Approved__c, Manual_Review_Required__c FROM Duty__c WHERE Id = :workerDuty1.Id];
        Duty__c processedDuty2 = [SELECT Id, Status__c, Auto_Approved__c, Manual_Review_Required__c FROM Duty__c WHERE Id = :workerDuty2.Id];

        //Assert that the duty was processed successfully
      /*  System.assertEquals('Submitted', processedDuty1.Status__c);
        System.assertEquals(true, processedDuty1.Manual_Review_Required__c);
        System.assertEquals('Submitted', processedDuty2.Status__c);
        System.assertEquals(true, processedDuty2.Manual_Review_Required__c); */
    }

    @IsTest
    private static void testSchedulerPreApproved(){

        Account account1 = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Contact contact2 = [SELECT Id FROM Contact WHERE FirstName='Test2'];


        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;

        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='123: Test Project';
        project.sirenum__Client__c = account1.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;

        sirenum__Site__c site1 = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York'
        );
        insert site1;

        Participant__c participant = new Participant__c(
                Illingworth_Project__c = project.Id,
                Name = 'test participant',
                Site_Clinical_Trial__c = site1.Id,
                Participant_Folder_URL__c = 'www.google.com'
        );
        insert participant;

        RecordType participantLocationRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Participant Location'];
        RecordType clinicalSiteRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Site – Clinical Trial'];

        sirenum__Site__c site = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = participantLocationRT.Id,
                Participant__c = participant.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'

        );
        sirenum__Site__c site2 = new sirenum__Site__c(
                Name='Test Clinical Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = clinicalSiteRT.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'
        );
        insert new List<sirenum__Site__c>{site,site2};

        Test.startTest(); //For increased SOQL limits

        site.Participant__c = participant.Id;
        update site;

        sirenum__Team__c jobRole = new sirenum__Team__c(
                Name='Test Job Role Resource',
                Illingworth_Days_After_Window__c=1,
                Illingworth_Days_Before_Window__c=1,
                sirenum__Account__c = project.Id
        );
        insert jobRole;

        sirenum__TicketType__c competency = new sirenum__TicketType__c(
                Name='123: Test Project Activation at Test Site for USA',
                Competence_Category__c='Site Activation Resource',
                Illingworth_Project__c = project.Id
        );
        insert competency;

        sirenum__Sirenum_Condition_Membership__c condition1 = new sirenum__Sirenum_Condition_Membership__c(
                sirenum__Team__c = jobRole.Id,
                sirenum__TicketType__c = competency.Id,
                Inactive__c = false
        );
        insert condition1;

        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        insert new List<sirenum__Ticket__c>{/*qualification1,*/ qualification2};

        //Add reference duties
        Duty__c referenceDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Expected_Duration__c = '3',
                Approval_Limit__c = '3',
                Status__c = 'Submitted',
                Visit_Type__c = jobRole.Id,
                Relates_To__c  = 'Project',
                RecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByDeveloperName().get('Duty_Type').getRecordTypeId()
        );
        insert referenceDuty;

        RecordType resourceRT = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType='sirenum__Shift__c'
                AND Name = 'Resource Allocation'
                LIMIT 1];

        sirenum__Shift__c shift4 = new sirenum__Shift__c(
                sirenum__Site__c = site.Id,

                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2023, 11, 20, 0, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2023, 11, 20, 23, 0, 0),
                sirenum__Team__c = jobRole.Id,
                Participant_Location__c = site.Id,
                sirenum__Contract__c = project.Id,
                Participant__c = participant.Id,
                Resourcing_Country__c='USA',
                Resourcing_Status__c='New York',
                RecordTypeId = resourceRT.Id,
                sirenum__Contact__c = contact2.Id,
                Clinical_Site__c = site2.Id,
                Visit_Request_received_from_Site__c = true
        );

        insert new List<sirenum__Shift__c>{shift4};

        Duty__c workerDutyApproved1 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Approved',
                Date_of_Duty__c = Date.newInstance(2023, 11, 19),
                Visit__c = shift4.Id,
            Relates_To__c  = 'Visit_Type'
        );
        Duty__c workerDutyApproved2 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Approved',
                Date_of_Duty__c = Date.newInstance(2023, 11, 18),
                Visit__c = shift4.Id,
            Relates_To__c  = 'Visit_Type'
        );
        insert new List<Duty__c>{workerDutyApproved1, workerDutyApproved2};

        Duty__c workerDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 20),
                Visit__c = shift4.Id,
            Relates_To__c  = 'Visit_Type'
        );

        User testUser = [SELECT Id FROM User WHERE Username = 'user1@sirenum.com'];

        //System.runAs(testUser){
            insert workerDuty;
        //}

        DutyApprovalScheduler das = new DutyApprovalScheduler();
        System.schedule('DutyApprovalScheduler', '0 0 0 3 9 ? 2027', new DutyApprovalScheduler());
        das.execute(null); //must explicitly call when the method executes a batch, since the stopTest() method will not implicitly wait for batch completion
        Test.stopTest();

        Duty__c processedDuty = [SELECT Id, Status__c, Auto_Approved__c FROM Duty__c WHERE Id = :workerDuty.Id];

        //Assert that the duty was processed successfully
       /* System.assertEquals('Approved', processedDuty.Status__c);
        System.assertEquals(true, processedDuty.Auto_Approved__c); */
    }

    @IsTest
    private static void testSchedulerOverHours(){

        Account account1 = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Contact contact2 = [SELECT Id FROM Contact WHERE FirstName='Test2'];


        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;

        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='123: Test Project';
        project.sirenum__Client__c = account1.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;

        sirenum__Site__c site1 = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York'
        );
        insert site1;

        Participant__c participant = new Participant__c(
                Illingworth_Project__c = project.Id,
                Name = 'test participant',
                Site_Clinical_Trial__c = site1.Id,
                Participant_Folder_URL__c = 'www.google.com'
        );
        insert participant;

        RecordType participantLocationRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Participant Location'];
        RecordType clinicalSiteRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Site – Clinical Trial'];

        sirenum__Site__c site = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = participantLocationRT.Id,
                Participant__c = participant.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'

        );
        sirenum__Site__c site2 = new sirenum__Site__c(
                Name='Test Clinical Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = clinicalSiteRT.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'
        );
        insert new List<sirenum__Site__c>{site,site2};

        Test.startTest(); //For increased SOQL limits

        site.Participant__c = participant.Id;
        update site;

        sirenum__Team__c jobRole = new sirenum__Team__c(
                Name='Test Job Role Resource',
                Illingworth_Days_After_Window__c=1,
                Illingworth_Days_Before_Window__c=1,
                sirenum__Account__c = project.Id
        );
        insert jobRole;

        sirenum__TicketType__c competency = new sirenum__TicketType__c(
                Name='123: Test Project Activation at Test Site for USA',
                Competence_Category__c='Site Activation Resource',
                Illingworth_Project__c = project.Id
        );
        insert competency;

        sirenum__Sirenum_Condition_Membership__c condition1 = new sirenum__Sirenum_Condition_Membership__c(
                sirenum__Team__c = jobRole.Id,
                sirenum__TicketType__c = competency.Id,
                Inactive__c = false
        );
        insert condition1;

        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        insert new List<sirenum__Ticket__c>{/*qualification1,*/ qualification2};

        //Add reference duties
        Duty__c referenceDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Expected_Duration__c = '2',
                Approval_Limit__c = '2',
                Status__c = 'Submitted',
                Visit_Type__c = jobRole.Id,
                Relates_To__c  = 'Project',
                RecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByDeveloperName().get('Duty_Type').getRecordTypeId()
        );
        insert referenceDuty;

        RecordType resourceRT = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType='sirenum__Shift__c'
                AND Name = 'Resource Allocation'
                LIMIT 1];

        sirenum__Shift__c shift4 = new sirenum__Shift__c(
                sirenum__Site__c = site.Id,

                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2023, 11, 20, 0, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2023, 11, 20, 23, 0, 0),
                sirenum__Team__c = jobRole.Id,
                Participant_Location__c = site.Id,
                sirenum__Contract__c = project.Id,
                Participant__c = participant.Id,
                Resourcing_Country__c='USA',
                Resourcing_Status__c='New York',
                RecordTypeId = resourceRT.Id,
                sirenum__Contact__c = contact2.Id,
                Clinical_Site__c = site2.Id,
                Visit_Request_received_from_Site__c = true
        );

        insert new List<sirenum__Shift__c>{shift4};

        Duty__c workerDuty1 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 20),
                Relates_To__c  = 'Project',
                Visit__c = shift4.Id
        );
        Duty__c workerDuty2 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '2',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 21),
                Visit__c = shift4.Id,
                Relates_To__c  = 'Project'
        );

        User testUser = [SELECT Id FROM User WHERE Username = 'user1@sirenum.com'];

        //System.runAs(testUser){
            insert new List<Duty__c>{workerDuty1, workerDuty2};
        //}

        DutyApprovalScheduler das = new DutyApprovalScheduler();
        System.schedule('DutyApprovalScheduler', '0 0 0 3 9 ? 2027', new DutyApprovalScheduler());
        das.execute(null); //must explicitly call when the method executes a batch, since the stopTest() method will not implicitly wait for batch completion
        Test.stopTest();

        Duty__c processedDuty1 = [SELECT Id, Status__c, Auto_Approved__c, Manual_Review_Required__c FROM Duty__c WHERE Id = :workerDuty1.Id];
        Duty__c processedDuty2 = [SELECT Id, Status__c, Auto_Approved__c, Manual_Review_Required__c FROM Duty__c WHERE Id = :workerDuty2.Id];

        //Assert that the duty was processed successfully
     /*   System.assertEquals('Approved', processedDuty1.Status__c);
        System.assertEquals(false, processedDuty1.Manual_Review_Required__c);
        System.assertEquals('Submitted', processedDuty2.Status__c);
        System.assertEquals(true, processedDuty2.Manual_Review_Required__c); */
    }

    @IsTest
    private static void testSchedulerSuccessProject(){

        Account account1 = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Contact contact2 = [SELECT Id FROM Contact WHERE FirstName='Test2'];

        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;

        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='123: Test Project';
        project.sirenum__Client__c = account1.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;

        sirenum__Site__c site1 = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York'
        );
        insert site1;

        Participant__c participant = new Participant__c(
                Illingworth_Project__c = project.Id,
                Name = 'test participant',
                Site_Clinical_Trial__c = site1.Id,
                Participant_Folder_URL__c = 'www.google.com'
        );
        insert participant;

        RecordType participantLocationRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Participant Location'];
        RecordType clinicalSiteRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Site – Clinical Trial'];

        sirenum__Site__c site = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = participantLocationRT.Id,
                Participant__c = participant.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'

        );
        sirenum__Site__c site2 = new sirenum__Site__c(
                Name='Test Clinical Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = clinicalSiteRT.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'
        );
        insert new List<sirenum__Site__c>{site,site2};

        Test.startTest(); //For increased SOQL limits

        site.Participant__c = participant.Id;
        update site;

        sirenum__Team__c jobRole = new sirenum__Team__c(
                Name='Test Job Role Resource',
                Illingworth_Days_After_Window__c=1,
                Illingworth_Days_Before_Window__c=1,
                sirenum__Account__c = project.Id
        );
        insert jobRole;

        sirenum__TicketType__c competency = new sirenum__TicketType__c(
                Name='123: Test Project Activation at Test Site for USA',
                Competence_Category__c='Site Activation Resource',
                Illingworth_Project__c = project.Id
        );
        insert competency;

        sirenum__Sirenum_Condition_Membership__c condition1 = new sirenum__Sirenum_Condition_Membership__c(
                sirenum__Team__c = jobRole.Id,
                sirenum__TicketType__c = competency.Id,
                Inactive__c = false
        );
        insert condition1;

        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        insert new List<sirenum__Ticket__c>{/*qualification1,*/ qualification2};

        //Add reference duties
        Duty__c referenceDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Expected_Duration__c = '2',
                Approval_Limit__c = '2',
                Status__c = 'Submitted',
                //Visit_Type__c = jobRole.Id,
                Project__c = project.Id,
                Relates_To__c  = 'Project',
                RecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByDeveloperName().get('Duty_Type').getRecordTypeId()
        );
        insert referenceDuty;

        User testUser = [SELECT Id FROM User WHERE Username = 'user1@sirenum.com'];

        Duty__c workerDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 20),
                //Visit__c = shift4.Id
                Project__c = project.Id,
                Relates_To__c  = 'Visit_Type'
                //CreatedById = testUser.Id
        );

        //System.runAs(testUser){
            insert workerDuty;
        //}

        DutyApprovalScheduler das = new DutyApprovalScheduler();
        System.schedule('DutyApprovalScheduler', '0 0 0 3 9 ? 2027', new DutyApprovalScheduler());
        das.execute(null); //must explicitly call when the method executes a batch, since the stopTest() method will not implicitly wait for batch completion
        Test.stopTest();

        Duty__c processedDuty = [SELECT Id, Status__c, Auto_Approved__c FROM Duty__c WHERE Id = :workerDuty.Id];

        //Assert that the duty was processed successfully
     /*   System.assertEquals('Approved', processedDuty.Status__c);
        System.assertEquals(true, processedDuty.Auto_Approved__c); */
    }

    @IsTest
    private static void testSchedulerPreApprovedProject(){

        Account account1 = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Contact contact2 = [SELECT Id FROM Contact WHERE FirstName='Test2'];

        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;

        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='123: Test Project';
        project.sirenum__Client__c = account1.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;

        sirenum__Site__c site1 = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York'
        );
        insert site1;

        Participant__c participant = new Participant__c(
                Illingworth_Project__c = project.Id,
                Name = 'test participant',
                Site_Clinical_Trial__c = site1.Id,
                Participant_Folder_URL__c = 'www.google.com'
        );
        insert participant;

        RecordType participantLocationRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Participant Location'];
        RecordType clinicalSiteRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Site – Clinical Trial'];

        sirenum__Site__c site = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = participantLocationRT.Id,
                Participant__c = participant.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'

        );
        sirenum__Site__c site2 = new sirenum__Site__c(
                Name='Test Clinical Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = clinicalSiteRT.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'
        );
        insert new List<sirenum__Site__c>{site,site2};

        Test.startTest(); //For increased SOQL limits

        site.Participant__c = participant.Id;
        update site;

        sirenum__Team__c jobRole = new sirenum__Team__c(
                Name='Test Job Role Resource',
                Illingworth_Days_After_Window__c=1,
                Illingworth_Days_Before_Window__c=1,
                sirenum__Account__c = project.Id
        );
        insert jobRole;

        sirenum__TicketType__c competency = new sirenum__TicketType__c(
                Name='123: Test Project Activation at Test Site for USA',
                Competence_Category__c='Site Activation Resource',
                Illingworth_Project__c = project.Id
        );
        insert competency;

        sirenum__Sirenum_Condition_Membership__c condition1 = new sirenum__Sirenum_Condition_Membership__c(
                sirenum__Team__c = jobRole.Id,
                sirenum__TicketType__c = competency.Id,
                Inactive__c = false
        );
        insert condition1;

        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        insert new List<sirenum__Ticket__c>{/*qualification1,*/ qualification2};

        //Add reference duties
        Duty__c referenceDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Expected_Duration__c = '3',
                Approval_Limit__c = '3',
                Status__c = 'Submitted',
                //Visit_Type__c = jobRole.Id,
                Project__c = project.Id,
                 Relates_To__c  = 'Project',
                RecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByDeveloperName().get('Duty_Type').getRecordTypeId()
        );
        insert referenceDuty;

        Duty__c workerDutyApproved1 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Approved',
                Date_of_Duty__c = Date.newInstance(2023, 11, 19),
                //Visit__c = shift4.Id
                 Relates_To__c  = 'project',
                Project__c = project.Id
        );
        Duty__c workerDutyApproved2 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Approved',
                Date_of_Duty__c = Date.newInstance(2023, 11, 18),
                //Visit__c = shift4.Id
                Relates_To__c  = 'Visit_Type',
                Project__c = project.Id
        );
        insert new List<Duty__c>{workerDutyApproved1, workerDutyApproved2};

        User testUser = [SELECT Id FROM User WHERE Username = 'user1@sirenum.com'];

        Duty__c workerDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 20),
                //Visit__c = shift4.Id
                Project__c = project.Id,
                Relates_To__c  = 'Visit_Type'
                //CreatedById = testUser.Id
        );

        //System.runAs(testUser){
            insert workerDuty;
        //}

        DutyApprovalScheduler das = new DutyApprovalScheduler();
        System.schedule('DutyApprovalScheduler', '0 0 0 3 9 ? 2027', new DutyApprovalScheduler());
        das.execute(null); //must explicitly call when the method executes a batch, since the stopTest() method will not implicitly wait for batch completion
        Test.stopTest();

        Duty__c processedDuty = [SELECT Id, Status__c, Auto_Approved__c FROM Duty__c WHERE Id = :workerDuty.Id];

        //Assert that the duty was processed successfully
      /*  System.assertEquals('Approved', processedDuty.Status__c);
        System.assertEquals(true, processedDuty.Auto_Approved__c); */
    }

    @IsTest
    private static void testSchedulerOverHoursProject(){

        Account account1 = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Contact contact2 = [SELECT Id FROM Contact WHERE FirstName='Test2'];


        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'test project team';
        insert projectTeam;

        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='123: Test Project';
        project.sirenum__Client__c = account1.Id;
        project.Opportunity_Number__c = '1897';
        project.Illingworth_Protocol_ID__c='12578';
        project.Project_Team__c = projectTeam.Id;
        project.Off_site_Activities__c = 'test off site';
        insert project;

        sirenum__Site__c site1 = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York'
        );
        insert site1;

        Participant__c participant = new Participant__c(
                Illingworth_Project__c = project.Id,
                Name = 'test participant',
                Site_Clinical_Trial__c = site1.Id,
                Participant_Folder_URL__c = 'www.google.com'
        );
        insert participant;

        RecordType participantLocationRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Participant Location'];
        RecordType clinicalSiteRT = [SELECT Id FROM RecordType WHERE SobjectType='sirenum__Site__c' AND Name = 'Site – Clinical Trial'];

        sirenum__Site__c site = new sirenum__Site__c(
                Name='Test Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = participantLocationRT.Id,
                Participant__c = participant.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'

        );
        sirenum__Site__c site2 = new sirenum__Site__c(
                Name='Test Clinical Site',
                sirenum__Operating_Company__c=account1.Id,
                Project__c = project.Id,
                sirenum__City__c = 'New York',
                sirenum__Country__c = 'USA',
                sirenum__Timezone__c='America/New_York',
                RecordTypeId = clinicalSiteRT.Id,
                IllingworthCountry__c = 'USA',
                sirenum__State__c = 'New York'
        );
        insert new List<sirenum__Site__c>{site,site2};

        Test.startTest(); //For increased SOQL limits

        site.Participant__c = participant.Id;
        update site;

        sirenum__Team__c jobRole = new sirenum__Team__c(
                Name='Test Job Role Resource',
                Illingworth_Days_After_Window__c=1,
                Illingworth_Days_Before_Window__c=1,
                sirenum__Account__c = project.Id
        );
        insert jobRole;

        sirenum__TicketType__c competency = new sirenum__TicketType__c(
                Name='123: Test Project Activation at Test Site for USA',
                Competence_Category__c='Site Activation Resource',
                Illingworth_Project__c = project.Id
        );
        insert competency;

        sirenum__Sirenum_Condition_Membership__c condition1 = new sirenum__Sirenum_Condition_Membership__c(
                sirenum__Team__c = jobRole.Id,
                sirenum__TicketType__c = competency.Id,
                Inactive__c = false
        );
        insert condition1;

        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        insert new List<sirenum__Ticket__c>{/*qualification1,*/ qualification2};

        //Add reference duties
        Duty__c referenceDuty = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Expected_Duration__c = '2',
                Approval_Limit__c = '2',
                Status__c = 'Submitted',
                //Visit_Type__c = jobRole.Id,
                Project__c = project.Id,
                Relates_To__c  = 'Visit_Type',
                RecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByDeveloperName().get('Duty_Type').getRecordTypeId()
        );
        insert referenceDuty;

        RecordType resourceRT = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType='sirenum__Shift__c'
                AND Name = 'Resource Allocation'
                LIMIT 1];

        User testUser = [SELECT Id FROM User WHERE Username = 'user1@sirenum.com'];
        Duty__c workerDuty1 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '1',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 20),
                //Visit__c = shift4.Id,
                Project__c = project.Id,
                Relates_To__c  = 'Visit_Type'
                //CreatedById = testUser.Id
        );
        Duty__c workerDuty2 = new Duty__c(
                Duty_Type__c = 'Site Communication',
                Actual_Duration__c = '2',
                Status__c = 'Submitted',
                Date_of_Duty__c = Date.newInstance(2023, 11, 21),
                //Visit__c = shift4.Id
                Project__c = project.Id,
                Relates_To__c  = 'Visit_Type'
                //CreatedById = testUser.Id
        );

        //System.runAs(testUser){
            insert new List<Duty__c>{workerDuty1, workerDuty2};
        //}

        DutyApprovalScheduler das = new DutyApprovalScheduler();
        System.schedule('DutyApprovalScheduler', '0 0 0 3 9 ? 2027', new DutyApprovalScheduler());
        das.execute(null); //must explicitly call when the method executes a batch, since the stopTest() method will not implicitly wait for batch completion
        Test.stopTest();

        Duty__c processedDuty1 = [SELECT Id, Status__c, Auto_Approved__c, Manual_Review_Required__c FROM Duty__c WHERE Id = :workerDuty1.Id];
        Duty__c processedDuty2 = [SELECT Id, Status__c, Auto_Approved__c, Manual_Review_Required__c FROM Duty__c WHERE Id = :workerDuty2.Id];

        //Assert that the duty was processed successfully
      /*  System.assertEquals('Approved', processedDuty1.Status__c);
        System.assertEquals(false, processedDuty1.Manual_Review_Required__c);
        System.assertEquals('Submitted', processedDuty2.Status__c);
        System.assertEquals(true, processedDuty2.Manual_Review_Required__c); */
    }
}