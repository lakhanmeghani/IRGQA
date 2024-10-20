@isTest
public class ProjectTicketStatusReportBatchTest {
    @isTest
    public static void createStaticData(){
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
        // project team # 5
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = 'NEW PROJECT ALERT';
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
        //Create Account
        Account acc = new Account();
        acc.Name = 'Resource Pool -UK';
        Insert acc;
        //Create Job Type
        sirenum__Job_Type__c jobtype = new 	sirenum__Job_Type__c();
        jobtype.Name = 'Research Nurse - UK';
        Insert jobtype;
        //Create Contact
       	Contact con = new Contact();
        con.AccountId = account.Id;
        Id RecordTypeIdcontact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        con.RecordTypeId =RecordTypeIdcontact;
        con.LastName = 'Seiketesting';
        con.FirstName = 'Amberttest';
        con.Email='testresource@syneoshealth.com';
        con.Illingworth_External_ID_c__c ='testresource@syneoshealth.com';
        con.Job_Type__c = jobtype.Id;
        con.MailingCountry = 'UK';
        con.MailingState = 'New Mexico';
        con.MailingCity = 'Peterborough';
        con.Work_Country__c = 'UK';
        con.Candidate_ID__c = '1292';
        Insert con;
        System.debug(con);
        //Create Competency 
        sirenum__TicketType__c Competency = new sirenum__TicketType__c();
        Competency.Name = 'Background Check Declarations12 (Annual)';
        Competency.Competence_Category__c = 'Compliance Documentation';
        Competency.Job_Type__c = 'Research Nurse';
        Competency.Severity__c = 'Fatal';
        Insert Competency ;
        System.debug(Competency);
        //Create CompetencyCondition
        sirenum__Sirenum_Condition_Membership__c CompetencyCondition = new sirenum__Sirenum_Condition_Membership__c();
        CompetencyCondition.sirenum__Job_Type__c = jobtype.Id;
        CompetencyCondition.sirenum__TicketType__c = Competency.Id;
        CompetencyCondition.sirenum__Severity__c = 'Fatal';
        Insert CompetencyCondition;
        System.debug(CompetencyCondition);
        //Create Ticket 
        sirenum__Ticket__c Ticket = new sirenum__Ticket__c();
        Ticket.sirenum__TicketType__c = Competency.Id;
        Ticket.sirenum__Revoked__c = false;
        Ticket.sirenum__Owner__c = con.Id;
        Ticket.sirenum__Valid_from__c = system.Today();
        Ticket.sirenum__Valid_until__c = system.today()+30;
        Insert Ticket;
		System.debug(Ticket);
        //Create CoveredCompetency
        sirenum__TicketType__c CoveredCompetency = new sirenum__TicketType__c();
        CoveredCompetency.Name = 'Valid Background Check';
      	CoveredCompetency.Competence_Category__c = 'Compliance Documentation';
        CoveredCompetency.Job_Type__c = 'Research Nurse';
        CoveredCompetency.Severity__c = 'Fatal';
        Insert CoveredCompetency ;
        System.debug(CoveredCompetency);
        //Create Related Competency
        sirenum__RelatedTicketType__c RealtedCompetency = new sirenum__RelatedTicketType__c();
        RealtedCompetency.sirenum__CoveredTicketType__c = CoveredCompetency.Id;
        RealtedCompetency.sirenum__CoveringTicketType__c = Competency.Id;
        Insert RealtedCompetency;
        System.debug(RealtedCompetency);
        //Create Ticket Status
        Project_Ticket_Status__c ProjectTicketStatus = new Project_Ticket_Status__c();
		ProjectTicketStatus.Account__c = account.id;
        ProjectTicketStatus.Resource__c = con.Id;
        ProjectTicketStatus.Competency_Condition__c = CompetencyCondition.Id;
        ProjectTicketStatus.Required_Competency__c = CompetencyCondition.sirenum__TicketType__c;
        ProjectTicketStatus.Severity__c = CompetencyCondition.sirenum__Severity__c;
        ProjectTicketStatus.Competence_Category__c = Competency.Competence_Category__c;
        ProjectTicketStatus.Ticket__c = Ticket.Id;
        ProjectTicketStatus.Related_Competency__c = RealtedCompetency.Id;
        ProjectTicketStatus.Covering_Competency__c = RealtedCompetency.sirenum__CoveringTicketType__c;
        Insert ProjectTicketStatus;
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
        // new condition 
            sirenum__ProActiveContract__c projecttest = new sirenum__ProActiveContract__c();
            projecttest.Name ='NEW PROJECT ALERT1239';
            projecttest.sirenum__Client__c = account.Id;
            projecttest.Opportunity_Number__c = '189567';
            projecttest.Illingworth_Protocol_ID__c='';
            projecttest.Project_Team__c = projectTeam.Id; 
            projecttest.Off_site_Activities__c = '';
            projecttest.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
            projecttest.Illingworth_Recruitment_Manager_2__c = RecruitmentManager2.Id;
            if(projecttest.Illingworth_Protocol_ID__c == null){
                String str = string.valueof(Math.abs(Crypto.getRandomLong()));
                project.Illingworth_Protocol_ID__c = str.substring(0, 6);
            }
            if(projecttest.Off_site_Activities__c == null){
                        project.Off_site_Activities__c ='Filled automatically by system'; 
                    }
        
        
    }
    static testMethod void start() 
    {
        createStaticData();
        Test.startTest();
        ProjectTicketStatusReportBatch obj = new ProjectTicketStatusReportBatch();
        DataBase.executeBatch(obj);
        Test.stopTest();
        }
}