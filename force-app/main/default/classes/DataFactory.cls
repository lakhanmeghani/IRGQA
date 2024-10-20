@isTest
public class DataFactory {
    
    //Recruitment Manager 
    public static User createUser(){
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User RecruitmentManager1=new User(firstname = 'Mrunal', 
                                          lastName = 'Bhingare', 
                                          email ='mrunal.bhingare@areya.tech', 
                                          Username = 'testClass619@illingworthresearch.com.irgprod', 
                                          EmailEncodingKey = 'ISO-8859-1', 
                                          Alias = 'monty', 
                                          TimeZoneSidKey = 'America/Los_Angeles', 
                                          LocaleSidKey = 'en_US',
                                          LanguageLocaleKey = 'en_US', 
                                          ProfileId = pf.Id
                                         ); 
        insert RecruitmentManager1;
        return RecruitmentManager1;
    }
    
    //Account
    public static Account createAccount(){
        Account account = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resource Pool').getRecordTypeId();
        account.RecordTypeId = RecordTypeIdaccount;
        account.Name = 'NEW PROJECT ALERT ACCOUNT';
        insert account;
        return account;
    }
    
    //Job Type
    public static sirenum__Job_Type__c createJobType(){
        sirenum__Job_Type__c jobtype = new sirenum__Job_Type__c();
        jobtype.name = 'Research Nurse';
        insert jobtype;
        return jobtype;
    }
    
    //Project Team
    public static Project_Team__c createProjectTeam(){
        
        Group p = [Select Id from Group where Name = 'FIONA'  AND Type = 'Queue' limit 1];
        Project_Team__c projectTeam = new Project_Team__c();
        projectTeam.Name = '6112: DNLI-E-0001';
        projectTeam.OwnerId = p.Id;
        insert projectTeam;
        return projectTeam;
    }
    
    //Project
    public static sirenum__ProActiveContract__c createProject(Account account,User RecruitmentManager1,Project_Team__c projectTeam){
        sirenum__ProActiveContract__c project = new sirenum__ProActiveContract__c();
        project.Name ='6112: DNLI-E-0001';
        project.sirenum__Client__c = account.Id;
        project.Opportunity_Number__c = '611';
        project.Illingworth_Protocol_ID__c='BAN23456';
        project.Project_Team__c = projectTeam.Id; 
        project.Off_site_Activities__c = 'test off site';
        project.Illingworth_Recruitment_Manager_1__c = RecruitmentManager1.Id;
        project.Project_Team__c = projectTeam.id;
        insert project;
        return project;
    }
    
    //Sirenum Group
    public static sirenum__SirenumGroup__c createSirenumGroup (sirenum__ProActiveContract__c project){
        sirenum__SirenumGroup__c sirenumGroup = new sirenum__SirenumGroup__c();
        sirenumGroup.Name = '6112: DNLI-E-0001';
        sirenumGroup.Project__c = project.Id;
        insert sirenumGroup;
        return sirenumGroup;
    }
    
    //Sirenum Group Criteria
    public static sirenum__GroupCriterion__c createSirenumGroupCriterion (sirenum__SirenumGroup__c sirenumGroup){
        sirenum__GroupCriterion__c criteria = new sirenum__GroupCriterion__c();
        criteria.sirenum__Group__c = sirenumGroup.Id;
        criteria.sirenum__ObjectType__c = 'Contact';
        String projectname = '111: Visit Validation';
        criteria.sirenum__SelectionClause__c = 'Active_Projects__c includes ('+projectname+')';
        insert criteria;
        return criteria;
    }
    
    //Contact of RecordType Resource
    public static List<Contact> createContact(User RecruitmentManager1,Account account,sirenum__Job_Type__c jobtype){
        List<Contact> resourceList = new List<Contact>();
        Contact resource = new Contact();
        Id RecordTypeIdResource = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        resource.RecordTypeId = RecordTypeIdResource;
        resource.FirstName='Class';
        resource.LastName ='Test Resource Name';
        resource.Start_Date__c = Date.parse('02/02/22');
        resource.AccountId =account.id;
        resource.Activity_Status__c = 'Onboarding';
        resource.Job_Type__c = jobtype.Id;
        resource.Candidate_ID__c = '12987';
        resource.Email='testvalidation@syneoshealth.com';
        resource.Illingworth_Line_Manager__c=RecruitmentManager1.id;
        resource.Active_Projects__c='6112: DNLI-E-0001';
        resource.Work_Country__c='USA;Canada';
        resource.Active_Projects_as_Text__c='611: DNLI-E-0001';
        resource.Illingworth_Work_Country_Text__c='USA';
        resource.MailingCity='paris';
        resource.MailingCountry='France';
        resource.MailingState = 'Alaska';
        resource.Illing_Licenced_in_States_Province__c='Alaska;Alberta;California;Alabama';
        resourceList.add(resource);
        
        Contact resource1 = new Contact();
        resource1.RecordTypeId = RecordTypeIdResource;
        resource1.FirstName='Class';
        resource1.LastName ='Test Resource Name 1';
        resource1.Start_Date__c = Date.parse('02/02/22');
        resource1.AccountId =account.id;
        resource1.Activity_Status__c = 'Active';
        resource1.Job_Type__c = jobtype.Id;
        resource1.Candidate_ID__c = '12988';
        resource1.Email='testvalidation1@syneoshealth.com';
        resource1.Illingworth_Line_Manager__c=RecruitmentManager1.id;
        resource1.Active_Projects__c='6112: DNLI-E-0001';
        resource1.Work_Country__c='USA;Canada';
        resource1.Active_Projects_as_Text__c='611: DNLI-E-0001';
        resource1.Illingworth_Work_Country_Text__c='USA';
        resource1.MailingCity='paris';
        resource1.MailingCountry='USA';
        resource1.MailingState = 'Alaska';
        resource1.Illing_Licenced_in_States_Province__c='California;British Columbia';
        resource1.Illingworth_HR_ID_Number__c='234011';
        resourceList.add(resource1);
        insert resourceList;
        return resourceList;
    }
    
