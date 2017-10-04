//
//  main1.cpp
//  Geometry Shader Example
//
//  Created by Fatima B on 7/24/15.
//  Copyright (c) 2015 nemo. All rights reserved.
//


#include "main.h"
#ifdef WIN32
#define ssize_t SSIZE_T
#endif

#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <cstdio>
#include <cmath>
#include "mesh.h"

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
std::vector<Vector3f> new_normals;
std::vector<Vector3f> new_vertices;
std::vector<unsigned int> new_vertex_indices;
std::vector<unsigned int> new_texture_indices;

GLuint vbo_buffer, vbo_indices, v_position, v_normal;
int g_vsize, g_nsize, g_tsize, g_isize;

// file locations
std::string vertexShader;
std::string fragmentShader;
std::string geometryShader;
bool geometryShaderEnable = false;
int geometryShaderOutputType = 0; // triangles

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
    //print(&rotateZ[0][0]);

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

    if (geometryShaderOutputType == 0) {
        glDrawElements(GL_TRIANGLES, (int)new_vertex_indices.size(), GL_UNSIGNED_INT, 0);
    } else if (geometryShaderOutputType == 1) {
        //printf("using adj triangles\n");
        glDrawElements(GL_TRIANGLES_ADJACENCY_EXT, (int)new_vertex_indices.size(), GL_UNSIGNED_INT, 0);
    }
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

        Vector3f a = mesh.vertices[av];
        Vector3f b = mesh.vertices[bv];
        Vector3f c = mesh.vertices[cv];

        // find the normal per face
        Vector3f ba = b - a;
        Vector3f ca = c - a;
        Vector3f normal;
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

void prep_data() {
    new_normals = mesh.normals;
    new_vertices = mesh.vertices;
    new_vertex_indices = mesh.vertex_indices;
}

void adj() {
    
    // Copy and make room for adjacency info
    for (unsigned int i = 0; i < mesh.vertex_indices.size(); i+=3) {
        new_vertex_indices.push_back(mesh.vertex_indices[i]);
        new_vertex_indices.push_back(-1);
        new_vertex_indices.push_back(mesh.vertex_indices[i+1]);
        new_vertex_indices.push_back(-1);
        new_vertex_indices.push_back(mesh.vertex_indices[i+2]);
        new_vertex_indices.push_back(-1);
    }

    // Find matching edges
    for (unsigned int i = 0; i < new_vertex_indices.size(); i+=6) {
        // A triangle
        unsigned int a1 = new_vertex_indices[i];
        unsigned int b1 = new_vertex_indices[i+2];
        unsigned int c1 = new_vertex_indices[i+4];

        // search all triangles
        for (unsigned j = 0; j < new_vertex_indices.size(); j+=6) {
            unsigned int a2 = new_vertex_indices[j];
            unsigned int b2 = new_vertex_indices[j+2];
            unsigned int c2 = new_vertex_indices[j+4];

            // Edge 1 == Edge 1
            if ((a1 == a2 && b1 == b2) || (a1 == b2 && b1 == a2)) {
                new_vertex_indices[i+1] = c2;
                new_vertex_indices[j+1] = c1;
            }
            // Edge 1 == Edge 2
            if ((a1 == b2 && b1 == c2) || (a1 == c2 && b1 == b2)) {
                new_vertex_indices[i+1] = a2;
                new_vertex_indices[j+3] = c1;
            }
            // Edge 1 == Edge 3
            if ((a1 == c2 && b1 == a2) || (a1 == a2 && b1 == c2)) {
                new_vertex_indices[i+1] = b2;
                new_vertex_indices[j+5] = c1;
            }
            // Edge 2 == Edge 1
            if ((b1 == a2 && c1 == b2) || (b1 == b2 && c1 == a2)) {
                new_vertex_indices[i+3] = c2;
                new_vertex_indices[j+1] = a1;
            }
            // Edge 2 == Edge 2
            if( (b1 == b2 && c1 == c2) || (b1 == c2 && c1 == b2)) {
                new_vertex_indices[i+3] = a2;
                new_vertex_indices[j+3] = a1;
            }
            // Edge 2 == Edge 3
            if ((b1 == c2 && c1 == a2) || (b1 == a2 && c1 == c2)) {
                new_vertex_indices[i+3] = b2;
                new_vertex_indices[j+5] = a1;
            }
            // Edge 3 == Edge 1
            if ((c1 == a2 && a1 == b2) || (c1 == b2 && a1 == a2)) {
                new_vertex_indices[i+5] = c2;
                new_vertex_indices[j+1] = b1;
            }
            // Edge 3 == Edge 2
            if ((c1 == b2 && a1 == c2) || (c1 == c2 && a1 == b2)) {
                new_vertex_indices[i+5] = a2;
                new_vertex_indices[j+3] = b1;
            }
            // Edge 3 == Edge 3
            if ((c1 == c2 && a1 == a2) || (c1 == a2 && a1 == c2)) {
                new_vertex_indices[i+5] = b2;
                new_vertex_indices[j+5] = b1;
            }
        }
    }
    
    // Look for any outside edges
    for (unsigned int i = 0; i < new_vertex_indices.size(); i+=6) {
        if (new_vertex_indices[i+1] == -1) new_vertex_indices[i+1] = new_vertex_indices[i+4];
        if (new_vertex_indices[i+3] == -1) new_vertex_indices[i+3] = new_vertex_indices[i];
        if (new_vertex_indices[i+5] == -1) new_vertex_indices[i+5] = new_vertex_indices[i+2];
    }
    new_vertices = mesh.vertices;
}

