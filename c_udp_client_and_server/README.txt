The README.txt file must explain what you have done and how to run it.
The documentation does not have to be long, but does have to be very clear.

REES LaBREE, NOAH FREEMAN

The server.c file is inside of the server directory.
There is also an associated makefile within the server directory.
    make clean    -removes executable files from directory
    make          -builds executable for the server

The client.c file is inside of the client directory.
There is also an associated makefile within the client directory.
    make clean    -removes executable files from the directory
    make          -builds executable for client

Inside of the main directory is shared.c, which contains functions referenced by both server and client.

./server accepts 1 argument, the port number.
./client accepts 2 arguments, the server address and the server port number.

The implementation is relatively simple.
All commands are sent through a buffer and receive on the same buffer.
In the event of sending a file, the shared.c method send_file is called which breaks the file into packets.
When the server realizes it is receiving a file, it calls receive_file which beings a do while loop for accepting packets and parsing them.
Because the responses on 'ls', 'delete' and 'exit' are short, those are loaded directly into the buffer in server.c and sent to client.
