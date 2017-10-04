//
//  Phong Lighting
//
//  Created by Fatima B on 7/24/15.
//  Copyright (c) 2015 nemo. All rights reserved.
//  This project is based on a template from Stanford/CS148
//

/* For the ShaderProgram to be able to find phong.vert and phong.frag
   you need to go to Product -> Scheme -> Edit Scheme -> options tab,
   Click "use custom working directory" and choose the project directory
*/

#define GLEW_VERSION_2_0 1

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#include <string.h>
#include <stdexcept>
#include <cmath>

#include "SimpleShaderProgram.h"

#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <cstdio>
#include <cmath>
#include "mesh.h"


#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define NUM_LIGHTS 2
glm::vec3 lightPosition[NUM_LIGHTS] = {glm::vec3(-5,-5,10), glm::vec3(5,5,10)};
std::string g_filename;
glm::vec3 color;
glm::vec3 Ka;
glm::vec3 Kd;
glm::vec3 Ks;

float g_translateX = 0.0;
float g_translateY = 0.0;
float g_translateZ = 0.0;

float g_x_degrees = 0.0;
float g_y_degrees = 0.0;
float g_z_degrees = 0.0;

int option;

Mesh mesh;
std::vector<vec3f> new_normals;
std::vector<vec3f> new_vertices;
std::vector<unsigned int> new_vertex_indices;
std::vector<unsigned int> new_texture_indices;

GLuint vbo_buffer, vbo_indices, v_position, v_normal;
int g_vsize, g_nsize, g_tsize, g_isize;

// file locations
std::string vertexShader;
std::string fragmentShader;
SimpleShaderProgram *shader;

void keyboard(unsigned char key, int x, int y) {
    switch (key) {
            // translate in the z direction
        case '=':
        case '+':
            g_translateZ+=.1;
            break;
        case '-':
            g_translateZ-=.1;
            break;
            // rotate around the z axis
        case 'x':
            g_x_degrees+=10.0;
            break;
        case 'c':
            g_x_degrees-=10.0;
            break;
            // rotate around the y axis
        case 'y':
            g_y_degrees+=10.0;
            break;
        case 'u':
            g_y_degrees-=10.0;
            break;
            // rotate around the z axis
        case 'z':
            g_z_degrees+=10.0;
            break;
        case 'a':
            g_z_degrees-=10.0;
            break;
        case '1':
            color = glm::vec3(1.0, 0.0, 0.0);
            break;
        case '2':
            color = glm::vec3(0.0, 1.0, 0.0);
            break;
        case '3':
            color = glm::vec3(0.0, 0.0, 1.0);
            break;
        case '4':
            color = glm::vec3(1.0, 1.0, 0.0);
            break;
        case '5':
            color = glm::vec3(0.0, 1.0, 1.0);
            break;
        case '6':
            color = glm::vec3(1.0, 0.0, 1.0);
            break;
    }
    glutPostRedisplay();
}

void keyboard_special(int key, int x, int y) {
    switch (key) {
        case GLUT_KEY_UP:    // key up
            g_translateY-=.3;
            break;
        case GLUT_KEY_DOWN:    // key down
            g_translateY+=.3;
            break;
        case GLUT_KEY_RIGHT:    // key right
            g_translateX-=.3;
            break;
        case GLUT_KEY_LEFT:    // key left
            g_translateX+=.3;
            break;
        case 27:
            exit (0);
            break;
    }
    glutPostRedisplay();
}

void mouse_click(int button, int state, int x, int y) {
    switch (button) {
        case GLUT_LEFT_BUTTON:
            g_translateZ+=.1;
            break;
        case GLUT_RIGHT_BUTTON:
            g_translateZ-=.1;
            break;
    }
    glutPostRedisplay();
}

