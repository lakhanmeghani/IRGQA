global  class CompetencyBatchScheduler implements schedulable {
    global void execute(SchedulableContext SC) {
      CompetencyBatch competencies = new CompetencyBatch();
        if(!Test.isRunningTest()){
        	database.executeBatch(competencies);    
        }  
   }
}