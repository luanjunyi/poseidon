//
//  ImageLoader.h
//  picful
//
//  Created by luanjunyi on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ImageLoaderDelegate;

@interface ImageLoader: NSObject {
    @public
    id delegate;
}

@property (strong, nonatomic) NSMutableArray *images;

-(void) removerImageFromLocalCache;
-(void) writeToLocalCache;

-(void) loadMoreImages;
-(UIImage *) getNextImage;

@end


#pragma mark - delegate

@protocol ImageLoaderDelegate

-(void) newPictureDidArrive:(ImageLoader *)loader;

@optional
-(void) writeLocalCacheFailed:(ImageLoader *)loader;
-(void) readLocalCacheFailed:(ImageLoader *)loader;

@end
