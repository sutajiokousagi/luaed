@implementation CHLuaBridge : CPObject
{
    CPString    filename;
    CPString    project;
    CPString    realURL;
    int         fd;

    int         stage;  // 1: Starting up  2: Established
    id          delegate;
    int c;
}


- (id)initWithFilename:(CPString)aFilename project:(CPString)aProject delegate:(id)aDelegate
{
    self = [super init];
    if (self) {
        c = 0;
        filename = aFilename;
        project = aProject;
        fd = -1;
        stage = 1;
        delegate = aDelegate;

        if (project && filename)
            realURL = [CPString stringWithFormat:@"/lua/open/%s/%s",
                                                 aProject, aFilename];
        else
            realURL = @"/lua/open";
        CPLog(@"Filename: %@  Project: %@  realURL: %@", aFilename,
                aProject, realURL);

        [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:realURL]]
                                        delegate:self
                                startImmediately:YES];
    }
}

-(void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    CPLog(@"Lua Bridge failed with error %@", error);
    fd = -1;
}

-(void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    if ([response statusCode] == 500)
        fd = -1;
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (stage == 1) {
        fd = data;
        stage = 2;
        realURL = [CPString stringWithFormat:@"/lua/stdio/%d", fd];
    }
    else {
        if ([delegate respondsToSelector:@selector(luaBridge:gotStdout:)])
            [delegate luaBridge:self gotStdout:data];
    }
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection {
    if (fd >= 0 && c++<15)
        [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:realURL]]
                                        delegate:self
                                startImmediately:YES];
}

@end
