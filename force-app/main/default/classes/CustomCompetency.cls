/**
 * Copyright (c) Sirenum by Bullhorn 2024
 *
 * Custom competency condition constraint for Active competency conditions
 */

global without sharing class CustomCompetency {

    global class ActiveConstraint implements sirenum.CompetencyConditionConstraint {
        global String getShiftFieldPath() {
            return 'Active__c';
        }

        global String getCompetencyConditionField() {
            return 'Inactive_Calculated__c';
        }

        global Object getShiftValue(sirenum__Shift__c shift) {
            return shift.Active__c;
        }

        global Object getCompetencyConditionValue(sirenum__Sirenum_Condition_Membership__c competencyCondition) {
            return competencyCondition.Inactive_Calculated__c;
        }
    }
}