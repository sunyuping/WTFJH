//Shall We Use Marcos instead of this shit?
#import "../SharedDefine.pch"
#import <mach-o/getsect.h>
#import <dlfcn.h>
extern NSString* RandomString();
typedef void (*WTLoaderPrototype)();  
extern void init_classdumpdyld_hook(){
#ifdef PROTOTYPE 
//Because We Ain't Ready Yet. No Test
	 for(int i=0;i<_dyld_image_count();i++){
        const char * Nam=_dyld_get_image_name(i);
        NSString* curName=[[NSString stringWithUTF8String:Nam] autorelease];
        if([curName containsString:WTFJHTWEAKNAME]){
            intptr_t ASLROffset=_dyld_get_image_vmaddr_slide(i);
            //We Found Ourself
#ifndef _____LP64_____
            uint32_t size=0;
            const struct mach_header*   selfHeader=(const struct mach_header*)_dyld_get_image_header(i);
            char * data=getsectdatafromheader(selfHeader,"WTFJH","classdumpdyld",&size);

#elif 
            uint64_t size=0;
            const struct mach_header_64*   selfHeader=(const struct mach_header_64*)_dyld_get_image_header(i);
            char * data=getsectdatafromheader_64(selfHeader,"WTFJH","classdumpdyld",&size);
#endif
            data=ASLROffset+data;//Add ASLR Offset To Pointer And Fix Address
            NSData* SDData=[NSData dataWithBytes:data length:size];
            NSString* randomPath=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),RandomString()];
            [SDData writeToFile:randomPath atomically:YES];
            void* handle=dlopen(randomPath.UTF8String,RTLD_NOW);//Open Created dylib
            dlclose(handle);

            handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);  
            WTLoaderPrototype WTHandle = dlsym(handle, "WTFJHInitclassdumpdyld");  //Call Init Function
            if(WTHandle!=NULL){
            WTHandle();  
            }
            dlclose(handle);  
            //Inform Our Logger
            CallTracer *tracer = [[CallTracer alloc] initWithClass:@"WTFJH" andMethod:@"LoadThirdPartyTools"];
        	[tracer addArgFromPlistObject:@"dlopen" withKey:@"Type"];
        	[tracer addArgFromPlistObject:randomPath withKey:@"Path"];
            [tracer addArgFromPlistObject:@"classdumpdyld" withKey:@"ModuleName"];
        	[traceStorage saveTracedCall: tracer];
        	[tracer release];
        	//End

            [SDData release];
              break;
        }



    }
#endif
}
