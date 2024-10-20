/**
* since    	  : 9th Sept,2023
* Description    : Test Class For Project Lookup Controller
*/
@isTest
public class ProjectLookupControllerTest {
    @testSetup
    static void setup(){
        //createUser
        User RecruitmentManager1= DataFactory.createUser();
        //create project Team
        Project_Team__c projectTeam=DataFactory.createProjectTeam();
        //account 
        Account account = DataFactory.createAccount();
        
        sirenum__ProActiveContract__c project=DataFactory.createProject(account,RecruitmentManager1,projectTeam);
    }
    
    
    @isTest
    static void testFetchRecords() {
        sirenum__ProActiveContract__c project=[Select id,name from sirenum__ProActiveContract__c LIMIT 1];
        
        // Call the fetchRecords method from ProjectLookupController
        ProjectLookupController.SearchWrapper testSearchWrapper = new ProjectLookupController.SearchWrapper();
        testSearchWrapper.objectApiName = 'sirenum__ProActiveContract__c'; 
        testSearchWrapper.fieldApiName = 'Name'; 
        testSearchWrapper.searchString='123';
        testSearchWrapper.otherFieldApiName='Oracle_Project_Code__c';
        testSearchWrapper.selectedRecordId=project.Id;
        List<ProjectLookupController.ResultWrapper> result = ProjectLookupController.fetchRecords(testSearchWrapper);
        
        System.assertEquals(1, result.size());
        
    }
    
    @isTest
    static void testGetRelatedSites() {
        
        // Query test data 
        sirenum__ProActiveContract__c project=[Select id,name from sirenum__ProActiveContract__c LIMIT 1];
        sirenum__Site__c site= DataFactory.createSite(project);
        sirenum__ProActiveContract__c proj=new sirenum__ProActiveContract__c();
        proj.id=project.Id;
        
        // Call the getRelatedSites method from ProjectLookupController
        List<sirenum__site__c> result = ProjectLookupController.getRelatedSites(proj);
        
    }
    
    @isTest
    static void testCreateCompetencyProjectTraining() {
        
        // Create test data 
        sirenum__ProActiveContract__c project=[Select id,name from sirenum__ProActiveContract__c LIMIT 1];
        sirenum__Site__c site= DataFactory.createSite(project);
        Map<String,String> testSelectedProject=new Map<String,String>();
        testSelectedProject.put('id',String.valueOf(project.Id));
        Map<String,String> siteMap=new Map<String,String>();
        siteMap.put(site.Id,site.Name);
        
        // Call  createCompetency method from ProjectLookupController
        Map<String, Object> result = ProjectLookupController.createCompetency(
            testSelectedProject,
            True,
            siteMap,
            'ProjectTraining',
            'TestCompName',
            'testSearchableName',
            'testLMSCourse',
            'Fatal'
        );
        System.assertEquals('Success', result.get('message'));
    } 
    
    @isTest
    static void testCreateCompetencyProjectSiteTraining() {
        
        // Create test data 
        sirenum__ProActiveContract__c project=[Select id,name from sirenum__ProActiveContract__c LIMIT 1];
        sirenum__Site__c site= DataFactory.createSite(project);
        Map<String,String> testSelectedProject=new Map<String,String>();
        testSelectedProject.put('id',String.valueOf(project.Id));
        Map<String,String> siteMap=new Map<String,String>();
        siteMap.put(site.Id,site.Name);
        
        // Call  createCompetency method from ProjectLookupController
        Map<String, Object> result = ProjectLookupController.createCompetency(
            testSelectedProject,
            True,
            siteMap,
            'ProjectSiteTraining',
            'TestCompName',
            'testSearchableName',
            'testLMSCourse',
            'Fatal'
        );
    }
}