@STATIC;1.0;p;15;AppController.jt;6788;@STATIC;1.0;I;21;Foundation/CPObject.ji;18;CHCodeMirrorView.jt;6720;objj_executeFile("Foundation/CPObject.j", NO);
objj_executeFile("CHCodeMirrorView.j", YES);
{var the_class = objj_allocateClassPair(CPObject, "AppController"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("exampleWindow"), new objj_ivar("codeMirrorView"), new objj_ivar("editor")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("applicationDidFinishLaunching:"), function $AppController__applicationDidFinishLaunching_(self, _cmd, aNotification)
{ with(self)
{
    objj_msgSend(self, "createWindows");
    objj_msgSend(self, "createCodeEditor");
    objj_msgSend(self, "createMenuBar");
}
},["void","CPNotification"]), new objj_method(sel_getUid("newDocument:"), function $AppController__newDocument_(self, _cmd, sender)
{ with(self)
{
    CPLog("Creating a new document, from " + sender);
}
},["void","var"]), new objj_method(sel_getUid("openDocument:"), function $AppController__openDocument_(self, _cmd, sender)
{ with(self)
{
    CPLog("Opening a document, from " + sender);
}
},["void","var"]), new objj_method(sel_getUid("saveDocument:"), function $AppController__saveDocument_(self, _cmd, sender)
{ with(self)
{
    CPLog("Saving a document, from %@", sender);
}
},["void","var"]), new objj_method(sel_getUid("saveDocumentAs:"), function $AppController__saveDocumentAs_(self, _cmd, sender)
{ with(self)
{
    var panel = objj_msgSend(CPSavePanel, "savePanel");
    objj_msgSend(panel, "setFloatingPanel:", YES);
    var i = objj_msgSend(panel, "orderFront:", self);
    CPLog("Saving a document, from " + sender + " to " + i + ", URL " +
            objj_msgSend(panel, "URL"));
}
},["void","var"]), new objj_method(sel_getUid("closeFile:"), function $AppController__closeFile_(self, _cmd, sender)
{ with(self)
{
    objj_msgSend(objj_msgSend(CPApp, "mainWindow"), "close");
}
},["void","id"]), new objj_method(sel_getUid("createWindows"), function $AppController__createWindows(self, _cmd)
{ with(self)
{
    exampleWindow = objj_msgSend(objj_msgSend(CPWindow, "alloc"), "initWithContentRect:styleMask:", CGRectMake(80, 150, 500, 550), CPTitledWindowMask|CPClosableWindowMask|CPMiniaturizableWindowMask|CPResizableWindowMask);
    objj_msgSend(exampleWindow, "orderFront:", self);
}
},["void"]), new objj_method(sel_getUid("connection:didReceiveData:"), function $AppController__connection_didReceiveData_(self, _cmd, connection, data)
{ with(self)
{
    objj_msgSend(codeMirrorView, "setCode:", data);
    objj_msgSend(exampleWindow, "setTitle:", "file.lua");
}
},["void","CPURLConnection","CPString"]), new objj_method(sel_getUid("windowShouldClose:"), function $AppController__windowShouldClose_(self, _cmd, sender)
{ with(self)
{
    if (objj_msgSend(sender, "isDocumentEdited")) {
        alert("Document was edited.  Not closing.");
        return false;
    }
    alert("Okay, closing.");
    return true;
}
},["BOOL","id"]), new objj_method(sel_getUid("createCodeEditor"), function $AppController__createCodeEditor(self, _cmd)
{ with(self)
{
    var currentView = objj_msgSend(exampleWindow, "contentView");
    var currentRect = objj_msgSend(currentView, "frame");
    codeMirrorView = objj_msgSend(objj_msgSend(CHCodeMirrorView, "alloc"), "initWithFrame:", currentRect);
    objj_msgSend(exampleWindow, "setContentView:", codeMirrorView);
    objj_msgSend(exampleWindow, "setDelegate:", self);
    objj_msgSend(objj_msgSend(CPURLConnection, "connectionWithRequest:delegate:", objj_msgSend(CPURLRequest, "requestWithURL:", "file.lua"), self), "start");
}
},["void"]), new objj_method(sel_getUid("createMenuBar"), function $AppController__createMenuBar(self, _cmd)
{ with(self)
{
    var mainMenu = objj_msgSend(objj_msgSend(CPMenu, "alloc"), "initWithTitle:", "MainMenu");
    var newMenuItem, newSubMenuItem;
    var newMenu;
    newMenu = objj_msgSend(objj_msgSend(CPMenu, "alloc"), "initWithTitle:", "File");
    objj_msgSend(newMenuItem, "setSubMenu:", newMenu);
    newSubMenuItem = objj_msgSend(objj_msgSend(CPMenuItem, "alloc"), "initWithTitle:action:keyEquivalent:", "File", nil, nil);
    objj_msgSend(newMenu, "addItem:", objj_msgSend(objj_msgSend(CPMenuItem, "alloc"), "initWithTitle:action:keyEquivalent:bundleImage:bundleAlternateImage:", "New", sel_getUid("newFile:"), "n", "CPApplication/New.png", "CPApplication/NewHighlighted.png"));
    objj_msgSend(newMenu, "addItem:", objj_msgSend(objj_msgSend(CPMenuItem, "alloc"), "initWithTitle:action:keyEquivalent:bundleImage:bundleAlternateImage:", "Open", sel_getUid("openFile:"), "o", "CPApplication/Open.png", "CPApplication/OpenHighlighted.png"));
    objj_msgSend(newMenu, "addItem:", objj_msgSend(objj_msgSend(CPMenuItem, "alloc"), "initWithTitle:action:keyEquivalent:bundleImage:bundleAlternateImage:", "Close", sel_getUid("closeFile:"), "w", "CPApplication/Close.png", "CPApplication/CloseHighlighted.png"));
    objj_msgSend(newMenu, "addItem:", objj_msgSend(objj_msgSend(CPMenuItem, "alloc"), "initWithTitle:action:keyEquivalent:bundleImage:bundleAlternateImage:", "Save", sel_getUid("saveFile:"), "s", "CPApplication/Save.png", "CPApplication/SaveHighlighted.png"));
    objj_msgSend(newSubMenuItem, "setSubmenu:", newMenu);
    objj_msgSend(mainMenu, "addItem:", newSubMenuItem);
    objj_msgSend(mainMenu, "addItem:", objj_msgSend(CPMenuItem, "separatorItem"));
    objj_msgSend(mainMenu, "setDelegate:", self);
    objj_msgSend(CPApp, "setMainMenu:", mainMenu);
    objj_msgSend(CPMenu, "setMenuBarVisible:", YES);
}
},["void"])]);
}
{
var the_class = objj_getClass("CPMenuItem")
if(!the_class) throw new SyntaxError("*** Could not find definition for class \"CPMenuItem\"");
var meta_class = the_class.isa;class_addMethods(the_class, [new objj_method(sel_getUid("initWithTitle:action:keyEquivalent:bundleImage:bundleAlternateImage:"), function $CPMenuItem__initWithTitle_action_keyEquivalent_bundleImage_bundleAlternateImage_(self, _cmd, aTitle, anAction, aKeyEquivalent, anImageName, anAlternateImageName)
{ with(self)
{
    self = objj_msgSend(self, "initWithTitle:action:keyEquivalent:", aTitle, anAction, aKeyEquivalent);
    var bundle = objj_msgSend(CPBundle, "bundleForClass:", objj_msgSend(CPApplication, "class"));
    var img = objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", objj_msgSend(bundle, "pathForResource:", anImageName), CGSizeMake(16.0, 16.0));
    var altImg = objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", objj_msgSend(bundle, "pathForResource:", anAlternateImageName), CGSizeMake(16.0, 16.0));
    objj_msgSend(self, "setImage:", img);
    objj_msgSend(self, "setAlternateImage:", altImg);
    return self;
}
},["id","CPString","SEL","CPString","CPString","CPString"])]);
}