    //Create Contact of record type Site Contact
    public static Contact createSiteContact(sirenum__Site__c clinicalSite){
        Contact siteResource = new Contact();
        Id RecordTypeIdSiteResource = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Site Contact').getRecordTypeId();
        siteResource.RecordTypeId = RecordTypeIdSiteResource;
        siteResource.FirstName='Test Class';
        siteResource.LastName ='Test Site Resource Name';
        siteResource.Site__c=clinicalSite.id;
        insert siteResource;
        return siteResource;
    }
    
    //Site of Record Type Clinical Trial
    public static sirenum__Site__c createSite(sirenum__ProActiveContract__c project){
        sirenum__Site__c clinicalSite = new sirenum__Site__c();
        Id RecordTypeIdClinicalSite = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Site – Clinical Trial').getRecordTypeId();
        clinicalSite.RecordTypeId = RecordTypeIdClinicalSite;
        clinicalSite.Name = 'Test Project Activation' ;
        clinicalSite.Site_Number__c = '1467';
        clinicalSite.Illingworth_Clinical_Site_Name__c ='Test-Trigger_clinical site';
        clinicalSite.sirenum__Country__c = 'France';
        clinicalSite.sirenum__City__c = 'Pairs';
        clinicalSite.Project__c = project.Id;
        insert clinicalSite;
        return clinicalSite; 
    }
    
    //Competency for Competence Category Site Activation Resource
    public static sirenum__TicketType__c createSiteActivationCompetency (){
        sirenum__TicketType__c CompetencyNew = new sirenum__TicketType__c();
        CompetencyNew.Name ='6112: DNLI-E-0001 Activation at Test Project Activation';
        CompetencyNew.Competence_Category__c='Site Activation Resource';
        //CompetencyNew.Illingworth_Project__c = project.Id;
        Insert CompetencyNew;
        return CompetencyNew;
    }
    
    //Participant
    public static Participant__c createParticipant (sirenum__Site__c clinicalSite ){
        Participant__c participant = new Participant__c();
        participant.Name ='001_102';
        participant.Site_Clinical_Trial__c = clinicalSite.id;
        insert participant;
        return participant;
    }
    
    //Participant Location
    public static sirenum__Site__c createParticipantLocation (Participant__c participant){
        sirenum__Site__c participantLocation = new sirenum__Site__c();
        Id RecordTypeIdParticipantLocation = Schema.SObjectType.sirenum__Site__c.getRecordTypeInfosByName().get('Participant Location').getRecordTypeId();
        participantLocation.RecordTypeId = RecordTypeIdParticipantLocation; 
        participantLocation.Name = 'TEST VISIT ALERT';
        participantLocation.Participant__c = participant.Id;
        participantLocation.Location_Type__c = 'Off Site';
        participantLocation.sirenum__City__c = 'paris';
        participantLocation.sirenum__Country__c = 'France';
        participantLocation.sirenum__State__c ='Alabama';
        insert participantLocation;
        return participantLocation;
    }
    
    //Visit Type
    public static List<sirenum__Team__c> createVisitType (sirenum__ProActiveContract__c project,sirenum__Job_Type__c jobtype){
        List<sirenum__Team__c> visitTypeList = new List<sirenum__Team__c>();
        
        //Normal  visit type
        sirenum__Team__c visitType = new sirenum__Team__c();
        visitType.Name = 'Test Visit Type';
        visitType.Requires_Confirmation_From_Site__c = true;
        visitType.Illingworth_Days_Before_Window__c =3;
        visitType.Illingworth_Days_After_Window__c = 2;
        visitType.sirenum__Account__c=project.id;
        visitType.sirenum__Job_Type__c = jobtype.id;
        visitTypeList.add(visitType);
        
        // visit type Resource Request
        sirenum__Team__c visitType1 = new sirenum__Team__c();
        visitType1.Name = 'Resource Request-Canada';
        visitType1.sirenum__Account__c=project.id;
        visitTypeList.add(visitType1);
        Insert visitTypeList;
        return visitTypeList;
    }
    
    //Competency for Competence Category Site Activation Resource
    public static sirenum__TicketType__c createCompetency (sirenum__ProActiveContract__c project){
        sirenum__TicketType__c Competency = new sirenum__TicketType__c();
        Competency.Name ='Test Project Activation';
        Competency.Competence_Category__c='Site Activation Resource';
        Competency.Illingworth_Project__c=project.id;
        competency.Date_Received_by_Illingworth__c = Date.parse('09/09/23');
        competency.Severity__c = 'Low';
        
        Insert Competency;
        
        return Competency;
    }
    
    //Location Create 
    public static sirenum__Location__c CreateLocation (){
        sirenum__Location__c loc = new sirenum__Location__c();
        loc.Name ='USA - California';
        Insert loc;
        return loc;
    }
    
