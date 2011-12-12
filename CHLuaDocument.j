/*
 * CHCodeMirrorView.j
 * Based on CPFlashView.j
 * AppKit
 *
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import "CHCodeMirrorView.j"

@implementation CHLuaDocument : CPDocument
{
    var         editor;
    DOMElement  _DOMDivElement;
    var         editorText;
    CPToolbar   toolbar;
    CPArray     toolbarItems;
    CPWindow    codeOutput;
}

- (void)readFromData:(CPData)aData ofType:(CPString)aType error:(CPError)anError
{
    editorText = [aData rawString];
}

- (CPData)dataOfType:(CPString)aType error:({CPError})anError
{
    return [CPData dataWithRawString:[editor code]];
}

- (void)makeWindowControllers
{
    var currentRect, contentRect, aWindow;
    var flags;

    flags  = CPTitledWindowMask|CPClosableWindowMask;
    flags |= CPMiniaturizableWindowMask|CPResizableWindowMask;

    if ([CPApp mainWindow]) {
        currentRect = [[CPApp mainWindow] frame];
        contentRect = CGRectMake(currentRect.origin.x+20.0,
                                 currentRect.origin.y+50.0,
                                 500.0, 300.0);
    }
    else {
        contentRect = CGRectMake(100.0,  100.0, 500.0, 300.0);
    }
    aWindow = [[CPWindow alloc] initWithContentRect:contentRect
                                          styleMask:flags];
    [self addWindowController:[[CPWindowController alloc] initWithWindow:aWindow]];

    [self setupToolbar:aWindow];

    /* Add an editor to the window */
    editor = [[CHCodeMirrorLuaView alloc] initWithFrame:contentRect];
    [editor setDocument:self];
    [editor setDelegate:self];

    /* If editorText is set, then we're loading from the Internet */
    if (editorText) {
        [editor setCode:editorText];
        editorText = nil;
    }
    else
        [editor setCode:@"print(\"Hello, world!\")"];

    [aWindow setContentView:editor];


    [self setupDebugOutput];

    /* Let the main app controller handle window events */
    [aWindow setDelegate:[CPApp delegate]];
}

- (void)setupToolbar:(CPWindow)aWindow
{
    /* Add a toolbar to the window */
    var item;

    item = [[CPToolbarItem alloc] initWithItemIdentifier:@"run"];
    [item setLabel:@"Run"];
    [item setAction:@selector(runCode:)];
    [item setTarget:self];

    toolbarItems = [CPArray arrayWithObjects:item];

    toolbar = [[CPToolbar alloc] init];
    [toolbar setDelegate:self];

    [aWindow setToolbar:toolbar];
}


- (void)setupDebugOutput
{
    var currentRect, contentRect, controller;
    var flags;

    flags  = CPTitledWindowMask|CPClosableWindowMask;
    flags |= CPMiniaturizableWindowMask|CPResizableWindowMask;

    if ([CPApp mainWindow]) {
        currentRect = [[CPApp mainWindow] frame];
        contentRect = CGRectMake(currentRect.origin.x+20.0,
                                currentRect.origin.y+50.0,
                                500.0, 300.0);
    }
    else {
        contentRect = CGRectMake(100.0,  100.0, 500.0, 300.0);
    }
    codeOutput = [[CPWindow alloc] initWithContentRect:contentRect
                                            styleMask:flags];
    var codeMirrorView = [[CHCodeMirrorView alloc] initWithFrame:[[codeOutput contentView] frame]];
    [codeOutput setContentView:codeMirrorView];
}



- (void)runCode:(id)sender
{
    if ([self fileURL]) {
        /* Decompose the URL and pass it to the bridge */
        var runURLParts = [[self fileURL] pathComponents];
        var pathParts = [runURLParts count];
        bridge = [[CHLuaBridge alloc] initWithFilename:[runURLParts objectAtIndex:pathParts-1]
                                               project:[runURLParts objectAtIndex:pathParts-2]
                                              delegate:self];

        /* Show the output window */
        [codeOutput orderFront:self];
        [codeOutput setTitle:@"Console Output"];
    }
    else {
        /* Decompose the URL and pass it to the bridge */
        var runURLParts = [[self fileURL] pathComponents];
        var pathParts = [runURLParts count];
        bridge = [[CHLuaBridge alloc] initWithString:[editor code]
                                              delegate:self];

        /* Show the output window */
        [codeOutput orderFront:self];
        [codeOutput setTitle:@"Console Output"];
    }
}

- (void)pauseCode:(id)sender
{
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    return [toolbarItems objectAtIndex:0];
}

-(CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
    return toolbarItems;
}



/* --- Lua bridge code --- */
- (void)luaBridge:(CHLuaBridge)bridge gotStdout:(CPString)stdout
{
    [[codeOutput contentView] appendCode:stdout];
}

- (void)luaBridge:(CHLuaBridge)bridge programEnded:(int)result
{
    [codeOutput setTitle:@"Console Output (program terminated)"];
}


