/*
 * AppController.j
 * luaed
 *
 * Created by You on November 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>

@implementation CHSavePanel : CPAlert
{
    CPWindow            _win;
    CPWindow            _sheet;

    var                 _messageLabel;
    var                 _extLabel;
    var                 _fileNameBox;
    var                 _saveButton;
    var                 _cancelButton;

    CPString            fileName;
    CPString            extension;

    id                  _modalDelegate;
    SEL                 _endSelector;
    id                  _contextInfo;
}

- (void)handleSaveAsClicked:(id)sender
{
    if ([sender tag] == 0)
        fileName = [_fileNameBox stringValue];
    [CPApp endSheet:_sheet returnCode:[sender tag]];
}


- (void)_alertDidEnd:(CPWindow)aWindow returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    if (fileName && extension)
        fileName = [CPString stringWithFormat:@"%@.%@", fileName, extension];
    if (_endSelector)
        objj_msgSend(_modalDelegate, _endSelector, self, fileName, _contextInfo);

    _modalDelegate = nil;
    _endSelector = nil;
}


+ (CHSavePanel)savePanelForWindow:(CPWindow)win extension:(CPString)ext modalDelegate:(id)modalDelegate didEndSelector:(SEL)alertDidEndSelector contextInfo:(id)contextInfo
{
    return [[CHSavePanel alloc] initWithWindow:win extension:ext
        modalDelegate:modalDelegate didEndSelector:alertDidEndSelector
        contextInfo:contextInfo];
}

- (id)initWithWindow:(CPWindow)win extension:(CPString)ext modalDelegate:(id)modalDelegate didEndSelector:(SEL)alertDidEndSelector contextInfo:(id)contextInfo
{
    var self = [super init];
    if (!self)
        return;

    _modalDelegate = modalDelegate;
    _endSelector = alertDidEndSelector;
    _contextInfo = contextInfo;
    extension = ext;

    _win = win;
    var frame = CGRectMakeZero();
    frame.size = CPSizeMake(400.0, 110.0);

    _sheet = [[CPWindow alloc] initWithContentRect:frame styleMask:CPDocModalWindowMask];

    _messageLabel = [CPTextField labelWithTitle:@"Save as"];
    _extLabel = [CPTextField labelWithTitle:[CPString stringWithFormat:@".%@", ext]];
    _fileNameBox = [CPTextField textFieldWithStringValue:@"" placeholder:@"filename" width:300.0];
    _saveButton = [CPButton buttonWithTitle:@"Save"];
    _cancelButton = [CPButton buttonWithTitle:@"Cancel"];

    var inset = CGInsetMake(15, 15, 15, 15),
        sizeWithFontCorrection = 6.0,
        messageLabelWidth,        messageLabelTextSize;
    var tempFrame;
    [_messageLabel setTextColor:[CPColor blackColor]];
    [_messageLabel setFont:[CPFont boldSystemFontOfSize:13.0]];
    [_messageLabel setTextShadowColor:[CPColor blackColor]];
    [_messageLabel setTextShadowOffset:CGSizeMakeZero()];
    [_messageLabel setAlignment:CPJustifiedTextAlignment];
    [_messageLabel setLineBreakMode:CPLineBreakByWordWrapping];
    messageLabelWidth = CGRectGetWidth(frame) - inset.left - inset.right;
    messageLabelTextSize = [[_messageLabel stringValue] sizeWithFont:[_messageLabel font] inWidth:messageLabelWidth];

    
    tempFrame = CGRectMake(inset.left,
                           inset.top,
                           messageLabelTextSize.width,
                           messageLabelTextSize.height + sizeWithFontCorrection);
    [_messageLabel setFrame:tempFrame];



    [_fileNameBox setFont:[CPFont systemFontOfSize:12.0]];
    [_fileNameBox setDelegate:self];


    tempFrame = CGRectMake(inset.left,
                           messageLabelTextSize.height + sizeWithFontCorrection + inset.top,
                           400.0-2*inset.left-20,
                           32.0);
    [_fileNameBox setFrame:tempFrame];

    tempFrame.origin.x += tempFrame.size.width - 5;
    tempFrame.size.width = 40 - inset.left;
    tempFrame.origin.y += 10;
    [_extLabel setFont:[CPFont systemFontOfSize:12.0]];
    [_extLabel setFrame:tempFrame];


    tempFrame.origin.y += tempFrame.size.height - 5;
    tempFrame.origin.x = inset.left;
    tempFrame.size.width = 100.0;
    tempFrame.size.height = [_saveButton frame].size.height;
    [_saveButton setKeyEquivalent:CPCarriageReturnCharacter];
    [_saveButton setTag:0];
    [_saveButton setEnabled:NO];
    [_saveButton setTarget:self];
    [_saveButton setAction:@selector(handleSaveAsClicked:)];
    [_saveButton setFrame:tempFrame];

    tempFrame.origin.x += tempFrame.size.width + inset.left;
    tempFrame.size.height = [_cancelButton frame].size.height;
    [_cancelButton setKeyEquivalent:CPEscapeFunctionKey];
    [_cancelButton setTag:1];
    [_cancelButton setTarget:self];
    [_cancelButton setAction:@selector(handleSaveAsClicked:)];
    [_cancelButton setFrame:tempFrame];

    [[_sheet contentView] addSubview:_messageLabel];
    [[_sheet contentView] addSubview:_fileNameBox];
    [[_sheet contentView] addSubview:_extLabel];
    [[_sheet contentView] addSubview:_saveButton];
    [[_sheet contentView] addSubview:_cancelButton];

    [CPApp beginSheet:_sheet
       modalForWindow:_win
        modalDelegate:self
       didEndSelector:@selector(_alertDidEnd:returnCode:contextInfo:)
          contextInfo:nil];

    [_fileNameBox becomeFirstResponder];
}


- (void)controlTextDidChange:(id)sender {
    if ([[_fileNameBox stringValue] length] > 0)
        [_saveButton setEnabled:YES];
    else
        [_saveButton setEnabled:NO];
}


@end

