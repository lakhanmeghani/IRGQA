trigger ProjectTrigger on sirenum__ProActiveContract__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        
        if( Label.Project_Trigger_Label  =='True' ) {
            ProjectTriggerHandler.updateDateAndOffSiteActivitiesUpdate(Trigger.newMap,Trigger.oldMap);
            List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
            Map<Id,String> mapOfProjectNameByRecId = new Map<Id,String>();
            Map<Id,sirenum__SirenumGroup__c> mapOfSirenumGroupByProjectId = new Map<Id,sirenum__SirenumGroup__c>();
            Map<Id,sirenum__GroupCriterion__c> mapofSirenumCriteriaBySirenumGroupid = new Map<Id,sirenum__GroupCriterion__c>();
            Set<Id> setOfProjectId = new Set<Id>();
            Set<id> setOfSirenumgroupId = new Set<id>();
            List<sirenum__GroupCriterion__c> listOfCriteriaToUpdate = new List<sirenum__GroupCriterion__c>();
            for(sirenum__ProActiveContract__c oldprojectRec : trigger.old){
                for(sirenum__ProActiveContract__c newprojectRec : trigger.new){
                    if(oldprojectRec.Name != newprojectRec.Name){
                        mapOfProjectNameByRecId.put(newprojectRec.Id,newprojectRec.Name);
                        setOfProjectId.add(newprojectRec.Id); 
                        
                        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                        
                        List<String> sendTo = new List<String>();
                        sendTo.add('sirenum.irg@areya.tech');
                        
                        mail.setToAddresses(sendTo);
                        
                        mail.setReplyTo('mrunal.bhingare@areya.tech');
                        mail.setSenderDisplayName('Do Not Reply');
                        
                        mail.setSubject('URGENT: '+ oldprojectRec.Name +'Project Name has been modified!');
                        String body = 'Hi,'+'<br/>'+
                            'Please complete the below mentioned action items -'+'<br/>'+
                            '1-Update the Active Project multi pick list value with the new Project name'+'<br/>'+
                            '2-Verify whether the Scheduler Contact’s Active Project Criteria has been updated automatically with the new Project name'+'<br/>'+
                            '3-Verify that the updated Project name appears in the Resources Active Project field'+'<br/>'+
                            '4-Verify that the Active Projects as Text field has been updated with the new Project name by clicking the edit and saving the record without any changes'+'<br/>'+
                            '<br/>'+'<br/>'+
                            'Regards,'+'<br/>'+
                            'Areya Team';
                        //String body = 'Sirenum Project '+ oldprojectRec.Name +' has been modified, please add the updated name in Active Project list and Sireum Criteria';
                        
                        mail.setHtmlBody(body);
                        
                        mailList.add(mail);
                    }
                }
            }
            List<sirenum__SirenumGroup__c> sirenumGroup = [select id,name,Project__c,Project__r.Name from sirenum__SirenumGroup__c WHERE Project__c =: setOfProjectId];
            System.debug('sirenumGroup::'+sirenumGroup);
            for(sirenum__SirenumGroup__c sirenumGrpRec : sirenumGroup){
                mapOfSirenumGroupByProjectId.put(sirenumGrpRec.Project__c,sirenumGrpRec);
                setOfSirenumgroupId.add(sirenumGrpRec.id);
            }
            List<sirenum__GroupCriterion__c> criteriaList = new List<sirenum__GroupCriterion__c>();
            
            criteriaList = [select id,name, sirenum__ObjectType__c, sirenum__SelectionClause__c, sirenum__Group__c from sirenum__GroupCriterion__c where sirenum__ObjectType__c = 'Contact' AND sirenum__Group__c =: setOfSirenumgroupId];
            for(sirenum__GroupCriterion__c criteriaRec : criteriaList){
                mapofSirenumCriteriaBySirenumGroupid.put(criteriaRec.sirenum__Group__c,criteriaRec);
            }
            
            for(Id sirenumgrpMapKey : mapOfSirenumGroupByProjectId.keySet()){
                sirenum__SirenumGroup__c sirenumGroup1 = mapOfSirenumGroupByProjectId.get(sirenumgrpMapKey);
                String projectName = String.valueOf(+'\''+sirenumGroup1.Project__r.Name+'\'');
                sirenum__GroupCriterion__c critRec = mapofSirenumCriteriaBySirenumGroupid.get(sirenumGroup1.Id);
                critRec.sirenum__SelectionClause__c = 'Active_Projects__c includes ('+projectName+')';
                listOfCriteriaToUpdate.add(critRec);
            }
            
            if(listOfCriteriaToUpdate != null){
                
                UPDATE listOfCriteriaToUpdate;
            }
            
            
            
            Messaging.sendEmail(mailList);
        }
    }
}