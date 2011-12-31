//
//  ImageLoader.m
//  picful
//
//  Created by luanjunyi on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageLoader.h"

@implementation ImageLoader

@synthesize images;

-(void) removerImageFromLocalCache {
    // Recover images cache, if any
    if (images != nil) {
        NSLog(@"images is not nil, skip recovering");
        return;
    }
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"images.cache"];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"Loading from image cache:(%@)", path);
        images = [NSMutableArray arrayWithContentsOfFile:path];
        if (images == nil) {
            NSLog(@"failed to remover from local cache");
            if ([delegate respondsToSelector:@selector(readLocalCacheFailed:)]) {
                [delegate readLocalCacheFailed:self];
            }
        } else {
            NSLog(@"recovered from local cache");
        }
    }

    if (images == nil) {
        NSLog(@"No image cache");
        images = [NSMutableArray arrayWithCapacity:50];
    }
}

-(void) writeToLocalCache {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"images.cache"];
    NSMutableArray *array = (NSMutableArray *)[images subarrayWithRange:NSMakeRange(0, MIN(50, images.count))];
    
    BOOL writeOK = [array writeToFile:path atomically:YES];
    if (!writeOK) {
        NSLog(@"failed to update local cache:(%@)", path);
    } else {
        NSLog(@"local cache updated");
    }
    if (!writeOK && [delegate respondsToSelector:@selector(writeLocalCacheFailed:)]) {
        [delegate writeLocalCacheFailed:self];
    }
}

- (void) synchronouslyLoadPictures {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hq2006.3322.org/picful/get_image.php"]];
    
    NSLog(@"Loading 20 more pictures");
    for (int i = 0; i < 20; i++) {
        NSURLResponse *resp;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
        if (data == nil) {
            NSLog(@"downloading image failed:%@", error.description);
        } else {
            NSLog(@"picture %d arrived", i);
            [images addObject:data];
            [delegate newPictureDidArrive:self];
        }
    }
}

-(void) loadMoreImages {
    [NSThread detachNewThreadSelector:@selector(synchronouslyLoadPictures) toTarget:self withObject:nil];
}

-(UIImage *)getNextImage {
    if (images.count == 0) {
        [self loadMoreImages];
        return nil;
    } else {
        NSData *data = [images lastObject];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [images removeLastObject];
        return image;
    }
}

@end
