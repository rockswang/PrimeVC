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
package primevc.gui.graphics.fills;
#if neko
 import primevc.tools.generator.ICodeGenerator;
#end
 import primevc.core.geom.IRectangle;
 import primevc.gui.graphics.GraphicElement;
 import primevc.gui.graphics.GraphicFlags;
 import primevc.gui.traits.IDrawable;
 import primevc.types.RGBA;
  using primevc.utils.Color;


/**
 * Solid fill for a graphic element
 * 
 * @author Ruben Weijers
 * @creation-date Jul 30, 2010
 */
class SolidFill extends GraphicElement, implements IFill
{
	public var color (default, setColor)	: RGBA;
	
	
	public function new ( color:RGBA )
	{
		super();
		this.color = color;
	}
	
	
	public inline function begin (target:IDrawable, ?bounds:IRectangle)
	{
		changes = 0;
#if flash9
		target.graphics.beginFill( color.rgb(), color.alpha() );
#end
	}
	
	
	public inline function end (target:IDrawable)
	{
#if flash9
		target.graphics.endFill();
#end
	}
	
	
	private inline function setColor (v:RGBA)
	{
		if (color != v) {
			this.color = v;
			invalidate( GraphicFlags.FILL );
		}
		return v;
	}
	
	
#if (debug || neko)
	override public function toCSS (prefix:String = "")
	{
		return color.string();
	}
#end
#if neko
	override public function toCode (code:ICodeGenerator)
	{
		code.construct( this, [ color ] );
	}
#end
}