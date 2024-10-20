@isTest
public class ContetDocumetLinkTriggerTest {
    @isTest
    public static void contectDoucumentTest(){
        
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCOUNT';
        insert account;
        
        sirenum__TicketType__c competency = new sirenum__TicketType__c ();
        Contact resource = new Contact();
        Id RecordTypeIdResource = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
		resource.RecordTypeId = RecordTypeIdResource;
        resource.FirstName='Class';
        resource.LastName ='Test Resource Name';
        resource.Start_Date__c = Date.parse('02/02/22');
        resource.Illing_Licenced_in_States_Province__c='Alberta';
        resource.MailingCity='paris';
        resource.Email='testvalidation@syneoshealth.com';// syneoshealth
		resource.MailingCountry='France';
        resource.AccountId =account.id;
        resource.Work_Country__c = 'Canada';
        
        insert resource;
        
        competency.Name = 'Valid Nursing Registration';
        competency.Competence_Category__c = 'RN Mandatory Training';
        competency.sirenum__Searchable_Name__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor';
        competency.LMS_Course_Title__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor';
        competency.Severity__c = 'Low';
        competency.Work_Country__c = 'Canada';
        
        insert competency;
        
        sirenum__Ticket__c ticket = new sirenum__Ticket__c ();
        ticket.sirenum__TicketType__c = competency.Id;
        ticket.sirenum__Owner__c = resource.Id;
        ticket.sirenum__Valid_from__c = Date.parse('02/05/22');
        ticket.sirenum__Valid_until__c = System.today()+30;
        
        
        insert ticket;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=ticket.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlobforAttachment=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlobforAttachment;
        attach.parentId=ticket.id;
        insert attach;
    }

}