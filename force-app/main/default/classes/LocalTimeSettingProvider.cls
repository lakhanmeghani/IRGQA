/**
 * © Sirenum By Bullhorn 2024
 * PS-946 provide option to disable Shift > Site local time processing, instead using GMT
 *
 * Provides settings for ShiftNotifications & ShiftNotificationsBatch
 */
public with sharing class LocalTimeSettingProvider {
    private static Local_Time_Trigger_Setting__mdt localTimeSetting; //Cached setting

    /**
     * Returns cached Local_Time_Trigger_Setting__mdt if not null, else retrieves from DB, then caches and returns.
     *
     * @param name The developer name of the Local_Time_Trigger_Setting__mdt to retrieve and return
     *
     * @return The (cached) Local_Time_Trigger_Setting__mdt with developer name = param 'name'
     */
    public static Local_Time_Trigger_Setting__mdt getSetting(String name){
        Local_Time_Trigger_Setting__mdt setting = localTimeSetting;
        if (setting == null){
            List<Local_Time_Trigger_Setting__mdt> settings = [
                    SELECT Id, Disable_Site_Timezone_Conversion__c
                    FROM Local_Time_Trigger_Setting__mdt
                    WHERE DeveloperName = :name
            ];
            //Set cached setting to the real setting in the org if it exists, otherwise use a transient one (i.e. during test execution)
            localTimeSetting = !settings.isEmpty() ? settings[0] : new Local_Time_Trigger_Setting__mdt(DeveloperName = name, Disable_Site_Timezone_Conversion__c = false);
            setting = localTimeSetting;
        }
        return setting;
    }

    /**
     * Creates a transient Local_Time_Trigger_Setting__mdt to allow different values to be set for different tests.
     * This is only used by test classes.
     *
     * @param name the developer name of the transient Local_Time_Trigger_Setting__mdt to create
     * @param disableSiteTimezone the Disable_Site_Timezone_Conversion__c value to use for the transient Local_Time_Trigger_Setting__mdt
     *
     * @return The transient Local_Time_Trigger_Setting__mdt
     */
    public static Local_Time_Trigger_Setting__mdt addSetting(String name, Boolean disableSiteTimezone){
        localTimeSetting = new Local_Time_Trigger_Setting__mdt(DeveloperName = name, Disable_Site_Timezone_Conversion__c = disableSiteTimezone);
        return localTimeSetting;
    }
}