    //Competency for Competence Category RN Mandatory Training
    public static sirenum__TicketType__c createCompetencyNew (sirenum__ProActiveContract__c project){
        sirenum__TicketType__c CompetencyNew = new sirenum__TicketType__c();
        CompetencyNew.Name ='New RN Mandatory Training Comptency';
        CompetencyNew.Competence_Category__c='RN Mandatory Training';
        CompetencyNew.sirenum__Searchable_Name__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor Old';
        CompetencyNew.LMS_Course_Title__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor Old';
        CompetencyNew.Illingworth_Project__c=project.id;
        CompetencyNew.Job_Type__c='Research Nurse';
        CompetencyNew.Work_State__c ='California;British Columbia;Australian Capital Territory';
        CompetencyNew.Work_Country__c='Australia;USA;Canada';
        CompetencyNew.sirenum__Expires__c = false;
        CompetencyNew.LMS_Course_Title__c ='';
        CompetencyNew.Severity__c ='High';
        Insert CompetencyNew;
        return CompetencyNew;
    }
    
    //Competency for Competence Category work state
    public static sirenum__TicketType__c createCompetencyNewState (sirenum__ProActiveContract__c project){
        sirenum__TicketType__c CompetencyNew = new sirenum__TicketType__c();
        CompetencyNew.Name ='New RN Mandatory Training Comptency';
        CompetencyNew.Competence_Category__c='work state';
        CompetencyNew.sirenum__Searchable_Name__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor Old';
        CompetencyNew.LMS_Course_Title__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor Old';
        CompetencyNew.Illingworth_Project__c=project.id;
        CompetencyNew.Job_Type__c='Research Nurse';
        CompetencyNew.Work_State__c ='California;British Columbia;Australian Capital Territory';
        CompetencyNew.Work_Country__c='Australia;USA;Canada'; 
        CompetencyNew.Generate_Competency_Condition__c = false;
        Insert CompetencyNew;
        return CompetencyNew;
    }
    
    //Valid Nursing Registration Competency 
    public static sirenum__TicketType__c createCompetencyNurReg (sirenum__ProActiveContract__c project){
        List<sirenum__TicketType__c> testCompList = new List<sirenum__TicketType__c>();
        sirenum__TicketType__c Competency1 = new sirenum__TicketType__c();
        Competency1.Name ='Valid Nursing Registration 1';
        Competency1.Competence_Category__c='RN Mandatory Training';
        Competency1.Illingworth_Project__c=project.id;
        competency1.sirenum__Searchable_Name__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor';
        competency1.LMS_Course_Title__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor';
        competency1.Job_Type__c='Research Nurse';
        competency1.Work_Country__c ='Argentina';
        competency1.Severity__c ='High';
        sirenum__TicketType__c Competency2 = new sirenum__TicketType__c();
        Competency2.Name ='Valid Nursing Registration';
        Competency2.Competence_Category__c='RN Mandatory Training';
        Competency2.Illingworth_Project__c=project.id;
        competency2.sirenum__Searchable_Name__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor New';
        competency2.LMS_Course_Title__c = 'PST (Opp 1066) - CCSJ117A12201C Concept PH Sensor New';
        competency2.Severity__c ='High';
        Insert competency1;
        return competency1;
    }
    
    //Ticket
    public static sirenum__Ticket__c createTicket (sirenum__TicketType__c Competency,Contact resource){
        sirenum__Ticket__c ticket = new sirenum__Ticket__c();
        ticket.sirenum__Owner__c=resource.Id;
        ticket.sirenum__TicketType__c=Competency.Id;
        ticket.sirenum__Valid_from__c = System.today()+1;
        ticket.sirenum__Valid_until__c = System.today()+10;
        ticket.Proof_of_Completed__c =false;
        ticket.Valid_Checkbox__c= true;
        ticket.SK_Status__c = 'Confirmed';
        ticket.sirenum__Revoked__c= false;
        insert ticket;
        return ticket;
    }
    
    //Competency for Competence Category Compact License
    public static sirenum__TicketType__c createCompactLicenseCompetency (){
        sirenum__TicketType__c CompetencyNew = new sirenum__TicketType__c();
        CompetencyNew.Name ='Compact License';
        CompetencyNew.Competence_Category__c='Compact License';
        Insert CompetencyNew;
        return CompetencyNew;
    }
    
    //Competency for Competence Category Compact License
    public static sirenum__TicketType__c createWorkStateCompetency (){
        sirenum__TicketType__c WorkStateCompetency = new sirenum__TicketType__c();
        WorkStateCompetency.Name ='Alabama';
        WorkStateCompetency.Competence_Category__c='Work State';
        WorkStateCompetency.Work_Country__c = 'USA';
        WorkStateCompetency.Work_State__c ='Alabama';
        WorkStateCompetency.Licensed_In_State_Competency__c = true;
        Insert WorkStateCompetency;
        return WorkStateCompetency;
    } 
    
