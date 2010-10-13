package com.jabbypanda.event {
	
    import flash.events.Event;
    /**
     * <P>Custom event class.</P>
     * stores custom data in the <code>data</code> variable.
     */	
    public class InputAssistEvent extends Event {
		
        public static const CHANGE : String = "change";
        
        public var data:Object;                
        
        public function InputAssistEvent(type:String, mydata:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
        	super(type, bubbles,cancelable);			
        	data = mydata;
        }

    }
}