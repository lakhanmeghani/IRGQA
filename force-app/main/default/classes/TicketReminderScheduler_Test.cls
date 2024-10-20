/**
 * PS-927 Scheduled Job to send Expiring Ticket notifications
 */

@IsTest
private class TicketReminderScheduler_Test {

    @IsTest
    private static void testScheduler() {
        //Prepare some test data

        //Add in-memory Ticket Reminder Settings for batch
      //  TicketReminderSettingProvider.addSetting(new Ticket_Reminder_Setting__mdt(
       //         DeveloperName='default',
      //          Batch_Size__c=200
      //  ));

        //Client Account
        Account account1 = new Account(Name='Test Account');
        //Resource Account
        RecordType resourcePoolRT = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name = 'Resource Pool'];
        Account account2 = new Account(Name='Test Account', RecordTypeId = resourcePoolRT.Id);

        insert new List<Account>{account1, account2};

        Contact contact1 = new Contact(
                FirstName = 'Test1',
                LastName = 'Test1',
                AccountId = account2.Id,
                Work_Country__c='USA',
                Illing_Licenced_in_States_Province__c='New York',
                MailingCountry = 'USA',
                MailingCity = 'New York',
                MailingState='New York',
                Email='illingworth.test@bullhorn.com.test',
                Active_Projects__c = '123: Test Project');
        Contact contact2 = new Contact(
                FirstName = 'Test2',
                LastName = 'Test2',
                AccountId = account2.Id,
                Work_Country__c='USA',
                Illing_Licenced_in_States_Province__c='California',
                MailingCountry = 'USA',
                MailingCity = 'New York',
                MailingState='New York',
                Email='illingworth2.test@bullhorn.com.test',
                Active_Projects__c = '123: Test Project');
        insert new List<Contact>{contact1, contact2};

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
                //RecordTypeId = participantLocationRT.Id
                //Participant__c = participant.Id
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
                //Participant__c = participant.Id
        );
        insert new List<sirenum__Site__c>{site,site2};

        site.Participant__c = participant.Id;
        update site;

        Test.startTest(); //for increased limits

        sirenum__Team__c jobRole = new sirenum__Team__c(
                Name='Test Job Role Resource',
                Illingworth_Days_After_Window__c=1,
                Illingworth_Days_Before_Window__c=1
        );
        insert jobRole;

        sirenum__TicketType__c competency = new sirenum__TicketType__c(
                Name='123: Test Project Activation at Test Site for USA',
                Competence_Category__c='Compliance Documentation',
                Illingworth_Project__c = project.Id,
                sirenum__Expires__c = true,
                Job_Type__c = 'Research Nurse',
                Show_In_TrialGo__c = true
        );
        insert competency;

        sirenum__Ticket__c qualification1 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact1.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true,
                sirenum__Valid_until__c = Date.today().addDays(13)
        );
        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true,
                sirenum__Valid_until__c = Date.today()
        );
        sirenum__Ticket__c qualification3 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true,
                sirenum__Valid_until__c = Date.today().addDays(30)
        );
        insert new List<sirenum__Ticket__c>{qualification1, qualification2};

        //Queue the schedulable
        TicketReminderScheduler trs = new TicketReminderScheduler();
        System.schedule('TicketReminderScheduler'+System.today(), '0 0 0 3 9 ? 2027', new TicketReminderScheduler());
        trs.execute(null); //must explicitly call when the method executes a batch, since the stopTest() method will not implicitly wait for batch completion

        Test.stopTest();

        //Assertions
        List<sirenum__Ticket__c> qualificationsSent14dReminder = [SELECT Id, X14DayReminderSent__c FROM sirenum__Ticket__c WHERE X14DayReminderSent__c != NULL];
        //List<sirenum__Ticket__c> qualificationsSent0dReminder = [SELECT Id, LastDayReminderSent__c FROM sirenum__Ticket__c WHERE LastDayReminderSent__c != NULL];

        System.assertEquals(1, qualificationsSent14dReminder.size());
        System.assertEquals(qualification1.Id, qualificationsSent14dReminder[0].Id);
        //System.assertEquals(1, qualificationsSent0dReminder.size());
        //System.assertEquals(qualification2.Id, qualificationsSent0dReminder[0].Id);
    }
}