    //Create Competency Conditions
    public static List<sirenum__Sirenum_Condition_Membership__c> createCompetencyCondition (User RecruitmentManager1,Account account,sirenum__Job_Type__c jobtype,sirenum__TicketType__c Competency,sirenum__Site__c clinicalSite,sirenum__Location__c Location){
        List<sirenum__Sirenum_Condition_Membership__c> compConditionsList = new List<sirenum__Sirenum_Condition_Membership__c>();
        sirenum__Sirenum_Condition_Membership__c compConditions = new sirenum__Sirenum_Condition_Membership__c();
        compConditions.sirenum__TicketType__c = competency.Id;
        compConditions.sirenum__Site__c = clinicalSite.Id;
        compConditions.sirenum__Client__c = account.Id;
        compConditions.sirenum__Job_Type__c = jobtype.Id;
        compConditions.sirenum__Severity__c = 'Low';
        compConditions.sirenum__Kind__c = 'Required';
        compConditions.sirenum__Location__c = Location.id;
        compConditionsList.add(compConditions);
        
        sirenum__Sirenum_Condition_Membership__c compConditions1 = new sirenum__Sirenum_Condition_Membership__c();
        compConditions1.sirenum__TicketType__c = competency.Id;
        compConditions1.sirenum__Site__c = clinicalSite.Id;
        compConditions1.sirenum__Client__c = account.Id;
        compConditions1.sirenum__Severity__c = 'Low';
        compConditionsList.add(compConditions1);
        
        /*sirenum__Sirenum_Condition_Membership__c compConditions2 = new sirenum__Sirenum_Condition_Membership__c();
compConditions2.sirenum__TicketType__c = competency.Id;
compConditions2.sirenum__Client__c = account.Id;
compConditions2.sirenum__Severity__c = 'Low';
compConditions2.sirenum__Job_Type__c = jobtype.Id;
compConditionsList.add(compConditions2);*/
        
        sirenum__Sirenum_Condition_Membership__c compConditions3 = new sirenum__Sirenum_Condition_Membership__c();
        compConditions3.sirenum__TicketType__c = competency.Id;
        compConditions3.sirenum__Client__c = account.Id;
        compConditions3.sirenum__Job_Type__c = jobtype.Id;
        compConditions3.sirenum__Severity__c = 'Low';
        compConditionsList.add(compConditions3);
        
        sirenum__Sirenum_Condition_Membership__c compConditions4 = new sirenum__Sirenum_Condition_Membership__c();
        compConditions4.sirenum__TicketType__c = competency.Id;
        compConditions4.sirenum__Job_Type__c = jobtype.Id;
        compConditions4.sirenum__Severity__c = 'Low';
        compConditionsList.add(compConditions4);
        
        sirenum__Sirenum_Condition_Membership__c compConditions5 = new sirenum__Sirenum_Condition_Membership__c();
        compConditions5.sirenum__TicketType__c = competency.Id;
        compConditions5.sirenum__Site__c = clinicalSite.Id;
        compConditions5.sirenum__Job_Type__c = jobtype.Id;
        compConditions5.sirenum__Severity__c = 'Low';
        compConditionsList.add(compConditions5);
        
        insert compConditionsList;
        return compConditionsList;
    }
    
    //Create Parent Placement
    public static sirenum__Placement__c createPlacement (sirenum__ProActiveContract__c project,Contact resource1,sirenum__Team__c visitType){
        sirenum__Placement__c projectPlacement = new sirenum__Placement__c();
        projectPlacement.sirenum__Contract__c =project.Id;
        projectPlacement.sirenum__Start_Date__c=system.today();
        projectPlacement.sirenum__Contact__c=resource1.Id;
        projectPlacement.sirenum__Status__c='Inactive';
        projectPlacement.sirenum__Job_Role__c=visitType.Id; 
        
        insert projectPlacement;
        return projectPlacement;
    }
    
    //Create Site Placement
    public static sirenum__Placement__c createSitePlacement (sirenum__ProActiveContract__c project,Contact resource1,sirenum__Team__c visitType, sirenum__Placement__c ProjPlacement, sirenum__Site__c Site ){
        sirenum__Placement__c sitePlacement = new sirenum__Placement__c();
        sitePlacement.sirenum__Contract__c =project.Id;
        sitePlacement.sirenum__Start_Date__c=system.today();
        sitePlacement.sirenum__Contact__c=resource1.Id;
        sitePlacement.sirenum__Status__c='Inactive';
        sitePlacement.sirenum__Job_Role__c=visitType.Id;
        sitePlacement.sirenum__Site__c  = Site.Id;
        sitePlacement.Project_Placement__c = ProjPlacement.Id;
        insert sitePlacement;
        return sitePlacement;
    }
    
    //create qualification list
    public static List<sirenum__Ticket__c> createQualifications(Contact resource, sirenum__TicketType__c competency){
        List<sirenum__Ticket__c> ticketList = new List<sirenum__Ticket__c>();
        sirenum__Ticket__c ticket1 = new sirenum__Ticket__c ();
        ticket1.sirenum__TicketType__c = competency.Id;
        ticket1.sirenum__Owner__c = resource.Id;
        ticket1.sirenum__Valid_from__c = Date.parse('02/05/22');
        ticket1.sirenum__Valid_until__c = System.today()+30;
        
        sirenum__Ticket__c ticket2 = new sirenum__Ticket__c ();
        ticket2.sirenum__TicketType__c = competency.Id;
        ticket2.sirenum__Owner__c = resource.Id;
        ticket2.sirenum__Valid_until__c = System.today()+30;
        
        sirenum__Ticket__c ticket3 = new sirenum__Ticket__c ();
        ticket3.sirenum__TicketType__c = competency.Id;
        ticket3.sirenum__Owner__c = resource.Id;
        ticketList.add(ticket1);
        ticketList.add(ticket2);
        ticketList.add(ticket3);
        insert ticketList;
        return ticketList;  
    }
    
    //Create Turn Around Time
    public static List<Turn_Around_Time__c> createTAT (sirenum__Shift__c testVisit){
        List<Turn_Around_Time__c> testTatList = new List<Turn_Around_Time__c>();
        Turn_Around_Time__c testTat1 = new Turn_Around_Time__c();
        testTat1.Changed_Date__c = System.now()-5;
        testTat1.New_Status__c = 'Pending Resource Allocation';
        testTat1.Visit__c = testVisit.Id;
        
        Turn_Around_Time__c testTat2 = new Turn_Around_Time__c();
        testTat2.Changed_Date__c = System.now()-5;
        testTat2.New_Status__c = 'Recruitment Required';
        testTat2.Previous_Status__c = 'Pending Resource Allocation';
        testTat2.Visit__c = testVisit.Id;
        testTatList.add(testTat1);
        testTatList.add(testTat2);
        insert testTatList;
        return testTatList;
    }
    
