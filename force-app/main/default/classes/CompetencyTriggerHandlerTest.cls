//Test class for CompetencyTriggerHandler
@isTest
public class CompetencyTriggerHandlerTest {
    @isTest
    
    public static void workCountryTestMandatory(){
        
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__TicketType__c  Competency =  DataFactory.createCompetencyNew(project);
        
        //Update Competency
        sirenum__TicketType__c Competency1 = new sirenum__TicketType__c(Id = Competency.Id);
        Competency1.Name='Update New Test Competency';
        Competency1.Competence_Category__c = 'Work State';
        Competency1.Illingworth_Project__c =project.id;
        Competency1.Work_Country__c ='USA';
        Competency1.Work_State__c='';
        try{
            update Competency1;
        }
        catch(exception e){}
    }
    
    @isTest
    public static void workCountryTestMandatory23(){
        
        User RecruitmentManager1 = DataFactory.createUser(); 
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__TicketType__c  Competency =  DataFactory.createCompetencyNew(project);
        
        //Update Competency
        sirenum__TicketType__c Competency1 = new sirenum__TicketType__c(Id = Competency.Id);
        Competency1.Name='Update New Test Competency';
        Competency1.Competence_Category__c = 'Work State';
        Competency1.Illingworth_Project__c =project.id;
        Competency1.Work_Country__c ='Afghanistan';
        Competency1.Work_State__c='Alabama';
        try{
            update Competency1;
        }
        catch(exception e){}
        
    }
    
    @isTest
    public static void createCompConditionOnNewStateCompetancyCreationTest(){
        
        //Create Competency with category RN Mandatory Training
        User RecruitmentManager1 = DataFactory.createUser();
        Account account = DataFactory.createAccount();
        sirenum__Job_Type__c jobtype = DataFactory.createJobType();
        Project_Team__c projectTeam = DataFactory.createProjectTeam();
        List<Contact> Resource  = DataFactory.createContact(RecruitmentManager1, account, jobtype);
        sirenum__ProActiveContract__c project = DataFactory.createProject(account,RecruitmentManager1,projectTeam);
        sirenum__TicketType__c  Competency =  DataFactory.createCompetencyNewState(project);
        sirenum__Site__c testClinicalSite = DataFactory.createSite(project);
        sirenum__Location__c Location = DataFactory.CreateLocation();
        
        //Update Competency
        sirenum__TicketType__c Competency1 = new sirenum__TicketType__c(Id = Competency.Id);
        Competency1.Generate_Competency_Condition__c = true;
        Competency1.Job_Type__c='Research Nurse';
        
        try{
            update Competency1;
        }
        catch(exception e){}
        
        String objectApiName = 'sirenum__TicketType__c';
        Utility.getRecordTypeIdNameMap(objectApiName);
        list<sirenum__TicketType__c> CompetencyList = new list<sirenum__TicketType__c>();
        CompetencyList.add(Competency1);
        CompetencyTriggerHandler.createCompetencyConditionForJobType(CompetencyList);
    }
}