void setup_vbos() {
    g_vsize = (int)new_vertices.size() * sizeof(Vector3f);
    g_nsize = (int)new_normals.size() * sizeof(Vector3f);
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
                          sizeof(Vector3f),
                          0);
    inline_gl_error("vertex pointer for in_position");


    glEnableVertexAttribArray(v_normal);
    inline_gl_error("enable attribute for v_normal");

    glVertexAttribPointer(v_normal,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(Vector3f),
                          BUFFER_OFFSET(g_vsize));
    inline_gl_error("vertex pointer for v_normal");

    // create index buffer
    glGenBuffers(1, &vbo_indices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_indices);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, g_isize, &new_vertex_indices[0], GL_STATIC_DRAW);
}

void setup() {
    shader = new SimpleShaderProgram();
    shader->LoadVertexShader(vertexShader);
    shader->LoadFragmentShader(fragmentShader);

    if (geometryShaderEnable) {
        shader->geometry_shader_enabled = true;
        shader->geometry_out_type = geometryShaderOutputType;
        shader->LoadGeometryShader(geometryShader);
    }
    shader->attached_and_link_shaders();

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    glDepthFunc(GL_LESS);
    glEnable(GL_DEPTH_TEST);

    // culling
    glFrontFace(GL_CCW);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
}

void menu() {
    printf("1 to generate the model venus with shrinked triangles \n");
    printf("2 to generate the model bunny with silhouettes (not complete) \n");
    printf("3 to generate the model teddy with tessellation \n");

}

void user_input() {
    printf("************************************************\n");
    printf("+ - to zoom in and out (translate in the z direction)\n");
    printf("(arrows keypad) to translate in the x and y directions\n");
    printf("x and c to rotate around the x axis\n");
    printf("y and u to rotate around the y axis\n");
    printf("z and a to rotate around the z axis\n");
    printf("1 to 6 change the color of the mesh if supported\n");
    printf("************************************************\n");
}


int main(int argc, char** argv) {
    int option = 1;

    menu();
    user_input();

    if (option == 1) { // venus + shrink geometry
        g_filename = "input/venus.obj";
        color = glm::vec3(1.0, 0.2, 0.3);
        Ka = glm::vec3(0.2f, 0.2f, 0.2f); // ambient constant
        Kd = glm::vec3(0.5f, 0.5f, 0.5f); // diffuse
        Ks = glm::vec3(1.0f, 1.0f, 1.0f); // specular

        g_translateX = 0.0;
        g_translateY = 1.0;
        g_translateZ = -3.0;

        g_x_degrees = -90.0;
        g_y_degrees = 0.0;
        g_z_degrees = 170.0;

        vertexShader = "shrink.vert";
        fragmentShader = "shrink.frag";
        geometryShader = "shrink.geom";
        geometryShaderEnable = true;
    }

    else if (option == 2) { // unknown
        g_filename = "input/bunny.obj";
        color = glm::vec3(1.0, 0.2, 0.3);
        Ka = glm::vec3(0.2f, 0.2f, 0.2f); // ambient constant
        Kd = glm::vec3(0.5f, 0.5f, 0.5f); // diffuse
        Ks = glm::vec3(1.0f, 1.0f, 1.0f); // specular

        g_translateX = 0.0;
        g_translateY = 0.15;
        g_translateZ = 3.7;

        g_x_degrees = 10.0;
        g_y_degrees = 190.0;
        g_z_degrees = 180.0;

        vertexShader = "sil.vert";
        fragmentShader = "sil.frag";
        geometryShader = "sil.geom";
        geometryShaderEnable = true;
        geometryShaderOutputType = 1;
    }

    else if (option == 3) { // unknown
        g_filename = "input/teddy.obj";
        color = glm::vec3(1.0, 0.2, 0.3);
        Ka = glm::vec3(0.2f, 0.2f, 0.2f); // ambient constant
        Kd = glm::vec3(0.5f, 0.5f, 0.5f); // diffuse
        Ks = glm::vec3(1.0f, 1.0f, 1.0f); // specular

        g_translateX = 0.0;
        g_translateY = 0.15;
        g_translateZ = -40.0;

        g_x_degrees = 0.0;
        g_y_degrees = 0.0;
        g_z_degrees = 180.0;

        vertexShader = "tess.vert";
        fragmentShader = "tess.frag";
        geometryShader = "tess.geom";
        geometryShaderEnable = true;
    }

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
    glutCreateWindow("Geometry Shader Example");
    printf("%s\n", glGetString(GL_VERSION));
    
    
    // Initialize GLEW
#if !defined(__APPLE__) && !defined(__linux__)
    glewInit();
    if(!GLEW_VERSION_2_0) {
        printf("Your graphics card or graphics driver does\n"
               "\tnot support OpenGL 2.0, trying ARB extensions\n");
        
        if(!GLEW_ARB_vertex_shader || !GLEW_ARB_fragment_shader) {
            printf("ARB extensions don't work either.\n");
            printf("\tYou can try updating your graphics drivers.\n"
                   "\tIf that does not work, you will have to find\n");
            printf("\ta machine with a newer graphics card.\n");
            exit(1);
        }
    }
#endif
    setup();

    if (option == 2) {
        adj();
    } else {
        if (!mesh.hasNormals) { // if no normals provided, calculate normals
            printf("calculating normals manually\n");
            calculate_normals();
        } else {
            prep_data(); // just copy data to the new arrays
        }
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
