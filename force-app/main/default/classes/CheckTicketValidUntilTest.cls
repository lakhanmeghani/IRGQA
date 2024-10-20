@isTest(seeAllData=false)
public class CheckTicketValidUntilTest {
    @isTest
    
    public static void createStaticData(){
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__Site__c testClinicalSite = DataFactory.createSite(project);
        List<Contact> Resource  = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__TicketType__c Competency = DataFactory.createCompetency(project);
        
        sirenum__Ticket__c ticket = new sirenum__Ticket__c();
        ticket.sirenum__Owner__c=resource[0].Id;
        ticket.sirenum__TicketType__c=Competency.Id;
        ticket.sirenum__Valid_from__c = System.today()-20;
        ticket.sirenum__Valid_until__c = System.today()-10;
        ticket.Proof_of_Completed__c =false;
        ticket.Valid_Checkbox__c= true;
        ticket.SK_Status__c = 'Confirmed';
        ticket.sirenum__Revoked__c= false;
        insert ticket;
        CheckTicketValidUntil batch = new CheckTicketValidUntil();
        DataBase.executeBatch(batch);
    }
}