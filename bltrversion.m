/*
       File: bltrversion.m
    Version: 0.1
   Abstract: A drop in replacement for the original bltrversion  
 Discussion: Replaces the PPC only version of bltrversion that comes with
			 the QuickSilver source code.  This allows updating of the
             QS plugin XML Property List files, without having to install
             Apple's Rosetta on Intel machines.
  Created by Paul Kohut on December 2, 2009
   Copyright (C) 2009 Paul Kohut. All rights reserved.
 
    License: Licensed under the Apache License, Version 2.0 (the "License");
             you may not use this file except in compliance with the License.
             You may obtain a copy of the License at
 
             http://www.apache.org/licenses/LICENSE-2.0
 
             Unless required by applicable law or agreed to in writing, software
             distributed under the License is distributed on an "AS IS" BASIS,
             WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
             See the License for the specific language governing permissions and
             limitations under the License.
*/


#import <Foundation/Foundation.h>

#define ERROR_SUCCESS 0
#define ERROR_NO_PARAMETERS 1
#define ERROR_TOO_MANY_PARAMETERS 2
#define ERROR_GETTING_FILE_ATTRIBUTES 3
#define ERROR_COULD_NOT_GET_DICTIONARY 4
#define ERROR_DICTIONARY_NOT_WRITTEN 5
#define ERROR_KEY_NOT_FOUND 6
#define ERROR_KEY_VALUE_INVALID 7

void manPage(void)
{
	printf("usage: bltrversion target_file\n\n");
	printf("  Opens the target_file if it is of type XML Property List. Then searches\n");
	printf("  for the key CFBundleVersion and increments the associated value by 1.\n");
//	printf("exit status: 0 on success and >0 if an error occurs.\n");
}

/*!
    @function   getUnsignedIntFromHexString
    @abstract   Converts input string to integer
    @discussion If input string cannot be converted then value is
				set to 0.
    @param      hexString (in) String to be converted
    @param      value (out) Integer version of hexString
    @result     0 on success, 1 of > otherwise
*/

int getUnsignedIntFromHexString(NSString * hexString, unsigned * value)
{
	NSScanner * scanner = [NSScanner scannerWithString:hexString];
	if(![scanner scanHexInt:value]) {
		// Found some invalid characters in the string.  Set value to 0.
		// set exitCode for informational purposes only and continue processing.
		*value = 0;
		return ERROR_KEY_VALUE_INVALID;
	}
	return ERROR_SUCCESS;	
}

/*!
    @function   incrementCFBundleVersion
    @abstract   
    @discussion Increments the hex value associated with key CFBundleVersion by
				1.  If key CFBundleVersion does not exist then it is add
				with an initial value of 1.
    @param      dict (in) dictionary to work with.
	@param      bundleVersion (out)
    @result     0 on success, 1 or > otherwise
*/
int incrementCFBundleVersion(NSMutableDictionary * dict, NSString ** bundleVersion)
{
	int exitCode = ERROR_SUCCESS;

	// Get key/value pair from dictionary
	NSString * keyValue = [dict objectForKey:@"CFBundleVersion"];
	if(!keyValue) {
		keyValue = @"0";
		//// setting exitCode for informational purposes only and		
		//// continue processing.
		//exitCode = ERROR_KEY_NOT_FOUND;
	}

	// CFBundleVersion number is in hex, convert to decimal ...
	unsigned value;
	exitCode = getUnsignedIntFromHexString(keyValue, &value);
	// ... increment by 1 ...
	value++;
	// ... and convert back to hex.
	keyValue = [[NSString stringWithFormat:@"%x", value] uppercaseString];
	
	// Set and/or add key/value pair to dictionary.
	[dict setObject:keyValue forKey:@"CFBundleVersion"];
	
	*bundleVersion = [[keyValue retain ]autorelease];
	return exitCode;
}

/*!
    @function   processFile
    @abstract   Updates XML Property List target file.
    @discussion Updates the targetFile if it is of type XML Property List by
				incrementing the assosiated value of key CFBundleVersion.
    @param      targetFile Input name of file to be processed
    @result     Returns 0 on success, > 0 otherwise.
*/

int processFile(const char * targetFile)
{
	int exitCode = ERROR_SUCCESS;
	
	NSString * infoFile = [NSString stringWithUTF8String:targetFile];
	NSError * error;

	NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:infoFile error:&error];
	if(!attributes) {
		printf("error: %s\n", [[error localizedDescription] UTF8String]);
		exitCode = ERROR_GETTING_FILE_ATTRIBUTES;		
	} else {
		NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithContentsOfFile:infoFile];
		if(!dict) {
			printf("error: Unexpected format. Is \"%s\" a property list file?\n", targetFile);
			exitCode = ERROR_COULD_NOT_GET_DICTIONARY;
		} else {
			NSString * bundleVersion = nil;
			if(ERROR_SUCCESS == exitCode && (exitCode = incrementCFBundleVersion(dict, &bundleVersion)) ) {
				if(ERROR_KEY_NOT_FOUND == exitCode) {
					printf("warning: CFBundleVersion key could not be found.\n");
					// change exitCode to ERROR_SUCCESS since this is just a warning.  This will allow
					// further processing to proceed and the dictionary to be serialized later.
					exitCode = ERROR_SUCCESS;
				} else if(ERROR_KEY_VALUE_INVALID == exitCode) {
					printf("warning: CFBundleVersion value had invalid hex characters.\n");
					exitCode = ERROR_SUCCESS;
				} else {
					exitCode = ERROR_SUCCESS;
				}
			}
			
			// do other key queries and modifications here
			// if(ERROR_SUCCESS == exitCode && (exitCode = doSomeWorkOnAKey(dict)) ) {}
			
			// write the dictionary back to the original file
			if(ERROR_SUCCESS == exitCode) {
				if(![dict writeToFile:infoFile atomically:NO]) {
					printf("error: Could not write dictionary to target_file\n");
					exitCode = ERROR_DICTIONARY_NOT_WRITTEN;
				} else {
					printf("CFBundleVersion set to %s\n", [bundleVersion UTF8String]);
					printf("\"%s\" successfully written\n", targetFile);
					exitCode = ERROR_SUCCESS;					
				}				
			}
		}
	}

	return exitCode;
}

// returns 0 on success
int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	int exitCode = 0;
	
	if(argc < 2) {
		manPage();
		exitCode = ERROR_NO_PARAMETERS;
	} else if(argc == 2) {

		exitCode = processFile(argv[1]);
	} else {
		printf("error: too many parameters provided.\n");
		manPage();
		exitCode = ERROR_TOO_MANY_PARAMETERS;
	}

    [pool drain];
    return exitCode;
}
