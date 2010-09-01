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
    [Style(name="highlightBackgroundColor", type="uint", format="Color", inherit="no", theme="spark")]
    
    [Event (name="itemClick", type="com.jabbypanda.event.HighlightItemListEvent")]
    [Event (name="lookupValueChange", type="com.jabbypanda.event.HighlightItemListEvent")]
    public class HighlightItemList extends List {
        
        public var searchMode : String;                
        
        public function HighlightItemList() {
            super();
        }
        
        // Define a static variable.
        private static var classConstructed:Boolean = classConstruct();
        
        // Define a static method.
        private static function classConstruct():Boolean {
            var customListStyles : CSSStyleDeclaration;
                        
            if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.jabbypanda.controls.HighlightItemList")) {
                // If there is no CSS definition for HighlightItemList 
                // then create one and set the default value.
                customListStyles = new CSSStyleDeclaration();
                customListStyles.defaultFactory = function() : void {
                    this.highlightBackgroundColor = 0xFFCC00;                    
                }
                
                FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.jabbypanda.controls.HighlightItemList", customListStyles, true);                                
            }                        
            
            return true;
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
        
        // Override the styleChanged() method to detect changes in your new style.
        override public function styleChanged(styleProp:String):void {            
            // Check to see if style changed. 
            if (styleProp == "highlightBackgroundColor")  {
                _highlightBackgroundColorStyleChanged = true; 
                invalidateDisplayList();
                return;
            }    
        }
        
        override protected function updateDisplayList(unscaledWidth:Number,
                                                      unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            // Check to see if style changed. 
            if (_highlightBackgroundColorStyleChanged) {
                setStyle("highlightBackgroundColor", getStyle("highlightBackgroundColor"));
                _highlightBackgroundColorStyleChanged = false;
            }
        }
        
        override protected function item_mouseDownHandler(event:MouseEvent) : void {
            super.item_mouseDownHandler(event);
            dispatchEvent(new HighlightItemListEvent(HighlightItemListEvent.ITEM_CLICK));
        }
        
        private var _lookupValue : String = "";
        
        private var _highlightBackgroundColorStyleChanged : Boolean;
        
    }
}