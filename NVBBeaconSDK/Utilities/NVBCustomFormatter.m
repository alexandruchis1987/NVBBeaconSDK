//
//  NVBCustomFormatter.m
//  NVBBeaconSDK
//
//  Created by d on 1/12/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "NVBCustomFormatter.h"

@implementation NVBCustomFormatter


- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError    : logLevel = @"Error"; break;
        case DDLogFlagWarning  : logLevel = @"Warn"; break;
        case DDLogFlagInfo     : logLevel = @"Info"; break;
        case DDLogFlagDebug    : logLevel = @"Debug"; break;
        default                : logLevel = @"Verbose"; break;
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/mm/yyyy HH:mm"];
    
    return [NSString stringWithFormat:@"%@ %@ %@::%@(%ld)| %@", logLevel,
            [dateFormatter stringFromDate:logMessage->_timestamp],
            logMessage->_fileName,
            logMessage->_function,
            logMessage->_line,
            logMessage->_message];
}


@end
