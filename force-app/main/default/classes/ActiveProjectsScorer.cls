/**
 * Copyright (c) Sirenum by Bullhorn 2024
 * PS-939 Custom Scorer to add a negative score when workers are not active on shift's Project
 *
 * Initial State template:
 * {
 * "notActiveOnProjectDetriment": 10
 * }
 *
 */

@JsonAccess(Serializable='always' Deserializable='always')
global with sharing class ActiveProjectsScorer implements sirenum.WorkerSearchScorer {

    // The amount of points to deduct if the conditions are not met. Expressed as a negative decimal.
    private Decimal notActiveOnProjectDetriment;

    /**
     * Implementation of the sirenum.WorkerSearchScorer interface's method.
     * This method is invoked to get the fully qualified sirenum__Shift__c custom object fields that the scorer
     * needs.
     *
     * @return the fully qualified field paths within the sirenum__Shift__c object that the
     *          scorer needs in order to perform its processing. May be null or empty
     *          if the scorer doesn't care about Shift details for scoring
     */
    global Set<String> getRequiredShiftFields() {
        return new Set<String>{'sirenum__Contract__c'};
    }

    /**
     * Implementation of the sirenum.WorkerSearchScorer interface's method.
     * This method is invoked to get the fully qualified Contact fields that the scorer
     * needs.
     *
     * @return the fully qualified field paths within the Contact object that the scorer needs in order to perform
     *         its processing. May be null or empty if the scorer doesn't care about Contact details for scoring
     */
    global Set<String> getRequiredWorkerFields() {
        return new Set<String>();
    }

    /**
     * Implementation of the sirenum.WorkerSearchScorer interface's method.
     * This method is invoked to score the contact's in the context against the shift templates in the context,
     * boosting workers that are car pool drivers, regardless of the shift templates.
     *
     * @param context contains the details describing the search to be performed. Will not be null
     *
     * @return a list of worker search scores representing the scoring applied. May be null or empty if the
     *         scorer did nothing. Any returned instances that do not include all mandatory property values, or
     *         that refer to workers not listed in the context, will be ignored
     */
    global List<sirenum.WorkerSearchScore> scoreWorkers(sirenum.WorkerSearchScorerContext context) {
        List<sirenum.WorkerSearchScore> scores = new List<sirenum.WorkerSearchScore>();

        //Set a default detriment if it has not been defined, or check negativity if defined
        this.notActiveOnProjectDetriment = this.notActiveOnProjectDetriment == null ?
                -10 :
                this.notActiveOnProjectDetriment <= 0 ?
                        this.notActiveOnProjectDetriment :
                        -1* this.notActiveOnProjectDetriment;

        //Build Set of Project Ids from shifts (to filter query)
        Set<Id> contextShiftProjectIds = new Set<Id>();

        for (sirenum__Shift__c shift : context.getShiftTemplates()){
            contextShiftProjectIds.add(shift.sirenum__Contract__c);
        }

        //Get ContactProjects for context Contacts and Shift.Projects
        List<Contact_Project__c> contactProjects = [
                SELECT Id, Contact__c, Project__c
                FROM Contact_Project__c
                WHERE Contact__c IN :context.getWorkersById().keySet()
                AND Project__c IN :contextShiftProjectIds
                AND Active__c = TRUE
        ];

        //Prepare map of Active Projects by Contact Id (for later checking)
        Map<Id, List<Id>> activeProjectIdsByContactId = new Map<Id, List<Id>>();

        for (Contact_Project__c contactProject : contactProjects){
            List<Id> activeProjects = activeProjectIdsByContactId.get(contactProject.Contact__c);
            if (activeProjects == null){
                activeProjectIdsByContactId.put(contactProject.Contact__c, new List<Id>{contactProject.Project__c});
            } else {
                activeProjects.add(contactProject.Project__c);
            }
        }

        //Loop workers being scored, checking each required Project against their active projects
        for (Id contactId : context.getWorkersById().keySet()){
            for (Id requiredProjectId : contextShiftProjectIds){
                //If Contacts Active Project list does not contain a required project...
                if (activeProjectIdsByContactId.get(contactId) == null ||
                        !activeProjectIdsByContactId.get(contactId).contains(requiredProjectId)){
                    //... then prepare a WSS, and break project loop (skip to next contact)
                    scores.add(new sirenum.WorkerSearchScore()
                            .withWorkerId(contactId)
                            .withScore(this.notActiveOnProjectDetriment)
                            .withDescription(Label.Contact_Missing_Active_Project)
                    );
                    break;
                }
            }
        }

        return scores;
    }
}