    //Site Activation Valid Ticket For Resource Used In Visit
    public static sirenum__Ticket__c createSiteActivationQualifications (Contact resource, sirenum__TicketType__c Competency){
        sirenum__Ticket__c ticket1 = new sirenum__Ticket__c ();
        ticket1.sirenum__TicketType__c = competency.Id;
        ticket1.sirenum__Owner__c = Resource.Id;
        ticket1.Valid_Checkbox__c = true;
        ticket1.sirenum__Valid_from__c = Date.parse('02/05/22');
        ticket1.sirenum__Valid_until__c = System.today()+30;
        insert ticket1;
        return ticket1;
    }
    
    // visit
    public static sirenum__Shift__c createVisit (sirenum__Site__c clinicalSite,sirenum__ProActiveContract__c project, sirenum__Team__c visitType,contact Resource){ 
        sirenum__Shift__c visit = new sirenum__Shift__c();
        Id RecordTypeIdvisit = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
        visit.RecordTypeId = RecordTypeIdvisit ;
        visit.sirenum__Site__c = clinicalSite.Id;
        visit.sirenum__Team__c = visitType.Id;
        visit.sirenum__Contact__c = Resource.id;
        visit.sirenum__Contract__c = project.id;
        Time nullTime = Time.newInstance(00, 00, 00 ,0000); 
        Time endTime = Time.newInstance(23, 59, 00 ,0000);
        visit.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit.Visit_Request_received_from_Site__c = true;
        visit.Target_Date__c = Date.parse('02/02/22');
        visit.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit.Clinical_Site__c = clinicalSite.id;
        visit.Project_Approval_Status__c='Pending';
        visit.PM_Approved_Date__c =Date.parse('02/09/29');
        visit.Illingworth_Site_Decline_date__c=Date.parse('07/09/22');
        visit.Illingworth_Project_Decline_Date__c = Date.parse('07/09/22');
        visit.Resource_Decline_Reason__c='Other';
        visit.Resource_Decline_Text__c='Resource Did not Accepted';
        visit.Outcome_Reason__c ='Cancelled Client';
        visit.Illingworth_Outcome_Reason__c='Nurse Not Available';
        visit.Site_Activation_Status__c ='Declined';
        visit.Visit_Approval_Status__c = 'Approved';
        visit.Resource_Decline_Reason__c='Other';
        visit.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit.Resource_Decline_Text__c='Resource Did not Accepted';
        visit.Site_Approval_Date__c=Date.parse('02/10/22');
        visit.Visit_Number__c = null;
        visit.sirenum__Accepted__c= 1;
        visit.Site_Approval_Date__c=Date.parse('02/10/28');
        insert visit;
        return visit;
    }
    
    // Task
    public static Task createTask (sirenum__Shift__c visit){
        Task tsk = new Task();
        tsk.WhatId = visit.Id;
        tsk.Priority = 'Low';
        tsk.Status = 'Completed';
        insert tsk;
        return tsk;
    }
     
