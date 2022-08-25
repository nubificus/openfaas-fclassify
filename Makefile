all: fileread.so test

fileread.so:
	gcc -Wall -c fileread.c -fPIC 
	gcc -shared fileread.o -o libfileread.so
	ar rcs libfileread.a fileread.o

test:
	gcc -Wall pipe.c -o pipe -lfileread -L. -lvaccel -ldl

clean:
	rm -rf *.o *.so *.a pipe
