trigger AfterDeleteRecord on Account (after delete) {
    
    for ( Account acc  :Trigger.Old ){
        
        // Process Shallow Delete Operation
        ShallowDelete.init(acc , 'Account' );
    }
    

}