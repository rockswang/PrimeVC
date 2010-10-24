/*
 * Copyright (c) 2010, The PrimeVC Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE PRIMEVC PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE PRIMVC PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 *
 * Authors:
 *  Ruben Weijers	<ruben @ onlinetouch.nl>
 */
package primevc.gui.styling;

#if flash9
 import primevc.core.collections.DoubleFastCell;
 import primevc.core.collections.PriorityList;
 import primevc.core.dispatcher.Signal1;
 import primevc.core.dispatcher.Wire;
 import primevc.core.traits.IInvalidatable;
 import primevc.gui.traits.IStylable;
 import primevc.utils.FastArray;
  using primevc.utils.Bind;
  using primevc.utils.BitUtil;
  using primevc.utils.FastArray;
  using primevc.utils.TypeUtil;
  using Type;


private typedef Flags = StyleFlags;


/**
 * UIElementStyle contains all style objects that are used by one IUIElement.
 * It's a unique collection of id-selectors, styleName-selectors and 
 * element-selectors.
 * 
 * The UIElementStyle of an element has to be rebuild everytime the element is 
 * changing of parent.
 * 
 * @author Ruben Weijers
 * @creation-date Sep 22, 2010
 */
class UIElementStyle implements IUIElementStyle
{
	/**
	 * object on which the style applies
	 */
	public var target					(default, null)			: IStylable;
	/**
	 * cached classname (incl package) of target since target won't change.
	 */
	private var targetClassName			: String;
	
	private var addedBinding			: Wire <Dynamic>;
	private var removedBinding			: Wire <Dynamic>;
	private var styleNamesChangeBinding	: Wire <Dynamic>;
	private var idChangeBinding			: Wire <Dynamic>;
	
	public var styles					(default, null)			: PriorityList < StyleBlock >;
//	public var idStyle					(default, null)			: StyleBlock;
//	public var styleNameStyles			(default, null)			: FastArray < StyleBlock >;
//	public var elementStyle				(default, null)			: StyleBlock;
	/**
	 * List with all state-style objects for the target
	 */
//	public var currentStatesStyle		(default, null)			: FastArray < StyleBlock >;
	
	
	/**
	 * Bitflag-collection with all properties that are set in the styles of 
	 * the target,
	 */
	public var filledProperties			(default, null)	: UInt;
	/**
	 * Cached bitflag with the properties of the id-style (if there is any)
	 */
//	public var idStyleProperties		(default, null)	: UInt;
	/**
	 * Cached bitflag with the properties of every style-name-style (if there 
	 * are any)
	 */
//	public var styleNameStyleProperties	(default, null)	: UInt;
	/**
	 * Cached bitflag with the properties of the element-style (if there is any)
	 */
//	public var elementStyleProperties	(default, null)	: UInt;
	/**
	 * Cached bitflag with the properties of all the current states
	 */
//	public var stateStyleProperties		(default, null)	: UInt;
	
	
	/**
	 * Signal which is dispatched when one of the style objects is changed. 
	 * The first parameter of signal will be a bit-flag conttaining all the 
	 * properties that are changed.
	 */
	public var change					(default, null)	: Signal1 < UInt >;
	/**
	 * Current css-states of the object.
	 */
	public var currentStates			(default, null)	: FastArray < StyleState >;
	
	/**
	 * Flag indicating wether the styles of the target are searched or not (by 
	 * calling updateStyles method). If the clearStyles method is called, this
	 * flag is set to false again.
	 * 
	 * Property is used to check if some style-updating methods should send a 
	 * change event or not.
	 */
	private var stylesAreSearched		: Bool;
	
