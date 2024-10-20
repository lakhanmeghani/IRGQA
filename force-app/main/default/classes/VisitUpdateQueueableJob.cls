public class VisitUpdateQueueableJob implements System.Queueable{
    
    List<sirenum__Shift__c> visitList = new List<sirenum__Shift__c>();
    public VisitUpdateQueueableJob(List<sirenum__Shift__c> visits){
        this.visitList = visits;
    } 
    public void execute(System.QueueableContext qc){
        
        Database.update(visitList,false);
    }
}