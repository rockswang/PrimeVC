﻿package primevc.gui.layout;
 import primevc.core.geom.Box;
 import primevc.core.geom.constraints.ConstrainedRect;
 import primevc.core.geom.constraints.SizeConstraint;
 import primevc.core.IDisposable;
 import primevc.core.states.SimpleStateMachine;
 import primevc.gui.events.LayoutEvents;
 import primevc.gui.states.LayoutStates;


/**
 * ILayoutClient is the most basic layouttype there is. It contains the size
 * and position of the layout-target.
 * 
 * @since	mar 19, 2010
 * @author	Ruben Weijers
 */
interface ILayoutClient implements IDisposable
{
	/**
	 * Flags of properties that are changed
	 */
	public var changes (default, setChanges)				: Int;
	/**
	 * Flag indicating if the layout should be automaticly revalidated when a 
	 * property, such as height or width, is changed.
	 * 
	 * If the property is false, the target of the layout should call the 
	 * validate method before the layout is validated again. This could happen
	 * for example after an enterFrame event.
	 * 
	 * @default false
	 */
	public var validateOnPropertyChange						: Bool;
	
	
	/**
	 * Flag indicating if this client should be included within the layout
	 * @default	true
	 */
	public var includeInLayout(default, setIncludeInLayout)	: Bool;
	
	/**
	 * Layout-group to which this client belongs. By setting this property,
	 * the client can let the parent know when it's size or position has
	 * changed wich could result in revalidating the parents layout.
	 */
	public var parent (default, setParent)					: ILayoutGroup<Dynamic>;
	
	
	//
	// LAYOUT METHODS
	//

	/**
	 * Measure is called before validating the layout. In meausure, each 
	 * layout-object has a change to correct it's bounding-properties
	 * or measured size.
	 * 
	 * Measure is called when a layoutClient is invalidated and the movie
	 * has entered a new frame.
	 */
	public function measure ()					: Void;
	public function measureHorizontal ()		: Void;
	public function measureVertical ()			: Void;
	/**
	 * Method is called when a layout is invalidated and will validate again
	 * by calculating it's new dimensions or position.
	 */
	public function validate ()					: Void;
	/**
	 * This method is called when a property of a layoutclient is changed which
	 * would cause the layout the validate again.
	 */
	public function invalidate ( change:Int )	: Void;
	
	private function resetProperties ()			: Void;
	
	
	//
	// CONSTRAINT PROPERTIES
	//
	
	
	/**
	 * rules for the size (min, max)
	 */
	public var sizeConstraint		(default, setSizeConstraint)		: SizeConstraint;
	/**
	 * rules for sizing / positioning the layout with relation to the parent
	 */
	public var relative				(default, setRelative)				: RelativeLayout;
	
	/**
	 * @default	false
	 */
	public var maintainAspectRatio	(default, setAspectRatio)			: Bool;
	private var aspectRatio			(default, default)					: Float;
	
	
	//
	// EVENTS
	//
	
	public var events	(default, null)			: LayoutEvents;
	
	public var states	(default, null)			: SimpleStateMachine < LayoutStates >;
	
	
	
	//
	// SIZE PROPERTIES
	//
	
	/**
	 * Propertie will return the explicitWidth when it's set and otherwise the
	 * measuredWidth.
	 * Setting this property will set the explicitWidth.
	 */
	public var width (getWidth, setWidth)			: Int;
	/**
	 * Propertie will return the explicitHeight when it's set and otherwise the
	 * measuredHeight.
	 * Setting this property will set the explicitHeight.
	 */
	public var height (getHeight, setHeight)		: Int;
	
	/**
	 * Padding is the distance between the content of the layout and the rest
	 * of the elements. 
	 * 
	 * The property contains 4 values to define the padding for each side of 
	 * the layout.
	 * 
	 * The x&y properties contain the position of the content, the properties
	 * bottom and right contain the position including the padding.
	 * 
	 * For example.
	 * Layout:
	 * 		- width:	400
	 * 		- height:	300
	 * 		- x:		50
	 * 		- y			60
	 * 		- padding	{ 10, 10, 10, 10 }
	 * 
	 * The left, right, top and bottom properties should then be:
	 * 		- left:		50
	 * 		- top:		60
	 * 		- right:	470 (400 + 50 + 20)
	 * 		- bottom:	380 (300 + 60 + 20)
	 */
	public var padding (default, setPadding)	: Box;
	
	
	//
	// POSITION PROPERTIES
	//
	
	public var x		(default, setX)			: Int;
	public var y		(default, setY)			: Int;
	
	public var bounds	(default, null)			: ConstrainedRect;
}