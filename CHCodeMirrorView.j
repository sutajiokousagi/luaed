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

/*!
    @ingroup appkit
*/
@implementation CHCodeMirrorView : CPView
{
    var         editor;
    DOMElement  _DOMDivElement;
}

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

- (void) setCode:(CGString)text
{
    editor.setValue(text);
}

- (void)display {
    [super display];
    editor.refresh();
}

- (void)setFrame:(CGRect)frame {
    var scroller = editor.getScrollerElement();
    var wrapper = editor.getWrapperElement();
    [super setFrame:frame];
    scroller.style.height = frame.size.height + "px";
    wrapper.style.height = frame.size.height + "px";
    editor.refresh();
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    CPLog("Become first responder");
    return YES;
}

- (void)scrollWheel:(CPEvent)anEvent
{
    CPLog("Scrolling");
    /* On WebKit, the _DOMScrollingElement prevents the editor from
     * getting more than one scroll event.  Fake it, if necessary.
     */
    if (CPBrowserIsEngine(CPWebKitBrowserEngine)) {
        var dx = [anEvent deltaX];
        var dy = [anEvent deltaY];
        editor.getScrollerElement().scrollLeft += dx;
        editor.getScrollerElement().scrollTop  += dy;
    }
}

- (void)mouseDragged:(CPEvent)anEvent
{
    [[[self window] platformWindow] _propagateCurrentDOMEvent:YES];
}

- (void)mouseDown:(CPEvent)anEvent
{
    [[[self window] platformWindow] _propagateCurrentDOMEvent:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
    [[[self window] platformWindow] _propagateCurrentDOMEvent:YES];
}

- (void)keyDown:(CPEvent)anEvent
{
    CPLog("Keydown event: %@", anEvent);
    // CPTextField uses an HTML input element to take the input so we need to
    // propagate the dom event so the element is updated. This has to be done
    // before interpretKeyEvents: though so individual commands have a chance
    // to override this (escape to clear the text in a search field for example).
    [[[self window] platformWindow] _propagateCurrentDOMEvent:YES];

    [self interpretKeyEvents:[anEvent]];

    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}