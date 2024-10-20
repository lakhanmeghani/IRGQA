public without sharing class TaskTriggerHandler {
    public static void updateFieldsOnTask(list<Task> taskList){
        set<id> whatIds = new set<id>();
        for(task t:taskList){
            if(t.WhatId != null){
                whatIds.add(t.WhatId);
                for(sirenum__Shift__c visit:[select id, sirenum__Team__r.name,Visit_Number__c, Participant_Name__c, sirenum__Contact__r.name, sirenum__Scheduled_Start_Time__c from sirenum__Shift__c where id = : t.WhatId]){
                    t.Illingworth_Visit_Type__c = visit.sirenum__Team__r.name;
                    t.Illingworth_Visit_Number__c = visit.Visit_Number__c;
                    t.Illingworth_Participant_Number__c = visit.Participant_Name__c;
                    t.Illingworth_Resource__c = visit.sirenum__Contact__r.name;
                    t.Illingworth_Visit_Date__c = visit.sirenum__Scheduled_Start_Time__c;
                }
            }
        }
        
    }
    public static void checkTaskCount(list<Task> taskList,Map<Id,task> oldTaskMap){
      /*  Map<Id,Integer> mapOfTaskCountByVisitId = new Map<Id,Integer>();
        List<Task> visitPreparationTaskList = new List<Task>();
        Set<Id> visitIdSetFromTask = new Set<Id>();
        List<sirenum__Shift__c> visitListToUpdate = new List<sirenum__Shift__c>();
        Map<Id,List<Task>> mapOfCompletedTasksByVisit = new Map<Id,List<Task>>();
        //Integer count = 0;
        
        for(Task taskrecord : taskList){
            if(taskrecord.Illingworth_Task_Category__c == 'Visit Preparation'){
                Integer count = 0;
                if(!mapOfTaskCountByVisitId.containsKey(taskrecord.WhatId)){
                    count++;
                    mapOfTaskCountByVisitId.put(taskrecord.WhatId,count);
                }else{
                    count = mapOfTaskCountByVisitId.get(taskrecord.WhatId);
                    count++;
                    mapOfTaskCountByVisitId.put(taskrecord.WhatId,count);
                }
                visitPreparationTaskList.add(taskrecord);
            	visitIdSetFromTask.add(taskrecord.WhatId);
            }
        }
        List<Task> completedTaskList = [select id,subject,Illingworth_Task_Category__c,whatid,whoid from Task where whatid =: visitIdSetFromTask and Illingworth_Task_Category__c = 'Visit Preparation' and status = 'Completed'];
        List<sirenum__Shift__c> visitList = [select id, Illingworth_Preparation_Tasks_Complete__c, Illing_No_of_Visit_Preparation_Completed__c, Illingworth_No_of_Visit_Preparation__c from sirenum__Shift__c where id =: visitIdSetFromTask];
        List<Task> visitPrepTaskList = [select id,subject,Illingworth_Task_Category__c,whatid,whoid from Task where whatid =: visitIdSetFromTask and Illingworth_Task_Category__c = 'Visit Preparation'];
        for(Task completedTaskRec : completedTaskList){
            mapOfCompletedTasksByVisit.put(completedTaskRec.WhatId,completedTaskList);
        }
        for(Task existingTaskRec : visitPrepTaskList){
            Integer existingCount = 0;
            if(mapOfTaskCountByVisitId.containsKey(existingTaskRec.WhatId)){
                existingCount = mapOfTaskCountByVisitId.get(existingTaskRec.WhatId);
            	existingCount++;
            	mapOfTaskCountByVisitId.put(existingTaskRec.WhatId,existingCount);
            	
            }
        }
        for(sirenum__Shift__c visitRecord : visitList){
            sirenum__Shift__c newVisitRecord = new sirenum__Shift__c();
              List<Task> newVisitRecordList = new List<Task>();
                if(mapOfTaskCountByVisitId.containsKey(visitRecord.Id) && !mapOfTaskCountByVisitId.isEmpty()){
                newVisitRecord.Id = visitRecord.Id;
                    system.debug('Count======::::'+mapOfTaskCountByVisitId.get(visitRecord.Id));
                newVisitRecord.Illingworth_No_of_Visit_Preparation__c = mapOfTaskCountByVisitId.get(visitRecord.Id) - 2;
                    system.debug('Illingworth_No_of_Visit_Preparation__c====='+newVisitRecord.Illingworth_No_of_Visit_Preparation__c);
                    //system.debug('@@'+mapOfCompletedTasksByVisit.get(visitRecord.Id).size());
                    if(mapOfCompletedTasksByVisit.get(visitRecord.Id) != null){
                        newVisitRecordList = mapOfCompletedTasksByVisit.get(visitRecord.Id);
                    }
                    
                    if(newVisitRecordList.size() > 0){
                    	//newVisitRecord.Illing_No_of_Visit_Preparation_Completed__c = newVisitRecordList.size();//mapOfCompletedTasksByVisit.get(visitRecord.Id).size();
                    }
                
                visitListToUpdate.add(newVisitRecord);
            
            }
        }
        if(visitListToUpdate.size()>0){
            UPDATE visitListToUpdate;
        } */
        
        set<id> whatIds = new set<id>();
        for(task t:taskList){
            if(t.WhatId != null){
                whatIds.add(t.WhatId);
            }
        }
        
        if(!whatIds.isEmpty()){
            List<sirenum__Shift__c> accList = [SELECT Id, Illingworth_No_of_Visit_Preparation__c, (SELECT Id FROM tasks where Illingworth_Task_Category__c = 'Visit Preparation') 
                                     FROM sirenum__Shift__c WHERE Id IN : whatIds];
            system.debug('List<sirenum__Shift__c> accList ===='+accList);
            if(!accList.isEmpty()){
                List<sirenum__Shift__c> updateAccList = new List<sirenum__Shift__c>();
                for(sirenum__Shift__c acc:accList){
                    for(sirenum__Shift__c shift:[SELECT Id, Illingworth_Number_of_Post_Visit_Tasks__c  , (SELECT Id FROM tasks where Illingworth_Task_Category__c = 'Post Visit') 
                                                 FROM sirenum__Shift__c WHERE Id IN : whatIds]){
                                                     
                                                     sirenum__Shift__c objAcc = new sirenum__Shift__c(Id = acc.Id, Illingworth_No_of_Visit_Preparation__c = acc.tasks.size(),Illingworth_Number_of_Post_Visit_Tasks__c = shift.tasks.size());
                                                     system.debug('objAcc===='+objAcc);
                                                     updateAccList.add(objAcc);
                                                 }
                }
                if(!updateAccList.isEmpty()){
                    
                Set<sirenum__Shift__c> removeDuplicate = new Set<sirenum__Shift__c>();
                List<sirenum__Shift__c> finalListToUpdate = new List<sirenum__Shift__c>();
                removeDuplicate.addAll(updateAccList);
                finalListToUpdate.addAll(removeDuplicate);
                if(!finalListToUpdate.isEmpty())
                    system.debug('updateAccList>>'+updateAccList);
                    system.debug('finalListToUpdate>>'+finalListToUpdate);
                update finalListToUpdate;
                }
            }
        }
        
        List<sirenum__Shift__c> completedTasks = [SELECT Id, Illing_No_of_Visit_Preparation_Completed__c, (SELECT Id FROM tasks where Illingworth_Task_Category__c = 'Visit Preparation' and status = 'Completed') 
                                           FROM sirenum__Shift__c WHERE Id IN : whatIds];
        
        if(!completedTasks.isEmpty()){
            List<sirenum__Shift__c> updateAccList = new List<sirenum__Shift__c>();
            for(sirenum__Shift__c acc:completedTasks){
                for(sirenum__Shift__c shift:[SELECT Id, Illing_No_of_Post_Visit_Tasks_Complete__c , (SELECT Id FROM tasks where Illingworth_Task_Category__c = 'Post Visit' and status = 'Completed') 
                                           FROM sirenum__Shift__c WHERE Id IN : whatIds]){
                    
                
                sirenum__Shift__c objAcc = new sirenum__Shift__c(Id = acc.Id, Illing_No_of_Visit_Preparation_Completed__c = acc.tasks.size(), Illing_No_of_Post_Visit_Tasks_Complete__c  = shift.tasks.size());
                system.debug('objAcc===='+objAcc);
                updateAccList.add(objAcc);
                                           }
            }
            if(!updateAccList.isEmpty()){
                Set<sirenum__Shift__c> removeDuplicate = new Set<sirenum__Shift__c>();
                List<sirenum__Shift__c> finalListToUpdate = new List<sirenum__Shift__c>();
                removeDuplicate.addAll(updateAccList);
                finalListToUpdate.addAll(removeDuplicate);
                if(!finalListToUpdate.isEmpty())
                update finalListToUpdate;
            }
        }
    }
        
        
}