#include "shared.h"
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <math.h>
#include <unistd.h>
#include <errno.h>

//note - add typing to variables
struct packet
{
	int file_id;				//keep track of packets for multiple files
	int packet_number;			//keep track of which packet we are on
	int total_packets;			//how many packets to expect
	int data_length;			//how much data is stored in this packet
	char data[1024 - 4*sizeof(int)];	//dataspace = BUF_SIZE - 4*sizeof(int)
};

void make_packet(struct packet* new_packet, int file_id, int packet_num, int total_packets, char* data, int count)
{
	new_packet->file_id = file_id; //this is the header information
	new_packet->packet_number = packet_num;
	new_packet->total_packets = total_packets;
	new_packet->data_length = count;
	memcpy(&new_packet->data,data,new_packet->data_length);
}

void send_file(int socket, void* address, char* filename, int* serverlen)
{
	int data_size = (1024 - 4*sizeof(int));
	int packet_counter = 1;
	struct packet* to_send = malloc(1024 * sizeof(char));
	srand(time(NULL));
	int file_id = rand();
	int n;

	//take file and break into BUF_SIZE - 4*sizeof(int) byte packets
	FILE* fp;
	char* buffer = (char*) malloc(1024*sizeof(char));

	//file operations
	fp = fopen(filename, "r");
	if(fp == NULL){
		fp = fopen("none.txt", "r"); //incase the file does not exist, place this message
	}
	struct stat st;
	stat(filename, &st);
	int file_size = st.st_size; // get file size to know how many packets needed
	int num_packets = ceil(file_size / data_size) + 1;
	size_t count;

	while(!feof(fp))
	{
		while((count = fread(buffer, 1, data_size, fp)) != 0)
		{
			printf("count: %zu\n", count);
			//make a packet
			printf("data size: %d\nnum_packets: %d\n", data_size, num_packets);
			make_packet(to_send, file_id, packet_counter, num_packets, buffer, count);

			packet_counter++;	//iterate packet counter for multiple packets
			memset(buffer, 0x00, 1024); //clear buffer
			memcpy(buffer, to_send, 1024); //copy packet into buffer

			//send a packet
			sleep(.25);
			n = sendto(socket, buffer, 1024, 0, (struct sockaddr *) address, *serverlen);

			fprintf(stderr, "error: %d\n", errno); //error handling for sendto

			printf("bytes sent: %d\n", n); //send verification
			sleep(.1); //wait a sec for receive
		}
	}
	free(buffer);
}

void parse_packet(char* buffer, struct packet *new_packet)
{
	//printf("Inside parse_packet, buffer = %s\n", buffer);
	int i=0;
	//grab file_id
	memcpy(&new_packet->file_id, &buffer[i], sizeof(int));
	i += sizeof(int);

	//grab packet number
	memcpy(&new_packet->packet_number, &buffer[i], sizeof(int));
	i += sizeof(int);

	//grab total packets
	memcpy(&new_packet->total_packets, &buffer[i], sizeof(int));
	i += sizeof(int);

	// grab data_length
	memcpy(&new_packet->data_length, &buffer[i], sizeof(int));
	i += sizeof(int);

	//grab data
	memset(&new_packet->data, 0x00, 1008);
	memcpy(&new_packet->data, &buffer[i], new_packet->data_length);
}

void receive_file(int socket, void *address, char* filename, int* length)
{
	char* buffer = (char*) malloc(1024*sizeof(char));
	int num_packets;
	int current_packet;
	struct packet* received = (struct packet*) malloc(1024*sizeof(char));

	// open empty file to write to
	FILE* fp;
	int n;
	fp = fopen(filename, "w");
	// start receiving packets
	if(fp){
		do {
			n = recvfrom(socket, buffer, 1024, 0, (struct sockaddr *) address, length);
			parse_packet(buffer, received); // take the header off the recv file

			// write packet to file
			fwrite(received->data, 1, received->data_length * sizeof(char), fp);

			num_packets = received->total_packets;
			current_packet = received->packet_number; // tracking number of packets
		} while(current_packet < num_packets); // to know when to quit loop
	}
	else{
		printf("%s\n", "unable to open file"); // if file is not there
	}

	fclose(fp);
	free(received);
	free(buffer);
}
