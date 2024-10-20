@isTest
public class QualificationTriggerHandlerTest {
    @isTest
    
    public static void createTestTickets(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Site__c testClinicalSite = DataFactory.createSite(project);
        Participant__c testParticipant = DataFactory.createParticipant(testClinicalSite);
        sirenum__Site__c testPaticipantLocn = DataFactory.createParticipantLocation(testParticipant);
        List<sirenum__Team__c> testVisitType = DataFactory.createVisitType(project,jobtype);
        sirenum__TicketType__c CompactLicenseCompetency = DataFactory.createCompactLicenseCompetency();
        sirenum__TicketType__c WorkStateCompetency = DataFactory.createWorkStateCompetency();
        
        Test.startTest();
        //Compact License Ticket 
        sirenum__Ticket__c ticketCompactLicense = new sirenum__Ticket__c ();
        ticketCompactLicense.sirenum__TicketType__c = CompactLicenseCompetency.Id;
        ticketCompactLicense.sirenum__Owner__c = resource[0].Id;
        ticketCompactLicense.sirenum__Valid_from__c = Date.parse('02/05/22');
        Insert ticketCompactLicense;
        
        ticketCompactLicense.SK_Status__c = 'Confirmed';
        ticketCompactLicense.sirenum__Valid_until__c = System.today()+40;
        update ticketCompactLicense;
        
        try{
            update ticketCompactLicense;
        }
        catch(exception e){}
        
        list<sirenum__Ticket__c> ticketList = new list<sirenum__Ticket__c>();
        ticketList.add(ticketCompactLicense);
        
        Compact_Licence__c cl = new Compact_Licence__c();
        cl.name = 'Test';
        cl.Country__c = 'USA';
        Insert cl;
        QualificationTriggerHandler.checkConfirmedCompactTicket(ticketList);
        
        Test.stopTest();   
    }   
}
/*@isTest
public class QualificationTriggerHandlerTest {
    @isTest
    
    public static void createTestTickets(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Site__c testClinicalSite = DataFactory.createSite(project);
        Participant__c testParticipant = DataFactory.createParticipant(testClinicalSite);
        sirenum__Site__c testPaticipantLocn = DataFactory.createParticipantLocation(testParticipant);
        List<sirenum__Team__c> testVisitType = DataFactory.createVisitType(project,jobtype);
        sirenum__TicketType__c testCompetencyNurReg = DataFactory.createCompetencyNurReg(project);
        sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
        sirenum__TicketType__c CompactLicenseCompetency = DataFactory.createCompactLicenseCompetency();
        
        //Compact License Ticket 
        sirenum__Ticket__c ticketCompactLicense = new sirenum__Ticket__c ();
        ticketCompactLicense.sirenum__TicketType__c = CompactLicenseCompetency.Id;
        ticketCompactLicense.sirenum__Owner__c = resource[0].Id;
        ticketCompactLicense.sirenum__Valid_from__c = Date.parse('02/05/22');
        Insert ticketCompactLicense;
        
        ticketCompactLicense.SK_Status__c = 'Confirmed';
        ticketCompactLicense.sirenum__Valid_until__c = System.today()+40;
        update ticketCompactLicense;
        
        try{
            update ticketCompactLicense;
        }
        catch(exception e){}
    }
    
    @isTest
    public static void createTestTicketvalidNull(){
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__TicketType__c testCompetencyNurReg = DataFactory.createCompetencyNurReg(project);
        sirenum__Ticket__c ticket = DataFactory.createTicket (testCompetencyNurReg,resource[0]); 
        ticket.sirenum__Valid_from__c = null;
        ticket.sirenum__Valid_until__c = Null;
        try{
            update ticket;
        }
        catch(exception e){}
    }
    
    @isTest
    public static void createTestTicketvalidNotNull(){
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__TicketType__c testCompetencyNurReg = DataFactory.createCompetencyNurReg(project);
        sirenum__Ticket__c ticket = DataFactory.createTicket (testCompetencyNurReg,resource[0]); 
        ticket.sirenum__Valid_from__c = Date.parse('03/05/22');
        ticket.sirenum__Valid_until__c = System.today()+40;
        try{
            update ticket;
        }
        catch(exception e){}
    }
    
    @isTest
    public static void createTestTicketvalidUntilNull(){
        User RecruitmentManager1 = DataFactory.createUser();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        List<Contact> resource = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__TicketType__c testCompetencyNurReg = DataFactory.createCompetencyNurReg(project);
        sirenum__Ticket__c ticket = DataFactory.createTicket (testCompetencyNurReg,resource[0]); 
        ticket.sirenum__Valid_from__c = Date.parse('03/05/22');
        ticket.sirenum__Valid_until__c = Null;
        try{
            update ticket;
        }
        catch(exception e){}
    }
}*/