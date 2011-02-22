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
 * DAMAGE.s
 *
 *
 * Authors:
 *  Ruben Weijers	<ruben @ onlinetouch.nl>
 */
package primevc.gui.components;
 import flash.errors.Error;
 import primevc.gui.core.UIContainer;
 import primevc.gui.core.UIWindow;
 import primevc.gui.layout.LayoutClient;
 import primevc.gui.layout.LayoutContainer;
 import primevc.gui.states.ValidateStates;
  using primevc.utils.Bind;
  using primevc.utils.TypeUtil;



/**
 * Class to add debug buttons to the window
 * 
 * @author Ruben Weijers
 * @creation-date Feb 22, 2011
 */
class DebugBar extends UIContainer
{
	private var inspectStageBtn		: Button;
	private var inspectLayoutBtn	: Button;
	private var validateLayoutBtn	: Button;
	private var showInvalidatedBtn	: Button;
	private var showRenderingBtn	: Button;
	
	
	override private function createChildren ()
	{
#if !debug
		Assert.that(false, "Can't use DebugBar without being in debugmode");
#end
		inspectStageBtn		= new Button("inspectStageBtn", "Inspect Stage");
		inspectLayoutBtn	= new Button("inspectLayoutBtn", "Controleer layout");
		validateLayoutBtn	= new Button("validateLayoutBtn", "Forceer layout validatie");
		showInvalidatedBtn	= new Button("showInvalidatedBtn", "Trace invalidated queue");
		showRenderingBtn	= new Button("showRenderingBtn", "Trace render queue");
		
		layoutContainer.children.add( inspectStageBtn.layout );
		layoutContainer.children.add( inspectLayoutBtn.layout );
		layoutContainer.children.add( validateLayoutBtn.layout );
		layoutContainer.children.add( showInvalidatedBtn.layout );
		layoutContainer.children.add( showRenderingBtn.layout );
		
		children.add( inspectStageBtn );
		children.add( inspectLayoutBtn );
		children.add( validateLayoutBtn );
		children.add( showInvalidatedBtn );
		children.add( showRenderingBtn );
		
		system.invalidation.traceQueues = system.rendering.traceQueues = true;
		
		inspectAllLayouts	.on( inspectLayoutBtn.userEvents.mouse.click, this );
		forceAllValidation	.on( validateLayoutBtn.userEvents.mouse.click, this );
		inspectStage		.on( inspectStageBtn.userEvents.mouse.click, this );
		system.invalidation	.traceQueue.on( showInvalidatedBtn.userEvents.mouse.click, this );
		system.rendering	.traceQueue	.on( showRenderingBtn.userEvents.mouse.click, this );
	}
	
	
	//
	// DEBUG METHODS
	//
	
	
	/**
	 * Method will check every layoutcontainer it can find to see if it's validated
	 */
	private function inspectAllLayouts ()
	{
		trace("beginInspectingLayout");
		try {
			var counter = inspectIfContainerIsValidated(window.as(UIWindow).layoutContainer);
			trace("finished InspectingLayout: "+counter+" valid layouts");
		} catch (e:Error) {
			trace("[ERROR INSPECTING LAYOUT] :: "+e.errorID+": "+e.message);
			trace(e.getStackTrace());
		}
	}
	
	
	private function inspectIfContainerIsValidated (cont:LayoutContainer, counter:Int = 0)
	{
		inspectIfLayoutIsValidated( cont );
		counter++;
		
		for (child in cont.children)
			if (Std.is(child, LayoutContainer)) {
				counter = inspectIfContainerIsValidated(cast child, counter);
			} else {
				inspectIfLayoutIsValidated( child );
				counter++;
			}
		
		return counter;
	}
	
	
	private inline function inspectIfLayoutIsValidated (layout:LayoutClient)
	{
		Assert.that( layout.state.is( ValidateStates.validated ), "layout of "+layout+" is "+layout.state.current+" instead of validated. Invalidated properties: "+layout.readChanges());
	}
	
	
	private function forceAllValidation ()
	{
		trace("begin force validation");
		var counter = forceValidationOnContainer(window.as(UIWindow).layoutContainer);
		trace("finished forcing validation: revalidated "+counter+" layouts");
		inspectAllLayouts();
	}
	
	
	private function forceValidationOnContainer (cont:LayoutContainer, counter:Int = 0)
	{
		if (forceValidationOnLayout( cont ))
			counter++;
		
		for (child in cont.children)
			if (Std.is(child, LayoutContainer)) {
				counter = forceValidationOnContainer(cast child, counter);
			} else {
				if (forceValidationOnLayout( child ))
					counter++;
			}

		return counter;
	}
	
	private function forceValidationOnLayout (layout:LayoutClient)
	{
		if (!layout.state.is( ValidateStates.validated )) {
			layout.validate();
			return true;
		}
		return false;
	}
	
	
	
	
	
	/**
	 * Method will try to send the window object to the insepct window of alcon trace
	 */
	private function inspectStage ()
	{
#if AlconTrace
		com.hexagonstar.util.debug.Debug.inspect( window );
#end
	}
}