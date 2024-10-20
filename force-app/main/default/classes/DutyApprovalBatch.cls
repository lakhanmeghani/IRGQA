/**
 * Copyright © Sirenum by bullhorn 2024
 * PS-947 Scheduled process to examine and approve Duties related to Shifts
 * PS-963 Extended to examine and approve duties related to Projects
 * SPS-971 Extended to handle In Hours & Out of Hours limits
 *
 * This class should ONLY be called via its scheduler (DutyApprovalScheduler).
 */

public class DutyApprovalBatch implements Database.Batchable<SObject>, Database.Stateful{

    //Declare final constants, these will be used by the start queryLocator
    public final Set<Id> shiftIds;
    public final Id referenceDutyRecordTypeId;
    public final Set<Id> projectIds;
    public static final String inHours = '(In Hours)';
    public static final String outOfHours = '(Out of Hours)';

    /**
     * Batch constructor to set final constant
     * @param recordIds the Ids of all SObjects for which there are Duties to evaluate
     * @param batchObjectType the SObjectType of the Id's of objects being passed in. Must be 'sirenum__Shift__c' or 'sirenum__ProActiveContract__c'
     * For context, sirenum__Shift__c is known as Visit, sirenum__ProActiveContract__c is known as Project
     */
    public DutyApprovalBatch(Set<Id> recordIds, String batchObjectType){
        this.referenceDutyRecordTypeId = Schema.SObjectType.Duty__c.getRecordTypeInfosByDeveloperName().get('Duty_Type').getRecordTypeId();
        if (batchObjectType == 'sirenum__Shift__c'){
            this.shiftIds = recordIds;
        } else if (batchObjectType == 'sirenum__ProActiveContract__c') {
            this.projectIds = recordIds;
        }
    }

    //Process batches of Shifts passed in by the Scheduler
    public Database.QueryLocator start(Database.BatchableContext bc){
        if (shiftIds != null && !shiftIds.isEmpty()){
            return Database.getQueryLocator([
                    SELECT Id, sirenum__Team__c
                    FROM sirenum__Shift__c
                    WHERE Id IN :shiftIds
            ]);
        } else if (projectIds != null && !projectIds.isEmpty()){
            return Database.getQueryLocator([
                    SELECT Id
                    FROM sirenum__ProActiveContract__c
                    WHERE Id IN :projectIds
            ]);
        } else {
            return Database.getQueryLocator([ //A valid query which will always return 0 records
                    SELECT Id
                    FROM Account
                    LIMIT 0
            ]);
        }
    }

    public void execute(Database.BatchableContext context, List<SObject> scope){
        String scopeObjectType = scope[0].getSObjectType().toString();

        if (scopeObjectType == 'sirenum__Shift__c'){
            processShifts((List<sirenum__Shift__c>)scope, referenceDutyRecordTypeId);
        } else if (scopeObjectType == 'sirenum__ProActiveContract__c'){
            processProjects((List<sirenum__ProActiveContract__c>)scope, referenceDutyRecordTypeId);
        }
    }

