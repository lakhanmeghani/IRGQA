global class CreateContactProjectsBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Active_Projects__c FROM Contact WHERE Active_Projects__c != null ]);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
    Map<String, Id> projectNameToIdMap = new Map<String, Id>();
    for(sirenum__ProActiveContract__c  project : [SELECT Id, Name FROM sirenum__ProActiveContract__c  WHERE Name IN :getActiveProjectNames(scope)]) {
        projectNameToIdMap.put(project.Name, project.Id);
    }

    Set<String> existingContactProjectKeys = new Set<String>();
    for(Contact_Project__c existingContactProject : [SELECT Contact__c, Project__c,Project__r.Name FROM Contact_Project__c]) {
        existingContactProjectKeys.add(existingContactProject.Contact__c + '_' + existingContactProject.Project__r.Name);
    }

    List<Contact_Project__c> contactProjectsToInsert = new List<Contact_Project__c>();

    for(Contact contactRecord : scope) {
        if(!String.isBlank(contactRecord.Active_Projects__c)) {
            List<String> activeProjects = contactRecord.Active_Projects__c.split(';'); // Assuming ';' is the delimiter for multi-select picklist

            for(String projectName : activeProjects) {
                String contactProjectKey = contactRecord.Id + '_' + projectName.trim();
                
                // Check if the Contact_Project__c record already exists for this contact and project combination
                if(!existingContactProjectKeys.contains(contactProjectKey)) {
                    Contact_Project__c newContactProject = new Contact_Project__c();
                    newContactProject.Contact__c = contactRecord.Id;
                    newContactProject.Project__c = projectNameToIdMap.get(projectName.trim());
                    newContactProject.Active__c=True;
                    // Add any other fields you need to populate

                    contactProjectsToInsert.add(newContactProject);
                    //existingContactProjectKeys.add(contactProjectKey); // Add the key to the set to avoid duplicates in the current batch
                }
            }
        }
    }

    if(!contactProjectsToInsert.isEmpty()) {
        insert contactProjectsToInsert;
    }
}

    private Set<String> getActiveProjectNames(List<Contact> contacts) {
        Set<String> activeProjectNames = new Set<String>();
        for(Contact contactRecord : contacts) {
            if(!String.isBlank(contactRecord.Active_Projects__c)) {
                activeProjectNames.addAll(contactRecord.Active_Projects__c.split(';'));
            }
        }
        return activeProjectNames;
    }

    global void finish(Database.BatchableContext BC) {
       
    }
}