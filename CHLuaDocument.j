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

/*
- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _DOMElement.style.height = "900px";
        editor = CodeMirror(_DOMElement, {
            lineWrapping: false,
            mode: "lua",
            lineNumbers: true,
            tabMode: "indent",
            matchBrackets: true,
            theme: "neat",
            value: "",
        });
        [self setFrame:aFrame];
    }

    return self;
}
*/

- (void)readFromData:(CPData)aData ofType:(CPString)aType error:(CPError)anError
{
    CPLog(@"Reading from data: %@  Type: %@", aData, aType);
    editorText = [aData rawString];
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
    CPLog(@"Making window controller.  Window size: %@",
            CPStringFromRect([aWindow frame]));

    if (editorText) {
        [editor setCode:editorText];
        editorText = nil;
    }
    else
        [editor setCode:@""];

    [aWindow setContentView:editor];
    [aWindow setDelegate:self];

}


- (void) setCode:(CGString)text
{
    [self setFrame:[self frame]];
    editor.setValue(text);
}

