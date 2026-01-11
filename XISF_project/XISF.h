
#pragma once
#define _USE_MATH_DEFINES
#include <math.h>

#ifdef XISF_EXPORTS
	#define XISF_API __declspec(dllexport)
#else
	#define XISF_API __declspec(dllimport)
#endif

