//
//  OpenGL_View.m
//  OpenGL-Tutorial
//
//  Created by Mahfuz on 16/2/20.
//  Copyright © 2020 KITE GAMES STUDIO. All rights reserved.
//

//#define    GLES_SILENCE_DEPRECATION

#import "OpenGL_View.h"
//----
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
//-----

@implementation OpenGL_View{
    
    CAEAGLLayer         *eaglLayer;
    EAGLContext         *context;
    GLuint              colorRenderBuffer;
    GLuint                 positionSlot;
    GLuint                 colorSlot;
    GLuint 				programHandle;
     float 			count;
}

- (void) update{
    
    if ([EAGLContext currentContext] != context) {
        [EAGLContext setCurrentContext:context];
    }

    glUseProgram(programHandle);
    //----
    GLfloat vVertices[] =
    	{0.0f, 0.5f, 0.0f,  //top
        -0.5f, -0.5f, 0.0f,  //bottom left
        0.5f, -0.5f, 0.0f};  //bottom right
    
    //count = count + 0.01;
    //vVertices[1] = count;
    //test
    NSLog(@"test======== %f", count);
    
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 1   // Set the viewport
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    // Load the vertex data
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
    glEnableVertexAttribArray(0);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    //----

    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];

    NSLog(@"update ================= GL view ");
}

+ (Class) layerClass {
    return [CAEAGLLayer class];
}

- (void) setupLayer {
    eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = YES;
}
- (void) setupContext {
    count = 0.5;
    
    context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    if (context == nil) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    if ( [EAGLContext setCurrentContext:context] == NO) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    
    [self setupLayer];
    [self setupContext];
    
	// setup RenderBuffer
    glGenRenderbuffers(1, & colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable: eaglLayer];

	// setup FrameBuffer
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
	//
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        NSLog(@"Failed to make complete framebuffer object!!! %d", status);
        exit(1);
    }

    [self compileShaders];
    //----
    GLfloat vVertices[] =
    	{0.0f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f};
    
    // Set the viewport
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 1
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    // Load the vertex data
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
    glEnableVertexAttribArray(0);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    //----
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)compileShaders {
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex"  withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"   withType:GL_FRAGMENT_SHADER];
    // 2
     programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);

    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }

    // 4
    glUseProgram(programHandle);

    // 5
//    positionSlot = glGetAttribLocation(programHandle, "Position");
//    colorSlot = glGetAttribLocation(programHandle, "SourceColor");
//    glEnableVertexAttribArray(positionSlot);
//    glEnableVertexAttribArray(colorSlot);
}
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {

    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName  ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath  encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }

    // 2
    GLuint shaderHandle = glCreateShader(shaderType);

    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);

    // 4
    glCompileShader(shaderHandle);

    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandle;
}


@end