    //VISIT
    Public static List<sirenum__Shift__c> createNormalAndRsrReqVisit(sirenum__Job_Type__c jobtype,sirenum__Site__c clinicalSite,sirenum__ProActiveContract__c project,Participant__c participant,sirenum__Site__c participantLocation, sirenum__Team__c visitType){
        List<sirenum__Shift__c> visitList = New List<sirenum__Shift__c>();
        sirenum__Shift__c visit1 = new sirenum__Shift__c();
        Id RecordTypeIdvisit1 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('IRG Shift').getRecordTypeId();
        visit1.RecordTypeId = RecordTypeIdvisit1 ;
        visit1.sirenum__Contract__c = project.id;
        visit1.sirenum__Team__c = visitType.id;
        visit1.Participant__c = participant.id;
        visit1.Participant_Location__c = participantLocation.id;
        Time nullTime = Time.newInstance(00, 00, 00 ,0000); 
        Time endTime = Time.newInstance(23, 00, 00 ,0000);
        visit1.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit1.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit1.Visit_Request_received_from_Site__c = true;
        visit1.Target_Date__c = Date.parse('02/02/22');
        visit1.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit1.Clinical_Site__c = clinicalSite.id;
        visit1.sirenum__Broadcasts__c = 3;
        visit1.Project_Approval_Status__c='Pending';
        visit1.PM_Approved_Date__c =Date.parse('02/09/26');
        visit1.Illingworth_Site_Decline_date__c=Date.parse('07/09/22');
        visit1.Illingworth_Project_Decline_Date__c = Date.parse('07/09/22');
        visit1.Resource_Decline_Reason__c='Other';
        visit1.Resource_Decline_Text__c='Resource Did not Accepted';
        visit1.Outcome__c='Completed In Full';
        visit1.Outcome_Reason__c ='Cancelled Client';
        visit1.Illingworth_Outcome_Reason__c='Nurse Not Available';
        visit1.Site_Activation_Status__c ='Declined';
        Visit1.Visit_Approval_Status__c = 'Approved';
        visit1.Resource_Decline_Reason__c='Other';
        visit1.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit1.Resource_Decline_Text__c='Resource Did not Accepted';
        visit1.Site_Approval_Date__c=Date.parse('02/10/22');
        visitList.add(visit1);
        
        // visit 2
        sirenum__Shift__c visit2 = new sirenum__Shift__c();
        Id RecordTypeIdvisit2 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Request').getRecordTypeId();
        visit2.RecordTypeId = RecordTypeIdvisit2 ;
        visit2.sirenum__Contract__c = project.id;
        visit2.Request_Type__c ='Resource Request'; 
        visit2.sirenum__Team__c = visitType.Id;
        
        visit2.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00 );
        visit2.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 00, 00);
        visit2.Visit_Request_received_from_Site__c = true;
        visit2.Target_Date__c = Date.parse('02/02/22');
        visit2.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit2.Clinical_Site__c = clinicalSite.id;
        visit2.sirenum__Broadcasts__c = 3;
        visit2.PM_Approved_Date__c =Date.parse('02/09/21');
        visit2.Illingworth_Project_Decline_Date__c= Date.parse('09/09/22');
        visit2.Resource_Decline_Reason__c='Other';
        visit2.Resource_Decline_Text__c='Resource Did not Accepted';
        visit2.sirenum__Site__c = clinicalSite.id;
        visit2.Site_Activation_Status__c ='Declined';
        visit2.Resource_Decline_Reason__c='Other';
        visit2.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit2.Resource_Decline_Text__c='Resource Did not Accepted';
        visit2.Site_Approval_Date__c=Date.parse('02/10/22');
        visitList.add(visit2);
        Insert  visitList;
        return  visitList;
    }
    
    //Visit3
    public static List<sirenum__Shift__c> CreateVisitResAlloc (sirenum__ProActiveContract__c project,sirenum__Team__c visitType,Participant__c participant ,sirenum__Site__c participantLocation,sirenum__Site__c clinicalSite, List<Contact> resourceList, sirenum__Shift__c visitId,sirenum__Location__c Location){
        sirenum__Shift__c visit3 = new sirenum__Shift__c();
        Id RecordTypeIdvisit3 = Schema.SObjectType.sirenum__Shift__c.getRecordTypeInfosByName().get('Resource Allocation').getRecordTypeId();
        visit3.RecordTypeId = RecordTypeIdvisit3 ;
        visit3.sirenum__Contract__c = project.id;
        visit3.sirenum__Team__c = visitType.id;
        visit3.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit3.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 59, 00);
        visit3.Visit_Request_received_from_Site__c = true;
        visit3.Target_Date__c = Date.parse('02/02/22');
        visit3.Reason_for_Target_Date__c = 'Project agreed SLA';
        visit3.Project_Approval_Status__c='pending ';
        visit3.Illingworth_Project_Decline_Date__c= Date.parse('02/09/22');
        visit3.Resource_Decline_Reason__c='Other';
        visit3.Resource_Decline_Text__c='Resource Did not Accepted';
        visit3.sirenum__Contact__c=resourceList[0].Id;
        visit3.Illingworth_Notify_Res_Request__c=true;
        visit3.sirenum__ShiftDemand__c=visitId.Id;
        visit3.Project_Approval_Status__c = 'Pending';
        visit3.Site_Activation_Status__c  = 'Declined';
        Visit3.Illingworth_Site_Decline_date__c = Date.parse('02/02/22');
        visit3.PM_Approved_Date__c = Date.parse('02/02/22');
        visit3.Site_Approval_Date__c=Date.parse('02/10/22');
        Visit3.Visit_Number__c = Null;
        Visit3.sirenum__Accepted__c = 1;
        Visit3.Visit_Approval_Status__c = 'Approved';
        visit3.Illingworth_Outcome_Reason__c ='Nurse Not Available';
        visit3.Visit_Number__c = Null;
        visit3.Actual_Other_Travel_Expenses__c ='test';
        visit3.sirenum__Site__c = clinicalSite.id;
        visit3.Clinical_Site__c = clinicalSite.id;
        visit3.sirenum__Location__c = Location.id;
        
        //Visit4
        sirenum__Shift__c visit4 = new sirenum__Shift__c();
        visit4.RecordTypeId = RecordTypeIdvisit3 ;
        visit4.sirenum__Contract__c = project.id;
        visit4.sirenum__Team__c = visitType.id;
        visit4.Visit_Request_received_from_Site__c = true;
        visit4.sirenum__Scheduled_Start_Time__c=datetime.newInstance(2023, 6, 7, 00, 00, 00);
        visit4.sirenum__Scheduled_End_Time__c=datetime.newInstance(2023, 6, 7, 23, 59, 00);
        visit4.Target_Date__c = Date.parse('06/02/22');
        visit4.Reason_for_Target_Date__c = 'Specific Client Request';
        visit4.Project_Approval_Status__c='Pending';
        visit4.sirenum__Contact__c=resourceList[1].Id;
        visit4.PM_Approved_Date__c =Date.parse('02/09/24');
        visit4.Site_Activation_Status__c='Pending';
        visit4.Illingworth_Notify_Res_Request__c=true;
        visit4.Site_Approval_Date__c=Date.parse('02/10/22');
        visit4.sirenum__Site__c = clinicalSite.id;
        visit4.Clinical_Site__c = clinicalSite.id;
        visit4.sirenum__ShiftDemand__c=visitId.Id;
        Visit4.Visit_Number__c = Null;
        Visit4.Visit_Approval_Status__c = 'Approved';
        
        
        List<sirenum__Shift__c> newList = new List<sirenum__Shift__c>();
        newList.add(visit3);
        newList.add(visit4);
        Test.startTest();
        Insert newList;
        Test.stopTest();
        return newList;
    }   
    
    //Create Related Competency
    public static sirenum__RelatedTicketType__c  createRelatedCompetency (sirenum__ProActiveContract__c project ,sirenum__TicketType__c CoveredCompetency,sirenum__TicketType__c Competency){
        sirenum__RelatedTicketType__c RealtedCompetency = new sirenum__RelatedTicketType__c();
        RealtedCompetency.sirenum__CoveredTicketType__c = CoveredCompetency.Id;
        RealtedCompetency.sirenum__CoveringTicketType__c = Competency.Id;
        Insert RealtedCompetency;
        return RealtedCompetency;
    }
    
    //Create ticket status
    Public static Illingworth_Ticket_Status__c TicketStatus ( List<Contact> resourceList, sirenum__Sirenum_Condition_Membership__c CompetencyCondition,sirenum__TicketType__c Competency){
        Illingworth_Ticket_Status__c TicketStatusTicketNull = new Illingworth_Ticket_Status__c();
        TicketStatusTicketNull.Required_Competency__c = CompetencyCondition.sirenum__TicketType__c;
        TicketStatusTicketNull.Job_Type__c = CompetencyCondition.sirenum__Job_Type__c;
        TicketStatusTicketNull.Severity__c = CompetencyCondition.sirenum__Severity__c;
        TicketStatusTicketNull.Competence_Category__c = Competency.Competence_Category__c;
        Insert TicketStatusTicketNull;
        return TicketStatusTicketNull;
    }
    
    // Create Log Entry
    Public static sirenum__LogEntry__c CreateLogEntry(sirenum__TicketType__c Competency , Contact resource, sirenum__Shift__c visit){
        sirenum__LogEntry__c newlog = new sirenum__LogEntry__c();
        newlog.sirenum__Category__c ='Missing Tickets';
        newlog.sirenum__Details__c = 'Missing Qualification: France';
        newlog.sirenum__Severity__c = 'High';
        newlog.sirenum__Created_By_Saving__c = true;
        newlog.sirenum__Contact__c = resource.id;
        newlog.Competency__c =Competency.id;
        newlog.sirenum__Shift__c = visit.Id;
        Insert newlog;
        return newlog;
    }
    
    // Create Log Entry for Detrimental Tickets
    Public static sirenum__LogEntry__c CreateLogEntryforDetrimentalTickets(sirenum__TicketType__c Competency , Contact resource, sirenum__Shift__c visit){
        sirenum__LogEntry__c newlog = new sirenum__LogEntry__c();
        newlog.sirenum__Category__c ='Detrimental Tickets';
        newlog.sirenum__Details__c = 'Missing Qualification: France';
        newlog.sirenum__Severity__c = 'High';
        newlog.sirenum__Created_By_Saving__c = true;
        newlog.sirenum__Contact__c = resource.id;
        newlog.Competency__c =Competency.id;
        newlog.sirenum__Shift__c = visit.Id;
        Insert newlog;
        return newlog;
    }
    
    // create policy definition 
    Public static Illingworth_Policy_Definition__c  CreatePolicyDefination(){
        Illingworth_Policy_Definition__c  PolicyDefination = new Illingworth_Policy_Definition__c();
        PolicyDefination.Name='Add Policy Exception at Visit to Bypass Work Country for Resource Request';
        Insert PolicyDefination;
        return PolicyDefination;
    }
    
    // Create policy applied  
    Public static List<Illingworht_Policy_Applied__c> CreatePolicyApplied(sirenum__Ticket__c Qualification,sirenum__Shift__c Visit,Illingworth_Policy_Definition__c policydefid){
        
        Illingworht_Policy_Applied__c PolicyApplied = new Illingworht_Policy_Applied__c();
        PolicyApplied.ADRN_PD_Approved__c= true;
        PolicyApplied.Policy_Approved_Date__c = System.today();
        PolicyApplied.Policy_Rejected_Date__c = Date.parse('04/04/22');
        PolicyApplied.Qualification__c=Qualification.id;
        PolicyApplied.Illingworth_Visit__c=Visit.id;
        PolicyApplied.Policy_Definition__c =policydefid.id;
        
        List<Illingworht_Policy_Applied__c> PolicyList = new List<Illingworht_Policy_Applied__c>();
        PolicyList.add(PolicyApplied);
        Insert PolicyList;
        return PolicyList;
    }
    
    //Compact License Record
    public static Compact_Licence__c  createCompactLicenseRecord (){
        Compact_Licence__c compactLicense = new Compact_Licence__c();
        compactLicense.Name = 'California';
        compactLicense.Country__c = 'USA';
        insert compactLicense;
        return compactLicense;
    }
    
    //Contact For CompactLicenseTriggerHandler Test Class
    public static Contact createContactForCompactLicense(User RecruitmentManager1,Account account,sirenum__Job_Type__c jobtype){
        Contact resource = new Contact();
        Id RecordTypeIdResource = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        resource.RecordTypeId = RecordTypeIdResource;
        resource.FirstName='Class';
        resource.LastName ='Test Resource Name';
        resource.Start_Date__c = Date.parse('02/02/22');
        resource.AccountId =account.id;
        resource.Activity_Status__c = 'Onboarding';
        resource.Job_Type__c = jobtype.Id;
        resource.Candidate_ID__c = '12987';
        resource.Email='testvalidation@syneoshealth.com';
        resource.Illingworth_Line_Manager__c=RecruitmentManager1.id;
        resource.Active_Projects__c='6112: DNLI-E-0001';
        resource.Work_Country__c='France;USA';
        resource.Active_Projects_as_Text__c='611: DNLI-E-0001';
        resource.Illingworth_Work_Country_Text__c='USA';
        resource.MailingCity='paris';
        resource.MailingCountry='France';
        resource.Illing_Licenced_in_States_Province__c='California;Alabama';
        resource.Status_from_Compact_License__c = 'Confirmed';
        resource.Valid_Until_from_Compact_License__c = Date.parse('02/02/29');
        resource.Compact_Licence__c = true;
        insert resource;
        return resource;
    }
    
    /*
    *@description              : This method is used to create Asset Record
    *@author                   : Akanksha Singh | 14-11-2023
    *@param Name    			: String of Name
    *@param Account          	: Id of AccountId
    *@param SerialNumber       : String Serial_Number__c
    *@param isInsert           : boolean Isinsert - true/false
    *@return                   : return record
    */
    //Asset Record
    public static Asset createAssetRecord(String Name,  Id AccountId, String SerialNumber, Boolean isInsert){
        Asset assetRec = new Asset();
        assetRec.Name  = Name;
        assetRec.AccountId  = AccountId;
        assetRec.Serial_Number__c= SerialNumber;
        if(isInsert){
            insert assetRec;
        }
        return assetRec;
    }
    
    /*
*@description              : This method is used to create Content Version Record
*@author                   : Akanksha Singh | 14-11-2023
*@param Title    			: String of Title
*@param PathOnClient       : String PathOnClient
*@param isInsert           : boolean Isinsert - true/false
*@return                   : return record
*/
    //Content Version Record
    public static ContentVersion createContentVersion (String Title, String PathOnClient, Boolean isInsert){ 
        ContentVersion contentVersion_1 = new ContentVersion();
        contentVersion_1.Title = Title;
        contentVersion_1.PathOnClient = PathOnClient;
        contentVersion_1.VersionData = Blob.valueOf('Test Content');
        contentVersion_1.IsMajorVersion = true ;
        if(isInsert){
            insert contentVersion_1;
        }
        return contentVersion_1;
    }
    
    /*
*@description              : This method is used to create Content Doucment Record
*@author                   : Akanksha Singh | 14-11-2023
*@param ContentVersion    	: Document Id of ContentVersion
*@param Task       		: String taskId
*@param isInsert           : boolean Isinsert - true/false
*@return                   : return record
*/
    //Content Document Link Record
    public static ContentDocumentLink createContentDocumentLink (ContentVersion contentVersion_1 , sObject tsk, Boolean isInsert){ 
        ContentDocumentLink contentlinktask =new ContentDocumentLink();
        contentlinktask.LinkedEntityId=tsk.id;
        contentlinktask.contentdocumentid=[select contentdocumentid from contentversion where id =: contentVersion_1.id].contentdocumentid;
        contentlinktask.ShareType = 'I';
        contentlinktask.Visibility = 'AllUsers';  
        if(isInsert){
            insert contentlinktask;
        }
        return contentlinktask;
    }   
    
    //
    public static Account createAssetsAccount(){
        Account acc = new Account();
        Id RecordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Asset Pool').getRecordTypeId();
        acc.RecordTypeId = RecordTypeIdaccount;
        acc.Name = 'Test ACCOUNT';
        
        insert acc;
        return acc;
        
    } 
    
    //Assest Assignment Record
    public static List<Illingworth_Asset_Assignment__c> createAssetAssignment (Integer noOfRecords, Asset asst,Contact Resource,Boolean isInsert){
        List<Illingworth_Asset_Assignment__c> assetsAssignmentRecord = new List<Illingworth_Asset_Assignment__c>();
        
        for(Integer i=0; i<noOfRecords ; i++){
            Illingworth_Asset_Assignment__c assmnt = new Illingworth_Asset_Assignment__c();
            assmnt.Assigned_Asset__c = asst.Id;
            assmnt.Asset_Location_Resource__c = Resource.Id;
            assmnt.Assignment_Start_Date__c = system.today().addDays(i);
            assetsAssignmentRecord.add(assmnt);
        }
        
        if(isInsert){
            
            Insert assetsAssignmentRecord;
        }
        return assetsAssignmentRecord;
    }

    public static List<Duty__c> createDutyTypeDuty (Integer noOfRecords,Boolean isInsert,sirenum__Shift__c Visit,sirenum__ProActiveContract__c project){
        List<Duty__c> dutyList = new List<Duty__c>();
        Id RecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByName().get('Worker Duty').getRecordTypeId();
        for(Integer i=0; i<noOfRecords ; i++){
            Duty__c duty = new Duty__c();
            duty.recordtypeId = RecordTypeId;
            duty.Project__c = project.Id;
            duty.Visit__c = Visit.Id;
            dutyList.add(duty);
        }
        
        if(isInsert){
            
            Insert dutyList;
        }
        return dutyList;
    }
    
     public static List<irg_Expense__c > createExpenses (Integer noOfRecords,Boolean isInsert,sirenum__Shift__c Visit,sirenum__ProActiveContract__c project){
        List<irg_Expense__c> expList = new List<irg_Expense__c>();
        for(Integer i=0; i<noOfRecords ; i++){
            irg_Expense__c exp = new irg_Expense__c();
            exp.Project__c = project.Id;
            exp.Visit__c = Visit.Id;
            exp.Expense_Task__c = 'Equipment';
            exp.Expenditure_type__c = 'Equipment';
            expList.add(exp);
        }
        
        if(isInsert){
            
            Insert expList;
        }
        return expList;
    }    
}