/*******************************************************************************************************
    * @author  : SARAVANAN C
    * @date    :  05 Jan 2017
    * @modified : 05 Jan 2017
    * @group    :  
    * @group-content : 
    * @description : THIS IS CLASS CAN BE INVOKED FROM ANY OBJECT DELETE TRIGGER, THIS CLASS LOGIC WILL DOES THE FOLLOWS:
    *                1. ALL FILLED FIELDS DETAILS WILL BE CAPTURED 2. CREATE NEW RECORD IN SHALLOW DELETE OBJECT 3. INSERT AN ATTACHMENT OF GENERATED JSON FILE
********************************************************************************************************/

Public Class ShallowDelete {
    
    //GLOABAL VARIABLES
    Public Static String sObjectName ;
    Public Static Sobject  Sobject2;
    
    /*******************************************************************************************************
    * @description : INIT METHOD  
    * @param : SOBJECT AND OBJECTTYPE
    * @param : 
    * @return : VOID
    * @example 
    *  
    *******************************************************************************************************/
    Public Static Void init(  Sobject Obj, String SObjectType){
       
       //try {
        
        System.Debug(' init() ==> ' + Obj);
        
        sObjectName = SObjectType ;
        Sobject2 = obj ;
        
        String recordName = NULL ;
        
        //LOCAL VARIABLE TO CAPTURE ONLY THE FILLED FIELDS DETAIL
        Map<String, Object> fieldsAndValues = Obj.getPopulatedFieldsAsMap();
        
        //INITILIAZE THE JSON GENERATOR CLASS        
        JSONGenerator gen = JSON.createGenerator(true);
          // Write data to the JSON string.
          gen.writeStartObject();
            
            //ITERATE THROUGH EACH FILLED FIELDS AND WRITE JSONS STRUCTURE FILE       
            for (String fieldName : fieldsAndValues.keySet()) {
                
                if ( fieldName == 'Name' ) recordName = (String)fieldsAndValues.get(fieldName) ;
            
              
                if ( getFieldType(fieldName) == 'String' || getFieldType(fieldName) == 'Combobox' || getFieldType(fieldName) == 'MultiPicklist' || 
                     getFieldType(fieldName) == 'EncryptedString' )
                    gen.writeStringField(fieldName,(String)fieldsAndValues.get(fieldName)) ;
                    
                else if ( getFieldType(fieldName) == 'Decimal' )
                    gen.writeNumberField(fieldName,(Decimal)fieldsAndValues.get(fieldName)) ;
                
                else if ( getFieldType(fieldName) == 'Double' )
                    gen.writeNumberField(fieldName,(Double)fieldsAndValues.get(fieldName)) ;
                
                else if ( getFieldType(fieldName) == 'Integer' )
                    gen.writeNumberField(fieldName,(Integer)fieldsAndValues.get(fieldName)) ;   
                
                else if ( getFieldType(fieldName) == 'Long' )
                    gen.writeNumberField(fieldName,(Long)fieldsAndValues.get(fieldName)) ;  
                    
                else if ( getFieldType(fieldName) == 'Date' )
                    gen.writeDateField(fieldName,(Date)fieldsAndValues.get(fieldName)) ;
                    
                else if ( getFieldType(fieldName) == 'DateTime' )
                    gen.writeDateTimeField(fieldName,(DateTime)fieldsAndValues.get(fieldName)) ;
                    
                else if ( getFieldType(fieldName) == 'Time' )
                    gen.writeTimeField(fieldName,(Time)fieldsAndValues.get(fieldName)) ;                
              /*  else if ( getFieldType(fieldName) == 'Blob' )
                    gen.writeBlobField(fieldName,(Blob)fieldsAndValues.get(fieldName)) ;
               */ 
             
            }   
        gen.writeEndObject();
        String JSONString = gen.getAsString();

        System.Debug(' JSONString  ==> ' + JSONString );
        
        Shallow_Delete__c recordDeleted = New Shallow_Delete__c (
        
            Name = recordName ,
            Object__c = SObjectType,
            Deleted_by__c = Userinfo.getUserid() ,
            Deleted_on__c = Datetime.Now()
        );
        
        Insert recordDeleted ;
        
        
        Blob body = Blob.valueOf(JSONString );

        insert new Attachment(
                Name = recordName+'.json',
                ContentType = 'json',
                Body = body,
                ParentId = recordDeleted.Id); 
      
      /*      
      } Catch (Exception e) {
          
          System.Debug(' Exception   ==> ' + e  );
          
      } 
      
        */
       
    }
    
    
    /*******************************************************************************************************
    * @description : HELPER METHOD - THIS METHOD WILL IDENTIFY THE FIELD TYPE FOR THE GIVEN FIELD
    * @param : FIELD NAME 
    * @param : 
    * @return : STRING
    * @example :
    *  
    *******************************************************************************************************/
    
    Public static String getFieldType(String fieldName){
        
        Schema.SObjectType t = Schema.getGlobalDescribe().get(((SObject)Sobject2).getSObjectType().getDescribe().getName() );
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        Schema.DisplayType fieldType = f.getType();
        
        if ( f.isUpdateable() ) {
         
        if(fieldType == Schema.DisplayType.String || 
            fieldType == Schema.DisplayType.TextArea ||
            fieldType == Schema.DisplayType.Id ||
            fieldType == Schema.DisplayType.Picklist ||
            fieldType == Schema.DisplayType.Reference ||
            fieldType == Schema.DisplayType.Phone ||
            fieldType == Schema.DisplayType.Email ||
            fieldType == Schema.DisplayType.URL)
            return 'String';
            
        if(fieldType == Schema.DisplayType.Currency ||
           fieldType == Schema.DisplayType.Double)
            return 'Decimal';
        if(fieldType == Schema.DisplayType.Integer)
            return 'Integer';
        if(fieldType == Schema.DisplayType.Boolean)
            return 'Boolean';
        if(fieldType == Schema.DisplayType.DateTime)
            return 'DateTime';    
        if(fieldType == Schema.DisplayType.Date)
            return 'Date';            
        if(fieldType == Schema.DisplayType.Time)
            return 'Time';
        if(fieldType == Schema.DisplayType.Combobox)
            return 'Combobox';    
        if(fieldType == Schema.DisplayType.MultiPicklist)
            return 'MultiPicklist';
       if(fieldType == Schema.DisplayType.EncryptedString)
            return 'EncryptedString';
       if(fieldType == Schema.DisplayType.base64 )
            return 'base64 ';               
       //if(fieldType == Schema.DisplayType.anytype)
       //     return 'anytype';                                  
        return 'UNKNOWN';      
             
       }
       
       return null ;   
    }

}