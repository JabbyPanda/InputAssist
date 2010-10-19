package com.jabbypanda.controls {
    
    import com.jabbypanda.event.HighlightItemListEvent;
    
    import flash.debugger.enterDebugger;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import mx.core.mx_internal;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    
    import spark.components.List;
    
    use namespace mx_internal;  //ListBase and List share selection properties that are mx_internal
    
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
        
        override protected function adjustSelectionAndCaretUponNavigation(event:KeyboardEvent):void
        {
            // If rtl layout, need to swap Keyboard.LEFT and Keyboard.RIGHT.
            var navigationUnit:uint = mapKeycodeForLayoutDirection(event);            
            var proposedNewIndex:int = layout.getNavigationDestinationIndex(caretIndex, navigationUnit, arrowKeysWrapFocus);
            super.adjustSelectionAndCaretUponNavigation(event);
        }
                
        override protected function dataProvider_collectionChangeHandler(event:Event):void {
            super.dataProvider_collectionChangeHandler(event);
            
            if (event is CollectionEvent) {
                var ce:CollectionEvent = CollectionEvent(event);            
                
                // workaround to set caretIndex to 0 if selection is required
                if (ce.kind == CollectionEventKind.REFRESH) {
                    if (requireSelection) {
                        setCurrentCaretIndex(0);
                    }    
                }
            }
        }
        
        private var _lookupValue : String = "";
    }
}