p;18;CHCodeMirrorView.jt;3859;@STATIC;1.0;t;3840;{var the_class = objj_allocateClassPair(CPView, "CHCodeMirrorView"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("editor"), new objj_ivar("_DOMDivElement")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("initWithFrame:"), function $CHCodeMirrorView__initWithFrame_(self, _cmd, aFrame)
{ with(self)
{
    self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("CHCodeMirrorView").super_class }, "initWithFrame:", aFrame);
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
        objj_msgSend(self, "setFrame:", aFrame);
    }
    return self;
}
},["id","CGRect"]), new objj_method(sel_getUid("setCode:"), function $CHCodeMirrorView__setCode_(self, _cmd, text)
{ with(self)
{
    editor.setValue(text);
}
},["void","CGString"]), new objj_method(sel_getUid("display"), function $CHCodeMirrorView__display(self, _cmd)
{ with(self)
{
    objj_msgSendSuper({ receiver:self, super_class:objj_getClass("CHCodeMirrorView").super_class }, "display");
    editor.refresh();
}
},["void"]), new objj_method(sel_getUid("setFrame:"), function $CHCodeMirrorView__setFrame_(self, _cmd, frame)
{ with(self)
{
    var scroller = editor.getScrollerElement();
    var wrapper = editor.getWrapperElement();
    objj_msgSendSuper({ receiver:self, super_class:objj_getClass("CHCodeMirrorView").super_class }, "setFrame:", frame);
    scroller.style.height = frame.size.height + "px";
    wrapper.style.height = frame.size.height + "px";
    editor.refresh();
}
},["void","CGRect"]), new objj_method(sel_getUid("acceptsFirstResponder"), function $CHCodeMirrorView__acceptsFirstResponder(self, _cmd)
{ with(self)
{
    return YES;
}
},["BOOL"]), new objj_method(sel_getUid("becomeFirstResponder"), function $CHCodeMirrorView__becomeFirstResponder(self, _cmd)
{ with(self)
{
    CPLog("Become first responder");
    return YES;
}
},["BOOL"]), new objj_method(sel_getUid("scrollWheel:"), function $CHCodeMirrorView__scrollWheel_(self, _cmd, anEvent)
{ with(self)
{
    CPLog("Scrolling");
    if (CPBrowserIsEngine(CPWebKitBrowserEngine)) {
        var dx = objj_msgSend(anEvent, "deltaX");
        var dy = objj_msgSend(anEvent, "deltaY");
        editor.getScrollerElement().scrollLeft += dx;
        editor.getScrollerElement().scrollTop += dy;
    }
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseDragged:"), function $CHCodeMirrorView__mouseDragged_(self, _cmd, anEvent)
{ with(self)
{
    objj_msgSend(objj_msgSend(objj_msgSend(self, "window"), "platformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseDown:"), function $CHCodeMirrorView__mouseDown_(self, _cmd, anEvent)
{ with(self)
{
    objj_msgSend(objj_msgSend(objj_msgSend(self, "window"), "platformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("mouseUp:"), function $CHCodeMirrorView__mouseUp_(self, _cmd, anEvent)
{ with(self)
{
    objj_msgSend(objj_msgSend(objj_msgSend(self, "window"), "platformWindow"), "_propagateCurrentDOMEvent:", YES);
}
},["void","CPEvent"]), new objj_method(sel_getUid("keyDown:"), function $CHCodeMirrorView__keyDown_(self, _cmd, anEvent)
{ with(self)
{
    CPLog("Keydown event: %@", anEvent);
    objj_msgSend(objj_msgSend(objj_msgSend(self, "window"), "platformWindow"), "_propagateCurrentDOMEvent:", YES);
    objj_msgSend(self, "interpretKeyEvents:", [anEvent]);
    objj_msgSend(objj_msgSend(CPRunLoop, "currentRunLoop"), "limitDateForMode:", CPDefaultRunLoopMode);
}
},["void","CPEvent"])]);
}p;6;main.jt;296;@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;15;AppController.jt;210;objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("AppController.j", YES);
main = function(args, namedArgs)
{
    CPApplicationMain(args, namedArgs);
}

e;