	public var effects					(default, null)	: EffectsCollection;
	public var boxFilters				(default, null)	: FiltersCollection;
	public var font						(default, null)	: FontCollection;
	public var layout					(default, null)	: LayoutCollection;
	/**
	 * Proxy object to loop through all available states in this object.
	 */
	public var states					(default, null)	: StatesCollection;
	
	
	
	
	public function new (target:IStylable)
	{
	//	styleNameStyles		= FastArrayUtil.create();
		currentStates		= FastArrayUtil.create();
		styles				= new PriorityList < StyleBlock > ();
		
		this.target			= target;
		targetClassName		= target.getClass().getClassName();
		change				= new Signal1();
		
		stylesAreSearched	= false;
		filledProperties	= 0;
		
		styleNamesChangeBinding = updateStyleNameStyles	.on( target.styleClasses.change, this );
		idChangeBinding			= updateIdStyle			.on( target.id.change, this );
		
		styleNamesChangeBinding.disable();
		idChangeBinding.disable();
		
		init();
	}
	
	
	private function init ()
	{
		addedBinding	= updateStyles	.on( target.displayEvents.addedToStage, this );
		removedBinding	= clearStyles	.on( target.displayEvents.removedFromStage, this );
		removedBinding.disable();
	}
	
	
	public function dispose ()
	{
		if (target == null)
			return;
		
		if (addedBinding != null)				addedBinding.dispose();
		if (removedBinding != null)				removedBinding.dispose();
		if (styleNamesChangeBinding != null)	styleNamesChangeBinding.dispose();
		if (idChangeBinding != null)			idChangeBinding.dispose();
		
		font.dispose();
		layout.dispose();
		effects.dispose();
		boxFilters.dispose();
		states.dispose();
		
		change.dispose();
		clearStyles();
		currentStates.removeAll();
		
		addedBinding	= removedBinding = styleNamesChangeBinding = idChangeBinding = null;
		currentStates	= null;
		styles			= null;
		targetClassName	= null;
		target			= null;
		change			= null;
		layout			= null;
		boxFilters		= null;
		effects			= null;
		states			= null;
		font			= null;
	}
	
	
	public function findStyle ( name:String, type:StyleDeclarationType, ?exclude:StyleBlock ) : StyleBlock
	{
		var style : StyleBlock = null;
		
		for (styleObj in styles)
		{
			style = styleObj.findStyle( name, type, exclude );
			if (style != null)
				break;
		}
		
		if (style == null)
		{
			//look in parent.. (prevent infinte loops with parentStyle != this)
			var parentStyle = getParentStyle();
			if (parentStyle != this)
				style = parentStyle.findStyle( name, type, exclude );
		}
		return style;
	}
	
	
	/**
	 * Method will remove all the styles defined for the target and disable
	 * the style-change-listeners.
	 */
	private function clearStyles () : Void
	{
		styleNamesChangeBinding.disable();
		idChangeBinding.disable();
		removedBinding.disable();
		addedBinding.enable();
		
		stylesAreSearched	= false;
		var changed			= filledProperties;
		
		//remove styles and their listeners
		removeStylesWithPriority( StyleDeclarationType.idState.enumIndex() );
		removeStylesWithPriority( StyleDeclarationType.styleNameState.enumIndex() );
		removeStylesWithPriority( StyleDeclarationType.elementState.enumIndex() );
		removeStylesWithPriority( StyleDeclarationType.id.enumIndex() );
		removeStylesWithPriority( StyleDeclarationType.styleName.enumIndex() );
		removeStylesWithPriority( StyleDeclarationType.element.enumIndex() );
		
		Assert.that( styles.length == 0 );
		
		filledProperties = 0;
		broadcastChanges( changed );
	}
	
	
	/**
	 * Method will fill the styles-list for this object and enable the 
	 * style-change listeners.
	 */
	public function updateStyles () : Void
	{
		styleNamesChangeBinding.enable();
		idChangeBinding.enable();
		removedBinding.enable();
		addedBinding.disable();
		
		if (effects == null)		effects		= new EffectsCollection(this);
		if (boxFilters == null)		boxFilters	= new FiltersCollection(this, FilterCollectionType.box);
		if (font == null)			font		= new FontCollection(this);
		if (layout == null)			layout		= new LayoutCollection(this);
		if (states == null)			states		= new StatesCollection(this);
		
		stylesAreSearched = false;
		filledProperties	= 0;
		
		//update styles.. start with the lowest priorities
		updateElementStyle();
		updateStyleNameStyles();
		updateIdStyle();
		updateStatesStyle();		//set de styles for any states that are already set
		
		//update filled-properties flag
		stylesAreSearched = true;
		broadcastChanges();
	}
	
	
	/**
	 * Method to loop through all available style objects to find all the 
	 * properties that are set for the target.
	 */
	public function broadcastChanges (changedProperties:Int = -1) : Int
	{
		if (!stylesAreSearched)
			return changedProperties;
		
		updateFilledPropertiesFlag();
		
		if (changedProperties == -1)
			changedProperties = filledProperties; //filledProperties.set( newProps );
		
		trace(target+".broadcastChanges "+readProperties(changedProperties));
		
		//update state properties
		if (changedProperties.has( Flags.STATES ))
		{
			var statesChangedProps	= states.filledProperties;
			states.updateFilledPropertiesFlag();
			statesChangedProps		= statesChangedProps.set( states.filledProperties );
			
			if (statesChangedProps > 0)
			{
				var tmp				= stylesAreSearched;
				stylesAreSearched	= false;
				changedProperties	= changedProperties.set( updateStatesStyle() );
				stylesAreSearched	= tmp;
				states.change.send( statesChangedProps );
			}
		}
		
		
		//update layout properties
		if (changedProperties.has( Flags.LAYOUT ))
		{
			var layoutChangedProps	= layout.filledProperties;
			layout.updateFilledPropertiesFlag();
			layoutChangedProps		= layoutChangedProps.set( layout.filledProperties );
			
			if (layoutChangedProps > 0)
				layout.change.send( layoutChangedProps );
		}
		
		
		//update effect properties
		if (changedProperties.has( Flags.EFFECTS ))
		{
			var effectsChangedProps	= effects.filledProperties;
			effects.updateFilledPropertiesFlag();
			effectsChangedProps		= effectsChangedProps.set( effects.filledProperties );
			
			if (effectsChangedProps > 0)
				effects.change.send( effectsChangedProps );
		}
		
		
		//update filter properties
		if (changedProperties.has( Flags.BOX_FILTERS ))
		{
			var filtersChangedProps	= boxFilters.filledProperties;
			boxFilters.updateFilledPropertiesFlag;
			filtersChangedProps		= filtersChangedProps.set( boxFilters.filledProperties );
			
			if (filtersChangedProps > 0)
				boxFilters.change.send( filtersChangedProps );
		}
		
		if (changedProperties > 0)
			change.send( changedProperties );
		
		return changedProperties;
	}
	
	
	public function addStyle (style:StyleBlock) : UInt
	{
#if debug
		Assert.notNull( styles );
		Assert.notNull( style );
		Assert.that( !styles.has(style) );
#end
		var styleCell	= styles.add( style );
		var changes		= 0;
		
		if (styleCell != null)
		{
			//
			// ADD LISTENERS
			//
			style.listeners.add( this );
			
			if (style.has( Flags.LAYOUT ))		style.layout.listeners.add( layout );
			if (style.has( Flags.EFFECTS ))		style.effects.listeners.add( effects );
			if (style.has( Flags.BOX_FILTERS ))	style.boxFilters.listeners.add( boxFilters );
			if (style.has( Flags.STATES ))		style.states.listeners.add( states );
			
			// FIND CHANGES
			changes				= getUsablePropertiesOf( styleCell );
			filledProperties	= filledProperties.set( changes );
			
		//	trace(target+".addedStyle "+readProperties( changes ));
		}
		return changes;
	}
	
	
	
