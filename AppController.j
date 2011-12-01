/*
 * AppController.j
 * luaed
 *
 * Created by You on November 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "CHCodeMirrorView.j"
@import "CHLuaDocument.j"

@implementation AppController : CPObject
{
    CHCodeMirrorView    codeMirrorView;
    var                 editor;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
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


-(void)connection:(CPURLConnection)connection
   didReceiveData:(CPString)data;
{
    [codeMirrorView setCode:data];
    [[codeMirrorView window] setTitle:"file.lua"];
}


- (void)decideShouldWindowClose:(id)sender returnCode:(id)returnCode contextInfo:(id)contextInfo
{
    /* Don't save */
    if (returnCode == 1) {
        [contextInfo close];
        return;
    }

    /* Cancel the close */
    if (returnCode == 2) {
        return;
    }

    /* Save and close */
    if (returnCode == 0) {
        CPLog("Fixme!  Need to save document");
        return;
    }

    CPLog.error("Unrecognized returnCode: %d", returnCode);
}


- (BOOL)windowShouldClose:(id)sender
{
    if ([sender isDocumentEdited]) {
        var alrt = [CPAlert alertWithMessageText:@"Save changes before closing?"
                                   defaultButton:@"Save changes"
                                 alternateButton:@"Discard changes"
                                     otherButton:@"Cancel"
                       informativeTextWithFormat:@"This file contains unsaved changes.  Save changes before closing?"];
        [alrt beginSheetModalForWindow:sender
                         modalDelegate:self
                        didEndSelector:@selector(decideShouldWindowClose:returnCode:contextInfo:)
                           contextInfo:sender];
        return false;
    }
    return true;
}



- (void)newFile:(id)sender
{
    [[CPDocumentController sharedDocumentController]
        openUntitledDocumentOfType:@"luaed"
        display:YES];
}


- (void)openFile:(id)sender
{
    [[CPDocumentController sharedDocumentController]
        openDocumentWithContentsOfURL:[CPURL URLWithString:@"file.lua"]
                              display:YES
                                error:nil];
    /*
    var newWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(80, 150, 500, 550)
                                                styleMask:CPTitledWindowMask|CPClosableWindowMask|CPMiniaturizableWindowMask|CPResizableWindowMask];
    [newWindow orderFront:self];

    codeMirrorView = [[CHCodeMirrorView alloc] initWithFrame:[[newWindow contentView] frame]];
    [newWindow setContentView:codeMirrorView];
    [newWindow setDelegate:self];

    [[CPURLConnection connectionWithRequest:[CPURLRequest
        requestWithURL:"file.lua"] delegate:self] start];
        */
}

- (void)createMenuBar
{
    var mainMenu = [[CPMenu alloc] initWithTitle:@"MainMenu"];
    var newMenuItem, newSubMenuItem;
    var newMenu;


    newMenu = [[CPMenu alloc] initWithTitle:@"File"];

    [newMenuItem setSubMenu:newMenu];

    newSubMenuItem = [[CPMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:nil];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"New..."
                                                action:@selector(newFile:)
                                         keyEquivalent:@"n"
                                           bundleImage:@"CPApplication/New.png"
                                  bundleAlternateImage:@"CPApplication/NewHighlighted.png"]];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Open..."
                                                action:@selector(openFile:)
                                         keyEquivalent:@"o"
                                           bundleImage:@"CPApplication/Open.png"
                                  bundleAlternateImage:@"CPApplication/OpenHighlighted.png"]];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Close File"
                                                action:@selector(closeFile:)
                                         keyEquivalent:@"w"
                                           bundleImage:@"CPApplication/Open.png"
                                  bundleAlternateImage:@"CPApplication/OpenHighlighted.png"]];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Save File"
                                                action:@selector(saveFile:)
                                         keyEquivalent:@"s"
                                           bundleImage:@"CPApplication/Save.png"
                                  bundleAlternateImage:@"CPApplication/SaveHighlighted.png"]];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Save As..."
                                                action:@selector(saveFileAs:)
                                         keyEquivalent:@"s"
                                           bundleImage:@"CPApplication/Save.png"
                                  bundleAlternateImage:@"CPApplication/SaveHighlighted.png"]];
    [newSubMenuItem setSubmenu:newMenu];
    [mainMenu addItem:newSubMenuItem];





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
