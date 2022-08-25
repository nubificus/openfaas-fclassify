#include <stdio.h>
#include <stdlib.h>

#include <vaccel.h>

int fileread(char **ptr, ssize_t * len);
int main(int argc, char **argv)
{
	char *ptr;
	ssize_t len;
	int ret = 0;

	char *image;
	size_t image_size;
	char out_text[512], out_imagename[512];
	struct vaccel_session sess;

	/* Read Input */
	fileread(&ptr, &len);

	/* init vAccel Session */
	ret = vaccel_sess_init(&sess, 0);
	if (ret != VACCEL_OK) {
		fprintf(stderr, "Could not initialize session\n");
		return 1;
	}

	printf("Initialized session with id: %u\n", sess.session_id);

	image = ptr;
	image_size = len;

	/* Do Image Classification */
	ret =
	    vaccel_image_classification(&sess, image, (unsigned char *)out_text,
					(unsigned char *)out_imagename,
					image_size, sizeof(out_text),
					sizeof(out_imagename));
	if (ret) {
		fprintf(stderr, "Could not run op: %d\n", ret);
		goto close_session;
	}

	printf("classification tags: %s\n", out_text);

	/* Close vAccel Session */
close_session:
	free(image);
	if (vaccel_sess_free(&sess) != VACCEL_OK) {
		fprintf(stderr, "Could not clear session\n");
		return 1;
	}

	return ret;
}
