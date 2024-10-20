/**
 * Created by scott.nicol on 06/02/2024.
 */
@IsTest
public with sharing class CustomCompetency_Test {
    @IsTest
    static void TestActiveConstraint(){
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

        Test.startTest(); //For increased SOQL limits

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

        sirenum__Ticket__c qualification1 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact1.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        sirenum__Ticket__c qualification2 = new sirenum__Ticket__c(
                sirenum__Owner__c = contact2.Id,
                sirenum__TicketType__c = competency.Id,
                Proof_of_Completed__c = true,
                Valid_Checkbox__c = true
        );
        insert new List<sirenum__Ticket__c>{qualification1, qualification2};

        RecordType visitRT = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType='sirenum__Shift__c'
                AND Name = 'Visit Allocation'
                LIMIT 1];

        RecordType resourceRT = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType='sirenum__Shift__c'
                AND Name = 'Resource Allocation'
                LIMIT 1];

        //Shifts to run scorer on
        sirenum__Shift__c shift1 = new sirenum__Shift__c(
                sirenum__Site__c = site.Id,
                //Scheduled_Day_local__c = Date.newInstance(2022,09,29),
                //Scheduled_Start_Time_local__c = '09:00',
               // Scheduled_End_Time_local__c = '17:00',
                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2023, 11, 30, 0, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2023, 11, 30, 23, 00, 0),
                sirenum__Team__c = jobRole.Id,
                Participant_Location__c = site.Id,
                sirenum__Contract__c = project.Id,
                Participant__c = participant.Id,
                RecordTypeId = resourceRT.Id,
                Clinical_Site__c = site2.Id
        );
        sirenum__Shift__c shift2 = new sirenum__Shift__c(
                sirenum__Site__c = site.Id,
                //Scheduled_Day_local__c = Date.newInstance(2022,09,29),
                //Scheduled_Start_Time_local__c = '09:00',
               // Scheduled_End_Time_local__c = '17:00',
                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2023, 11, 30, 0, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2023, 11, 30, 23, 00, 0),
                sirenum__Team__c = jobRole.Id,
                Participant_Location__c = site.Id,
                sirenum__Contract__c = project.Id,
                Participant__c = participant.Id,
                Resourcing_Country__c='USA',
                Resourcing_Status__c='New York',
                RecordTypeId = resourceRT.Id,
                Clinical_Site__c = site2.Id
        );
        //Historical shifts for match % increase
        sirenum__Shift__c shift3 = new sirenum__Shift__c(
                sirenum__Site__c = site.Id,
                //Scheduled_Day_local__c = Date.newInstance(2022,08,29),
                //Scheduled_Start_Time_local__c = '09:00',
               // Scheduled_End_Time_local__c = '17:00',
                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2023, 11, 20, 0, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2023, 11, 20, 23, 00, 0),
                sirenum__Team__c = jobRole.Id,
                Participant_Location__c = site.Id,
                sirenum__Contract__c = project.Id,
                Participant__c = participant.Id,
                RecordTypeId = resourceRT.Id,
                sirenum__Contact__c = contact1.Id,
                Clinical_Site__c = site2.Id,
                Visit_Request_received_from_Site__c = true
        );
        sirenum__Shift__c shift4 = new sirenum__Shift__c(
                sirenum__Site__c = site.Id,
                //Scheduled_Day_local__c = Date.newInstance(2022,08,29),
                //Scheduled_Start_Time_local__c = '09:00',
              //  Scheduled_End_Time_local__c = '17:00',
                sirenum__Scheduled_Start_Time__c = Datetime.newInstance(2023, 11, 20, 0, 0, 0),
                sirenum__Scheduled_End_Time__c = Datetime.newInstance(2023, 11, 20, 23, 00, 0),
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


        insert new List<sirenum__Shift__c>{shift1, shift2, shift3, shift4};
        Test.stopTest();

        //Initialise
        CustomCompetency.ActiveConstraint activeConstraint = new CustomCompetency.ActiveConstraint();
        System.assertEquals('Active__c', activeConstraint.getShiftFieldPath());
        System.assertEquals('Inactive_Calculated__c', activeConstraint.getCompetencyConditionField());
        System.assertEquals(shift1.Active__c, activeConstraint.getShiftValue(shift1));
        System.assertEquals(condition1.Inactive_Calculated__c, activeConstraint.getCompetencyConditionValue(condition1));
    }
}