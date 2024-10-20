/**
 * L2SUP-1208 Onboarding path ticket assignment
 * Checks to ensure a Contact has the require tickets assigned
 *
 * Copyright Sirenum 2022
 */

@IsTest
private class OnboardingTicketCheck_Test {

    @TestSetup
    static void CreateData(){
        //Account
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'Test Account';
        insert account;

        //Job Type
        sirenum__Job_Type__c jobType = new sirenum__Job_Type__c();
        jobtype.Name = 'Test Job Type';
        insert jobType;

        //Resource contact
        Contact resource = new Contact();
        Id RecordTypeIdResource = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        resource.RecordTypeId = RecordTypeIdResource;
        resource.FirstName='Class';
        resource.LastName ='Test Resource Name';
        resource.Start_Date__c = Date.parse('02/02/22');
        resource.AccountId = account.Id;
        resource.Job_Type__c = jobType.Id;
        resource.Candidate_ID__c = '12987';
        resource.Email='testvalidation@syneoshealth.com';
        //resource.Illingworth_Line_Manager__c=RecruitmentManager2.id;
        //resource.Active_Projects__c='611: DNLI-E-0001';
        //resource.Active_Projects_as_Text__c='611: DNLI-E-0001';
        resource.Work_Country__c='France';
        resource.MailingCity='paris';
        resource.MailingCountry='France';
        insert resource;

        sirenum__TicketType__c ticketType1 = new sirenum__TicketType__c(
                Name = 'test',
                Applicable_Oboarding_Paths__c = 'UK; Italy',
                Competence_Category__c = 'Compliance Documentation',
            Job_Type__c = 'Research Nurse'
        );
        sirenum__TicketType__c ticketType2 = new sirenum__TicketType__c(
                Name = 'test',
                Applicable_Oboarding_Paths__c = 'Austria;Germany',
                Competence_Category__c = 'Compliance Documentation',
            	Job_Type__c = 'Research Nurse'
        );

        insert new List<sirenum__TicketType__c>{ticketType1, ticketType2};
    }

    @IsTest
    static void TestBehaviour(){

        Contact contact = [SELECT Id, Onboarding_Path__c FROM Contact LIMIT 1][0];
        contact.Which_country_are_you_registered_in__c = 'UK';
        contact.Onboarding_Path__c = 'UK';
        contact.Activity_Status__c = 'Onboarding';
        update contact;

        //Required in case flow is not active
        OnboardingTicketCheck.CheckTickets(New List<List<Id>>{New List<Id>{contact.Id}});

        List<sirenum__Ticket__c> tickets = [
                SELECT Id
                FROM sirenum__Ticket__c
                WHERE sirenum__Owner__c = :contact.Id
                AND sirenum__TicketType__r.Name = 'test'
        ];

        //Assert that the one applicable ticket out of 2 possible tickets was assigned
        System.assertEquals(1, tickets.size());
    }
}