void DrawWithShader() {
    shader->Bind();

    // (1) projection is perspective
    int w = glutGet(GLUT_WINDOW_WIDTH); int h = glutGet(GLUT_WINDOW_HEIGHT);
    glm::mat4 projectionMatrix = glm::perspective(30.0f, (float)w/(float)h, 0.1f, 100000.f);

    // (2) view matrix
    glm::vec3 eyePosition = glm::vec3(0,0,4);
    glm::vec3 center = glm::vec3(0,0,0);
    glm::vec3 up = glm::vec3(0,1,0);
    glm::mat4 viewMatrix = glm::lookAt(eyePosition, // eye position
                                       center, // center looking at
                                       up); // up

    // (3) model matrix
    glm::mat4 translate = glm::translate(glm::mat4(1), glm::vec3(g_translateX, g_translateY, g_translateZ));
    glm::mat4 rotateX = glm::rotate(glm::mat4(1), glm::radians(g_x_degrees), glm::vec3(1,0,0));
    glm::mat4 rotateY = glm::rotate(glm::mat4(1), glm::radians(g_y_degrees), glm::vec3(0,1,0));
    glm::mat4 rotateZ = glm::rotate(glm::mat4(1), glm::radians(g_z_degrees), glm::vec3(0,0,1));

    // model, modelView, modelViewProjection & normal matrices
    glm::mat4 modelMatrix = translate * rotateZ * rotateY * rotateX;
    glm::mat4 modelViewMatrix = viewMatrix * modelMatrix;
    glm::mat4 modelViewProjectionMatrix = projectionMatrix * modelViewMatrix;
    glm::mat3 normalMatrix = glm::transpose(glm::inverse(glm::mat3(modelViewMatrix)));

    // transfer to the GPU
    GLuint eyeL = glGetUniformLocation(shader->programid, "eyePosition");
    glUniform3fv(eyeL, 1, &eyePosition[0]);
    inline_gl_error("eyePosition");

    GLuint lightL = glGetUniformLocation(shader->programid, "lightPosition");
    glUniform3fv(lightL, NUM_LIGHTS, &lightPosition[0][0]);
    inline_gl_error("lightPosition");

    GLuint colorL = glGetUniformLocation(shader->programid, "color");
    GLuint KaL = glGetUniformLocation(shader->programid, "Ka");
    GLuint KdL = glGetUniformLocation(shader->programid, "Kd");
    GLuint KsL = glGetUniformLocation(shader->programid, "Ks");
    glUniform3fv(colorL, 1, &color[0]);
    glUniform3fv(KaL, 1, &Ka[0]);
    glUniform3fv(KdL, 1, &Kd[0]);
    glUniform3fv(KsL, 1, &Ks[0]);
    inline_gl_error("color");

    glm::vec3 refV = glm::vec3(mesh.vertices[0].x, mesh.vertices[0].y, mesh.vertices[0].z);
    GLuint refL = glGetUniformLocation(shader->programid, "refVertex");
    glUniform3fv(refL, 1, &refV[0]);
    inline_gl_error("refV");

    GLuint normL = glGetUniformLocation(shader->programid, "normalMatrix");
    glUniformMatrix3fv(normL, 1, GL_FALSE, &normalMatrix[0][0]);
    inline_gl_error("normalMatrix");

    GLuint mvpL = glGetUniformLocation(shader->programid, "modelViewProjectionMatrix");
    glUniformMatrix4fv(mvpL, 1, GL_FALSE, &modelViewProjectionMatrix[0][0]);
    inline_gl_error("modelViewProjectionMatrix");

    glDrawElements(GL_TRIANGLES, (int)new_vertex_indices.size(), GL_UNSIGNED_INT, 0);
    inline_gl_error("drawElements");
    shader->UnBind();
}

void display() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    DrawWithShader();
    glutSwapBuffers();
}

void reshape(int w, int h) {
    glViewport(0, 0, w, h);
}

void calculate_normals() {
    // duplicate and calculate normals
    for (int i = 0; i < mesh.vertex_indices.size(); i+=3) {
        // each three will make a face
        int av = mesh.vertex_indices[i];
        int bv = mesh.vertex_indices[i+1];
        int cv = mesh.vertex_indices[i+2];

        vec3f a = mesh.vertices[av];
        vec3f b = mesh.vertices[bv];
        vec3f c = mesh.vertices[cv];

        // find the normal per face
        vec3f ba = b - a;
        vec3f ca = c - a;
        vec3f normal;
        cross(&normal, &ba, &ca);

        normal.normalize();
        new_normals.push_back(normal);
        new_normals.push_back(normal);
        new_normals.push_back(normal);

        // duplicate vertices
        new_vertices.push_back(a);
        new_vertices.push_back(b);
        new_vertices.push_back(c);

        new_vertex_indices.push_back(i);
        new_vertex_indices.push_back(i+1);
        new_vertex_indices.push_back(i+2);
    }
}

