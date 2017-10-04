#include "mesh.h"
#include <fstream>
#include <sstream>


bool Mesh::load_file(const std::string& filename) {
    // peek at the extension
    std::string::size_type idx;
    idx = filename.rfind('.');

    if (idx != std::string::npos) {
        std::string extension = filename.substr(idx + 1);
        if (extension == "obj") {
            return load_object(filename);
        } else {
            std::cerr << "ERROR: unable to load file " << filename
            << "  -- unknown extension." << std::endl;
            std::cerr << "Input only (.obj) files" << std::endl;
        }
    }
    // No filename extension found, or none matching {.obj}
    return false;
}

bool check_index(int index, size_t size) {
    if (index < 0 || index >= size) {
        std::cerr << "ERROR: unable to load triangles file; index out of range (" << index << ")" << std::endl;
        return false;
    }
    return true;
}

bool Mesh::load_object(const std::string& filename) {
    std::ifstream ifs(filename.c_str());

    if (ifs.is_open()) {
        int t0[3], t1[3], t2[3];
        float v0, v1, v2;
        std::string line;
        char temp[2];
        num_faces=0;

        while (std::getline(ifs, line)) {
            // (1) load vertices
            if (line[0] == 'v' && line[1] == ' ') { // vertices
                sscanf(line.c_str(), "%s %f %f %f", temp, &v0, &v1, &v2);
                vec3f vector(v0, v1, v2);
                vertices.push_back(vector);

            // (2) load normals
            } else if (line[0] == 'v' && line[1] == 'n') { // normals
                sscanf(line.c_str(), "%s %f %f %f", temp, &v0, &v1, &v2);
                vec3f vector(v0, v1, v2);
                normals.push_back(vector);

            // (3) load textures
            } else if (line[0] == 'v' && line[1] == 't') { // textures
                sscanf(line.c_str(), "%s %f %f %f", temp, &v0, &v1, &v2);
                vec3f vector(v0, v1, v2);
                textures.push_back(vector);

            // (4) load faces - usually last part of the file
            } else if (line[0] == 'f') {
                num_faces++;
                t0[0] = t0[1] = t0[2] = t1[0] = t1[1] = t1[2] = t2[0] = t2[1] = t2[2] = -1;

                if (line.find("//") != std::string::npos) { // vertices and normals
                    sscanf(line.c_str(), "%s %d//%d %d//%d %d//%d",
                           temp, &t0[0], &t0[2],
                           &t1[0], &t1[2],
                           &t2[0], &t2[2]);

                } else if (line.find("/") != std::string::npos) { // everything or textures
                    int total = sscanf(line.c_str(), "%s %d/%d/%d %d/%d/%d %d/%d/%d",
                                       temp, &t0[0], &t0[1], &t0[2],
                                       &t1[0], &t1[1], &t1[2],
                                       &t2[0], &t2[1], &t2[2]);

                    // sscanf returns the number of values it was able to parse
                    if (total < 10) { // only vertices and textures
                        sscanf(line.c_str(), "%s %d/%d %d/%d %d/%d", temp, &t0[0],
                               &t0[1], &t1[0], &t1[1], &t2[0], &t2[1]);
                    }

                } else { // no '/' so only vertices
                    sscanf(line.c_str(), "%s %d %d %d", temp, &t0[0], &t1[0], &t2[0]);
                }

                //printf("%s %d %d %d,    %d %d %d,   %d %d %d\n", temp, t0[0]-1, t0[1]-1, t0[2]-1,
                //       t1[0]-1, t1[1]-1, t1[2]-1, t2[0]-1, t2[1]-1, t2[2]-1);

                vertex_indices.push_back(t0[0]-1);
                vertex_indices.push_back(t1[0]-1);
                vertex_indices.push_back(t2[0]-1);

                if (t0[1] != -1 && t1[1] != -1) {
                    hasTextures = true;
                    texture_indices.push_back(t0[1]-1);
                    texture_indices.push_back(t1[1]-1);
                    texture_indices.push_back(t2[1]-1);
                }

                if (t0[2] != -1 && t1[2] != -1) {
                    hasNormals = true;
                    normals_indices.push_back(t0[2]-1);
                    normals_indices.push_back(t1[2]-1);
                    normals_indices.push_back(t2[2]-1);
                }
            }
        }
    }
    return true;
}
