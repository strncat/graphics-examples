//
//  ViewController.m
//  iOSAssignment1
//
//  Created by Fatima B on 6/13/15.
//  Copyright (c) 2015 nemo. All rights reserved.
//

#import "ViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

enum { // Uniform index
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

GLfloat vertexData[] = {
    //  X     Y     Z           U     V
    1.0f, 1.0f, 0.0f,       1.0f, 1.0f, // vertex 0
    -1.0f, 1.0f, 0.0f,       0.0f, 1.0f, // vertex 1
    1.0f,-1.0f, 0.0f,       1.0f, 0.0f, // vertex 2
    -1.0f,-1.0f, 0.0f,       0.0f, 0.0f, // vertex 3
}; // 4 vertices with 5 components (floats) each

GLuint indexData[] = {
    0,1,2, // first triangle
    2,1,3, // second triangle
};

// The following is an 8x8 checkerboard pattern using
// GL_RED, GL_UNSIGNED_BYTE data.
static const GLubyte textureCheckerboardData[] = {
    0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
    0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
    0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
    0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
    0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
    0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
    0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
    0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF
};

@interface ViewController () {
    GLuint _program;
    GLuint _texture;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLKMatrix4 _modelViewProjectionMatrix;
    float _rotation;
}
@property (strong, nonatomic) EAGLContext *context;
- (void)setupGL;
- (void)tearDownGL;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    [self setupGL];
}

- (void)dealloc {
    [self tearDownGL];
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        [self tearDownGL];
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadTextures {
    glGenTextures(1, &_texture);
    // Bind the texture
    glBindTexture(GL_TEXTURE_2D, _texture);
    // Allocate storage for the texture data
    glTexStorage2D(GL_TEXTURE_2D, 4, GL_R8, 8, 8);
    // Specify the data for the texture
    glTexSubImage2D(GL_TEXTURE_2D,              // target
                    0,                          // First mipmap level
                    0, 0,                       // x and y offset
                    8, 8,                       // width and height
                    GL_RED, GL_UNSIGNED_BYTE,   // format and type
                    textureCheckerboardData);     // data
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    [self loadShaders];

    [self loadTextures];

    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);

    // vertices
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5*sizeof(GLfloat), BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribPosition);

    // texture vertices
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 5*sizeof(GLfloat), BUFFER_OFFSET(3*sizeof(GLfloat)));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);

    // generate and bind the index buffer object
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

    // fill with data
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*2*3, indexData, GL_STATIC_DRAW);

}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    GLKMatrix4 modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -3.0f);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(_program);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders {
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    // Create shader program
    _program = glCreateProgram();

    // Create and compile vertex shader
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }

    // Create and compile fragment shader
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }

    glAttachShader(_program, vertShader); // Attach vertex shader to program
    glAttachShader(_program, fragShader); // Attach fragment shader to program

    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "texCoordinates");

    // Link program
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);

        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return NO;
    }

    // Release vertex and fragment shaders
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    GLint status;
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    *shader = glCreateShader(type); // creates a shader's object
    glShaderSource(*shader, 1, &source, NULL); // set the source code in the shader
    glCompileShader(*shader); // compiles the source code in shader

    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status); // return parameter
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog {
    GLint status;
    glLinkProgram(prog);

    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog {
    GLint logLength, status;
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

@end
