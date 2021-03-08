#ifndef SHARED
#define SHARED

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/stat.h>
#include <dirent.h>

#define key 'P'
#define BUFSIZE 1024

char hash(char ch);

int share_send(FILE* fp, char* buffer, int n);

int share_recv(char* buf, int s);

void split(char* input, char** request, char** filename);

#endif
