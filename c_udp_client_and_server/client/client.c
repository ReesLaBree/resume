// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// client.c
// serve as the client to send requests to and from the server
//
// parameters:		int			IP address ofthe machine on which the server application is running
// 			int			port the server application is using
//
// functionality:	get [file_name]		retrieves a file from the server
// 			put [file_name]		sends a file to the server
// 			delete [file_name]	delete a file from the server
// 			ls			lists files currently stored on server
// 			exit			exits the client


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>

#include "../shared.c"

#define BUF_SIZE 1024

void printMenu()
{
	printf("1) get [file_name]\n");
	printf("2) put [file_name]\n");
	printf("3) delete [file_name]\n");
	printf("4) ls\n");
	printf("5) exit\n");
	printf("Enter Selection: \n");
}

int main(int argc, char* argv[])
{
	int sockfd, portno, n;
	int serverlen;
	struct sockaddr_in serveraddr;
	struct hostent *server;
	char *hostname;
	char buf[BUF_SIZE];

	// check structure of the function call
	if (argc != 3) {
		 fprintf(stderr,"usage: %s <hostname> <port>\n", argv[0]);
		 exit(0);
	}
	hostname = argv[1];
	portno = atoi(argv[2]); //get port number from input

	/* socket: create the socket */
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0)
			perror("ERROR opening socket");

	/* gethostbyname: get the server's DNS entry */
	server = gethostbyname(hostname);
	if (server == NULL) {
			fprintf(stderr,"ERROR, no such host as %s\n", hostname);
			exit(0);
	}

	/* build the server's Internet address */
	bzero((char *) &serveraddr, sizeof(serveraddr));
	serveraddr.sin_family = AF_INET;
	bcopy((char *)server->h_addr,
	(char *)&serveraddr.sin_addr.s_addr, server->h_length);
	serveraddr.sin_port = htons(portno);

	//some useful variables
	int fd;
	char* request;
	char* filename;
	FILE* file;
	char* response;

	char delim[] = " ";

	char readline[BUF_SIZE];

	serverlen = sizeof(serveraddr);

	while(1)
	{
		bzero(buf, BUF_SIZE);
		printMenu();
		fgets(buf, BUF_SIZE, stdin);

		memcpy(&readline, &buf, BUF_SIZE);

		readline[strcspn(readline, "\n")] = 0;
		request = strtok(readline, delim);
		filename = strtok(NULL, delim);

			if (!strcmp(request, "get"))
			{
				n = sendto(sockfd, buf, strlen(buf), 0, (struct sockaddr *)&serveraddr, serverlen);
		    if (n < 0)
		      printf("ERROR in sendto");
				receive_file(sockfd,&serveraddr,filename, &serverlen);
			}
			else if (!strcmp(request, "put"))
			{
				n = sendto(sockfd, buf, strlen(buf), 0, (struct sockaddr *)&serveraddr, serverlen);
				if((file = fopen(filename,"r")) == NULL){
					printf("%s\n","404 File Not Found!" );
				}
				else{
					fclose(file);
					send_file(sockfd,&serveraddr,filename, &serverlen);
				}
			}
			else if (!strcmp(request, "delete"))// to delete a file
			{
				n = sendto(sockfd, buf, strlen(buf), 0, (struct sockaddr *)&serveraddr, serverlen);
			}
			else if (!strcmp(request, "ls")) // list all files on server
			{
		    n = sendto(sockfd, buf, strlen(buf), 0, (struct sockaddr *)&serveraddr, serverlen);
		    if (n < 0)
		      perror("ERROR in sendto");
				n = recvfrom(sockfd, buf, BUF_SIZE, 0, (struct sockaddr *)&serveraddr, &serverlen);
				printf("%s\n", buf);
			}
			else if (!strcmp(request, "exit")) // terminate server and client
			{
				sendto(sockfd, (const char *)buf, strlen(buf), 0,
				(const struct sockaddr *) &serveraddr, serverlen);
				exit(0);
			}
			else
			{
				printf("Invalid request, please input again\n");
			}
		}

}
