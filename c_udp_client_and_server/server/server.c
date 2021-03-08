#include "../shared.c"
#include <dirent.h>

#define BUFSIZE 1024

int main(int argc, char **argv)
{
  int sockfd; /* socket */
  int portno; /* port to listen on */
  int clientlen; /* byte size of client's address */
  struct sockaddr_in serveraddr; /* server's addr */
  struct sockaddr_in clientaddr; /* client addr */
  struct hostent *hostp; /* client host info */
  char buf[BUFSIZE]; /* message buf */
  char *hostaddrp; /* dotted decimal host addr string */
  int optval; /* flag value for setsockopt */
  int n; /* message byte size */
  char* req; // requested fucntion like get and put
  char delim[] = " "; // for space between get and file or any other similar call
  char* filename; // var for filename
  char* spare_string; // everyone needs a spare

  char* dirname = "./"; //for ls
  DIR* p;
  struct dirent* d;
  char* fname;

  if (argc != 2) {
    fprintf(stderr, "usage: %s <port>\n", argv[0]);
    exit(1);
  }
  portno = atoi(argv[1]);

  sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0)
    perror("ERROR opening socket");


  optval = 1;
  setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR,
	     (const void *)&optval , sizeof(int));

  bzero((char *) &serveraddr, sizeof(serveraddr));
  serveraddr.sin_family = AF_INET;
  serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
  serveraddr.sin_port = htons((unsigned short)portno);

  if (bind(sockfd, (struct sockaddr *) &serveraddr,
	   sizeof(serveraddr)) < 0)
    perror("ERROR on binding");

  clientlen = sizeof(clientaddr);
  while (1) {
    bzero(buf, BUFSIZE);
    n = recvfrom(sockfd, buf, BUFSIZE, 0, (struct sockaddr *) &clientaddr, &clientlen);
    if (n < 0)
      perror("ERROR in recvfrom");

    hostp = gethostbyaddr((const char *)&clientaddr.sin_addr.s_addr,
			  sizeof(clientaddr.sin_addr.s_addr), AF_INET);
    if (hostp == NULL)
      perror("ERROR on gethostbyaddr");

    hostaddrp = inet_ntoa(clientaddr.sin_addr);
    if (hostaddrp == NULL)
      perror("ERROR on inet_ntoa\n");

    printf("server received datagram from %s (%s)\n", hostp->h_name, hostaddrp);

    printf("server received %ld/%d bytes: %s\n", strlen(buf), n, buf);

    if(n > 0)
		{
      buf[strcspn(buf, "\n")] = 0;
  		req = strtok(buf, delim);
  		filename = strtok(NULL, delim);
      printf("req:%s, filename:%s\n",req,filename);

			if(!strcmp(req, "get")) //if client needs a file
      {
        send_file(sockfd, &clientaddr, filename, &clientlen);  //in shared.c
      }

			else if(!strcmp(req, "put")) // if client wants to send a file
      {
        receive_file(sockfd, &clientaddr, filename, &clientlen); //in shared.c
      }

			else if(!strcmp(req, "delete")) // to delete a file on the server
      {
        if(remove(filename) != 0)
        {
          printf("%s\n", "File not found");
        }
      }

			else if(!strcmp(req, "ls")) //send all filenames in local dir
      {
        buf[0] = '\0';
        p=opendir(dirname);
        while(d = readdir(p))
        {
          fname = d->d_name;
          if(!strcmp(fname, ".") || !strcmp(fname, "..")) continue; // change directory
          strcat(fname, ", "); // csv
          strcat(buf, fname); //filenames concatted to buffer
        }

        sendto(sockfd, buf, BUFSIZE, MSG_CONFIRM,
          (struct sockaddr *) &clientaddr, clientlen);
      }

			else if (!strcmp(req, "exit"))
      {
        printf("%s\n", "Server requested to exit");
        exit(0);
        return 0;
      }

      else
      {
        printf("Invalid request, please input again\n");
      }
		}
  }
};
