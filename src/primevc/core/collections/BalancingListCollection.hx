package primevc.core.collections;
 import primevc.core.events.ListEvents;
 import primevc.utils.IntMath;
  using primevc.utils.IntMath;
  using primevc.utils.TypeUtil;
 

/**
 * BalancingListCollection is a collection of a fixed number of lists which act 
 * like one list. When an item is added to the collection it will put it in one
 * of the child-lists and it will try to make each list of the same length.
 * 
 * @exampleText
 * 		- Collection has 3 childlists
 * 		
 * 		ADDING ITEMS
 * 		1. add item to collection 
 * 			-> all lists have the same length (0) so it will be added to childlist0
 * 		2. add item to collection 
 * 			-> childlist0 has length '1' and childlist1 has length '0' so the item will be added to childlist1
 * 		3. add item to collection
 * 			-> childlist0 and childlist1 have length '1' so the item will be added to childlist3
 * 		4. add item to collection
 * 			-> all 3 childlists have length '1' so add the item to childlist0
 * 
 * 		MOVING ITEMS
 * 		- Collection has 4 items and 3 childlists
 * 		
 * 		1. move item0 from position0 to position2
 * 			-> list0.remove( item0 )
 * 				-> list0 has a nextList (list1)
 * 					-> get first item of list1 == item1
 * 					-> list1.remove( item1 )
 * 						-> get first item of list2 == item2
 * 						-> list2.remove( item2 )
 * 							-> 
 * 					-> list0.add( item1, 0)
 * 
 * 			-> list0.add
 * 
 * @creation-date	Jul 1, 2010
 * @author			Ruben Weijers
 */
