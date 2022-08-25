all: fileread.so test

fileread.so:
	gcc -Wall -c fileread.c -fPIC 
	gcc -shared fileread.o -o libfileread.so
	ar rcs libfileread.a fileread.o

test:
	gcc -Wall test.c -o test -lfileread -L. -lvaccel -ldl # -I/vaccelrt/include -L/vaccelrt/lib -lvaccel -ldl
	#gcc -Wall test.c -o test_static -static -lfileread -L. -L${PWD}/vaccelrt/build/src -lvaccel -I${PWD}/vaccelrt/src

clean:
	rm -rf *.o *.so *.a test test_static
