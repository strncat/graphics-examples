//
//  ViewController.m
//  Based on the iOS game template and
//  http://www.opengl-tutorial.org/beginners-tutorials/tutorial-4-a-colored-cube/
//
//  Created by Fatima B on 6/17/15.
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

GLfloat cubeVertices[216] = {
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,

    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,

    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,

    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,

    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,

    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};
static const GLfloat cubeColors[] = {
    0.583f,  0.771f,  0.014f, 1.000f,
    0.609f,  0.115f,  0.436f, 1.000f,
    0.327f,  0.483f,  0.844f, 1.000f,
    0.822f,  0.569f,  0.201f, 1.000f,
    0.435f,  0.602f,  0.223f, 1.000f,
    0.310f,  0.747f,  0.185f, 1.000f,
    0.597f,  0.770f,  0.761f, 1.000f,
    0.559f,  0.436f,  0.730f, 1.000f,
    0.359f,  0.583f,  0.152f, 1.000f,
    0.483f,  0.596f,  0.789f, 1.000f,
    0.559f,  0.861f,  0.639f, 1.000f,
    0.195f,  0.548f,  0.859f, 1.000f,
    0.014f,  0.184f,  0.576f, 1.000f,
    0.771f,  0.328f,  0.970f, 1.000f,
    0.406f,  0.615f,  0.116f, 1.000f,
    0.676f,  0.977f,  0.133f, 1.000f,
    0.971f,  0.572f,  0.833f, 1.000f,
    0.140f,  0.616f,  0.489f, 1.000f,
    0.997f,  0.513f,  0.064f, 1.000f,
    0.945f,  0.719f,  0.592f, 1.000f,
    0.543f,  0.021f,  0.978f, 1.000f,
    0.279f,  0.317f,  0.505f, 1.000f,
    0.167f,  0.620f,  0.077f, 1.000f,
    0.347f,  0.857f,  0.137f, 1.000f,
    0.055f,  0.953f,  0.042f, 1.000f,
    0.714f,  0.505f,  0.345f, 1.000f,
    0.783f,  0.290f,  0.734f, 1.000f,
    0.722f,  0.645f,  0.174f, 1.000f,
    0.302f,  0.455f,  0.848f, 1.000f,
    0.225f,  0.587f,  0.040f, 1.000f,
    0.517f,  0.713f,  0.338f, 1.000f,
    0.053f,  0.959f,  0.120f, 1.000f,
    0.393f,  0.621f,  0.362f, 1.000f,
    0.673f,  0.211f,  0.457f, 1.000f,
    0.820f,  0.883f,  0.371f, 1.000f,
    0.982f,  0.099f,  0.879f, 1.000f
};

@interface ViewController () {
    GLuint _program;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _colorBuffer;
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
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

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    [self loadShaders];

    glEnable(GL_DEPTH_TEST); // Enable depth test
    glDepthFunc(GL_LESS); // Accept fragment if it closer to the camera than the former one

    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);

    // vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));

    // normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));

    // colors
    glGenBuffers(1, &_colorBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _colorBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeColors), cubeColors, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor,
                          4,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          BUFFER_OFFSET(0));
    glBindBuffer(GL_ARRAY_BUFFER, 0);
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

    // translate
    GLKMatrix4 modeViewlMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -3.0f);
    // Optional Rotation
    modeViewlMatrix = GLKMatrix4Rotate(modeViewlMatrix, _rotation - 0.4, 0.0f, 1.0f, 0.0f);


    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modeViewlMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modeViewlMatrix);

    //_rotation += self.timeSinceLastUpdate * 0.7f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glUseProgram(_program);

    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);

    glDrawArrays(GL_TRIANGLES, 0, 12*3);
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
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribColor, "sourceColor");

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

    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");

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
