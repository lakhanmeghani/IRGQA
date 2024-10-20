/**
* 
* @since               : 1st Mar, 2024
* @description         : This Class Contains test methods for LogEntryTriggerHandler
*/
@isTest
public class LogEntryTriggerHandlerTest {
    
    @isTest
    public static void createLogEntry(){
        
        //Create Account
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Resource Pool -UK';
        acc.RecordTypeId = RecordTypeIdaccount;
        Insert acc;
        
        //Create Job Type
        sirenum__Job_Type__c jobtype = new 	sirenum__Job_Type__c();
        jobtype.Name = 'Research Nurse - UK';
        Insert jobtype;
        
        //Create Contact
        Id RecordTypeIdcontact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.RecordTypeId =RecordTypeIdcontact;
        con.LastName = 'Seiketesting';
        con.FirstName = 'Amberttest';
        con.Email='asehhh@syneoshealth.test'; //syneoshealth
        con.Illingworth_External_ID_c__c ='asehh@syneoshealth.test'; //syneoshealth
        con.Job_Type__c = jobtype.Id;
        con.MailingCountry = 'UK';
        con.MailingState = 'New Mexico';
        con.MailingCity = 'Peterborough';
        con.Work_Country__c = 'UK';
        con.Candidate_ID__c = '1292';
        Insert con;
        
        //Create Competency 
        sirenum__TicketType__c competency = new sirenum__TicketType__c();
        competency.Name = 'Background Check Declaration (Annual)';
        competency.Competence_Category__c = 'Compliance Documentation';
        competency.Job_Type__c='Research Nurse';
        Insert competency ;
        
        //Create Ticket 
        sirenum__Ticket__c Ticket = new sirenum__Ticket__c();
        Ticket.sirenum__TicketType__c = competency.Id;
        Ticket.sirenum__Revoked__c = True;
        Ticket.Valid_Checkbox__c= false;
        Ticket.sirenum__Owner__c = con.Id;
        Ticket.sirenum__Valid_from__c = system.Today();
        Ticket.sirenum__Valid_until__c = system.today()+30;
        Insert Ticket;
        
        sirenum__LogEntry__c newLogEntry=new sirenum__LogEntry__c();
        newLogEntry.sirenum__Contact__c=con.Id;
        newLogEntry.sirenum__Details__c='Missing Qualification: Background Check Declaration (Annual)';
        Test.startTest();
        Insert newLogEntry;
        Test.stopTest();
        List<sirenum__LogEntry__c> logEntryRecordList=[Select id,Qualification__c,sirenum__Contact__c,sirenum__Details__c from sirenum__LogEntry__c where Qualification__c!=null];
        system.assertEquals(True,logEntryRecordList.size()>0);
        
    }
}