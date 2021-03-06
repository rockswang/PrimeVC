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
 *  Ruben Weijers	<ruben @ rubenw.nl>
 */
package primevc.mvc;
 import primevc.core.dispatcher.Signals;
 import primevc.core.traits.IDisposable;



/**
 * Parent facade is the main-application facade that will be started up as first.
 * The parent facade is responsible for creating the channels object that will
 * be distributed to the ChildFacades
 * 
 * @author Ruben Weijers
 * @creation-date May 25, 2011
 */
class ParentFacade <
		EventsType		: Signals,
		ModelType		: IMVCCore,
		StatesType		: IDisposable,
		ControllerType	: IMVCCoreActor,
		ViewType		: IMVCCoreActor,
		ChannelsType	: Signals
	> extends Facade <EventsType, ModelType, StatesType, ControllerType, ViewType>
{
	public var channels		(default, null) : ChannelsType;
	
	
	public function new ()
	{
		setupChannels();
		super();
	}
	
	
	override public function dispose ()
	{
		super.dispose();
		channels.dispose();
		channels = null;
	}
	
	
	/**
	 * Can instantiate the channels for this Facade.
	 */
	function setupChannels()	{ Assert.abstract(); }
}