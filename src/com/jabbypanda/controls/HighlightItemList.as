package com.jabbypanda.controls {
    
    import com.jabbypanda.event.HighlightItemListEvent;
    
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import mx.core.FlexGlobals;
    import mx.styles.CSSStyleDeclaration;
    
    import spark.components.List;
    
    /**
     *  The color of the background for highlighted text segments 
     *
     *   @default 0#FFCC00
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="highlightBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]
    
    [Event (name="itemClick", type="com.jabbypanda.event.HighlightItemListEvent")]
    [Event (name="lookupValueChange", type="com.jabbypanda.event.HighlightItemListEvent")]
    public class HighlightItemList extends List {
        
        public var searchMode : String;                
        
        public function HighlightItemList() {
            super();
        }
        
        public function set lookupValue(lookupValue : String) : void {
            _lookupValue = lookupValue;
            dispatchEvent(new HighlightItemListEvent(HighlightItemListEvent.LOOKUP_VALUE_CHANGE));
        }
        
        public function get lookupValue() : String {
            return _lookupValue;
        }
        
        public function focusListUponKeyboardNavigation(event : KeyboardEvent) : void {            
            adjustSelectionAndCaretUponNavigation(event);            
        }                
        
        override protected function item_mouseDownHandler(event:MouseEvent) : void {
            super.item_mouseDownHandler(event);
            dispatchEvent(new HighlightItemListEvent(HighlightItemListEvent.ITEM_CLICK));
        }
        
        private var _lookupValue : String = "";
    }
}