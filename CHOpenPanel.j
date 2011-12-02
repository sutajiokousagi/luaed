/*
 * AppController.j
 * luaed
 *
 * Created by You on November 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>

@implementation CHOpenPanel : CPAlert
{
    CPWindow            _win;
    CPWindow            _sheet;

    CPArray             _files;

    CPTextField         fileNameCell;

    var                 _messageLabel;
    var                 _fileBox;
    var                 _openButton;
    var                 _cancelButton;

    CPString            fileName;

    id                  _modalDelegate;
    SEL                 _endSelector;
    id                  _contextInfo;
    id                  _url;
}

- (void)handleOpenClicked:(id)sender
{
    if ([sender tag] != 0)
        fileName = nil;
    [CPApp abortModal];
    [_sheet close];

    if (_endSelector)
        objj_msgSend(_modalDelegate, _endSelector, self, fileName, _contextInfo);
    _modalDelegate = nil;
    _endSelector = nil;
}


+ (CHOpenPanel)openPanelForWindow:(CPWindow)win fileURL:(URL)source modalDelegate:(id)modalDelegate didEndSelector:(SEL)alertDidEndSelector contextInfo:(id)contextInfo
{
    return [[CHOpenPanel alloc] initWithWindow:win fileURL:source
        modalDelegate:modalDelegate didEndSelector:alertDidEndSelector
        contextInfo:contextInfo];
}

- (id)initWithWindow:(CPWindow)win fileURL:(CPURL)url modalDelegate:(id)modalDelegate didEndSelector:(SEL)alertDidEndSelector contextInfo:(id)contextInfo
{
    var self = [super init];
    if (!self)
        return;


    var frame = CGRectMakeZero();
    var inset = CGInsetMake(15, 15, 15, 15),
        sizeWithFontCorrection = 6.0,
        messageLabelWidth,        messageLabelTextSize;
    var tempFrame;

    _modalDelegate = modalDelegate;
    _endSelector = alertDidEndSelector;
    _contextInfo = contextInfo;
    _url = url;
    _win = win;

    _files = [[CPArray alloc] init];

    frame.size = CPSizeMake(500.0, 415.0);

    _sheet = [[CPWindow alloc] initWithContentRect:frame styleMask:CPDocModalWindowMask];


    var listScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(15,
            40, 470, CGRectGetHeight(frame) - 85)];
    [listScrollView setAutohidesScrollers:YES];
    [listScrollView setHasHorizontalScroller:NO];
    [listScrollView setAutoresizingMask:CPViewHeightSizable];
    [[listScrollView contentView] setBackgroundColor:[CPColor colorWithRed:213.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1.0]];


    _messageLabel = [CPTextField labelWithTitle:@"Open"];
    _fileBox = [[CPCollectionView alloc]
        initWithFrame:CGRectMake(0, 0,
                frame.size.width-inset.left*2,
                frame.size.height-inset.top*2)];
    _openButton = [CPButton buttonWithTitle:@"Open"];
    _cancelButton = [CPButton buttonWithTitle:@"Cancel"];

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



    var fileNameCellItem = [[CPCollectionViewItem alloc] init];
    fileNameCell = [[CHTextCell alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
    [fileNameCellItem setView:fileNameCell];
    [_fileBox setMinItemSize:CGSizeMake(frame.size.width, 30)];
    [_fileBox setMaxItemSize:CGSizeMake(frame.size.width, 30)];
    [_fileBox setMaxNumberOfColumns:1];
    [_fileBox setVerticalMargin:0.0];
    [_fileBox setItemPrototype:fileNameCellItem];
    [_fileBox setDelegate:self];
    [listScrollView setDocumentView:_fileBox];



    tempFrame.origin.y += CGRectGetHeight(frame) - [_openButton frame].size.height - inset.bottom*2;
    tempFrame.origin.x = inset.left;
    tempFrame.size.width = 100.0;
    tempFrame.size.height = [_openButton frame].size.height;
    [_openButton setKeyEquivalent:CPCarriageReturnCharacter];
    [_openButton setTag:0];
    [_openButton setEnabled:NO];
    [_openButton setTarget:self];
    [_openButton setAction:@selector(handleOpenClicked:)];
    [_openButton setFrame:tempFrame];

    tempFrame.origin.x += tempFrame.size.width + inset.left;
    tempFrame.size.height = [_cancelButton frame].size.height;
    [_cancelButton setKeyEquivalent:CPEscapeFunctionKey];
    [_cancelButton setTag:1];
    [_cancelButton setTarget:self];
    [_cancelButton setAction:@selector(handleOpenClicked:)];
    [_cancelButton setFrame:tempFrame];

    [[_sheet contentView] addSubview:_messageLabel];
    [[_sheet contentView] addSubview:listScrollView];
    [[_sheet contentView] addSubview:_openButton];
    [[_sheet contentView] addSubview:_cancelButton];

    [CPApp runModalForWindow:_sheet];

    [_fileBox becomeFirstResponder];

    /* Get available files */
    [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:url]
                                    delegate:self 
                            startImmediately:YES];
}



-(void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    _files = [data componentsSeparatedByString:@"\n"];
    CPLog(@"List expands to: %@", _files);
    [_files removeLastObject];
    [_fileBox setContent:_files];
}



- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
    var listIndex = [[aCollectionView selectionIndexes] firstIndex];
    fileName = [aCollectionView content][listIndex];
    [_openButton setEnabled:YES];
}

-(void)collectionView:(CPCollectionView)collectionView didDoubleClickOnItemAtIndex:(int)index
{
    [self handleOpenClicked:_openButton];
}


@end


@implementation CHTextCell : CPView
{
    CPTextField label;
    CPView      highlightView;
}

- (void)setRepresentedObject:(JSObject)anObject
{
    if(!label)
    {
        label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];

        [label setFont:[CPFont systemFontOfSize:16.0]];
        [label setTextShadowColor:[CPColor whiteColor]];
        [label setTextShadowOffset:CGSizeMake(0, 1)];

        [self addSubview:label];
    }

    [label setStringValue:anObject];
    [label sizeToFit];

    [label setFrameOrigin:CGPointMake(20,CGRectGetHeight([label bounds]) / 2.0)];
}

- (void)setSelected:(BOOL)flag
{
    if(!highlightView)
    {
        highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
        [highlightView setBackgroundColor:[CPColor blueColor]];
    }

    if(flag)
    {
        [self addSubview:highlightView positioned:CPWindowBelow relativeTo:label];
        [label setTextColor:[CPColor whiteColor]];
        [label setTextShadowColor:[CPColor blackColor]];
    }
    else
    {
        [highlightView removeFromSuperview];
        [label setTextColor:[CPColor blackColor]];
        [label setTextShadowColor:[CPColor whiteColor]];
    }
}

@end