class BalancingListCollection <DataType> implements IList <DataType>,
	implements IListCollection < DataType, BalancingList<DataType> > 
	#if (flash9 || cpp) ,implements haxe.rtti.Generic #end
{
	private var _length		: Int;
	public var length		(getLength, never)			: Int;
	public var events		(default, null)				: ListEvents <DataType>;
	public var lists		(default, null)				: ArrayList < BalancingList<DataType> > ;
	
	/**
	 * Maximum number of lists that will be balanced.
	 * 
	 * TODO: create a setter for this property and rebalance all the lists 
	 * when this number is changed.
	 */
	public var maxLists		(default, default)			: UInt;
	
	/**
	 * The position of the list that is currently the longest
	 */
//	private var longestListNum	: Int;
	
	
	
	public function new (max) 
	{
		events			= new ListEvents();
		lists			= new ArrayList< BalancingList<DataType> >();
		
	//	longestListNum	= 0;
		maxLists		= max;
		_length			= 0;
	}
	
	
	public function dispose ()
	{
		events.dispose();
		
		for (list in lists) {
			list.dispose();
		}
		
		lists.removeAll();
		lists	= null;
		events	= null;
	}
	
	
	//
	// ILISTCOLLECTION METHODS
	//
	
	public inline function addList (list)
	{
		//give the previous list a reference to the new list
		if (lists.length > 0)
			lists.getItemAt(lists.length - 1).nextList = list;
		
		list.listNum	= lists.length;
		list.maxLists	= maxLists - 1;
		
		//if the new-list is the last allowed list, give it a reference to the first list
		if (list.listNum == list.maxLists)
			list.nextList = lists.getItemAt(0);
		
		lists.add(list);
		return list;
	}
	
	
	
	//
	// LIST MANIPULATION METHODS
	//
	
	public inline function add (item:DataType, pos:Int = -1) : DataType
	{
		pos = insertAt( item, pos );
		events.added.send( item, pos );
		return item;
	}
	
	
	public inline function remove (item:DataType) : DataType
	{
		removeItem(item);
		events.removed.send( item, removeItem(item) );
		return item;
	}
	
	
	
	/**
	 * Method will move the given item to it's new position. The process of 
	 * moving is a bit complexer in a balancingList because the items that
	 * follow up on eachother are spread over multiple lists.
	 * 
	 * @exampleText
	 * 		- pos0: item0 -> list0
	 * 		- pos1: item1 -> list1
	 * 		- pos2: item2 -> list2
	 * 		- pos3: item3 -> list0
	 * 
	 * Moving item0 to pos3 means that 4 items have to change of lists.
	 * 
	 * @param	item
	 * @param	newpos
	 * @return	item
	 */
	public inline function move (item:DataType, newPos:Int, curPos:Int = -1) : DataType
	{
		curPos = moveItem(item, newPos, curPos);
		if (curPos != newPos)
			events.moved.send( item, curPos, newPos );
		return item;
	}
	
	
	public inline function has (item:DataType) : Bool
	{
		var found:Bool	= false;
		for (list in lists) {
			if (list.has(item)) {
				found = true;
				break;
			}
		}
		return found;
	}
	
	
	public inline function indexOf (item:DataType) : Int
	{
		var pos:Int = -1;
		var listNum:Int = 0;
		for (list in lists) {
			var depth:Int = list.indexOf(item);
			if (depth >= 0) {
				pos = listNum + (depth * maxLists);
				break;
			}
			listNum++;
		}
		
		return pos;
	}
	
	
	
	/**
	 * Method does the same thing as the add method, except that it won't fire
	 * an 'added' event.
	 * 
	 * @param	item
	 * @param	pos
	 * @return	position where the cell is inserted
	 */
	private inline function insertAt (item:DataType, pos:Int = -1) : Int
	{
		if (pos < 0 || pos > length)
			pos = length;
		
		var listPos = getListNumForPosition(pos);
		
		if (lists.length <= listPos)
			addList( new BalancingList<DataType>() );
		
		//1. find corrent list to add item in
		var targetList	= lists.getItemAt(listPos);
		//2. find correct depth to add item to
		var itemDepth	= calculateItemDepth( pos );
		
		//3. add the item to the correct list
		targetList.add( item, itemDepth );
		//4. update length value
		_length++;
		return pos;
	}
	
	
	/**
	 * Method does the same thing as the remove method, except that it won't fire
	 * an 'removed' event.
	 * 
	 * Removing items for an balancinglist is a quite heavy operation (the 
	 * lower the position of the item, the heavier). The method will move the
	 * item that needs to be removed to the end of list, using the moveItem
	 * method. This way all items after the removed items will be placed in the
	 * correct balancing-list. 
	 * 
	 * After the item is moved to the end of the list, it will be removed.
	 * 
	 * @param	item
	 * @return	last position of the item
	 */
	private inline function removeItem (item:DataType) : Int
	{
		var oldItemPos	= indexOf(item);
		var itemList	= getListForPosition(oldItemPos);
		itemList.remove(item);
		_length--;
		return oldItemPos;
	}
	
	
	/**
	 * Method does the same thing as the move method, except that it won't fire
	 * an 'moved' event.
	 * 
	 * @param	item
	 * @return	new position for the item
	 */
	private inline function moveItem (item:DataType, newPos:Int, curPos:Int = -1) : Int
	{
		if (curPos == -1)
			curPos = indexOf(item);
		
		if (newPos != curPos)
		{
			var oldListPos	= getListNumForPosition(curPos);
			var oldDepth	= calculateItemDepth(curPos);
			var itr			= lists.iterator().as(FastArrayIterator);
			itr.current		= oldListPos;
			var lastList	= lists.getItemAt(oldListPos).as(BalancingList);	//last list that was swapped
			var lastDepth	= oldDepth;											//last depth on which was swapped
			var curDepth	= oldDepth;
			
			if (newPos > curPos)
			{
				//loop forward through lists
				var steps = newPos - curPos;
				for ( i in 0...steps ) {
					if (!itr.hasNext()) {
						itr.rewind();
						curDepth++;
					}
					
					var curList = itr.next().as(BalancingList);
					item		= cast curList.swapAtDepth( cast item, curDepth );
					item		= cast lastList.swapAtDepth( cast item, lastDepth );
					
					lastList	= curList;
					lastDepth	= curDepth;
				}
			}
			else 
			{
				//loop backwards through lists
				var steps = curPos - newPos;
				
				for ( i in 0...steps ) {
					if (!itr.hasPrev()) {
						itr.forward();
						curDepth--;
					}
					
					var curList	= itr.prev().as(BalancingList);
					item		= cast curList.swapAtDepth( cast item, curDepth );
					item		= cast lastList.swapAtDepth( cast item, lastDepth );
					
					lastList	= curList;
					lastDepth	= curDepth;
				}
			}
		}
		return curPos;
	}
	
	
	//
	// ITERATION METHODS
	//
	
	public inline function getItemAt (pos:Int) : DataType
	{
		var itemPos:Int	= calculateItemDepth( pos );		//calculate the position of the item in the list
		return getListForPosition(pos).getItemAt(itemPos);
	}
	
	
	public function iterator () : Iterator <DataType>
	{
		return new BalancingListCollectionIterator<DataType>(this);
	}
	
	
	
	private inline function getListForPosition (globalPos:Int) : BalancingList<DataType> {
		return lists.getItemAt(getListNumForPosition(globalPos));
	}
	
	
	private inline function getListNumForPosition (globalPos:Int) : Int {
		//calculate the number of the list in which the item will be
		return (globalPos < maxLists)
				? globalPos
				: Std.int( globalPos % maxLists );
	}
	
	
	private inline function calculateItemDepth (globalPos:Int) : Int
	{
		return (globalPos < maxLists)
				? 0
				: globalPos.divFloor( maxLists ); // - 1;
	}
	
	
	
	//
	// GETTERS / SETTERS
	//
	
	private inline function getLength () {
		return _length;
	}
	
	
#if debug
	/*public function toString ()
	{
		var str = "";
		for (depth in 0...lists[0].length) {
			var max = getListNumForPosition( IntMath.max((depth + 1) * maxLists, length) );
			 
			for (listNum in 0...max) {
				var item = lists[listNum].getItemAt(depth);
				str += "balance[" + listNum + "][" + depth + "] = " + item + "\n";
			}
		}
		return str;
	}*/
	
	public function toString ()
	{
		var str = "";
		var j = 0;
		var columns = new Array();
		for (list in lists) {
			var items = new Array();
			for (item in list) {
				items.push( "[ " + item + " ]" );
			}
			columns.push( "column" + j + " - " + items.join(" ") + " ( "+list.length+" )" );
			j++;
		}
		return "#\n"+columns.join("\n");
	}
#end
}



/**
 * Iterator for the BalancingListCollection.
 * 
 * @creation-date	Jul 1, 2010
 * @author			Ruben Weijers
 */
class BalancingListCollectionIterator <DataType> #if (flash9 || cpp) implements haxe.rtti.Generic #end
{
	private var target			(default, null) : BalancingListCollection<DataType>;
	private var currentListNum	: UInt;
	private var currentDepth	: UInt;
	public var currentPos		: Int;
	
	
	public function new (target:BalancingListCollection<DataType>) 
	{
		this.target		= target;
		currentDepth	= 0;
		currentPos		= 0;
		currentListNum	= 0;
	}
	
	
	public inline function hasNext () : Bool
	{
		return currentPos < target.length;
	}
	
	
	public function next () : DataType
	{
		if (currentListNum >= target.maxLists) {
			currentListNum = 0;
			currentDepth++;
		}
		
		var item = target.lists.getItemAt(currentListNum).getItemAt(currentDepth);
		currentListNum++;
		currentPos++;
		
		return item;
	}
}