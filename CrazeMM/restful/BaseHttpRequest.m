//
//  BaseHttpRequest.m
//  CrazeMM
//
//  Created by saix on 16/4/28.
//  Copyright © 2016年 189. All rights reserved.
//

#import "BaseHttpRequest.h"
#import "LoginViewController.h"
#import "UIAlertView+AnyPromise.h"

#define CustomErrorDomain @"com.189mm"
typedef enum {
    k189MMHttpRequestFailed = -1000,
//    XRegisterFailed,
//    XConnectFailed,
//    XNotBindedFailed
}CustomErrorFailed;

@interface BaseHttpRequest ()

//@property (nonatomic, readonly) AFHTTPRequestOperationManager *manager;
@end


@implementation BaseHttpRequest

-(AFHTTPRequestOperationManager*)manager
{
    AFHTTPRequestOperationManager* mgr = [AFHTTPRequestOperationManager manager];
    
    NSURL* url = [NSURL URLWithString:COMB_URL(@"")];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    NSDictionary* requestHeaderFieldsWithCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [mgr.requestSerializer setValue:requestHeaderFieldsWithCookies[@"Cookie"] forHTTPHeaderField:@"Cookie"];
    
    // set request timeout 10s
//    [mgr.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    mgr.requestSerializer.timeoutInterval = 10.f;
//    [mgr.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    return mgr;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
        self.params =  [@{} mutableCopy];;
        
    }
    
    return self;
}

-(NSMutableDictionary*)getTokenParams
{
    return [@{@"name": self.tokenName} mutableCopy];
}

-(Class)responseClass
{
    return [BaseHttpResponse class];
}

-(NSString*)tokenName
{
    return @"invalid_token_name";
}

-(NSString*)url
{
    return COMB_URL(@"invalid_url");
}

-(NSString*)method
{
    return @"GET";
}

-(AFPromise*)request
{

    
    return [self request2]
    .catch(^(NSError *error){
//        if ([error needLogin] && self.caller) {
//            [self.caller.navigationController pushViewController:[LoginViewController new] animated:YES];
//            //return [[UIAlertView new] promise];
//            return (NSError *)nil;
//        }
//        else {
            return error ;
//        }
    });
}

-(AFPromise*)request2
{
    if (self.needToken) {
        
        return [self getTokenThenDoRequest];
    }
    else {
        [self.params removeObjectForKey:self.tokenName];
        return [self doResqust];
    }
    
    return nil;
}

-(AFPromise*)requestWithErrorCallback:(errorCallback)callback
{
    
    if (callback == nil) {
        return [self request];
    }
    else {
        if (self.needToken) {
            
            return [self getTokenThenDoRequest].catch(^(NSError *error){
                callback(error);
                return [BaseHttpRequest httpRequestError:@""];

            });
        }
        else {
            [self.params removeObjectForKey:self.tokenName];
            return [self doResqust].catch(^(NSError *error){
                callback(error);
                return [BaseHttpRequest httpRequestError:@""];
            });
        }
        
        return nil;
    }
    
}

//-(AFPromise*)requestWithAcceptContentTypes:(NSSet*)AcceptContentTypes andReponse

-(AFPromise*)requestWithAcceptContentTypes:(NSSet*)AcceptContentTypes
{
    
//    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.url] sessionConfiguration:configuration];

//    AFHTTPResponseSerializer           二进制格式
//    AFJSONResponseSerializer           JSON
//    AFXMLParserResponseSerializer      XML,只能返回XMLParser,还需要自己通过代理方法解析
//    AFXMLDocumentResponseSerializer (Mac OS X)
//    AFPropertyListResponseSerializer   PList
//    AFImageResponseSerializer          Image
//    AFCompoundResponseSerializer       组合
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = AcceptContentTypes;


    return [self doResqustWithSessionManage:manager];
    
//    return [manager GET:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
//        self.response = [[[self responseClass] alloc] initWith:responseObject];
//        return responseObject;
//    });
}

-(AFPromise*)getTokenThenDoRequest
{
    //NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString: @"http://b.189mm.com"]];

    
    return [self.manager GET:COMB_URL(GET_TOKEN_PATH) parameters:[self getTokenParams]]
    .then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);
        if (![responseObject[@"ok"] boolValue]) {
            return [BaseHttpRequest httpRequestError:[NSString stringWithFormat:@"Get %@ Failed!", [self getTokenParams][@"name"]]];
        }
        
        [self.params setObject:responseObject[self.tokenName] forKey:self.tokenName];
        return [self doResqust];
    });
}

