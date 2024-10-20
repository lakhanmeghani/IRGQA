global class ProjectTicketStatusReportBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id,Project_Team__r.Name,Illingworth_Project_Team_Memebers__c,Off_site_Activities__c,Illingworth_Protocol_ID__c from sirenum__ProActiveContract__c]);
    }
    global void execute(Database.BatchableContext BC, List<sirenum__ProActiveContract__c> projectIds){
        //get group related to site 
        List<sirenum__ProActiveContract__c> ProjectUpdated = new List<sirenum__ProActiveContract__c>();
        List<user> ProjectTeamMembers = new List<user>();
        List <Group> Relatedgroup = new List<Group>();
        List<String> idList = new List<String>();
        if(projectIds !=null && projectIds.size()>0 ){
            for(sirenum__ProActiveContract__c project : projectIds){
                // Relatedgroup = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name =: project.Project_Team__r.Name Limit 1];
                
                // add group memebers related to the group 
                //List<String> idList = new List<String>();
                // if(Relatedgroup.size()>0 && Relatedgroup!=null){
                for(Group g:[SELECT (select userOrGroupId from groupMembers) FROM group WHERE name =: project.Project_Team__r.Name]){
                    if(g.groupMembers!=null){
                        for (GroupMember gm : g.groupMembers) {
                            idList.add(gm.userOrGroupId);
                        }
                    }
                }
                //}
                // add users in the project team member set 
                
               // ProjectTeamMembers = [SELECT id FROM user WHERE id IN :idList and isactive =true limit 12];
                project.Illingworth_Project_Team_Memebers__c='';
                for(user usr:[SELECT id FROM user WHERE id IN :idList and isactive =true limit 12]){
                    project.Illingworth_Project_Team_Memebers__c += usr.id+',';
                    if(project.Illingworth_Protocol_ID__c == null){
                        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
                        project.Illingworth_Protocol_ID__c = str.substring(0, 6);
                    }
                    if(project.Off_site_Activities__c == null){
                        project.Off_site_Activities__c ='Filled automatically by system'; 
                    }
                }
                ProjectUpdated.add(project);
            }
            update ProjectUpdated;
        }
        
    }
    global void finish(Database.BatchableContext BC) {
    }
    public void execute(SchedulableContext sc){
        ProjectTicketStatusReportBatch batch = new ProjectTicketStatusReportBatch();
        Database.executebatch(batch, 1);
    }
}