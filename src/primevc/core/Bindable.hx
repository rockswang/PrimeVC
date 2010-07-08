package primevc.core;
 import primevc.core.IDisposable;
 import primevc.core.dispatcher.Signal1;
 import haxe.FastList;
  using primevc.utils.Bind;

/**
 * Class to keep a value automatically updated.
 * 
 * You can trigger another bindable to update by doing:
 * 	
 * 		var a = new Bindable <Int> (5);
 * 		var b = new Bindable <Int> (6);
 * 		a.bind(b);		//a will be 6 now
 * 		b.value = 8;	//a will be 8 now
 * 	
 * You can also create a two way binding by doing:
 * 		a.pair(b);
 * 	
 * Which is effictively the same as doing:
 * 		a.bind(b);
 * 		b.bind(a);  	//will not create an infinte loop ;-)
 * 
 * 
 * You can trigger a method when the property is changed:
 * 		
 * 		using primevc.utils.BindUtil;
 * 
 * 		function updateLabel (newLabel:String) : Void {
 * 			textField.text = newLabel;
 * 		}
 * 		
 * 		var a = new Bindable <String> ("aap");
 * 		updateLabel.on( a.change, this );
 * 		
 * 		a.value = "2 apen";		//textField.text will also be changed now
 * 		
 * 
 * The 'change' event will be dispatched after 'this.value' changes.
 * 
 * @creation-date	Jun 18, 2010
 * @author			Ruben Weijers, Danny Wilson
 */
class Bindable <DataType> implements IBindable<DataType>, implements haxe.rtti.Generic, implements primevc.core.IDisposable
{
	public var value	(default, setValue)	: DataType;
	
	/** 
	 * Dispatched just before "value" is set to a new value.
	 * Signal argument: The new value.
	 */
	public var change	(default, null)	: Signal1<DataType>;
	
	/**
	 * Keeps track of which Bindables update this.value
	 */
	private var boundTo : FastList<IBindableReadonly<DataType>>;
	/**
	 * Keeps track of which Bindables should be updated when this.value changes.
	 */
	private var writeTo : FastList<IBindable<DataType>>;
	
	public function new( val:DataType )
	{
		change = new Signal1();
		value  = val;
	}
	
	public function dispose ()
	{
		if (change == null) return; // already disposed
		
		if (boundTo != null) {
		 	// Dispose of all binding connections
			while (!boundTo.isEmpty()) boundTo.pop().unbind(this);
			boundTo = null;
		}
		if (writeTo != null) {
		 	// Dispose of all binding connections
			while (!writeTo.isEmpty()) writeTo.pop().unbind(this);
			writeTo = null;
		}
		
		change.dispose();
		change = null;
		
		(untyped this).value = null; // Int can't be set to null, so we trick it with untyped
	}
	
#if debug
	public function isBoundTo(otherBindable)
	{
		if (boundTo != null) for (b in boundTo) if (b == otherBindable) return true;
		return false;
	}
#end
	
	
	private function setValue (newValue:DataType) : DataType
	{
		if (value != newValue)
		{
			value = newValue;			//first set the value -> will possibly trigger an infinite loop otherwise
			change.send( newValue );
		//	value = newValue;
			BindableTools.dispatchValueToBound(writeTo, newValue);
		}
		
		return newValue;
	}
	
	/**
	 * Makes sure this.value is (and remains) equal
	 * to otherBindable's value.
	 *	
	 * In other words: 
	 * - update this when otherBindable.value changes
	 */
	public function bind (otherBindable:IBindableReadonly<DataType>)
	{
		Assert.that(otherBindable != null);
		Assert.that(otherBindable != this);
		
		registerBoundTo(otherBindable);
		untyped otherBindable.keepUpdated(this);
	}
	
	private inline function registerBoundTo(otherBindable)
	{
		if (boundTo == null)
			boundTo = new FastList<IBindableReadonly<DataType>>();
		
		addToBoundList(boundTo, otherBindable);
	}
	
	private inline function addToBoundList<T>(list:FastList<T>, otherBindable:T)
	{
		Assert.that(list != null);
		
		// Only bind if not already bound.
		var n = list.head;
		while (n != null)
		 	if (n.elt == otherBindable) { list = null; break; } // already bound, skip add()
			else n = n.next;
		
		if (list != null)
			list.add(otherBindable);
	}
	
	/**
	 * @see IBindableReadonly
	 */
	private function keepUpdated (otherBindable:IBindable<DataType>)
	{
		Assert.that(otherBindable != null);
		Assert.that(otherBindable != this);
		
		otherBindable.value = this.value;
		untyped otherBindable.registerBoundTo(this);
		
		if (writeTo == null)
			writeTo = new FastList<IBindable<DataType>>();
		
		addToBoundList(writeTo, otherBindable);
	}
	
	/** 
	 * Makes sure this Bindable and otherBindable always have the same value.
	 * 
	 * In other words: 
	 * - update this when otherBindable.value changes
	 * - update otherBindable when this.value changes
	 */
	public function pair (otherBindable:IBindable<DataType>)
	{
		untyped otherBindable.keepUpdated(this);
		keepUpdated(otherBindable);
	}
	
	/**
	 * @see IBindableReadonly
	 */
	public function unbind (otherBindable:IBindableReadonly<DataType>)
	{
		Assert.that(otherBindable != null);
		Assert.that(otherBindable != this);
	
	// TODO: Optimally this should only trace twice, not 3 times.
	//	trace("unbind");
	
		
		var removed = false;
		if (boundTo != null)
		 	removed = this.boundTo.remove(otherBindable);
		if (writeTo != null)
		 	removed = this.writeTo.remove(cast otherBindable) || removed;
		if (removed)
			otherBindable.unbind(this);
		
		return removed;
	}
}

class BindableTools
{
	/**
	 * Propagate a value to Bindables in the given FastList.
	 */
	public static inline function dispatchValueToBound<T> (list:FastList<IBindable<T>>, newValue:T)
	{
		if (list != null)
		{
			var n = list.head;
			while (n != null) {
				n.elt.value = newValue;
				n = n.next;
			}
		}
	}
}