+(AFPromise*)httpRequestError:(NSString*)errorString
{

    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorString                                                                     forKey:NSLocalizedDescriptionKey];
    
    return (AFPromise*)[[NSError alloc] initWithDomain:CustomErrorDomain code:k189MMHttpRequestFailed userInfo:userInfo];
}

-(AFPromise*)getTokenFaield:(id)responseObject
{
    return (AFPromise*)[[NSError alloc] initWithDomain:@"" code:NSURLErrorUnknown userInfo:@{}];
;
}

-(AFPromise*)doResqust
{
//    [self.manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if ([self.method.uppercaseString isEqualToString:@"POST"]) {
        return [self doPostRequest];
    }
    else if ([self.method.uppercaseString isEqualToString:@"PUT"]){
        return [self doPutRequst];

    }
    else  if([self.method.uppercaseString isEqualToString:@"DELETE"]){
        return [self doDeleteRequest];
        
    }
    else  if([self.method.uppercaseString isEqualToString:@"HEAD"]){
        return [self doHeadRequest];
        
    }
    else {
        return [self doGetRequest];
    }
}

-(AFPromise*)doPutRequst
{
    return [self.manager PUT:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);
        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}

-(AFPromise*)doPostRequest
{
    return [self.manager POST:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);
        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}


-(AFPromise*)doGetRequest
{
    return [self.manager GET:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);

        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}

-(AFPromise*)doDeleteRequest
{
    return [self.manager DELETE:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);

        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}

-(AFPromise*)doHeadRequest
{
    return [self.manager HEAD:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);

        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return [responseObject promise];
    });
}

-(AFPromise*)doResqustWithSessionManage:(AFHTTPSessionManager*)sessionManage
{
    if ([self.method.uppercaseString isEqualToString:@"POST"]) {
        return [self doPostRequestWithSessionManage:sessionManage];
    }
    else if ([self.method.uppercaseString isEqualToString:@"PUT"]){
        return [self doPutRequstWithSessionManage:sessionManage];
        
    }
    else  if([self.method.uppercaseString isEqualToString:@"DELETE"]){
        return [self doDeleteRequestWithSessionManage:sessionManage];
        
    }
    else  if([self.method.uppercaseString isEqualToString:@"HEAD"]){
        return [self doHeadRequestWithSessionManage:sessionManage];
        
    }
    else {
        return [self doGetRequestWithSessionManage:sessionManage];
    }
}

-(AFPromise*)doPutRequstWithSessionManage:(AFHTTPSessionManager*)sessionManage
{
    return [self.manager PUT:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}

-(AFPromise*)doPostRequestWithSessionManage:(AFHTTPSessionManager*)sessionManage
{
    return [self.manager POST:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);

        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}


-(AFPromise*)doGetRequestWithSessionManage:(AFHTTPSessionManager*)sessionManage
{
    return [sessionManage GET:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);

        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}

-(AFPromise*)doDeleteRequestWithSessionManage:(AFHTTPSessionManager*)sessionManage
{
    return [sessionManage DELETE:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);

        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}

-(AFPromise*)doHeadRequestWithSessionManage:(AFHTTPSessionManager*)sessionManage
{
    return [sessionManage HEAD:self.url parameters:self.params].then(^(id responseObject, AFHTTPRequestOperation *operation){
        NSLog(@"response status: %ld,  header : %@", operation.response.statusCode, operation.response.allHeaderFields);

        self.response = [[[self responseClass] alloc] initWith:responseObject];
        return responseObject;
    });
}



@end

@implementation BaseHttpResponse

-(instancetype)initWith:(NSDictionary*)response
{
    self = [super init];
    if (self) {
        
        // TODO
        // for some request, its response is not NSDictionary
        self.all = response;
        [self parserResponse];

    }
    
    return self;
}

-(void)parserResponse
{
    
}

-(NSString*)errorTitle
{
    return @"HTTP Request Failed!";
}

-(NSString*)errorDetail
{
    return nil;
}

-(BOOL)ok
{
    if (!self.all) {
        return NO;
    }
    
    NSString* ok = self.all[@"ok"];
    if (ok) {
        return [ok intValue] != 0;
    }
    else {
        return NO;
    }
}

-(NSString*)errorMsg
{
    if (!self.all) {
        return nil;
    }

    
    NSString* msg = self.all[@"msg"];
    return msg;
}


-(NSDictionary*)data
{
    if (!self.all) {
        return nil;
    }
    
    return self.all[@"data"];
}

@end
