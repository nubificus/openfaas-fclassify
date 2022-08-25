#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define CHUNK 4096
int fileread(char**ptr, ssize_t *len)
{
	char buf[CHUNK];
	int ret = 0;
	int size = 0;
	char *p = malloc(CHUNK);
	while ((ret = read (STDIN_FILENO, buf, CHUNK)) > 0) {
		size += ret;
		p = realloc(p, size);
		memcpy(p+(size - ret), buf, ret);
	}
	//write(STDOUT_FILENO, p, size);
	*ptr = p;
	*len = size;

	return 0;
}