    public static void processShifts(List<sirenum__Shift__c> scope, Id referenceDutyRecordTypeId){
        Map<Id, sirenum__Shift__c> shiftsById = new Map<Id, sirenum__Shift__c>(scope);
        Set<Id> jobRoleIds = new Set<Id>();
        for (sirenum__Shift__c shift : scope){
            jobRoleIds.add(shift.sirenum__Team__c);
        }

        List<Duty__c> referenceDuties = [
                SELECT Id, Duty_Type__c, Approval_Limit__c, Visit_Type__c, In_Hours_Approval_Limit__c, Out_of_Hours_Approval_Limit__c, Duty_Type_Name__c
                FROM Duty__c
                WHERE Visit_Type__c IN :jobRoleIds
                AND RecordTypeId = :referenceDutyRecordTypeId
        ];

        // KEY: [0] = Job Role Id, [1] = Duty Type VALUE: Approval Limit
        Map<Object[], Double> dutyApprovalLimitByDutyTypeAndJobRole = new Map<Object[], Double>();

        for (Duty__c duty : referenceDuties){
            //Do not check for existing entry as there should only be one (last in wins if not)
            //Split by In hours/ Out of hours/ Standard or total
            //In Hours and Out of Hours specify trimmed total, but standard duty types do not (just in case data contains leading or trailing spaces)
            String masterDutyType = duty.Duty_Type__c.replace(inHours,'').replace(outOfHours,'').trim();
            if (duty.Duty_Type_Name__c.contains(inHours)){
                dutyApprovalLimitByDutyTypeAndJobRole.put(new Object[]{duty.Visit_Type__c, duty.Duty_Type__c}, Double.valueOf(duty.In_Hours_Approval_Limit__c));
                dutyApprovalLimitByDutyTypeAndJobRole.put(new Object[]{duty.Visit_Type__c, masterDutyType}, Double.valueOf(duty.Approval_Limit__c));
            } else if (duty.Duty_Type_Name__c.contains(outOfHours)) {
                dutyApprovalLimitByDutyTypeAndJobRole.put(new Object[]{duty.Visit_Type__c, duty.Duty_Type__c}, Double.valueOf(duty.Out_of_Hours_Approval_Limit__c));
                dutyApprovalLimitByDutyTypeAndJobRole.put(new Object[]{duty.Visit_Type__c, masterDutyType}, Double.valueOf(duty.Approval_Limit__c));
            } else {
                dutyApprovalLimitByDutyTypeAndJobRole.put(new Object[]{duty.Visit_Type__c, duty.Duty_Type__c}, Double.valueOf(duty.Approval_Limit__c));
            }

        }

        //Retrieve all non-reference (i.e. worker) Duties for shifts in context
        List<Duty__c> contextDuties = [
                SELECT Id, Status__c, Visit__c, Duty_Type__c, Actual_Duration__c, CreatedBy.Profile.Name, Manual_Review_Required__c, Visit__r.sirenum__Team__c, Duty_Type_Name__c
                FROM Duty__c
                WHERE Visit__c IN :shiftsById.keySet() AND Relates_To__c  = 'Visit_Type'
                AND (   //Exclude Duties where Manual review is required UNLESS it has already been approved
                        Manual_Review_Required__c = FALSE
                        OR (Manual_Review_Required__c = TRUE AND Status__c = 'Approved')
                )
                AND Deleted_by_Worker__c = FALSE
                AND RecordTypeId != :referenceDutyRecordTypeId
                ORDER BY Date_of_Duty__c, CreatedDate ASC
        ];

        //KEY: <VisitId>|<DutyType> VALUE: Approved time (the key is a string rather than Object[] so that we can check
        // if a Set<String> of 'blocked' keys contains the key later on)
        Map<String,Double> approvedTimeByShiftAndDutyType = new Map<String, Double>();
        List<Duty__c> dutiesRequiringEvaluation = new List<Duty__c>();

        for (Duty__c duty : contextDuties){
            //Build Map: {ShiftId|DutyType} : {Total Time approved}
            if (duty.Status__c == 'Approved'){
                //If the Duty is an In Hours or Out of Hours duty, first handle the master duty type
                if (duty.Duty_Type_Name__c.contains(inHours) || duty.Duty_Type_Name__c.contains(outOfHours)){
                    String dutyShiftAndMasterType = duty.Visit__c + '|' + duty.Duty_Type__c.replace(inHours,'').replace(outOfHours,'').trim();
                    Double approvedTime = approvedTimeByShiftAndDutyType.get(dutyShiftAndMasterType);
                    if (approvedTime == null){
                        approvedTimeByShiftAndDutyType.put(dutyShiftAndMasterType, Double.valueOf(duty.Actual_Duration__c));
                    } else {
                        approvedTime += Double.valueOf(duty.Actual_Duration__c);
                    }
                }

                //Now handle standard duty types and in/out of hours types
                String dutyShiftAndType = duty.Visit__c + '|' + duty.Duty_Type__c;
                Double approvedTime = approvedTimeByShiftAndDutyType.get(dutyShiftAndType);
                if (approvedTime == null){
                    approvedTimeByShiftAndDutyType.put(dutyShiftAndType, Double.valueOf(duty.Actual_Duration__c));
                } else {
                    approvedTime += Double.valueOf(duty.Actual_Duration__c);
                }
            }
            //Build List of Duties to evaluate
            else if (duty.Status__c == 'Submitted' && !duty.Manual_Review_Required__c){
                dutiesRequiringEvaluation.add(duty);
            }
        }

        //{ShiftId}|{DutyType} where the shift/duty type are blocked from approvals (due to a duty which would put them over limit)
        Set<String> dutyShiftAndTypesBlocked = new Set<String>();

        //If there are records to examine, then check them
        if (!dutiesRequiringEvaluation.isEmpty()) {
            for (Duty__c duty : dutiesRequiringEvaluation) {

                //If Duty is In/Out of hours, first get approval limit & currently approved time of master type
                Double masterApprovalLimit;
                Double currentlyApprovedMasterTime;
                Boolean isInOrOutOfHours = false;
                String masterType = duty.Duty_Type__c.replace(inHours,'').replace(outOfHours,'').trim();
                String dutyShiftAndMasterType = duty.Visit__c + '|' + masterType;

                if (duty.Duty_Type_Name__c.contains(inHours) || duty.Duty_Type_Name__c.contains(outOfHours)){
                    isInOrOutOfHours = true;
                    currentlyApprovedMasterTime = approvedTimeByShiftAndDutyType.get(dutyShiftAndMasterType);
                    if (currentlyApprovedMasterTime == null) {
                        approvedTimeByShiftAndDutyType.put(dutyShiftAndMasterType, 0);
                        currentlyApprovedMasterTime = 0;
                    }
                    masterApprovalLimit = dutyApprovalLimitByDutyTypeAndJobRole.get(new Object[]{
                            duty.Visit__r.sirenum__Team__c, masterType
                    });
                }

                //Set flag to simplify check on whether limit would be exceeded
                Boolean noMasterOrWithinMasterLimit =
                        (masterApprovalLimit == null && currentlyApprovedMasterTime == null) ||
                        (currentlyApprovedMasterTime + Double.valueOf(duty.Actual_Duration__c) <= masterApprovalLimit && !dutyShiftAndTypesBlocked.contains(dutyShiftAndMasterType));

                //Whether or not duty is in/out of hours, get approval limit & currently approved time of type
                String dutyShiftAndType = duty.Visit__c + '|' + duty.Duty_Type__c;
                Double currentlyApprovedTime = approvedTimeByShiftAndDutyType.get(dutyShiftAndType);
                if (currentlyApprovedTime == null) {
                    approvedTimeByShiftAndDutyType.put(dutyShiftAndType, 0);
                    currentlyApprovedTime = 0;
                }
                Double approvalLimit = dutyApprovalLimitByDutyTypeAndJobRole.get(new Object[]{
                        duty.Visit__r.sirenum__Team__c, duty.Duty_Type__c
                });

                //Duty's duration would not go over standard or master limit, and no prior duties would have gone over limit
                if (currentlyApprovedTime + Double.valueOf(duty.Actual_Duration__c) <= approvalLimit && !dutyShiftAndTypesBlocked.contains(dutyShiftAndType) && noMasterOrWithinMasterLimit) {
                    duty.Status__c = 'Approved';
                    duty.Auto_Approved__c = true;
                    approvedTimeByShiftAndDutyType.put(dutyShiftAndType, currentlyApprovedTime + Double.valueOf(duty.Actual_Duration__c));
                    if (isInOrOutOfHours){
                        approvedTimeByShiftAndDutyType.put(dutyShiftAndMasterType, currentlyApprovedMasterTime + Double.valueOf(duty.Actual_Duration__c));
                    }
                //Master limit would be breached
                } else if (isInOrOutOfHours && !noMasterOrWithinMasterLimit){
                    duty.Manual_Review_Required__c = true;
                    dutyShiftAndTypesBlocked.add(dutyShiftAndMasterType); //Block master type, which effectively blocks in hours and out of hours types too.
                //Standard or in/out of hours limit would be breached
                } else {
                    duty.Manual_Review_Required__c = true;
                    dutyShiftAndTypesBlocked.add(dutyShiftAndType); //Only block the standard or in/out of hours limit, do not block master type
                }
            }

            //All examined duties will have been updated in some way; no need for separate list
            update dutiesRequiringEvaluation;
        }
    }

