//
// Source: Stanford CS148
//

// SimpleShaderProgram.h
#ifndef __SIMPLESHADERPROGRAM_H__
#define __SIMPLESHADERPROGRAM_H__

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <string>
#include <vector>
#include <assert.h>
#include <string>
#include <fstream>
#include <sstream>

/**
 * SimpleShaderProgram - class to use GLSL programs.
 * Call LoadVertexShader and UploadFragmentShader
 * to add shaders to the program. Call Bind() to begin
 * using the shader and UnBind() to stop using it.
 */

inline void inline_gl_error(const char* location) {
    GLenum errorCode = glGetError();
    const GLubyte *errorString;
    if (errorCode != GL_NO_ERROR) {
        errorString = gluErrorString(errorCode);
        printf("%s %d %s\n", location, errorCode, errorString);
    }
}

class SimpleShaderProgram {
public:
    unsigned int programid;
    GLuint shaderF, shaderV;

    SimpleShaderProgram() {
        programid = glCreateProgram();
    }

    ~SimpleShaderProgram() {
        glDeleteProgram(programid);
    }

    // You need to add at least one vertex shader and one fragment shader. You can add multiple shaders
    // of each type as long as only one of them has a main() function.
    void LoadVertexShader(const std::string& filename) {
        std::ifstream in(filename.c_str());
        if(!in) {
            fprintf(stderr, "Failed to open shader file '%s'\n", filename.c_str());
            assert(false);
            return;
        }
        std::stringstream ss;
        ss << in.rdbuf();

        std::string str = ss.str();
        const char* ptr = str.c_str();

        // Buffer for error messages
        static const int kBufferSize = 1024;
        char buffer[1024];

        shaderV = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(shaderV, 1, &ptr, NULL);
        glCompileShader(shaderV);
        GLint result = 0;
        glGetShaderiv(shaderV, GL_COMPILE_STATUS, &result);
        if(result != GL_TRUE) {
            GLsizei length = 0;
            glGetShaderInfoLog(shaderV, kBufferSize-1,
                                &length, buffer);
            fprintf(stderr, "%s: GLSL error\n%s\n", filename.c_str(), buffer);
            assert(false);
        }
    }

    void LoadFragmentShader(const std::string& filename) {
        std::ifstream in(filename.c_str());
        if(!in) {
            fprintf(stderr, "Failed to open shader file '%s'\n", filename.c_str());
            assert(false);
            return;
        }
        std::stringstream ss;
        ss << in.rdbuf();

        std::string str = ss.str();
        const char* ptr = str.c_str();

        // Buffer for error messages
        static const int kBufferSize = 1024;
        char buffer[1024];

        shaderF = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(shaderF, 1, &ptr, NULL);
        glCompileShader(shaderF);
        GLint result = 0;
        glGetShaderiv(shaderF, GL_COMPILE_STATUS, &result);
        if(result != GL_TRUE) {
            GLsizei length = 0;
            glGetShaderInfoLog(shaderF, kBufferSize-1, &length, buffer);
            fprintf(stderr, "%s: GLSL error\n%s\n", filename.c_str(), buffer);
            assert(false);
        }
    }

    void attached_and_link_shaders() {
        glAttachShader(programid, shaderV);
        inline_gl_error("attaching vertex shader");

        glAttachShader(programid, shaderF);
        inline_gl_error("attaching fragment shader");

        glLinkProgram(programid);
    }

    void Bind() {
        glUseProgram(programid);
        for (unsigned int i = 0; i < textures.size(); i++) {
            glUniform1i(textures[i].location, textures[i].tex_id);
        }
    }

    void UnBind() {
        glUseProgram(0);
    }

    // Set a uniform global parameter of the program by name.
    void SetTexture(const std::string& name, int tex_index) {
        GLint location = glGetUniformLocation(programid, name.c_str());
        UnboundTexture tex;
        tex.location = location;
        tex.tex_id = tex_index;
        textures.push_back(tex);
    }

    void SetUniform(const std::string& name, float value) {
        GLint location = GetUniformLocation(name);
        if (location == -1) return;
        glUniform1f(location, value);
    }

    void SetUniform(const std::string& name, float v0, float v1) {
        GLint location = GetUniformLocation(name);
        if (location == -1) return;
        glUniform2f(location, v0, v1);

    }

    void SetUniform(const std::string& name, float v0, float v1, float v2) {
        GLint location = GetUniformLocation(name);
        if (location == -1) return;
        glUniform3f(location, v0, v1, v2);

    }

    void SetUniform(const std::string& name, float v0, float v1, float v2, float v3) {
        GLint location = GetUniformLocation(name);
        if (location == -1) return;
        glUniform4f(location, v0, v1, v2, v3);
    }

private:
    // Helper routine - get the location for a uniform shader parameter.
    GLint GetUniformLocation(const std::string& name) {
        return glGetUniformLocation(programid, name.c_str());
    }
    struct UnboundTexture {
        GLint location;
        GLint tex_id;
    };
    std::vector<UnboundTexture> textures;
};

#endif //__SIMPLESHADERPROGRAM_H__