	/**
	 * Method will remove the given stylecell from the the list with styles.
	 * This includes removing the change-listeners. It will return a flag with
	 * style-properties that are changed after removing the style.
	 */
	public function removeStyleCell (styleCell:DoubleFastCell < StyleBlock >) : UInt
	{
#if debug
		Assert.notNull( styleCell );
#else
		if (styleCell == null)
			return 0;
#end
		
		var style	= styleCell.data;
		var changes	= getUsablePropertiesOf( styleCell );
		
		styles.removeCell( styleCell );
		
		//
		// REMOVE LISTENERS
		//
		style.listeners.remove( this );
		
		if (style.has( Flags.LAYOUT ))		style.layout.listeners.remove( layout );
		if (style.has( Flags.EFFECTS ))		style.effects.listeners.remove( effects );
		if (style.has( Flags.BOX_FILTERS ))	style.boxFilters.listeners.remove( boxFilters );
		if (style.has( Flags.STATES ))		style.states.listeners.remove( states );
		
	//	trace(target+".removedStyle "+readProperties( changes ));
		return changes;
	}
	
	
	/**
	 * Method will remove all the styles with the given priority and will return
	 * an UInt flag with all the properties that where set in the removed styles.
	 */
	private function removeStylesWithPriority (priority:Int) : UInt
	{	
		var changes = 0;
		var styleCell:DoubleFastCell < StyleBlock > = null;
		
		while (null != (styleCell = styles.getCellWithPriority( priority )))
			changes = changes.set( removeStyleCell( styleCell ) );
		
		return changes;
	}
	
	
	
	
	//
	// STYLE UPDATE METHODS
	//
	
	
	/**
	 * Method will find the styles for every defined state
	 */
	private function updateStatesStyle () : UInt
	{
		var changes = removeStylesWithPriority( StyleDeclarationType.idState.enumIndex() );
		var changes = removeStylesWithPriority( StyleDeclarationType.styleNameState.enumIndex() );
		var changes = removeStylesWithPriority( StyleDeclarationType.elementState.enumIndex() );
		
		if (currentStates.length > 0)
		{	
			//search the style-objects of each state
			for ( state in currentStates )
				changes = changes.set( state.setStyles() );
		}
		
		return broadcastChanges( changes );
	}
	
	
	private function updateIdStyle () : UInt
	{
		var changes = removeStylesWithPriority( StyleDeclarationType.id.enumIndex() );
		
		if (target.id.value != null && target.id.value != "")
		{
			var parentStyle	= getParentStyle();
			var idStyle		= parentStyle.findStyle( target.id.value, StyleDeclarationType.id );
			
			if (idStyle != null)
				changes = changes.set( addStyle( idStyle ) );
		}
		
		return broadcastChanges( changes );
	}
	
	
	private function updateStyleNameStyles () : UInt
	{
		var changes = removeStylesWithPriority( StyleDeclarationType.styleName.enumIndex() );
		
		if (target.styleClasses.value != null && target.styleClasses.value != "")
		{	
			//search the style-object of each stylename
			var parentStyle	= getParentStyle();
			var styleNames	= target.styleClasses.value.split(",");
			
			for ( styleName in styleNames )
			{
				var style = parentStyle.findStyle( styleName, StyleDeclarationType.styleName );
				if (style != null)
					changes = changes.set( addStyle( style ) );
			}
		}
		
		return broadcastChanges( changes );
	}
	
	
	private function updateElementStyle () : UInt
	{
		var changes		= removeStylesWithPriority( StyleDeclarationType.element.enumIndex() );
		var parentStyle = getParentStyle();
		
		var style:StyleBlock	= null;
		var parentClass				= target.getClass();
		
		//search for the first element style that is defined for this object or one of it's super classes
		while (parentClass != null && style == null)
		{
			style		= parentStyle.findStyle( parentClass.getClassName(), StyleDeclarationType.element );
			parentClass	= cast parentClass.getSuperClass();
		}
		
		if (style != null)
			changes = changes.set( addStyle( style ));
		
		return broadcastChanges( changes );
	}
	
	
	//
	// END UPDATE STYLE METHODS
	//
	
	
	
	
	
