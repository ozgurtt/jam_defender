#import "EJBindingImage.h"
#import "EJJavaScriptView.h"
#import "EJNonRetainingProxy.h"
#import "EJTexture.h"

@implementation EJBindingImage
@synthesize texture;

- (void)beginLoad {
	// This will begin loading the texture in a background thread and will call the
	// JavaScript onload callback when done
	loading = YES;
	
	// Protect this image object from garbage collection, as its callback function
	// may be the only thing holding on to it
	JSValueProtect(scriptView.jsGlobalContext, jsObject);
	
	NSString *fullPath;

	// If path is a Data URI or remote URL we don't want to prepend resource paths
	if( [path hasPrefix:@"data:"] ) {
		NSLog(@"Loading Image from Data URI");
		fullPath = path;
	}
	else if( [path hasPrefix:@"http:"] || [path hasPrefix:@"https:"] ) {
		NSLog(@"Loading Image from URL: %@", path);
		fullPath = path;
	}
	else {
		NSLog(@"Loading Image: %@", path);
		fullPath = [scriptView pathForResource:path];
	}
	
	// Use a non-retaining proxy for the callback operation and take care that the
	// loadCallback is always cancelled when dealloc'ing
	loadCallback = [[NSInvocationOperation alloc]
		initWithTarget:[EJNonRetainingProxy proxyWithTarget:self]
		selector:@selector(endLoad) object:nil];
	
	texture = [[EJTexture cachedTextureWithPath:fullPath
		loadOnQueue:scriptView.backgroundQueue callback:loadCallback] retain];
}

- (void)prepareGarbageCollection {
	[loadCallback cancel];
	[loadCallback release];
	loadCallback = nil;
}

- (void)dealloc {
	[loadCallback cancel];
	[loadCallback release];
	
	[texture release];
	[path release];
	[super dealloc];
}

- (void)endLoad {
	loading = NO;
	[loadCallback release];
	loadCallback = nil;
	
	[self triggerEvent:(texture.textureId ? @"load" : @"error")];
	JSValueUnprotect(scriptView.jsGlobalContext, jsObject);
}

EJ_BIND_GET(src, ctx ) { 
	JSStringRef src = JSStringCreateWithUTF8CString( path.UTF8String );
	JSValueRef ret = JSValueMakeString(ctx, src);
	JSStringRelease(src);
	return ret;
}

EJ_BIND_SET(src, ctx, value) {
	// If the texture is still loading, do nothing to avoid confusion
	// This will break some edge cases; FIXME
	if( loading ) { return; }
	
	NSString *newPath = JSValueToNSString( ctx, value );
	
	// Same as the old path? Nothing to do here
	if( [path isEqualToString:newPath] ) { return; }
	
	
	// Release the old path and texture?
	if( path ) {
		[path release];
		path = nil;
		
		[texture release];
		texture = nil;
	}
	
	if( !JSValueIsNull(ctx, value) && [newPath length] ) {
		path = [newPath retain];
		[self beginLoad];
	}
}

EJ_BIND_GET(width, ctx ) {
	return JSValueMakeNumber( ctx, texture ? (texture.width / texture.contentScale) : 0);
}

EJ_BIND_GET(height, ctx ) { 
	return JSValueMakeNumber( ctx, texture ? (texture.height / texture.contentScale) : 0 );
}

EJ_BIND_GET(complete, ctx ) {
	return JSValueMakeBoolean(ctx, (texture && texture.textureId) );
}

EJ_BIND_EVENT(load);
EJ_BIND_EVENT(error);

EJ_BIND_GET(nodeName, ctx ) {
	return NSStringToJSValue(ctx, @"IMG");
}

@end
