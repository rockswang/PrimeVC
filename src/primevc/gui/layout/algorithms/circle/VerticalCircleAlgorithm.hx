package primevc.gui.layout.algorithms.circle;
 import primevc.gui.layout.AdvancedLayoutClient;
 import primevc.gui.layout.algorithms.directions.Vertical;
 import primevc.gui.layout.algorithms.IVerticalAlgorithm;
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
class VerticalCircleAlgorithm extends LayoutAlgorithmBase, implements IVerticalAlgorithm
{
	public var direction	(default, setDirection)		: Vertical;
	
	
	public function new ( ?direction )
	{
		super();
		this.direction = direction == null ? Vertical.top : direction;
	}
	
	
	
	//
	// GETTERS / SETTERS
	//
	
	/**
	 * Setter for direction property. Method will change the apply method based
	 * on the given direction. After that it will dispatch a 'directionChanged'
	 * signal.
	 */
	private inline function setDirection (v) {
		if (v != direction) {
			direction = v;
			switch (v) {
				case Vertical.top:		apply = applyTopToBottom;
				case Vertical.center:	apply = applyCentered;
				case Vertical.bottom:	apply = applyBottomToTop;
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
		return changes.has( LayoutFlags.HEIGHT_CHANGED ) && childHeight.notSet();
	}
	
	
	public inline function measure ()
	{
		if (group.children.length == 0)
			return;
		
		measureHorizontal();
		measureVertical();
	}
	
	
	public inline function measureHorizontal ()
	{
		var width:Int = childWidth;
		
		if (childWidth.notSet())
		{
			for (child in group.children)
				if (child.bounds.width > width)
					width = child.bounds.width;
		}
		
		setGroupWidth(width);
	}
	
	
	public inline function measureVertical ()
	{
		var height:Int = 0;
		
		if (childHeight.notSet())
		{
			for (child in group.children)
				height += child.bounds.height;
		}
		else
		{
			height = childHeight * (group.children.length.divCeil(2) + 1);
		}
		
		setGroupHeight(height);
	}
	
	
	private inline function applyCircle (startRadians)
	{
		if (group.children.length > 0)
		{
			var childAngle		= (360 / group.children.length) * (Math.PI / 180);		//in radians
			var angle:Float		= 0;
			var radius:Int		= Std.int( group.height * .5 );
			var i:Int			= 0;
			var pos:Int			= 0;
			var start			= getTopStartValue() + radius;
			
			for (child in group.children) {
				angle	= (childAngle * i);
				pos		= start + Std.int( radius * Math.sin(angle + startRadians) );
				
				trace("pos: " + pos + " - halfH: " + radius + " - PI: " + Math.PI + ", angle " + angle+ "; childAngle: "+childAngle+"; start: "+startRadians);
				var halfChildHeight	= Std.int( child.bounds.height * .5 );
				var doCenter		= pos.isWithin( radius - halfChildHeight, radius + halfChildHeight );
				
				if		(doCenter)				child.bounds.centerY	= pos;
				else if	(pos > radius)			child.bounds.bottom		= pos;
				else							child.bounds.top		= pos;
				i++;
			}
		}
	}
	
	
	private inline function applyTopToBottom ()	: Void		{ applyCircle( 0 ); }				//   0 degrees
	private inline function applyCentered ()	: Void		{ applyCircle( -Math.PI / 2 ); }	//- 90 degrees
	private inline function applyBottomToTop () : Void		{ applyCircle( -Math.PI ); }		//-180 degrees
	
	
	
	
	//
	// START VALUES
	//
	
	private inline function getTopStartValue ()		: Int
	{
		var top:Int = 0;
		if (group.padding != null)
			top = group.padding.top;
		
		return top;
	}
	
	
	private inline function getBottomStartValue ()	: Int	{
		var h:Int = group.height;
		if (group.is(AdvancedLayoutClient))
			h = IntMath.max(group.as(AdvancedLayoutClient).measuredHeight, h);
		
		if (group.padding != null)
			h += group.padding.top; // + group.padding.bottom;
		
		return h;
	}
	
	
#if debug
	public function toString ()
	{
		var start = direction == Vertical.top ? "top" : "bottom";
		var end = direction == Vertical.top ? "bottom" : "top";
		return "circle.ver ( " + start + " -> " + end + " ) ";
	}
#end
}