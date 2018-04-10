public class EmployeeSkillsTriggerHandler {
    
	public EmployeeSkillsTriggerHandler() {
        this.manage();
    }
 
    public void manage() {
       
        if(Trigger.isInsert && Trigger.isBefore)
        {
            
        }
        else if(Trigger.isInsert && Trigger.isAfter)
        {
 			EmployeeSkillsTriggerHelper.OnAfterInsert(Trigger.New);
            //task_4(count dev's and qa's)
            //second param == true - if insert
            EmployeeSkillsTriggerHelper.OnAfterInsert(Trigger.New, true);
        }
        else if(Trigger.isUpdate && Trigger.isBefore)
        {
			
        }
        else if(Trigger.isUpdate && Trigger.isAfter)
        {
 			EmployeeSkillsTriggerHelper.OnAfterUpdate(Trigger.New);
        }
        else if(Trigger.isDelete && Trigger.isBefore)
        {
 			
        }
        else if(Trigger.isDelete && Trigger.isAfter)
        {
			//task_4(count dev's and qa's)
 			//second param == false -  if delete
            EmployeeSkillsTriggerHelper.OnAfterDelete(Trigger.Old, false);
        }
        else if(Trigger.isundelete)
        {
           
        }
    }
}