	private inline function getParentStyle () : UIElementStyle
	{
		Assert.notNull( target.container );
		Assert.that( target.container.is( IStylable ) );
		Assert.notNull( target.container.as( IStylable ).style );
		return target.container.as( IStylable ).style;
	}
	
	
	/**
	 * Method returns all the properties that are defined in the given cell-style
	 * and which are not defined in the styles with higher priority.
	 * 
	 * @example
	 * 		idStyle props:			background, border
	 * 		elementStyle props:		font, background, border
	 * 
	 * Usabable props of elementStyle: font
	 */ 
	public function getUsablePropertiesOf ( styleCell:DoubleFastCell < StyleBlock >, properties:Int = -1 ) : UInt
	{
		Assert.notNull( styleCell );
		if (properties == -1)
			properties = styleCell.data.allFilledProperties;
		
		//loop through all cell's with higher priority
		while (null != (styleCell = styleCell.prev) && properties > 0)
			properties = properties.unset( styleCell.data.allFilledProperties );
		
		return properties;
	}
	
	
	/**
	 * Method returns a UInt with flags of every property that is set. 
	 * Important: The method won't set the UInt as value for filledProperties.
	 */
	private function updateFilledPropertiesFlag () : Void
	{
		filledProperties = 0;
		for (style in styles)
		{
			filledProperties = filledProperties.set( style.allFilledProperties );
			if (filledProperties == Flags.ALL_PROPERTIES)
				break;
		}
	}
	
	
	public function getChildren () : StyleChildren
	{
		var children : StyleChildren = null;
		for (style in styles)
		{
			if (!style.hasChildren())
			{
				children = style.children;
				break;
			}
		}
		return children;
	}
	
	
	
