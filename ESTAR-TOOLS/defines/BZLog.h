//
//  BZLog.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#ifndef BZLog_h
#define BZLog_h


//#define BZDEBUG     //日志统一开关，如果想关闭整个系统的日志，直接将本行注释即可

#ifdef BZDEBUG
#define BZLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#else

#define BZLog(FORMAT, ...)

#endif



#endif /* BZLog_h */


