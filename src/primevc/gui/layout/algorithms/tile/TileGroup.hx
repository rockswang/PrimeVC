package primevc.gui.layout.algorithms.tile;
 import primevc.core.collections.IList;
 import primevc.core.collections.ArrayList;
 import primevc.core.Number;
 import primevc.gui.layout.algorithms.ILayoutAlgorithm;
 import primevc.gui.layout.ILayoutGroup;
 import primevc.gui.layout.LayoutFlags;
 import primevc.gui.layout.LayoutClient;
 import primevc.gui.states.LayoutStates;
  using primevc.utils.Bind;
  using primevc.utils.BitUtil;
  using primevc.utils.IntUtil;
  using primevc.utils.TypeUtil;
 

/**
 * Group of tiles within a tile layout. Behaves as a LayoutGroup but without 
 * the properties of AdvancedLayoutGroup.
 * 
 * @creation-date	Jun 30, 2010
 * @author			Ruben Weijers
 */
class TileGroup <ChildType:LayoutClient> extends LayoutClient, implements ILayoutGroup <ChildType>
{
	public var algorithm	(default, setAlgorithm)			: ILayoutAlgorithm;
	public var children		(default, null)					: IList<ChildType>;
	
	
	public function new( list:IList<ChildType> = null )
	{
		super();
		children	= list == null ? new ArrayList<ChildType>() : list;
		
		childAddedHandler.on( children.events.added, this );
		childRemovedHandler.on( children.events.removed, this );
		
		invalidateChildList.on( children.events.added, this );
		invalidateChildList.on( children.events.moved, this );
		invalidateChildList.on( children.events.removed, this );
		
		setHorChildPosition.on( bounds.props.left.change, this );
		setVerChildPosition.on( bounds.props.top.change, this );
	}
	
	
	override public function dispose ()
	{
		children.dispose();
		children	= null;
		algorithm	= null;
		
		super.dispose();
	}
	
	
	public function iterator () {
		return children.iterator();
	}
	
	
	public inline function childInvalidated (childChanges:Int) : Bool
	{
		var r = false;
		if (childChanges.has(LayoutFlags.LIST_CHANGED) || (algorithm != null && algorithm.isInvalid(childChanges))) {
			invalidate( LayoutFlags.CHILDREN_INVALIDATED );
			r = true;
		}
		return r;
	}
	
	
	override public function measure () 
	{
		if (changes == 0)
			return;
		
		measureHorizontal();
		measureVertical();
	}
	
	
	override public function measureHorizontal ()
	{
		if (changes == 0)
			return;
		
		Assert.that(algorithm != null);
		
		for (child in children) {
			trace("measure hor " + child + " - "+child.readChanges() + " - measure? "+childInvalidated(child.changes));
			if (childInvalidated(child.changes))
				child.measureHorizontal();
		}
		
		algorithm.group = cast this;
		algorithm.measureHorizontal();
		super.measureHorizontal();
	}
	
	
	override public function measureVertical ()
	{
		if (changes == 0)
			return;
		
		Assert.that(algorithm != null);
		
		for (child in children)
			if (childInvalidated(child.changes))
				child.measureVertical();
		
		algorithm.group = cast this;
		algorithm.measureVertical();
		super.measureVertical();
	}
	
	
	override public function validate ()
	{
		if (changes == 0)
			return;
		
		algorithm.group = cast this;
		algorithm.apply();
		trace("validated " + readChanges());
		changes = 0;
	}
	
	
	private function setHorChildPosition () {
		for (child in children)
			child.bounds.left = bounds.left;
	}
	
	
	private function setVerChildPosition () {
		for (child in children)
			child.bounds.top = bounds.top;
	}
	
	
	
	//
	// GETTERS / SETTERS
	//
	
	private inline function setAlgorithm (v:ILayoutAlgorithm)
	{
		if (v != algorithm)
		{
			if (algorithm != null) {
				algorithm.algorithmChanged.unbind(this);
				algorithm.group = null;
			}
			
			algorithm = v;
			invalidate( LayoutFlags.ALGORITHM_CHANGED );
			
			if (algorithm != null) {
				algorithmChangedHandler.on( algorithm.algorithmChanged, this );
				algorithm.group = cast this;
			}
		}
		return v;
	}
	
	
	
	
	//
	// EVENT HANDLERS
	//
	
	private function algorithmChangedHandler ()							{ invalidate( LayoutFlags.ALGORITHM_CHANGED ); }
	private function invalidateChildList ()								{ invalidate( LayoutFlags.LIST_CHANGED ); }
	private function childRemovedHandler (child:ChildType, pos:Int)		{ child.parent = null; }
	
	private function childAddedHandler (child:ChildType, pos:Int)
	{
		child.parent = this;
		if (bounds.left != 0)	child.bounds.left	= bounds.left;
		if (bounds.top != 0)	child.bounds.top	= bounds.top;
	}
	
	
#if debug
	override public function toString() { return "TileGroup"; }
#end
}