	//
	// STATE SUPPORT
	//
	
	
	public function createState ()
	{
		var state = new StyleState( this );
		currentStates.push( state );
		return state;
	}
	
	
	public function removeState (state:StyleState)
	{
		currentStates.remove( state );
		state.dispose();
	}
	
	
/*	private inline function setState (v:String) : String
	{
	//	trace(target + ".setStyleState "+state+" => "+v);
		return state = v;
	}*/
	
	
	//
	// IINVALIDATELIST METHODS
	//
	
	public function invalidateCall (changes:UInt, sender:IInvalidatable)
	{
		var senderCell	= styles.getCellForItem( cast sender );
		Assert.notNull(senderCell);
		changes			= getUsablePropertiesOf( senderCell, changes );
		
		trace("\tchanged properties "+StyleFlags.readProperties(changes));
		
		if (changes > 0)
			broadcastChanges( changes );
	}
	
	
	//
	// ITERATABLE METHODS
	//
	
	public function iterator () : Iterator < StyleBlock >
	{
		return styles.iterator();
	}
	
	
#if debug
	public function readProperties (flags:Int = -1) : String
	{
		if (flags == -1)
			flags = filledProperties;
		
		return StyleFlags.readProperties(flags);
	}
	
	
	public function readStates () : String
	{
		var r = [];
		
		for (state in currentStates)
			r.push( state );
		
		return r.join(", ");
	}
#end
}




/*
class UIElementStyleIterator
{
	private var target				: UIElementStyle;
	private var currentStyleObj		: StyleBlock;
	
	/**
	 * The StyleDeclarationType of the last used StyleBlock
	 */
//	private var currentType			: StyleDeclarationType;
	
	/**
	 * Keeps track of the last position of the currentStyleObj in the 
	 * target.styleNameStyles list or the target.currentStates list.
	 */
//	private var currentListPos		: Int;
	
	
	
/*	
	public function new (target:StyleSheet)
	{
		this.target			= target;
		currentType			= isTargetEmpty() ? null : specific;
		styleNamesListPos	= 0;
	}
	
	
	public function next () : StyleBlock
	{
		switch (currentType)
		{
			//there is no next object
			case element:
				currentStyleObj = null;
				currentType		= null;
			
			
			//element will be next if this is the last styleName style
			case styleName:
				if (currentListPos >= target.styleNameStyles.length) {
					currentStyleObj = target.elementStyle;
					currentType		= element;
				}
				else
					currentStyleObj	= target.styleNameStyles[ currentListPos++ ];
			
			
			case id:
				currentType = styleName;
			
			
			
			default:
				if (currentListPos >= target.currentStatesStyle.length) {
					currentListPos	= 0;
					currentStyleObj = target.idStyle;
					currentType		= id;
				}
				else {
					currentStyleObj	= target.currentStatesStyle[ currentListPos++ ];
					currentType		= state;
				}
		}
		
		
		if (currentStyleObj == null && hasNext())
			next();
		
		return currentStyleObj;
	}
	
	
	public function hasNext () : Bool {
		return currentType != null && currentType != element;
	}
	
	
	private function isTargetEmpty () : Bool {
		return target.idStyle == null && target.elementStyle == null && target.styleNameStyles.length == 0 && target.currentStates.length == 0;
	}
}
*/
#else

class UIElementStyle {}

#end