void setup_vbos() {
    g_vsize = (int)new_vertices.size() * sizeof(vec3f);
    g_nsize = (int)new_normals.size() * sizeof(vec3f);
    g_tsize = (int)mesh.texture_indices.size() * sizeof(unsigned int);
    g_isize = (int)new_vertex_indices.size() * sizeof(unsigned int);

    // create the vbo buffer
    glGenBuffers(1, &vbo_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_buffer);
    // just allocate the memory for now
    glBufferData(GL_ARRAY_BUFFER, g_vsize + g_nsize + g_tsize, NULL, GL_DYNAMIC_DRAW);

    // add the data in the buffers
    glBufferSubData(GL_ARRAY_BUFFER, 0, g_vsize, &new_vertices[0]); // vertices
    glBufferSubData(GL_ARRAY_BUFFER, g_vsize, g_nsize, &new_normals[0]); // normals

    // get the location of the attributes
    v_position = glGetAttribLocation(shader->programid, "in_position");
    inline_gl_error("get attribute for in_position");

    v_normal = glGetAttribLocation(shader->programid, "in_normal");
    inline_gl_error("get attribute for in_normal");
    printf("%d\n", v_normal);

    glEnableVertexAttribArray(v_position);
    inline_gl_error("enable attribute for v_position");

    glVertexAttribPointer(v_position,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(vec3f),
                          0);
    inline_gl_error("vertex pointer for in_position");


    glEnableVertexAttribArray(v_normal);
    inline_gl_error("enable attribute for v_normal");

    glVertexAttribPointer(v_normal,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(vec3f),
                          BUFFER_OFFSET(g_vsize));
    inline_gl_error("vertex pointer for v_normal");

    // create index buffer
    glGenBuffers(1, &vbo_indices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_indices);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, g_isize, &new_vertex_indices[0], GL_STATIC_DRAW);
}

void user_input() {
    printf("************************************************\n");
    printf("+ - to zoom in and out (translate in the z direction)\n");
    printf("(arrows keypad) to translate in the x and y directions\n");
    printf("x and c to rotate around the x axis\n");
    printf("y and u to rotate around the y axis\n");
    printf("z and a to rotate around the z axis\n");
    printf("1 to 6 change the color of the mesh\n");
    printf("************************************************\n");
}


int main(int argc, char** argv) {
    user_input();
    g_filename = "input/venus.obj";

    // light prep
    color = glm::vec3(0.7, 0.7, 0.7);
    Ka = glm::vec3(0.2f, 0.2f, 0.2f); // ambient constant
    Kd = glm::vec3(0.5f, 0.5f, 0.5f); // diffuse
    Ks = glm::vec3(1.0f, 1.0f, 1.0f); // specular

    g_translateX = 0.0;
    g_translateY = 1.0;
    g_translateZ = -3.0;

    g_x_degrees = -90.0;
    g_y_degrees = 0.0;
    g_z_degrees = 170.0;

    vertexShader = "phong.vert";
    fragmentShader = "phong.frag";

    // Initialize model
    if (!mesh.load_file(g_filename)) {
        printf("Mesh file couldn't be laoded\n");
        return 0;
    }

    // Initialize GLUT
    glutInit(&argc, argv);
    glutInitDisplayMode( GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
    glutInitWindowPosition(800, 20);
    glutInitWindowSize(640, 480);
    glutCreateWindow("Phong Lighting");
    printf("%s\n", glGetString(GL_VERSION));

    // Shader init
    shader = new SimpleShaderProgram();
    shader->LoadVertexShader(vertexShader);
    shader->LoadFragmentShader(fragmentShader);
    shader->attached_and_link_shaders();

    // color
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glDepthFunc(GL_LESS);
    glEnable(GL_DEPTH_TEST);

    // culling
    glFrontFace(GL_CCW);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);

    // normals
    if (!mesh.hasNormals) { // if no normals provided, calculate normals
        printf("calculating normals manually\n");
        calculate_normals();
    } else {
        // just copy data to the new arrays
        new_normals = mesh.normals;
        new_vertices = mesh.vertices;
        new_vertex_indices = mesh.vertex_indices;
    }

    setup_vbos();

    // display & reshape
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutIdleFunc(display);

    // user input
    glutSpecialFunc(keyboard_special);
    glutKeyboardFunc(keyboard);
    glutMouseFunc(mouse_click);

    glutMainLoop();
    return 0;
}
