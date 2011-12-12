@implementation CHLuaBridge : CPObject
{
    CPString    filename;
    CPString    project;
    CPString    realURL;
    CPString    code;
    int         fd;

    int         stage;  // 1: Starting up  2: Established
    id          delegate;
}


- (id)initWithFilename:(CPString)aFilename project:(CPString)aProject delegate:(id)aDelegate
{
    self = [super init];
    if (self) {
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

- (id)initWithString:(CPString)theCode delegate:(id)aDelegate
{
    self = [super init];
    if (self) {
        code = theCode;
        fd = -1;
        stage = 1;
        delegate = aDelegate;

            realURL = @"/lua/open";
        [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:realURL]]
                                        delegate:self
                                startImmediately:YES];
    }
}

- (void)setBreakpoint:(int)line
{
    var realURL = [CPString stringWithFormat:@"/lua/bpadd/%d/%d:%s", fd, line, filename];
    [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:realURL]]
                                    delegate:self
                            startImmediately:YES];
}

- (void)clearBreakpoint:(int)line
{
    var realURL = [CPString stringWithFormat:@"/lua/bpdel/%d/%d:%s", fd, line, filename];
    [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:realURL]]
                                    delegate:self
                            startImmediately:YES];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    CPLog(@"Lua Bridge failed with error %@", error);
    fd = -1;
}

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    if ([response statusCode] != 200) {
        if ([response statusCode] == 204) {
            CPLog(@"Connction closed");
            if ([delegate respondsToSelector:@selector(luaBridge:programEnded:)])
                [delegate luaBridge:self programEnded:0];
        }
        else {
            if ([delegate respondsToSelector:@selector(luaBridge:programEnded:)])
                [delegate luaBridge:self programEnded:1];
            CPLog(@"Error occurred");
        }
        fd = -1;
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (stage == 1) {
        fd = data;
        stage = 2;
        realURL = [CPString stringWithFormat:@"/lua/stdio/%d", fd];
        if (code) {
            /* Post the code to stdin */
            var req = [CPURLRequest requestWithURL:[CPURL URLWithString:realURL]];
            [req setHTTPMethod:@"POST"];
            [req setHTTPBody:[code stringByAppendingString:@"\n"]];
            [[CPURLConnection alloc] initWithRequest:req
                                            delegate:self
                                    startImmediately:YES];
        }
    }
    else if (fd >= 0) {
        if ([delegate respondsToSelector:@selector(luaBridge:gotStdout:)])
            [delegate luaBridge:self gotStdout:data];
    }
}

- (void)connectionDidFinishLoading:(CPURLConnection)connection {
    if (fd >= 0)
        [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:realURL]]
                                        delegate:self
                                startImmediately:YES];
}

@end
