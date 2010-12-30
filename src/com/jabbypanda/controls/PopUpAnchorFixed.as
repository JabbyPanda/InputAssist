package com.jabbypanda.controls
{
    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.display.StageDisplayState;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.utils.MatrixUtil;
    
    import spark.components.PopUpAnchor;
    
    use namespace mx_internal;
        
    public class PopUpAnchorFixed extends PopUpAnchor
    {
                
        public function PopUpAnchorFixed()
        {
            super();
        }
        
        override public function updatePopUpTransform():void
        {            
            var m:Matrix = MatrixUtil.getConcatenatedMatrix(this);
            
            // Set the dimensions explicitly because UIComponents always set themselves to their
            // measured / explicit dimensions if they are parented by the SystemManager. 
            if (popUp is UIComponent)
            {
                if (popUpWidthMatchesAnchorWidth) {
                    UIComponent(popUp).width = unscaledWidth;
                }
                
                if (popUpHeightMatchesAnchorHeight) {
                    UIComponent(popUp).height = unscaledHeight;
                }
                
            }
            else
            {
                var w:Number = popUpWidthMatchesAnchorWidth ? unscaledWidth : popUp.measuredWidth;
                var h:Number = popUpHeightMatchesAnchorHeight ? unscaledHeight : popUp.measuredHeight;
                popUp.setActualSize(w, h);
            }
            
            var popUpPoint:Point = calculatePopUpPosition();
            
            // the transformation doesn't take the fullScreenRect in to account
            // if we are in fulLScreen mode. This code will throw a RTE if run from inside of a sandbox. 
            try
            {
                var smStage:Stage = systemManager.stage;
                if (smStage && smStage.displayState != StageDisplayState.NORMAL && smStage.fullScreenSourceRect)
                {
                    popUpPoint.x += smStage.fullScreenSourceRect.x;
                    popUpPoint.y += smStage.fullScreenSourceRect.y;
                }
            }
            catch (e:Error)
            {
                // Ignore the RTE
            }
            
            if (!m)
                return;
            
            // Position the popUp. 
            m.tx = Math.round(popUpPoint.x);
            m.ty = Math.round(popUpPoint.y);
            if (popUp is UIComponent)
                UIComponent(popUp).setLayoutMatrix(m,false);
            else if (popUp is DisplayObject)
                DisplayObject(popUp).transform.matrix = m;            
            
            //super.updatePopUpTransform();
            
            // apply the color transformation, but restore alpha value of popup
            var oldAlpha:Number = DisplayObject(popUp).alpha;
            var tmpColorTransform:ColorTransform = $transform.concatenatedColorTransform;
            if (tmpColorTransform != null)
            {
                tmpColorTransform.alphaMultiplier = oldAlpha;
                tmpColorTransform.alphaOffset = 0;
            }
            DisplayObject(popUp).transform.colorTransform = tmpColorTransform;
        }                
    }
}