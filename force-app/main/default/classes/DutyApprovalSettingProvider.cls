/**
 * Copyright © Sirenum by bullhorn 2024
 * PS-947 Scheduled process to examine and approve Duties related to Shifts
 *
 * Provides a mechanism to access the Duty Approval Settings which can be used by the test class.
 * Note that when running the test class, if the custom metadata exists on the org, it will be used for testing
 * (this is primarily a consideration for change sets or deployment packages)
 */

public with sharing class DutyApprovalSettingProvider {
    private static Duty_Approval_Setting__mdt dutyApprovalSetting;

    public static Duty_Approval_Setting__mdt getSetting(String name){
        Duty_Approval_Setting__mdt setting = dutyApprovalSetting;
        if (setting == null){
            List<Duty_Approval_Setting__mdt> settings = [
                    SELECT Id, Batch_Size__c
                    FROM Duty_Approval_Setting__mdt
                    WHERE DeveloperName = :name
            ];

            dutyApprovalSetting = !settings.isEmpty() ? settings[0] : new Duty_Approval_Setting__mdt(DeveloperName=name,Batch_Size__c=200);

            setting = dutyApprovalSetting;
        }
        return setting;
    }
}