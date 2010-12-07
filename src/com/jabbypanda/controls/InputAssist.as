package com.jabbypanda.controls {

	import com.jabbypanda.data.SearchModes;
	import com.jabbypanda.event.HighlightItemListEvent;
	import com.jabbypanda.event.InputAssistEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.managers.FocusManager;
	import mx.managers.SystemManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleProxy;
	
	import spark.components.PopUpAnchor;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TextOperationEvent;
	import spark.utils.LabelUtil;
    
    use namespace mx_internal;
	
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
    
	[Event (name="change", type="com.jabbypanda.event.InputAssistEvent")]
	public class InputAssist extends SkinnableComponent {
		                
        [Bindable]
        public var maxRows : Number = 6;
        
        [Bindable]
        public var processing : Boolean;
        
        public var forceOpen : Boolean = true;
        
        public var requireSelection : Boolean = false;        
        
        [SkinPart(required="true",type="spark.components.PopUpAnchor")]
		public var popUp : PopUpAnchor;
        
        [SkinPart(required="true",type="odyssey.common.component.HighlightItemList")]
        public var list : HighlightItemList;
        
        [SkinPart(required="true",type="spark.components.TextInput")]
        public var inputTxt : TextInput;
		        
        // Define a static variable.
        private static var classConstructed:Boolean = classConstruct();
        
        // Define a static method.
        private static function classConstruct():Boolean {
            var customListStyles : CSSStyleDeclaration;
                        
            if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.jabbypanda.controls.InputAssist")) {
                // If there is no CSS definition for InputAssist 
                // then create one and set the default value.
                customListStyles = new CSSStyleDeclaration();
                customListStyles.defaultFactory = function() : void {
                    this.highlightBackgroundColor = 0xFFCC00;                    
                }
                                 
                FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.jabbypanda.controls.InputAssist", customListStyles, true);                                
            }                        
            
            return true;
        }
        
        public function InputAssist() {
            super();
            this.mouseEnabled = true;
            dataProvider = null;
        }        
                        
        [Bindable]
        public function set dataProvider(value : Object) : void {
            if (value is Array) {
        		_collection = new ArrayCollection(value as Array);
            } else if (value is ArrayList) {
                _collection = new ArrayCollection(ArrayList(value).source);                
                ArrayList(value).addEventListener(CollectionEvent.COLLECTION_CHANGE, onDataProviderCollectionChange, false, 0, true);
            } else if (value is ArrayCollection) {
                _collection = new ArrayCollection((value as ArrayCollection).source);
                ArrayCollection(value).addEventListener(CollectionEvent.COLLECTION_CHANGE, onDataProviderCollectionChange, false, 0, true);
        	} else {
                _collection = new ArrayCollection();
            }            
            
            //reset previously selected item
            selectedItem = null;
            
            if (isOurFocus(this.getFocus())) {
                filterData();
            }
                            	
            _dataProviderChanged = true;
            invalidateProperties(); 
        }
		
        public function get dataProvider() : Object {
            return _collection; 
        }		                
		
        public function set searchMode(searchMode : String) : void {            
            _searchMode = searchMode; 
            if (list) {
                list.searchMode = searchMode;   
            } 
        }
        
        public function get searchMode() : String { 
            return _searchMode;
        };
        
        public function get labelField() : String { 
            return _labelField;
        };
        
        public function set labelField(field:String) : void {
			_labelField = field; 
			if (list) {
                list.labelField = field;   
            } 
		}
		
        public function get labelFunction() : Function	 { 
            return _labelFunction; 
        }
        
        public function set labelFunction(func:Function) : void {
        	_labelFunction = func; 
        	if (list) {
                list.labelFunction = func;   
            } 
        }
        
        [Bindable]
        public function get selectedItem() : Object { 
            return _selectedItem; 
        }
        
        public function set selectedItem(item : Object) : void {            
            _selectedItem = item;
            _selectedItemChanged = true;                                
            invalidateProperties();            
        }
        
        public function get prompt() : String {
            return _prompt;
        }
        
        public function set prompt(value : String) : void {
            _prompt = value;
            _promptChanged = true;
            invalidateProperties();            
        }
        
        public function get errorMessage() : String {
            return _errorMessage;
        }
        
        public function set errorMessage(value : String) : void {
            _errorMessage = value;
            _errorMessageChanged = true;
            invalidateProperties();
        }

		
        // default filter function         
        public function filterFunction(item : Object) : Boolean {
            var itemLabel : String = itemToLabel(item).toLowerCase();
            
            switch (searchMode) {
                case SearchModes.PREFIX_SEARCH :
                    if (itemLabel.substr(0, enteredText.length) == enteredText.toLowerCase()) {
                        return true;
                    }
                    else { 
                        return false;
                    }
                    break;
                case SearchModes.INFIX_SEARCH :
                    
                    if (itemLabel.indexOf(enteredText.toLowerCase()) != -1) {
                        return true;   
                    }                         
                    break;
            }
            
            return false;
        }
		        
        override public function set enabled(value:Boolean) : void {
            super.enabled = value;
            _enabledChanged = true;
            invalidateProperties();
        }
        
        override public function setFocus() : void {            
            if (inputTxt) {
                inputTxt.setFocus();
            }
        }
        
        override protected function isOurFocus(target : DisplayObject) : Boolean {
            if (!inputTxt) {
                return false;
            }
            
            return target == inputTxt.textDisplay || super.isOurFocus(target);
        }
        
        override protected function partAdded(partName : String, instance : Object) : void {
            super.partAdded(partName, instance)
            
            if (instance == inputTxt) {
                inputTxt.text = _enteredText;                
                
                inputTxt.addEventListener(FocusEvent.FOCUS_IN, onInputFieldFocusIn, false, 0, true);
                inputTxt.addEventListener(FocusEvent.FOCUS_OUT, onInputFieldFocusOut, false, 0, true);
                inputTxt.addEventListener(TextOperationEvent.CHANGE, onInputFieldChange, false, 0, true);
                inputTxt.addEventListener(KeyboardEvent.KEY_DOWN, onInputFieldKeyDown, false, 0, true);
            }
            
            if (instance == list) {
                list.dataProvider = _collection;
                list.labelField = labelField;
                list.labelFunction = labelFunction;
                list.searchMode = searchMode;
                list.requireSelection = requireSelection;
                list.styleName = new StyleProxy(this, {});
                
                list.addEventListener(HighlightItemListEvent.ITEM_CLICK, onListItemClick, false, 0, true);
            }                        
        }
        
        override protected function commitProperties():void {            
            if (_dataProviderChanged) {
                list.dataProvider = _collection;
                
                if (!dataProvider || dataProvider.length == 0) {
                    enabled = false;
                    displayErrorMessage();
                } else {
                    enabled = true;
                    if (prompt) {
                        displayPromptMessage();
                    } else {
                        displayInputTextText(selectedItem);
                    }
                }
                
                _dataProviderChanged = false;
            }
            
            if (_selectedItemChanged) {
                if (!selectedItem) {
                    if (prompt) {
                        displayPromptMessage();
                    } else {
                        displayInputTextText(selectedItem);
                    }
                }  else {
                    displayInputTextText(_selectedItem);
                }
                _selectedItemChanged = false;
            }
            
            if (_promptChanged) {
                displayPromptMessage();                
                _promptChanged = false;
            }

            if (_errorMessageChanged) {
                displayErrorMessage();
                _errorMessageChanged = false;
            }
            
            if (_enabledChanged) {                
                inputTxt.enabled = enabled;
                _enabledChanged = false;
            }
            
            
            // Should be last statement.
            // Don't move it up.
            super.commitProperties();                        
        }
                               
        protected function set enteredText(t : String) : void {
            _enteredText = t;            
            if (inputTxt) {
                inputTxt.text = t;
            }
            
            if (list) {
                list.lookupValue = _enteredText;
            }
            
            filterData();
        }
        
        protected function get enteredText() : String {
            return _enteredText;
        }                
        
        protected function filterData() : void {
            _collection.filterFunction = filterFunction;                        	
            _collection.refresh();                                    
        }
        
        protected function itemToLabel(item : Object) : String {
            if (!item) {
                return "";
            } else {
                return LabelUtil.itemToLabel(item, labelField, labelFunction);
            }
        }
        
        private function acceptCompletion() : void {            
            var proposedSelectedItem : Object;            
            if (_collection.length > 0 && list.selectedIndex >= 0) {
                _completionAccepted = true;
                proposedSelectedItem = _collection.getItemAt(list.selectedIndex);
            }
            else {
                _completionAccepted = false;
                proposedSelectedItem = null;
                displayInputTextText(null);
            }
                       
            if (proposedSelectedItem != selectedItem) {
                selectedItem = proposedSelectedItem;
                var e:InputAssistEvent = new InputAssistEvent(InputAssistEvent.CHANGE, _selectedItem);
                dispatchEvent(e);                
                hidePopUp();
            } else {
                showPreviousTextAndHidePopUp(true);
            }                        
        }
        
        private function displayOptionsList() : void {
            if (_collection.length == 0) {                
                hidePopUp();
            } else if (forceOpen || enteredText.length > 0) {
                showPopUp();
            }
        }
        
        private function displayInputTextText(selectedItem : Object) : void {
            _previouslyDisplayedText = enteredText = itemToLabel(selectedItem as Object);                                    
        }
        
        private function displayErrorMessage() : void {
            if (_collection.length == 0) {
                inputTxt.text = _errorMessage;
            }
        }
        
        private function displayPromptMessage() : void {            
            if (_collection.length > 0) {
                inputTxt.text = _prompt;
            }            
        }
                
        private function hidePopUp() : void {
            if (isDropDownOpen) {
                popUp.popUp.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseDownOutside);
                popUp.displayPopUp = false;
            }
        }
        
        private function showPopUp() : void {
            if (!isDropDownOpen) {
                popUp.displayPopUp = true;
                                
                if (requireSelection) {
                    setListOptionsSelectedIndex();                
                } else {
                    list.selectedIndex = -1;
                }
                                        
                popUp.popUp.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseDownOutside);
            }
        }
        
        private function setListOptionsSelectedIndex() : void {
            var selectedIndex : int = _collection.getItemIndex(selectedItem);
            if (selectedIndex != -1) {
                list.selectedIndex = selectedIndex;
            } else {
                list.selectedIndex = 0;
            }
        }
        
        private function showPreviousTextAndHidePopUp(showPreviousText : Boolean) : void {            
            if (showPreviousText) {
                enteredText = _previouslyDisplayedText;
            }
                        
            hidePopUp();            
        }                
        
        private function get isDropDownOpen() : Boolean {
            return popUp.displayPopUp;
        }
        
        private function onDataProviderCollectionChange(event : CollectionEvent) : void {
            _dataProviderChanged = true;
            invalidateProperties();
        }
        
        private function onInputFieldChange(event : TextOperationEvent = null) : void {
            _completionAccepted = false;
            enteredText = inputTxt.text;
            displayOptionsList();
        }
        
        private function onInputFieldFocusIn(event : FocusEvent) : void {
            displayInputTextText(selectedItem);
            if (forceOpen) {
                displayOptionsList();
            }
        }
        
        private function onInputFieldFocusOut(event : FocusEvent) : void {
            if (!selectedItem && prompt) {
                displayPromptMessage();
                hidePopUp();
            } else {
                showPreviousTextAndHidePopUp(!_completionAccepted);
            }
        }
        
        private function onInputFieldKeyDown(event: KeyboardEvent) : void {        	            
            switch (event.keyCode) {
                case Keyboard.UP:
                case Keyboard.DOWN:
                case Keyboard.END:
                case Keyboard.HOME:
                case Keyboard.PAGE_UP:
                case Keyboard.PAGE_DOWN: 
                    list.focusListUponKeyboardNavigation(event);                                     			
                    break;                   
                case Keyboard.ENTER:
                    acceptCompletion();
                    break;
                case Keyboard.TAB:
                case Keyboard.ESCAPE:
                    showPreviousTextAndHidePopUp(!_completionAccepted);
                    break;
            }            
        }
        
        private function onListItemClick(event : HighlightItemListEvent) : void {            
            acceptCompletion();
            event.stopPropagation();
        }
        
        private function onMouseDownOutside(event:FlexMouseEvent) : void {            
            var mouseDownInsideComponent : Boolean = false;            
            var clickedObject : DisplayObjectContainer = event.relatedObject as DisplayObjectContainer;
                        
            while (!(clickedObject.parent is SystemManager)) {                
                if (clickedObject == this) {
                    mouseDownInsideComponent = true;
                    break;
                }
                
                clickedObject = clickedObject.parent;
            }
                        
            if (!mouseDownInsideComponent) {                
                showPreviousTextAndHidePopUp(!_completionAccepted);
            }
        }               
                                    
        private var _collection : ArrayCollection = new ArrayCollection();
    
        private var _completionAccepted : Boolean;
        
        private var _dataProviderChanged : Boolean;        
                
        private var _enteredText : String = "";
        
        private var _labelField : String;
        
        private var _labelFunction : Function;
        
        private var _previouslyDisplayedText : String = "";
        
        private var _searchMode : String = SearchModes.INFIX_SEARCH;
        
        private var _selectedItem : Object;
        
        private var _selectedItemChanged : Boolean;
        
        private var _prompt : String;
        
        private var _promptChanged : Boolean;
        
        private var _errorMessage : String = "No available options";
        
        private var _errorMessageChanged : Boolean;
        
        private var _enabledChanged : Boolean;
               
    }
		
}