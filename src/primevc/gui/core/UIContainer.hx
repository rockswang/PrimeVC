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
package primevc.gui.core;
 import primevc.gui.layout.IScrollableLayout;
 import primevc.gui.layout.LayoutContainer;
  using primevc.utils.TypeUtil;

#if flash9
/* 
 import primevc.gui.behaviours.LoadStyleBehaviour;
 import primevc.gui.styling.StyleDeclaration;
 import primevc.gui.traits.IStylable;*/
#end


/**
 * @author Ruben Weijers
 * @creation-date Aug 02, 2010
 */
class UIContainer <DataType> extends UIDataComponent <DataType>
			, implements IUIContainer
{
	public var layoutContainer	(getLayoutContainer, never)		: LayoutContainer;
	public var scrollableLayout	(getScrollableLayout, never)	: IScrollableLayout;
	
	private inline function getLayoutContainer () 	{ return layout.as(LayoutContainer); }
	private inline function getScrollableLayout () 	{ return layout.as(IScrollableLayout); }
	
	
#if flash9
	//
	// ISTYLEABLE IMPLEMENTATION
	//
	
/*	public var style (default, setStyle)	: StyleDeclaration;
	
	override private function createBehaviours ()
	{
		behaviours.add( new LoadStyleBehaviour( this ) );
	}
	
	
	private inline function setStyle (v:StyleDeclaration)
	{
		return style = v;
	}*/
#end
}