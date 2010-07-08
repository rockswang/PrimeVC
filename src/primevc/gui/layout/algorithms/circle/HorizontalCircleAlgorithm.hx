package primevc.gui.layout.algorithms.circle;
 import primevc.gui.layout.AdvancedLayoutClient;
 import primevc.gui.layout.algorithms.directions.Horizontal;
 import primevc.gui.layout.algorithms.IHorizontalAlgorithm;
 import primevc.gui.layout.algorithms.LayoutAlgorithmBase;
 import primevc.gui.layout.LayoutFlags;
 import primevc.utils.IntMath;
  using primevc.utils.BitUtil;
  using primevc.utils.IntMath;
  using primevc.utils.IntUtil;
  using primevc.utils.TypeUtil;
 

/**
 * Algorithm to place layoutClients in a horizontal circle
 * 
 * @creation-date	Jul 7, 2010
 * @author			Ruben Weijers
 */
class HorizontalCircleAlgorithm extends LayoutAlgorithmBase, implements IHorizontalAlgorithm
{
	public var direction (default, setDirection)	: Horizontal;
	
	
	public function new ( ?direction )
	{
		super();
		this.direction = direction == null ? Horizontal.left : direction;
	}
	
	
	
	//
	// GETTERS / SETTERS
	//
	
	/**
	 * Setter for direction property. Method will change the apply method based
	 * on the given direction. After that it will dispatch a 'directionChanged'
	 * signal.
	 */
	private inline function setDirection (v:Horizontal)
	{
		if (v != direction) {
			direction = v;
			switch (v) {
				case Horizontal.left:		apply = applyLeftToRight;
				case Horizontal.center:		apply = applyCentered;
				case Horizontal.right:		apply = applyRightToLeft;
			}
			algorithmChanged.send();
		}
		return v;
	}
	
	
	
	//
	// LAYOUT
	//
	
	/**
	 * Method indicating if the size is invalidated or not.
	 */
	public inline function isInvalid (changes:Int)	: Bool
	{
		return changes.has( LayoutFlags.WIDTH_CHANGED ) && childWidth.notSet();
	}
	
	
	public inline function measure ()
	{
		if (group.children.length == 0)
			return;
		
		measureHorizontal();
		measureVertical();
	}
	
	
	public inline function measureVertical ()
	{
		var height:Int = childHeight;
		
		if (childHeight.notSet())
		{
			for (child in group.children)
				if (child.bounds.height > height)
					height = child.bounds.height;
		}
		
		setGroupHeight(height);
	}
	
	
	/**
	 * Method will return the total width of all the children.
	 */
	public inline function measureHorizontal ()
	{
		var width:Int = 0;
		
		if (childWidth.notSet())
		{
			for (child in group.children)
				width += child.bounds.width;
		}
		else
		{
			width = childWidth * (group.children.length.divCeil(2) + 1);
		}
		
		setGroupWidth(width);
	}
	
	
	private inline function applyCircle (startRadians)
	{
		if (group.children.length > 0)
		{
			var childAngle		= (360 / group.children.length) * (Math.PI / 180);		//in radians
			var angle:Float		= 0;
			var radius:Int		= Std.int( group.width * .5 );
			var i:Int			= 0;
			var pos:Int			= 0;
			var start			= getLeftStartValue() + radius;
			
			for (child in group.children) {
				angle	= (childAngle * i);
				pos		= start + Std.int( radius * Math.cos(angle + startRadians) );
				
				trace("PI: " + Math.PI + ", angle " + angle+ "; childAngle: "+childAngle+"; start: "+startRadians);
				var halfChildWidth	= Std.int( child.bounds.width * .5 );
				var doCenter		= pos.isWithin( radius - halfChildWidth, radius + halfChildWidth );
				
				if		(doCenter)				child.bounds.centerX	= pos;
				else if	(pos > radius)			child.bounds.right		= pos;
				else							child.bounds.left		= pos;
				i++;
			}
		}
	}
	
	
	private inline function applyLeftToRight ()	: Void		{ applyCircle( 0 ); }				//   0 degrees
	private inline function applyCentered ()	: Void		{ applyCircle( -Math.PI / 2 ); }	//- 90 degrees
	private inline function applyRightToLeft () : Void		{ applyCircle( -Math.PI ); }		//-180 degrees
	
	
	
	
	//
	// START VALUES
	//
	
	private inline function getLeftStartValue ()	: Int
	{
		var left:Int = 0;
		if (group.padding != null)
			left = group.padding.left;
		
		return left;
	}
	
	
	private inline function getRightStartValue ()	: Int
	{
		var w = group.width;
		if (group.is(AdvancedLayoutClient))
			w = IntMath.max(group.as(AdvancedLayoutClient).measuredWidth, w);
		
		if (group.padding != null)
			w += group.padding.left; // + group.padding.right;
		return w;
	}
	
	
#if debug
	public function toString ()
	{
		var start	= direction == Horizontal.left ? "left" : "right";
		var end		= direction == Horizontal.left ? "right" : "left";
		return "circle.hor " + start + " -> " + end;
	}
#end
}