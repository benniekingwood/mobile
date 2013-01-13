//
//  FontUtil.m
//  uLink
//
//  Created by Bennie Kingwood on 11/13/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "FontUtil.h"

@implementation FontUtil
-(void) listSystemFonts {
	NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
	NSArray *fontNames;
	NSInteger family, j;
	int numFamilies = [familyNames count];
	int numFonts = 0;	// tallied below
	for (family=0; family < numFamilies; ++family)
	{
		//Log(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
		fontNames = [[NSArray alloc] initWithArray: [UIFont fontNamesForFamilyName: [familyNames objectAtIndex: family]]];
		for (j=0; j<[fontNames count]; ++j)
		{
			NSLog(@"\"%@\", ", [fontNames objectAtIndex:j]);
			++numFonts;
		}
	}
}
@end
