void
end
delete
termination 
end
stop 









































































@implementation Delegate

- (void)_logDelegateCall:(SEL)selector {
  fprintf(stdout, "<DELEGATE METHOD \"%s\" CALLED>\n", [NSStringFromSelector(selector) UTF8String]);
}

- (void)webServerDidStart:(GCDWebServer*)server {
  [self _logDelegateCall:_cmd];
}

- (void)webServerDidCompleteBonjourRegistration:(GCDWebServer*)server {
  [self _logDelegateCall:_cmd];
}

- (void)webServerDidUpdateNATPortMapping:(GCDWebServer*)server {
  [self _logDelegateCall:_cmd];
}

- (void)webServerDidConnect:(GCDWebServer*)server {
  [self _logDelegateCall:_cmd];
}

- (void)webServerDidDisconnect:(GCDWebServer*)server {
  [self _logDelegateCall:_cmd];
}

- (void)webServerDidStop:(GCDWebServer*)server {
  [self _logDelegateCall:_cmd];
}

- (void)davServer:(GCDWebDAVServer*)server didDownloadFileAtPath:(NSString*)path {
  [self _logDelegateCall:_cmd];
}

- (void)davServer:(GCDWebDAVServer*)server didUploadFileAtPath:(NSString*)path {
  [self _logDelegateCall:_cmd];
}

- (void)davServer:(GCDWebDAVServer*)server didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
  [self _logDelegateCall:_cmd];
}

- (void)davServer:(GCDWebDAVServer*)server didCopyItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
  [self _logDelegateCall:_cmd];
}

- (void)davServer:(GCDWebDAVServer*)server didDeleteItemAtPath:(NSString*)path {
  [self _logDelegateCall:_cmd];
}

- (void)davServer:(GCDWebDAVServer*)server didCreateDirectoryAtPath:(NSString*)path {
  [self _logDelegateCall:_cmd];
}

- (void)webUploader:(GCDWebUploader*)uploader didDownloadFileAtPath:(NSString*)path {
  [self _logDelegateCall:_cmd];
}

- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
  [self _logDelegateCall:_cmd];
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
  [self _logDelegateCall:_cmd];
}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
  [self _logDelegateCall:_cmd];
}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
  [self _logDelegateCall:_cmd];
}

@end

