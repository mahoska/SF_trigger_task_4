public class EmployeeTriggerHandler {
 
    public static void manage() {
       
       
        if(Trigger.isInsert && Trigger.isBefore)
        {
            
        }
        else if(Trigger.isInsert && Trigger.isAfter)
        {
 			EmployeeTriggerHelper.OnAfterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate && Trigger.isBefore)
        {
 			 
        }
        else if(Trigger.isUpdate && Trigger.isAfter)
        {
 			EmployeeTriggerHelper.OnAfterUpdate(Trigger.new);
			
			//task_4(count dev's and qa's)
            if(CheckRecursive.RunMe) { 
                EmployeeTriggerHelper.OnAfterUpdateActiveDepartmentFields(Trigger.new, Trigger.old);
                CheckRecursive.RunMe=false;
            }
        }
        else if(Trigger.isDelete && Trigger.isBefore)
        {
 
        }
        else if(Trigger.isDelete && Trigger.isAfter)
        {
 
        }
        else if(Trigger.isundelete)
        {
           
        }
    }

}