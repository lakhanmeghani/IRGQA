public class SetAtsJobConverionidHandler {
    public static void SetAtsJobConverion(List<Illingworth_ATS_Job_Conversion__c>ATSId){
        List<Illingworth_ATS_Job_Conversion__c> UpdatedAtsConversion= new List<Illingworth_ATS_Job_Conversion__c>();
        List<Illingworth_ATS_Job_Conversion__c> ATSConversionIDs= [SELECT Id, Name FROM Illingworth_ATS_Job_Conversion__c WHERE Id IN :ATSId];
        if(ATSConversionIDs!=null && ATSConversionIDs.size()>0){
            for(Illingworth_ATS_Job_Conversion__c Ats: ATSConversionIDs){
                Ats.Name = String.valueOf(Ats.Id).substring(0, 15);
                UpdatedAtsConversion.add(Ats);
            }
            if(UpdatedAtsConversion.size()>0 && UpdatedAtsConversion !=null){
                update UpdatedAtsConversion;
            }
        }
    }
}