int main(int argc, const char* argv[]) {
  int result = -1;
  @autoreleasepool {
    Mode mode = kMode_WebServer;
    BOOL recording = NO;
    NSString* rootDirectory = NSHomeDirectory();
    NSString* testDirectory = nil;
    NSString* authenticationMethod = nil;
    NSString* authenticationRealm = nil;
    NSString* authenticationUser = nil;
    NSString* authenticationPassword = nil;
    BOOL bindToLocalhost = NO;
    BOOL requestNATPortMapping = NO;

    if (argc == 1) {
      fprintf(stdout, "Usage: %s [-mode webServer | htmlPage | htmlForm | htmlFileUpload | webDAV | webUploader | streamingResponse | asyncResponse] [-record] [-root directory] [-tests directory] [-authenticationMethod Basic | Digest] [-authenticationRealm realm] [-authenticationUser user] [-authenticationPassword password] [--localhost]\n\n", basename((char*)argv[0]));
    } else {
      for (int i = 1; i < argc; ++i) {
        if (argv[i][0] != '-') {
          continue;
        }
        if (!strcmp(argv[i], "-mode") && (i + 1 < argc)) {
          ++i;
          if (!strcmp(argv[i], "webServer")) {
            mode = kMode_WebServer;
          } else if (!strcmp(argv[i], "htmlPage")) {
            mode = kMode_HTMLPage;
          } else if (!strcmp(argv[i], "htmlForm")) {
            mode = kMode_HTMLForm;
          } else if (!strcmp(argv[i], "htmlFileUpload")) {
            mode = kMode_HTMLFileUpload;
          } else if (!strcmp(argv[i], "webDAV")) {
            mode = kMode_WebDAV;
          } else if (!strcmp(argv[i], "webUploader")) {
            mode = kMode_WebUploader;
          } else if (!strcmp(argv[i], "streamingResponse")) {
            mode = kMode_StreamingResponse;
          } else if (!strcmp(argv[i], "asyncResponse")) {
            mode = kMode_AsyncResponse;
          }
        } else if (!strcmp(argv[i], "-record")) {
          recording = YES;
        } else if (!strcmp(argv[i], "-root") && (i + 1 < argc)) {
          ++i;
          rootDirectory = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:argv[i] length:strlen(argv[i])];
        } else if (!strcmp(argv[i], "-tests") && (i + 1 < argc)) {
          ++i;
          testDirectory = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:argv[i] length:strlen(argv[i])];
        } else if (!strcmp(argv[i], "-authenticationMethod") && (i + 1 < argc)) {
          ++i;
          authenticationMethod = [NSString stringWithUTF8String:argv[i]];
        } else if (!strcmp(argv[i], "-authenticationRealm") && (i + 1 < argc)) {
          ++i;
          authenticationRealm = [NSString stringWithUTF8String:argv[i]];
        } else if (!strcmp(argv[i], "-authenticationUser") && (i + 1 < argc)) {
          ++i;
          authenticationUser = [NSString stringWithUTF8String:argv[i]];
        } else if (!strcmp(argv[i], "-authenticationPassword") && (i + 1 < argc)) {
          ++i;
          authenticationPassword = [NSString stringWithUTF8String:argv[i]];
        } else if (!strcmp(argv[i], "--localhost")) {
          bindToLocalhost = YES;
        } else if (!strcmp(argv[i], "--nat")) {
          requestNATPortMapping = YES;
        }
      }
    }

    GCDWebServer* webServer = nil;
    switch (mode) {
      // Simply serve contents of home directory
      case kMode_WebServer: {
        fprintf(stdout, "Running in Web Server mode from \"%s\"\n", [rootDirectory UTF8String]);
        webServer = [[GCDWebServer alloc] init];
        [webServer addGETHandlerForBasePath:@"/" directoryPath:rootDirectory indexFilename:nil cacheAge:0 allowRangeRequests:YES];
        break;
      }

      // Renders a HTML page
      case kMode_HTMLPage: {
        fprintf(stdout, "Running in HTML Page mode\n");
        webServer = [[GCDWebServer alloc] init];
        [webServer addDefaultHandlerForMethod:@"GET"
                                 requestClass:[GCDWebServerRequest class]
                                 processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
                                   return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
                                 }];
        break;
      }

      // Implements an HTML form
      case kMode_HTMLForm: {
        fprintf(stdout, "Running in HTML Form mode\n");
        webServer = [[GCDWebServer alloc] init];
        [webServer addHandlerForMethod:@"GET"
                                  path:@"/"
                          requestClass:[GCDWebServerRequest class]
                          processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
                            NSString* html = @" \
            
        ";
        [webServer addHandlerForMethod:@"GET"
                                  path:@"/"
                          requestClass:[GCDWebServerRequest class]
                          processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
                            NSString* html = [NSString stringWithFormat:@"<html><body>%@</body></html>", formHTML];
                            return [GCDWebServerDataResponse responseWithHTML:html];
                          }];
        [webServer addHandlerForMethod:@"POST"
                                  path:@"/"
                          requestClass:[GCDWebServerMultiPartFormRequest class]
                          processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
                            NSMutableString* string = [NSMutableString string];
                            for (GCDWebServerMultiPartArgument* argument in [(GCDWebServerMultiPartFormRequest*)request arguments]) {
                              [string appendFormat:@"%@ = %@<br>", argument.controlName, argument.string];
                            }
                            for (GCDWebServerMultiPartFile* file in [(GCDWebServerMultiPartFormRequest*)request files]) {
                              NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file.temporaryPath error:NULL];
                              [string appendFormat:@"%@ = &quot;%@&quot; (%@ | %llu %@)<br>", file.controlName, file.fileName, file.mimeType,
                                                   attributes.fileSize >= 1000 ? attributes.fileSize / 1000 : attributes.fileSize,
                                                   attributes.fileSize >= 1000 ? @"KB" : @"Bytes"];
                            };
                            NSString* html = [NSString stringWithFormat:@"<html><body><p>%@</p><hr>%@</body></html>", string, formHTML];
                            return [GCDWebServerDataResponse responseWithHTML:html];
                          }];
        break;
      }

      // Serve home directory through WebDAV
      case kMode_WebDAV: {
        fprintf(stdout, "Running in WebDAV mode from \"%s\"\n", [rootDirectory UTF8String]);
        webServer = [[GCDWebDAVServer alloc] initWithUploadDirectory:rootDirectory];
        break;
      }

      // Serve home directory through web uploader
      case kMode_WebUploader: {
        fprintf(stdout, "Running in Web Uploader mode from \"%s\"\n", [rootDirectory UTF8String]);
        webServer = [[GCDWebUploader alloc] initWithUploadDirectory:rootDirectory];
        break;
      }

      // Test streaming responses
      case kMode_StreamingResponse: {
        fprintf(stdout, "Running in Streaming Response mode\n");
        webServer = [[GCDWebServer alloc] init];
        [webServer addHandlerForMethod:@"GET"
                                  path:@"/sync"
                          requestClass:[GCDWebServerRequest class]
                          processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
                            __block int countDown = 10;
                            return [GCDWebServerStreamedResponse responseWithContentType:@"text/plain"
                                                                             streamBlock:^NSData*(NSError** error) {
                                                                               usleep(100 * 1000);
                                                                               if (countDown) {
                                                                                 return [[NSString stringWithFormat:@"%i\n", countDown--] dataUsingEncoding:NSUTF8StringEncoding];
                                                                               } else {
                                                                                 return [NSData data];
                                                                               }
                                                                             }];
                          }];
        [webServer addHandlerForMethod:@"GET"
                                  path:@"/async"
                          requestClass:[GCDWebServerRequest class]
                          processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
                            __block int countDown = 10;
                            return [GCDWebServerStreamedResponse responseWithContentType:@"text/plain"
                                                                        asyncStreamBlock:^(GCDWebServerBodyReaderCompletionBlock completionBlock) {
                                                                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                            NSData* data = countDown ? [[NSString stringWithFormat:@"%i\n", countDown--] dataUsingEncoding:NSUTF8StringEncoding] : [NSData data];
                                                                            completionBlock(data, nil);
                                                                          });
                                                                        }];
                          }];
        break;
      }

      // Test async responses
      case kMode_AsyncResponse: {
        fprintf(stdout, "Running in Async Response mode\n");
        webServer = [[GCDWebServer alloc] init];
        [webServer addHandlerForMethod:@"GET"
                                  path:@"/async"
                          requestClass:[GCDWebServerRequest class]
                     asyncProcessBlock:^(GCDWebServerRequest* request, GCDWebServerCompletionBlock completionBlock) {
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         GCDWebServerDataResponse* response = [GCDWebServerDataResponse responseWithData:(NSData*)[@"Hello World!" dataUsingEncoding:NSUTF8StringEncoding] contentType:@"text/plain"];
                         completionBlock(response);
                       });
                     }];
        [webServer addHandlerForMethod:@"GET"
                                  path:@"/async2"
                          requestClass:[GCDWebServerRequest class]
                     asyncProcessBlock:^(GCDWebServerRequest* request, GCDWebServerCompletionBlock handlerCompletionBlock) {
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         __block int countDown = 10;
                         GCDWebServerStreamedResponse* response = [GCDWebServerStreamedResponse responseWithContentType:@"text/plain"
                                                                                                       asyncStreamBlock:^(GCDWebServerBodyReaderCompletionBlock readerCompletionBlock) {
                                                                                                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                                                           NSData* data = countDown ? [[NSString stringWithFormat:@"%i\n", countDown--] dataUsingEncoding:NSUTF8StringEncoding] : [NSData data];
                                                                                                           readerCompletionBlock(data, nil);
                                                                                                         });
                                                                                                       }];
                         handlerCompletionBlock(response);
                       });
                     }];
        break;
      }
    }

    if (webServer) {
      Delegate* delegate = [[Delegate alloc] init];
      if (testDirectory) {
#if DEBUG
        webServer.delegate = delegate;
#endif
        fprintf(stdout, "<RUNNING TESTS FROM \"%s\">\n\n", [testDirectory UTF8String]);
        result = (int)[webServer runTestsWithOptions:@{GCDWebServerOption_Port : @8080} inDirectory:testDirectory];
      } else {
        webServer.delegate = delegate;
        if (recording) {
          fprintf(stdout, "<RECORDING ENABLED>\n");
          webServer.recordingEnabled = YES;
        }
        fprintf(stdout, "\n");
        NSMutableDictionary* options = [NSMutableDictionary dictionary];
        [options setObject:@8080 forKey:GCDWebServerOption_Port];
        [options setObject:@(requestNATPortMapping) forKey:GCDWebServerOption_RequestNATPortMapping];
        [options setObject:@(bindToLocalhost) forKey:GCDWebServerOption_BindToLocalhost];
        [options setObject:@"" forKey:GCDWebServerOption_BonjourName];
        if (authenticationUser && authenticationPassword) {
          [options setValue:authenticationRealm forKey:GCDWebServerOption_AuthenticationRealm];
          [options setObject:@{authenticationUser : authenticationPassword} forKey:GCDWebServerOption_AuthenticationAccounts];
          if ([authenticationMethod isEqualToString:@"Basic"]) {
            [options setObject:GCDWebServerAuthenticationMethod_Basic forKey:GCDWebServerOption_AuthenticationMethod];
          } else if ([authenticationMethod isEqualToString:@"Digest"]) {
            [options setObject:GCDWebServerAuthenticationMethod_DigestAccess forKey:GCDWebServerOption_AuthenticationMethod];
          }
        }
        if ([webServer runWithOptions:options error:NULL]) {
          result = 0;
        }
      }
      webServer.delegate = nil;
    }
  }
  return result;
}
