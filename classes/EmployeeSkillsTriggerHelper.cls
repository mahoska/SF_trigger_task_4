public with sharing class EmployeeSkillsTriggerHelper {
    
	public static void OnAfterInsert(List<EmployeeSkills__c> skills){
        EmployeeSkillsService.OnAfterInsertUpdate(skills);
    }
    
    public static void OnAfterUpdate(List<EmployeeSkills__c> skills){
        EmployeeSkillsService.OnAfterInsertUpdate(skills);
    }
    
    //task_4(count dev's and qa's)
    public static void OnAfterInsert(List<EmployeeSkills__c> skills, Boolean isInsert){
        EmployeeSkillsService.OnAfterInsertDeleteChangeCountEmployees(skills, isInsert);
    }
    
	//task_4(count dev's and qa's)
    public static void OnAfterDelete(List<EmployeeSkills__c> skills, Boolean isInsert){
        EmployeeSkillsService.OnAfterInsertDeleteChangeCountEmployees(skills, isInsert);
    }
    
}