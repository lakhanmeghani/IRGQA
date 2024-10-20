@isTest
public class ProjectTriggerTest {
    @isTest
    public static void updateProjectName(){
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
        
        // project team
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'Test Visit Validation';
        insert projectTeam;
        
        //account
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCOUNT';
        insert account;
        
        //project 
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='11110: Visit Validation';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '11110';
        project.Illingworth_Protocol_ID__c='BAN23456';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off site';
        project.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        insert project;
        
        sirenum__SirenumGroup__c sirenumGroup = new sirenum__SirenumGroup__c();
        sirenumGroup.Name = '11110: Visit Validation';
        sirenumGroup.Project__c = project.Id;
        insert sirenumGroup;
        
        sirenum__GroupCriterion__c criteria = new sirenum__GroupCriterion__c();
        criteria.sirenum__Group__c = sirenumGroup.Id;
        criteria.sirenum__ObjectType__c = 'Contact';
        String projectname = '111: Visit Validation';
        criteria.sirenum__SelectionClause__c = 'Active_Projects__c includes ('+projectname+')';
        insert criteria;
        
        sirenum__ProActiveContract__c project1 = new sirenum__ProActiveContract__c();
        project1.Id = project.Id;
        project1.Name ='111: Visit Validation';
        //project1.sirenum__Client__c = account.Id;
        project1.Opportunity_Number__c = '111';
        project1.Illingworth_Protocol_ID__c='BAN23456';
        project1.Project_Team__c = projectTeam.Id; 
        project1.Off_site_Activities__c = 'test off site';
        project1.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        update project1;
    }
}