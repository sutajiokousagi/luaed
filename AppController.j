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
@import "CHSavePanel.j"
@import "CHOpenPanel.j"

@implementation AppController : CPObject
{
    CHCodeMirrorView    codeMirrorView;
    var                 editor;
    var                 projectName;
    var                 currentDoc;
    var                 currentCtx;
    var                 _fileNameBox;
    SEL                 resultSel;

    var                 shouldCloseAfterSave;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    /* Hack for now -- hardcode the project name to dev-proj */
    projectName = @"dev-proj";
    [self createMenuBar];
}

- (void)saveDidFinish:(id)sender didSave:(BOOL)didSave contextInfo:(id)ctx
{
    CPLog(@"Saved? %d", didSave);
}

/* Actually save the file on the server */
- (void)saveFile:(var)sender
{
    var doc = [[[CPApp mainWindow] contentView] document];
    CPLog("Saving a document %@, from %@", doc, sender);
    if (![doc fileURL])
        return [self saveFileAs:sender];
    [doc saveToURL:[doc fileURL]
            ofType:@"luaed"
  forSaveOperation:CPSaveOperation
          delegate:self
   didSaveSelector:@selector(saveDidFinish:didSave:contextInfo:)
       contextInfo:nil];

    if (shouldCloseAfterSave)
        [[CPApp mainWindow] performClose:sender];
    shouldCloseAfterSave = NO;
}

- (void)saveFileAs:(var)sender
{
    var doc = [[[CPApp mainWindow] contentView] document];
    [CHSavePanel savePanelForWindow:[CPApp mainWindow]
                          extension:@"lua"
                      modalDelegate:self
                     didEndSelector:@selector(saveAsEnded:fileName:contextInfo:)
                        contextInfo:doc];
    return;
}

/* Called when the "Save File As" panel closes */
- (void)saveAsEnded:(id)sender fileName:(CPString)fileName contextInfo:(id)ctx
{
    CPLog(@"Save As ended.  Filename: %@  Context: %@", fileName, ctx);
    if (!fileName) {
        shouldCloseAfterSave = NO;
        return;
    }

    [ctx setFileURL:[CPURL URLWithString:fileName]];
    [self saveFile:sender];

    if (shouldCloseAfterSave)
        [[CPApp mainWindow] performClose:sender];
    shouldCloseAfterSave = NO;
}



- (void)closeFile:(id)sender
{
    [[CPApp mainWindow] performClose:sender];
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
        var doc = [[[CPApp mainWindow] contentView] document];
        shouldCloseAfterSave = YES;
        [self saveFile:sender];
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
    [CHOpenPanel openPanelForWindow:nil
                            fileURL:[CPURL URLWithString:[CPString stringWithFormat:@"/file/%@", projectName]]
                      modalDelegate:self
                     didEndSelector:@selector(openEnded:fileName:contextInfo:)
                        contextInfo:nil];
    /*
    [[CPDocumentController sharedDocumentController]
        openDocumentWithContentsOfURL:[CPURL URLWithString:@"file.lua"]
                              display:YES
                                error:nil];
    */
}

- (void)openEnded:(id)sender fileName:(CPString)fileName contextInfo:(id)ctx
{
    [[CPDocumentController sharedDocumentController]
        openDocumentWithContentsOfURL:[CPURL URLWithString:[CPString stringWithFormat:@"/file/%@/%@", projectName, fileName]]
                              display:YES
                                error:nil];
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
