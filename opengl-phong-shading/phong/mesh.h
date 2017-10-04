#ifndef MESH_H
#define MESH_H

#include <vector>
#include <string>
#include <iostream>
#include <algorithm>

#include "util.h"

class Mesh {
public:
    std::vector<vec3f> vertices;
    std::vector<vec3f> normals;
    std::vector<vec3f> textures;

    std::vector<unsigned int> vertex_indices;
    std::vector<unsigned int> texture_indices;
    std::vector<unsigned int> normals_indices;

    int num_faces;
    bool hasTextures;
    bool hasNormals;
    Mesh() { hasNormals = false; hasTextures = false; }
    bool load_file(const std::string& filename);
private:
    bool load_object(const std::string& filename);
};

#endif
