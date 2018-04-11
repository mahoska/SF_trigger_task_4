public with sharing class EmployeeSkillsTriggerHelper {
    
	public static void OnAfterInsertUpdateCheckAssignedTime(List<EmployeeSkills__c> skills){
       for(EmployeeSkills__c item: skills){
            List<AggregateResult> res = [
                SELECT Employee__r.Id emId, SUM(Assigned_Time__c) assignedTime  
                FROM EmployeeSkills__c 
                WHERE Employee__r.Id =: item.Employee__c AND Id !=: item.Id
                GROUP BY Employee__r.Id
                LIMIT 1
            ];
            
            List<Employee__c> em = [SELECT Availability__c FROM Employee__c  WHERE Id =: item.Employee__c];
            
            if(
                (!res.isEmpty() && em[0].Availability__c < (Double)res[0].get('assignedTime') + item.Assigned_Time__c) ||
                (res.isEmpty() && em[0].Availability__c < item.Assigned_Time__c)
            ){
                item.addError('The number of hours(Assigned Times) exceeds hours(availability) of employee.');
            }
            
        }
    }
    
    //task_4(count dev's and qa's)
    public static void OnAfterInsertDeleteEmplSkChangeProjectFieldDevAndQA(List<EmployeeSkills__c> skills, Boolean isInsert){
        //create item helper class for inicialization infoMap(key - id project and info - count dev's and qa's)
       DevQaFieldsService.Info itemSeviceClass = new DevQaFieldsService.Info();
        
        for(EmployeeSkills__c item: skills){
            Employee__c empl = [SELECT IT_Department__c, isActive__c FROM Employee__c  WHERE Id =: item.Employee__c LIMIT 1];
            
            if(empl.isActive__c == True && (empl.IT_Department__c== 'QA' || empl.IT_Department__c == 'DEV')){
                
                //looking employee  for in the project - so as not to duplicate it
                AggregateResult  ifExistEmpl = [
                    SELECT COUNT(Employee__c) countEmpl 
                    FROM EmployeeSkills__c 
                    WHERE Employee__c=: item.Employee__c AND Project__c =: item.Project__c
                ];
                
                //if not exists
                if((Integer)ifExistEmpl.get('countEmpl') == 0) {
                    
                    Integer Qa = empl.IT_Department__c == 'QA' ? 1 :0 ;
                    Integer Dev = empl.IT_Department__c == 'DEV' ? 1 : 0; 
                    
                    DevQaFieldsService.Info emplInfo = new DevQaFieldsService.Info(Qa,Dev);
                    itemSeviceClass.addRecordToMap(item.Project__c, emplInfo);
                }
            }
        }
        
        List<Project__c> updProjectList;
        if(isInsert){
        	updProjectList = DevQaFieldsService.getListProjectsToUbdate(itemSeviceClass.infoMap, true);
        }else{
        	updProjectList = DevQaFieldsService.getListProjectsToUbdate(itemSeviceClass.infoMap, false);
        }
        
        update updProjectList;
    }

    
}