    public static void processProjects(List<sirenum__ProActiveContract__c> scope, Id referenceDutyRecordTypeId){
        Map<Id, sirenum__ProActiveContract__c> projectsById = new Map<Id, sirenum__ProActiveContract__c>(scope);

        //Get Reference duties of all Projects in scope
        List<Duty__c> referenceDuties = [
                SELECT Id, Duty_Type__c, Approval_Limit__c, Project__c, In_Hours_Approval_Limit__c, Out_of_Hours_Approval_Limit__c, Duty_Type_Name__c
                FROM Duty__c
                WHERE Project__c IN :projectsById.keySet() AND Relates_To__c  = 'Project'
                AND RecordTypeId = :referenceDutyRecordTypeId
        ];

        // KEY: [0] = Project Id, [1] = Duty Type VALUE: Approval Limit
        Map<Object[], Double> dutyApprovalLimitByDutyTypeAndProject = new Map<Object[], Double>();

        //Examine reference duties, building map of Approval Limits by Project and Duty Type
        for (Duty__c duty : referenceDuties){
            //Do not check for existing entry as there should only be one (last in wins if not)
            //Split by In hours/ Out of hours/ Standard or total
            //In Hours and Out of Hours specify trimmed total, but standard duty types do not (just in case data contains leading or trailing spaces)
            String masterDutyType = duty.Duty_Type__c.replace(inHours,'').replace(outOfHours,'').trim();
            if (duty.Duty_Type_Name__c.contains(inHours)){
                dutyApprovalLimitByDutyTypeAndProject.put(new Object[]{duty.Project__c, duty.Duty_Type__c}, Double.valueOf(duty.In_Hours_Approval_Limit__c));
                dutyApprovalLimitByDutyTypeAndProject.put(new Object[]{duty.Project__c, masterDutyType}, Double.valueOf(duty.Approval_Limit__c));
            } else if (duty.Duty_Type_Name__c.contains(outOfHours)) {
                dutyApprovalLimitByDutyTypeAndProject.put(new Object[]{duty.Project__c, duty.Duty_Type__c}, Double.valueOf(duty.Out_of_Hours_Approval_Limit__c));
                dutyApprovalLimitByDutyTypeAndProject.put(new Object[]{duty.Project__c, masterDutyType}, Double.valueOf(duty.Approval_Limit__c));
            } else {
                dutyApprovalLimitByDutyTypeAndProject.put(new Object[]{duty.Project__c, duty.Duty_Type__c}, Double.valueOf(duty.Approval_Limit__c));
            }
        }

        //Retrieve all non-reference (i.e. worker) duties for Projects in context
        List<Duty__c> contextDuties = [
                SELECT Id, Status__c, Duty_Type__c, Actual_Duration__c, CreatedBy.Profile.Name, Manual_Review_Required__c, Project__c, Duty_Type_Name__c
                FROM Duty__c
                WHERE Project__c IN :projectsById.keySet() AND Relates_To__c  = 'Project'
                AND (   //Exclude Duties where Manual review is required UNLESS it has already been approved
                        Manual_Review_Required__c = FALSE
                        OR (Manual_Review_Required__c = TRUE AND Status__c = 'Approved')
                )
                AND Deleted_by_Worker__c = FALSE
                AND RecordTypeId != :referenceDutyRecordTypeId
                ORDER BY Date_of_Duty__c, CreatedDate ASC
        ];

        //KEY: <ProjectId>|<DutyType> VALUE: Approved time (the key is a string rather than Object[] so that we can check
        // if a Set<String> of 'blocked' keys contains the key later on)
        Map<String,Double> approvedTimeByProjectAndDutyType = new Map<String, Double>();
        List<Duty__c> dutiesRequiringEvaluation = new List<Duty__c>();

        for (Duty__c duty : contextDuties){
            //Examine already approved worker duties, Building Map: {ProjectId|DutyType} : {Total Time approved}
            if (duty.Status__c == 'Approved'){
                //If the Duty is an In Hours or Out of Hours duty, first handle the master duty type
                if (duty.Duty_Type_Name__c.contains(inHours) || duty.Duty_Type_Name__c.contains(outOfHours)){
                    String dutyProjectAndMasterType = duty.Project__c + '|' + duty.Duty_Type__c.replace(inHours,'').replace(outOfHours,'').trim();
                    Double approvedTime = approvedTimeByProjectAndDutyType.get(dutyProjectAndMasterType);
                    if (approvedTime == null){
                        approvedTimeByProjectAndDutyType.put(dutyProjectAndMasterType, Double.valueOf(duty.Actual_Duration__c));
                    } else {
                        approvedTime += Double.valueOf(duty.Actual_Duration__c);
                    }
                }

                //Now handle standard duty types and in/out of hours types
                String dutyProjectAndType = duty.Project__c + '|' + duty.Duty_Type__c;
                Double approvedTime = approvedTimeByProjectAndDutyType.get(dutyProjectAndType);
                if (approvedTime == null){
                    approvedTimeByProjectAndDutyType.put(dutyProjectAndType, Double.valueOf(duty.Actual_Duration__c));
                } else {
                    approvedTime += Double.valueOf(duty.Actual_Duration__c);
                }
            }
            //Build List of submitted worker Duties to evaluate
            else if (duty.Status__c == 'Submitted' && !duty.Manual_Review_Required__c){
                dutiesRequiringEvaluation.add(duty);
            }
        }

        //{ProjectId}|{DutyType} where the Project/duty type are blocked from approvals (due to a duty which would put them over limit)
        Set<String> dutyProjectAndTypesBlocked = new Set<String>();

        //If there are records to examine, then check them
        if (!dutiesRequiringEvaluation.isEmpty()) {
            for (Duty__c duty : dutiesRequiringEvaluation) {
                //If Duty is In/Out of hours, first get approval limit & currently approved time of master type
                Double masterApprovalLimit;
                Double currentlyApprovedMasterTime;
                Boolean isInOrOutOfHours = false;
                String masterType = duty.Duty_Type__c.replace(inHours,'').replace(outOfHours,'').trim();
                String dutyProjectAndMasterType = duty.Project__c + '|' + masterType;

                if (duty.Duty_Type_Name__c.contains(inHours) || duty.Duty_Type_Name__c.contains(outOfHours)){
                    isInOrOutOfHours = true;
                    currentlyApprovedMasterTime = approvedTimeByProjectAndDutyType.get(dutyProjectAndMasterType);
                    if (currentlyApprovedMasterTime == null) {
                        approvedTimeByProjectAndDutyType.put(dutyProjectAndMasterType, 0);
                        currentlyApprovedMasterTime = 0;
                    }
                    masterApprovalLimit = dutyApprovalLimitByDutyTypeAndProject.get(new Object[]{
                            duty.Project__c, masterType
                    });
                }

                //Set flag to simplify check on whether limit would be exceeded
                Boolean noMasterOrWithinMasterLimit =
                        (masterApprovalLimit == null && currentlyApprovedMasterTime == null) ||
                                (currentlyApprovedMasterTime + Double.valueOf(duty.Actual_Duration__c) <= masterApprovalLimit && !dutyProjectAndTypesBlocked.contains(dutyProjectAndMasterType));

                //Whether or not duty is in/out of hours, get approval limit & currently approved time of type
                String dutyProjectAndType = duty.Project__c + '|' + duty.Duty_Type__c;
                Double currentlyApprovedTime = approvedTimeByProjectAndDutyType.get(dutyProjectAndType);
                if (currentlyApprovedTime == null) {
                    approvedTimeByProjectAndDutyType.put(dutyProjectAndType, 0);
                    currentlyApprovedTime = 0;
                }
                Double approvalLimit = dutyApprovalLimitByDutyTypeAndProject.get(new Object[]{
                        duty.Project__c, duty.Duty_Type__c
                });

                //Duty's duration would not go over standard or master limit, and no prior duties would have gone over limit
                if (currentlyApprovedTime + Double.valueOf(duty.Actual_Duration__c) <= approvalLimit && !dutyProjectAndTypesBlocked.contains(dutyProjectAndType) && noMasterOrWithinMasterLimit) {
                    duty.Status__c = 'Approved';
                    duty.Auto_Approved__c = true;
                    approvedTimeByProjectAndDutyType.put(dutyProjectAndType, currentlyApprovedTime + Double.valueOf(duty.Actual_Duration__c));
                    if (isInOrOutOfHours){
                        approvedTimeByProjectAndDutyType.put(dutyProjectAndMasterType, currentlyApprovedMasterTime + Double.valueOf(duty.Actual_Duration__c));
                    }
                //Master limit would be breached
                } else if (isInOrOutOfHours && !noMasterOrWithinMasterLimit){
                    duty.Manual_Review_Required__c = true;
                    dutyProjectAndTypesBlocked.add(dutyProjectAndMasterType); //Block master type, which effectively blocks in hours and out of hours types too.
                //Standard or in/out of hours limit would be breached
                } else {
                    duty.Manual_Review_Required__c = true;
                    dutyProjectAndTypesBlocked.add(dutyProjectAndType); //Only block the standard or in/out of hours limit, do not block master type
                }
            }

            //All examined duties will have been updated in some way; no need for separate list
            update dutiesRequiringEvaluation;
        }
    }

    public void finish(Database.BatchableContext bc){
        //do nothing
    }
}