//
//  MDWampAdvancedTests.m
//  MDWamp
//
//  Created by Niko Usai on 09/10/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CommonCrypto/CommonCrypto.h>
#import "MDWamp.h"
#import "MDWampTestIncludes.h"
#import "XCTAsyncTestCase.h"

#define SECRET @"C8qpncoHEXUzr5CBdvS7"

@interface MDWampAdvancedTests : XCTAsyncTestCase
@property (strong, nonatomic) MDWamp *wamp;
@property (strong, nonatomic) MDWampClientDelegateMock *delegate;
@property (strong, nonatomic) MDWampTransportMock *transport;
@property (strong, nonatomic) MDWampSerializationMock *s;
@property (strong, nonatomic) NSDictionary *dictionaryPayload;
@property (strong, nonatomic) NSArray *arrayPayload;
@end

@implementation MDWampAdvancedTests

- (void)setUp
{
    [super setUp];
    _delegate = [[MDWampClientDelegateMock alloc] init];
    _transport = [[MDWampTransportMock alloc] initWithServer:[NSURL URLWithString:@"http://fakeserver.com"] protocolVersions:@[]];
    _transport.serializationClass = kMDWampSerializationMock;
    self.wamp = [[MDWamp alloc] initWithTransport:_transport realm:@"Realm1" delegate:_delegate];
    _s = [[MDWampSerializationMock alloc] init];
    
    self.dictionaryPayload = @{@"color": @"orange", @"sizes": @[@23, @42, @7]};
    self.arrayPayload = @[@1,@2, @34, @4545];
}

- (void)tearDown
{
    [super tearDown];
}

- (id<MDWampMessage>)msgFromTransportAndCheckIsA:(Class)class
{
    NSArray *arr = [_s unpack:[_transport.sendBuffer lastObject]];
    
    NSMutableArray *tmp = [arr mutableCopy];
    [tmp shift];
    
    id<MDWampMessage> msg = [[MDWampMessageFactory sharedFactory] objectFromCode:arr[0] withPayload:tmp];
    XCTAssertTrue([[msg class] isSubclassOfClass:class], @"Wrong class");
    XCTAssertNotNil(msg, @"An %@ message must be in the transport buffer", NSStringFromClass(class));
    
    return msg;
}

