package primevc.gui.layout.algorithms.tile;
 import primevc.core.collections.BalancingListCollection;
 import primevc.core.collections.BalancingList;
 import primevc.core.collections.ChainedListCollection;
 import primevc.core.collections.ChainedList;
 import primevc.core.collections.IList;
 import primevc.core.collections.IListCollection;
 import primevc.core.Number;
 import primevc.core.RangeIterator;
 import primevc.gui.layout.algorithms.directions.Direction;
 import primevc.gui.layout.algorithms.float.HorizontalFloatAlgorithm;
 import primevc.gui.layout.algorithms.float.VerticalFloatAlgorithm;
 import primevc.gui.layout.algorithms.ILayoutAlgorithm;
 import primevc.gui.layout.ILayoutGroup;
 import primevc.gui.layout.LayoutClient;
 import primevc.gui.layout.LayoutFlags;
 import primevc.gui.layout.LayoutGroup;
 import primevc.utils.FastArray;
 import primevc.utils.IntMath;
  using primevc.utils.BitUtil;
  using primevc.utils.Bind;
  using primevc.utils.IntUtil;
  using primevc.utils.IntMath;
  using primevc.utils.TypeUtil;
 

/**
 * Algorithm to layout children as tiles in rows and columns.
 * 
 * @creation-date	Jun 25, 2010
 * @author			Ruben Weijers
 */
class FixedTileAlgorithm extends TileAlgorithmBase, implements ILayoutAlgorithm
{
	/**
	 * Maximum number of rows or columns that the layout can have. 
	 * When the start-direction is 'horizontal', the value will be used as 
	 * the max number of columns. The number of rows will vary on the number
	 * of items.
	 * 
	 * When the start-direction is 'vertical', the value will be used as the
	 * maxmimum number or rows. The number of columns will vary on the number
	 * of items.
	 * 
	 * @default		4
	 */
	public var maxTilesInDirection	(default, setMaxTilesInDirection)		: Int;
	
	
	
	/**
	 * The maximum width of each tile. Their orignal width will be ignored if
	 * the tile is bigger then this number (it won't get resized).
	 * 
	 * @default		Number.NOT_SET
	 */
//	public var tileWidth			(default, setTileWidth)					: Int;
	/**
	 * The maximum height of each tile. Their orignal height will be ignored if
	 * the tile is heigher then this number (it won't get resized).
	 * 
	 * @default		Number.NOT_SET
	 */
//	public var tileHeight			(default, setTileHeight)				: Int;
	
	
	
	
	/**
	 * Rows is a TileGroup containing a reference to each row (also TileGroup).
	 * The rows property is responsible for setting the correct y position of
	 * each row.
	 * 
	 * rows (TileGroup)
	 * 	-> children (ListCollection)
	 * 		-> row0 (TileGroup)
	 * 			-> children (ChainedList)
	 * 		-> row1 (TileGroup)
	 * 			-> children (ChainedList)
	 * 		-> etc.
	 */
	public var rows					(default, null)		: TileGroup < TileGroup < LayoutClient > >;
	/**
	 * HorizontalMap is a collection of the children properties of all rows. 
	 * Defining them in a ChainedListCollection makes it easy to let the 
	 * children flow easily from one row to another.
	 * 
	 * map (ChainedListCollection)
	 * 		-> lists
	 * 			-> row0.children
	 * 			-> row1.children
	 * 		-> items
	 * 			-> tile0
	 * 			-> tile1
	 * 			-> ...
	 */
	private var horizontalMap		: IListCollection <LayoutClient, IList<LayoutClient>>;
	
	
	/**
	 * Columns is a TileGroup containing a reference to each column (also TileGroup).
	 * The columns property is responsible for setting the correct x position of
	 * each column.
	 * 
	 * columns (TileGroup)
	 * 	-> children (ListCollection)
	 * 		-> column0 (TileGroup)
	 * 			-> children (ChainedList)
	 * 		-> column1 (TileGroup)
	 * 			-> children (ChainedList)
	 * 		-> etc.
	 */
	public var columns				(default, null)		: TileGroup < TileGroup < LayoutClient > >;
	/**
	 * VerticalMap is a collection of the children properties of all columns. 
	 * Defining them in a ChainedListCollection makes it easy to let the 
	 * children flow easily from one column to another.
	 * 
	 * map (ChainedListCollection)
	 * 		-> lists
	 * 			-> column0.children
	 * 			-> column1.children
	 * 		-> items
	 * 			-> tile0
	 * 			-> tile3
	 * 			-> ...
	 */
	private var verticalMap			: IListCollection <LayoutClient, IList<LayoutClient>>;
	
	
	private var childHorAlgorithm	: HorizontalFloatAlgorithm;
	private var childVerAlgorithm	: VerticalFloatAlgorithm;
	
	
	public function new() 
	{
		super();
		maxTilesInDirection	= 4;
		childHorAlgorithm	= new HorizontalFloatAlgorithm( horizontalDirection );
		childVerAlgorithm	= new VerticalFloatAlgorithm( verticalDirection );
	}
	
	
	
	//
	// TILEMAP METHODS
	//
	
