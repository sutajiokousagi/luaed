/*
 * AppController.j
 * luaed
 *
 * Created by You on November 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "CHCodeMirrorView.j"

@implementation AppController : CPObject
{
    CPWindow            exampleWindow;
    CHCodeMirrorView    codeMirrorView;
    var                 editor;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [self createWindows];
    [self createCodeEditor];
    [self createMenuBar];
}

- (void)newDocument:(var)sender
{
    CPLog("Creating a new document, from " + sender);
}

- (void)openDocument:(var)sender
{
    CPLog("Opening a document, from " + sender);
}

- (void)saveDocument:(var)sender
{
    CPLog("Saving a document, from %@", sender);
}

- (void)saveDocumentAs:(var)sender
{
    var panel = [CPSavePanel savePanel];
    [panel setFloatingPanel:YES];

    var i = [panel orderFront:self];
    CPLog("Saving a document, from " + sender + " to " + i + ", URL " +
            [panel URL]);
}

- (void)closeFile:(id)sender
{
    [[CPApp mainWindow] close];
}


- (void)createWindows
{

    exampleWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(80, 150, 500, 550)
                                                 styleMask:CPTitledWindowMask|CPClosableWindowMask|CPMiniaturizableWindowMask|CPResizableWindowMask];

    [exampleWindow orderFront:self];
}

-(void)connection:(CPURLConnection)connection
   didReceiveData:(CPString)data;
{
    [codeMirrorView setCode:data];
    [exampleWindow setTitle:"file.lua"];
}

- (BOOL)windowShouldClose:(id)sender
{
    if ([sender isDocumentEdited]) {
        alert("Document was edited.  Not closing.");
        return false;
    }
    alert("Okay, closing.");
    return true;
}


- (void)createCodeEditor
{
    var currentView = [exampleWindow contentView];
    var currentRect = [currentView frame];

    codeMirrorView = [[CHCodeMirrorView alloc] initWithFrame:currentRect];

    [exampleWindow setContentView:codeMirrorView];
    [exampleWindow setDelegate:self];
    //[codeMirrorView setFrame:currentRect];

    [[CPURLConnection connectionWithRequest:[CPURLRequest
        requestWithURL:"file.lua"] delegate:self] start];
}

- (void)createMenuBar
{
    var mainMenu = [[CPMenu alloc] initWithTitle:@"MainMenu"];
    var newMenuItem, newSubMenuItem;
    var newMenu;


    newMenu = [[CPMenu alloc] initWithTitle:@"File"];

    [newMenuItem setSubMenu:newMenu];

    newSubMenuItem = [[CPMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:nil];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"New"
                                                action:@selector(newFile:)
                                         keyEquivalent:@"n"
                                           bundleImage:@"CPApplication/New.png"
                                  bundleAlternateImage:@"CPApplication/NewHighlighted.png"]];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Open"
                                                action:@selector(openFile:)
                                         keyEquivalent:@"o"
                                           bundleImage:@"CPApplication/Open.png"
                                  bundleAlternateImage:@"CPApplication/OpenHighlighted.png"]];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Close"
                                                action:@selector(closeFile:)
                                         keyEquivalent:@"w"
                                           bundleImage:@"CPApplication/Close.png"
                                  bundleAlternateImage:@"CPApplication/CloseHighlighted.png"]];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Save"
                                                action:@selector(saveFile:)
                                         keyEquivalent:@"s"
                                           bundleImage:@"CPApplication/Save.png"
                                  bundleAlternateImage:@"CPApplication/SaveHighlighted.png"]];
    [newSubMenuItem setSubmenu:newMenu];
    [mainMenu addItem:newSubMenuItem];


    /*
    newMenuItem = [[CPMenuItem alloc] initWithTitle:@"Save"
                                             action:@selector(saveFile:)
                                      keyEquivalent:@"s"
                                        bundleImage:@"CPApplication/Save.png"
                               bundleAlternateImage:@"CPApplication/SaveHighlighted.png"];
    [newMenuItem setSubMenu:newMenu];
    [mainMenu addItem:newMenuItem];


    [mainMenu addItem:newMenu];
    */

    [mainMenu addItem:[CPMenuItem separatorItem]];


    
    [mainMenu setDelegate:self];
    [CPApp setMainMenu:mainMenu];
    [CPMenu setMenuBarVisible:YES];
}


@end


@implementation CPMenuItem (WithImage)

- (id)initWithTitle:(CPString)aTitle
             action:(SEL)anAction
      keyEquivalent:(CPString)aKeyEquivalent
        bundleImage:(CPString)anImageName
bundleAlternateImage:(CPString)anAlternateImageName
{
    self = [self initWithTitle:aTitle action:anAction keyEquivalent:aKeyEquivalent];
    var bundle = [CPBundle bundleForClass:[CPApplication class]];
    var img = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:anImageName]
                                                 size:CGSizeMake(16.0, 16.0)];
    var altImg = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:anAlternateImageName]
                                                    size:CGSizeMake(16.0, 16.0)];

    [self setImage:img];
    [self setAlternateImage:altImg];
    return self;
}
@end