- (void)testAuthWampCRA {
    MDWampClientConfig *conf = [[MDWampClientConfig alloc] init];
    conf.authmethods = @[kMDWampAuthMethodCRA];
    conf.authid = @"guybrush";
    conf.sharedSecret = SECRET;
    [_wamp setConfig:conf];
    
    [self prepare];
    [_wamp connect];
    
    MDWampHello *msg = [self msgFromTransportAndCheckIsA:[MDWampHello class]];
    XCTAssertEqualObjects(@"guybrush", msg.details[@"authid"]);
    
    // server response normal Challenge
    MDWampChallenge* challenge = [[MDWampChallenge alloc] initWithPayload:@[ kMDWampAuthMethodCRA, @{ @"challenge" : @"{\"nonce\": \"LHRTC9zeOIrt_9U3\", \"authprovider\": \"userdb\", \"authid\": \"guybrush\",\"timestamp\": \"2014-06-22T16:36:25.448Z\",\"authmethod\": \"wampcra\", \"session\": 3251278072152162}" } ]];
    
    [_transport triggerDidReceiveMessage:[challenge marshall]];
    
    MDWampAuthenticate *auth = [self msgFromTransportAndCheckIsA:[MDWampAuthenticate class]];
    NSData *key = [SECRET dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [challenge.extra[@"challenge"] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, key.bytes, key.length, data.bytes, data.length, hash.mutableBytes);
    NSString *base64Hash = [hash base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    XCTAssertEqualObjects(base64Hash, auth.signature, @"Signature must be the same");

    
    // server response  Challenge with salt
//    MDWampChallenge* challenge2 = [[MDWampChallenge alloc] initWithPayload:@[ kMDWampAuthMethodCRA,
//            @{ @"challenge" : @"{\"nonce\": \"LHRTC9zeOIrt_9U3\", \"authprovider\": \"userdb\", \"authid\": \"guybrush\",\"timestamp\": \"2014-06-22T16:36:25.448Z\",\"authmethod\": \"wampcra\", \"session\": 3251278072152162}",
//               @"salt" : @"salt123",
//               @"keylen" : @32,
//               @"iterations" : @1000 } ]];
//    
//    [_transport triggerDidReceiveMessage:[challenge2 marshall]];
//    
//    MDWampAuthenticate *auth2 = [self msgFromTransportAndCheckIsA:[MDWampAuthenticate class]];
//    NSMutableData* hash2 = [NSMutableData dataWithLength:[@32 integerValue] ];
//    NSData *pass = [SECRET dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *salt = [@"salt123" dataUsingEncoding:NSUTF8StringEncoding];
//    CCKeyDerivationPBKDF(kCCPBKDF2, pass.bytes, pass.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA256, 1000, hash.mutableBytes, [@32 integerValue]);
//    NSString *base64Hash2 = [hash2 base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    
//    XCTAssertEqualObjects(base64Hash2, auth2.signature, @"Signature must be the same");
//    
    
    // auth succede simulate welcome message form server
    MDWampWelcome *welcome = [[MDWampWelcome alloc] init];
    welcome.session = [NSNumber numberWithInt:[@123123234324 intValue]];
    welcome.details = @{
        @"serverIdent" : @"MDWampServer",
        @"authid" : @"peter",
        @"authrole" : @"user",
        @"authmethod" : @"wampcra",
        @"authprovider" : @"userdb",
    };
    
    [_transport triggerDidReceiveMessage:[welcome marshall]];
    
    XCTAssertTrue([_wamp isConnected], @"must be connected");
    XCTAssertNotNil(_wamp.sessionId , @"Must have session");
}



- (void)testAuthWampCRAThreeLegged {
    MDWampClientConfig *conf = [[MDWampClientConfig alloc] init];
    conf.authmethods = @[kMDWampAuthMethodCRA];
    conf.authid = @"guybrush";
    conf.sharedSecret = SECRET;
    [conf setDeferredWampCRASigningBlock:^(NSString *challange, void(^finishBLock)(NSString *signature) ) {
        // do something with challenge
        // call http service ....
        NSString *sign = [challange substringToIndex:5];
       // ... then call finish block
        finishBLock(sign);
    }];
    
    [_wamp setConfig:conf];
    
    [self prepare];

    [_wamp connect];
    
    MDWampHello *msg = [self msgFromTransportAndCheckIsA:[MDWampHello class]];
    XCTAssertEqualObjects(@"guybrush", msg.details[@"authid"]);
    
    // server response normal Challenge
    MDWampChallenge* challenge = [[MDWampChallenge alloc] initWithPayload:@[ kMDWampAuthMethodCRA, @{ @"challenge" : @"{\"nonce\": \"LHRTC9zeOIrt_9U3\", \"authprovider\": \"userdb\", \"authid\": \"guybrush\",\"timestamp\": \"2014-06-22T16:36:25.448Z\",\"authmethod\": \"wampcra\", \"session\": 3251278072152162}" } ]];
    
    [_transport triggerDidReceiveMessage:[challenge marshall]];
    NSString *signature = [challenge.extra[@"challenge"] substringToIndex:5]; // Yeah signature !!
    MDWampAuthenticate *auth = [self msgFromTransportAndCheckIsA:[MDWampAuthenticate class]];

    
    XCTAssertEqualObjects(signature, auth.signature, @"Signature must be the same");
    
}

- (void)testAuthTicket {
    MDWampClientConfig *conf = [[MDWampClientConfig alloc] init];
    conf.authmethods = @[kMDWampAuthMethodTicket];
    conf.authid = @"guybrush";
    conf.ticket = SECRET;
    [_wamp setConfig:conf];
    
    [self prepare];
    [_wamp connect];
    
    MDWampHello *msg = [self msgFromTransportAndCheckIsA:[MDWampHello class]];
    XCTAssertEqualObjects(@"guybrush", msg.details[@"authid"]);
    
    // server response normal Challenge
    MDWampChallenge* challenge = [[MDWampChallenge alloc] initWithPayload:@[ kMDWampAuthMethodTicket, @{} ]];
    
    [_transport triggerDidReceiveMessage:[challenge marshall]];
    
    MDWampAuthenticate *auth = [self msgFromTransportAndCheckIsA:[MDWampAuthenticate class]];
    
    XCTAssertEqualObjects(SECRET, auth.signature, @"Signature must be the same");
    
    // auth succede simulate welcome message form server
    MDWampWelcome *welcome = [[MDWampWelcome alloc] init];
    welcome.session = [NSNumber numberWithInt:[@123123234324 intValue]];
    welcome.details = @{
                        @"serverIdent" : @"MDWampServer",
                        @"authid" : @"peter",
                        @"authrole" : @"user",
                        @"authmethod" : @"wampcra",
                        @"authprovider" : @"userdb",
                        };
    
    [_transport triggerDidReceiveMessage:[welcome marshall]];
    
    XCTAssertTrue([_wamp isConnected], @"must be connected");
    XCTAssertNotNil(_wamp.sessionId , @"Must have session");
}


@end