	/**
	 * Method will create a new index of all the children of the group. It will
	 * calculate the rows and columns on which each child will be.
	 * 
	 * For creating the tilemap it doesn't matter if it's horizontal or vertical.
	 * The variable names below just describe the horizontal direction.. 
	 * At the end of this method the properties will be switched when it turns 
	 * out to be a vertical list.
	 */
	public function createTileMap () : Void
	{
		var children		= group.children;
		var childLen:Int	= children.length;
		var childNum:Int	= 0;
		
		horizontalMap		= cast new ChainedListCollection <LayoutClient>(maxTilesInDirection);
		verticalMap			= cast new BalancingListCollection <LayoutClient>(maxTilesInDirection);
		
		rows				= new TileGroup<TileGroup<LayoutClient>>();
		rows.algorithm		= verAlgorithm;
		rows.padding		= group.padding;
		
		columns				= new TileGroup<TileGroup<LayoutClient>>();
		columns.algorithm	= horAlgorithm;
		columns.padding		= group.padding;
		
		if (childLen != 0)
		{
			var curRows	= childLen < maxTilesInDirection ? 1 : childLen.divCeil( maxTilesInDirection );
			
			//1. create a TileGroup for each row
			for (i in 0...curRows)
				addRow(childHorAlgorithm);
			
			//2. create a TileGroup for each column
			for ( i in 0...maxTilesInDirection )
			{
				var columnChildren	= new BalancingList<LayoutClient>();
				var column			= new TileGroup<LayoutClient>( columnChildren );
				column.algorithm	= childVerAlgorithm;
				verticalMap.addList( columnChildren );
				columns.children.add( column );
			}
			
			//3. add all the children to the rows and columns
			for (child in children) {
				horizontalMap.add(child);
				verticalMap.add(child);
			}
		}
		
		if (startDirection == Direction.vertical)
			swapHorizontalAndVertical();
	}
	
	
	private inline function addRow (childAlg:ILayoutAlgorithm)
	{
		var rowChildren	= new ChainedList<LayoutClient>( maxTilesInDirection );
		var row			= new TileGroup<LayoutClient>( rowChildren);
		row.algorithm	= childAlg;
		horizontalMap.addList( rowChildren );
		rows.children.add( row );	
	}
	
	
	private inline function swapHorizontalAndVertical ()
	{
		if (horizontalMap != null && verticalMap != null)
		{
			//switch algorithms of columns and rows around
			var columnsAlg		= columns.algorithm;
			columns.algorithm	= rows.algorithm;
			rows.algorithm		= columnsAlg;
			
			var columnAlg		= columns.children.getItemAt(0).algorithm;
			var rowAlg			= rows.children.getItemAt(0).algorithm;
			
			for (group in columns)
				group.algorithm = rowAlg;
			
			for (group in rows)
				group.algorithm = columnAlg;
		}
	}
	
	
	private function updateMapsAfterRemove (client, pos) : Void
	{
		if (horizontalMap == null || verticalMap == null)
			return;
		
		horizontalMap.remove(client);
		verticalMap.remove(client);
	}
	
	
	private function updateMapsAfterAdd (client:LayoutClient, pos:Int) : Void
	{
		if (horizontalMap == null || verticalMap == null)
			return;
		
		//reset boundary properties
		client.bounds.left	= 0;
		client.bounds.top	= 0;
		
		if (horizontalMap.length % maxTilesInDirection == 0) {
			if (startDirection == horizontal)		addRow(childHorAlgorithm);
			else									addRow(childVerAlgorithm);
			
		}
		
		horizontalMap.add(client, pos);
		verticalMap.add(client, pos);
	}
	
	
	private function updateMapsAfterMove (client, oldPos, newPos)
	{
		if (horizontalMap == null || verticalMap == null)
			return;
		
		horizontalMap.move(client, newPos, oldPos);
		verticalMap.move(client, newPos, oldPos);
	}
	
	
	
	
	//
	// LAYOUT METHODS
	//
	
	
	override public function measure () : Void
	{
		Assert.that( maxTilesInDirection.isSet(), "maxTilesInDirection should have been set" );
		
		if (group.children.length == 0)
			return;
		
		if (horizontalMap == null || verticalMap == null)
			createTileMap();
		
		measureHorizontal();
		measureVertical();
	}
	
	
	override public function measureHorizontal ()
	{
		var w:Int;
		if (startDirection == Direction.horizontal) {
			columns.measureHorizontal();
			w = rows.width = columns.width;
		} else {
			rows.measureHorizontal();
			w = columns.width = rows.width;
		}
		
		setGroupWidth(w);
	}
	
	
	override public function measureVertical ()
	{
		var h:Int;
		if (startDirection == Direction.horizontal) {
			rows.measureVertical();
			h = columns.height = rows.height;
		} else {
			columns.measureVertical();
			h = rows.height = columns.height;
		}
		
		setGroupHeight(h);
	}
	
	
/*	public function applyBoth () : Void
	{
		columns.validate();
		rows.validate();
	}
*/	
	
	override private function invalidate (shouldbeResetted:Bool = true) : Void
	{
		if (shouldbeResetted) {
			horizontalMap = verticalMap = null;
			rows = columns = null;
		}
		
		super.invalidate(shouldbeResetted);
	}
	
	
	
	
	//
	// SETTERS / GETTERS
	//
	
	
	private inline function setMaxTilesInDirection (v)
	{
		if (v != maxTilesInDirection) {
			maxTilesInDirection = v;
			invalidate( true );
		}
		return v;
	}
	
	
	override private function setStartDirection (v)
	{
		if (v != startDirection) {
			swapHorizontalAndVertical();
			super.setStartDirection(v);
		}
		return v;
	}
	
	
	override private function setGroup (v)
	{
		if (group != v)
		{
			if (group != null) {
				if (rows.padding == group.padding)		rows.padding = null;
				if (columns.padding == group.padding)	columns.padding = null;
				
				group.children.events.unbind(this);
			}
			
			v = super.setGroup(v);
			
			if (v != null) {
				updateMapsAfterAdd		.on( group.children.events.added, this );
				updateMapsAfterRemove	.on( group.children.events.removed, this );
				updateMapsAfterMove		.on( group.children.events.moved, this );
			}
		}
		return v;
	}
}