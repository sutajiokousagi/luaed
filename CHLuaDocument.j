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
}

- (id)initWithType:(CPString)aType error:({CPError})anError
{
    CPLog("Initializing with type %@", aType);
    return [super initWithType:aType error:anError];
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
    // debugger;
    var contentRect = CGRectMake(100.0,  100.0, 400.0, 300.0);
    var aWindow = [[CPWindow alloc] initWithContentRect:contentRect
                                              styleMask:CPTitledWindowMask|CPClosableWindowMask|CPMiniaturizableWindowMask|CPResizableWindowMask];
    var controller = [[CPWindowController alloc] initWithWindow:aWindow];

    [self addWindowController:controller];

    editor = [[CHCodeMirrorView alloc] initWithFrame:contentRect];
    [editor setDocument:self];

    /* If editorText is set, then we're loading from the Internet */
    if (editorText) {
        [editor setCode:editorText];
        editorText = nil;
    }
    else
        [editor setCode:@""];

    [aWindow setContentView:editor];

    /* Let the main app controller handle window events */
    [aWindow setDelegate:[CPApp delegate]];
}
