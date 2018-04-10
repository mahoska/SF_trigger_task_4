public with sharing class EmployeeTriggerHelper {
    
    public static void OnAfterInsert(List<Employee__c> employees){
        EmployeeTriggerService.OnAfterInsertUpdate(employees);
    }
    
    public static void OnAfterUpdate(List<Employee__c> employees){
        EmployeeTriggerService.OnAfterInsertUpdate(employees);
    }
    
	//task_4(count dev's and qa's)
    public static void OnAfterUpdateActiveDepartmentFields(List<Employee__c> employeesNew, List<Employee__c> employeesOld){
        EmployeeTriggerService.OnAfterUpdateActiveDepartmentFieldsServ(employeesNew, employeesOld);
    }
}