@isTest
public class SetAtsJobConverionidHandlerTest {
	@isTest
    public static void createATSData(){
     Illingworth_ATS_Job_Conversion__c ATS = new Illingworth_ATS_Job_Conversion__c();
       ATS.Name = 'Test';
        ATS.Greenhouse_Department__c ='Trainee RoW';
        ATS.Greenhouse_Job_Name__c ='Trainee Research Nurse (RoW)';
		Insert ATS;
    }
    
}