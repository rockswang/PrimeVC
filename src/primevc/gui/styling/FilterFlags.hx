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
  using primevc.utils.BitUtil;



/**
 * @author Ruben Weijers
 * @creation-date Sep 29, 2010
 */
class FilterFlags
{
	public static inline var ALL_PROPERTIES	: UInt = SHADOW | BEVEL | BLUR | GLOW | GRADIENT_BEVEL | GRADIENT_GLOW;
	public static inline var SHADOW			: UInt = 1;
	public static inline var BEVEL			: UInt = 2;
	public static inline var BLUR			: UInt = 4;
	public static inline var GLOW			: UInt = 8;
	public static inline var GRADIENT_BEVEL	: UInt = 16;
	public static inline var GRADIENT_GLOW	: UInt = 32;
	
	
#if debug
	public static function readProperties (flags:UInt) : String
	{
		var output	= [];
		
		if (flags.has( BEVEL ))				output.push("bevel");
		if (flags.has( BLUR ))				output.push("blur");
		if (flags.has( GLOW ))				output.push("glow");
		if (flags.has( GRADIENT_BEVEL ))	output.push("gradient-bevel");
		if (flags.has( GRADIENT_GLOW ))		output.push("gradient-glow");
		if (flags.has( SHADOW ))			output.push("shadow");
		
		return "properties: " + output.join(", ");
	}
#end
}