//
//  ServerProtocol.m
//  ClippyMacClient
//
//  Created by Albert Pascual on 12/18/12.
//  Copyright (c) 2012 Esri. All rights reserved.
//

#import "ServerProtocol.h"

#define ServerURL @"http://clippy.azurewebsites.net/sync/"

@implementation ServerProtocol

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

- (BOOL) serverLogin:(NSString*)username Pasword:(NSString*)password
{
    
//"Login?username=" + Encrypter.base64Encode(Username) + "&Password=" + Encrypter.base64Encode(Password) + "&Version=1");
    
    NSString *encodedUsername = [ServerProtocol encodeBase64WithString:username];
    NSString *encodedPassword = [ServerProtocol encodeBase64WithString:password];
    NSString *loginUrl = [[NSString alloc] initWithFormat:@"Login?username=%@&Password=%@&Version=1", encodedUsername, encodedPassword];
    
    NSString *response = [self requestToServer:loginUrl];
    NSLog(@"Login Response is %@", response);
    
    if ( [response isEqualToString:@"true"] == YES)
        return YES;
    
    return NO;
}

- (BOOL) serverRegistration:(NSString *)username Password:(NSString*)password
{
    //"Register?username=" + Encrypter.base64Encode(Username) + "&Password=" + Encrypter.base64Encode(Password) + "&Version=1")
    
    NSString *encodedUsername = [ServerProtocol encodeBase64WithString:username];
    NSString *encodedPassword = [ServerProtocol encodeBase64WithString:password];
    
    NSString *registrationUrl = [[NSString alloc] initWithFormat:@"Register?username=%@&Password=%@&Version=1", encodedUsername, encodedPassword];
    
    NSString *response = [self requestToServer:registrationUrl];
    NSLog(@"Registration Response is %@", response);
    
    return YES;
}

- (NSString*) requestToServer:(NSString*)urlRequest
{
    NSString *fullUrl = [[NSString alloc] initWithFormat:@"%@%@", ServerURL, urlRequest];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];    
    NSString *get = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    return get;
}

- (double) sendTextToClipboard:(NSString*)clipboard withUsername:(NSString*)username Password:(NSString*)password
{
    //"SendClipboard?username=" + Encrypter.base64Encode(Username) + "&Password=" + Encrypter.base64Encode(Password) + "&Clipboard=" + Encrypter.base64Encode(sClipboard) + "&Version=1";
    

    NSString *encodedUsername = [ServerProtocol encodeBase64WithString:username];
    NSString *encodedPassword = [ServerProtocol encodeBase64WithString:password];
    NSString *encodedClipboard = [ServerProtocol encodeBase64WithString:clipboard];
    
    NSString *clipboardUrl = [[NSString alloc] initWithFormat:@"SendClipboard?username=%@&Password=%@&Clipboard=%@&Version=1", encodedUsername, encodedPassword, encodedClipboard];
    
    NSString *response = [self requestToServer:clipboardUrl];
    NSLog(@"Clipboard Response %@", response);
    
    double responseDouble = [response doubleValue];    
    
    return responseDouble;
}

- (NSString*)getTextFromClipboard:(NSString*)username withPassword:(NSString*)password andSequenceNumber:(double)sequenceNumber
{
    //"GetClipboard?username=" + Encrypter.base64Encode(Username) + "&Password=" + Encrypter.base64Encode(Password) +
    //"&SequenceNumber=" + SequenceNumber + "&version=1"
    
    NSString *encodedUsername = [ServerProtocol encodeBase64WithString:username];
    NSString *encodedPassword = [ServerProtocol encodeBase64WithString:password];
    
    NSString *clipboardUrl = [[NSString alloc] initWithFormat:@"GerClipboard?username=%@&Password=%@&SequenceNumber=%f&version=1", encodedUsername, encodedPassword, sequenceNumber];
    
    NSString *response = [self requestToServer:clipboardUrl];
    
    return response;
}


// To Encode
+ (NSString *)encodeBase64WithString:(NSString *)strData {
    return [self encodeBase64WithData:[strData dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)encodeBase64WithData:(NSData *)objData {
    const unsigned char * objRawData = [objData bytes];
    char * objPointer;
    char * strResult;
    
    // Get the Raw Data length and ensure we actually have data
    int intLength = [objData length];
    if (intLength == 0) return nil;
    
    // Setup the String-based Result placeholder and pointer within that placeholder
    strResult = (char *)calloc((((intLength + 2) / 3) * 4) + 1, sizeof(char));
    objPointer = strResult;
    
    // Iterate through everything
    while (intLength > 2) { // keep going until we have less than 24 bits
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
        
        // we just handled 3 octets (24 bits) of data
        objRawData += 3;
        intLength -= 3;
    }
    
    // now deal with the tail end of things
    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }
    
    // Terminate the string-based result
    *objPointer = '\0';
    
    // Create result NSString object
    NSString *base64String = [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
    
    // Free memory
    free(strResult);
    
    return base64String;
}

//To decode
+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
    const char *objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
    size_t intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    unsigned char *objResult = calloc(intLength, sizeof(unsigned char));
    
    // Run through the whole string, converting as we go
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                // the padding character is invalid at this point -- so this entire string is invalid
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // we're at a whitespace -- simply skip over
            continue;
        } else if (intCurrent == -2) {
            // we're at an invalid character
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    // mop things up if we ended on a boundary
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;
                
            case 2:
                k++;
                // flow through
            case 3:
                objResult[k] = 0;
        }
    }
    
    // Cleanup and setup the return NSData
    NSData * objData = [[NSData alloc] initWithBytes:objResult length:j];
    free(objResult);
    return objData;
}


/*

 
 public double SendTextToClipboard(string Username, string Password, string sClipboard)
 {
 string sRequestString = "SendClipboard?username=" + Encrypter.base64Encode(Username) + "&Password=" + Encrypter.base64Encode(Password) + "&Clipboard=" + Encrypter.base64Encode(sClipboard) + "&Version=1";
 string sResponse = RequestToServer(sRequestString);
 
 double SyncID = 0;
 try
 {
 Console.WriteLine("DEBUG: response: " + sResponse);
 SyncID = Convert.ToDouble(sResponse);
 }
 catch
 {
 SyncID = -1;
 }
 
 return SyncID;
 }
 
 public string GetTextFromClipboard(string Username, string Password, double SequenceNumber)
 {
 string sRequestString = "GetClipboard?username=" + Encrypter.base64Encode(Username) + "&Password=" + Encrypter.base64Encode(Password) +
 "&SequenceNumber=" + SequenceNumber + "&version=1";
 
 // Timeouts happen
 string sResponse = "";
 try
 {
 sResponse = RequestToServer(sRequestString);
 }
 catch { }
 
 
 return sResponse;
 }
 
 public string RegistrationUrl()
 {
 return Server.Url.Replace("sync/", "Account/Register");
 }
 
 private string RequestToServer(string sUrlRequest)
 {
 string sUrl = Server.Url + sUrlRequest;
 
 WebClient client = new WebClient();
 return client.DownloadString(sUrl);
 }*/

@end
