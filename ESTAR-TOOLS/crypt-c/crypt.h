#ifndef _CRYPT_H
#define _CRYPT_H

#include <stdbool.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>

#define MICRO_IN_SEC 1000000.00

inline static double microtime() {
	struct timeval tp = {0};

	if (gettimeofday(&tp, NULL)) {
		return 0;
	}

	return (double)(tp.tv_sec + tp.tv_usec / MICRO_IN_SEC);
};

unsigned int crypt_code(const char *str, unsigned int strlen, char **ret, const char *key, bool mode, unsigned int expiry);

inline static char *crypt_encode(const char *str, unsigned int strlen, const char *key, unsigned int expiry) {
	char *enc = NULL;

	crypt_code(str, strlen, &enc, key, false, expiry);
	
	return enc;
}

inline static unsigned int crypt_decode(const char *dec, char **data, const char *key, unsigned int expiry) {
	return crypt_code(dec, strlen(dec), data, key, true, expiry);
}

#endif
