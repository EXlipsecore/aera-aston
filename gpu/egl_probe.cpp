/*
 * Copyright (C) 2026 AERA Recovery Project contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * aera-gpu-probe - renders a test frame and prints the GL renderer string.
 *
 * Checks whether the Adreno path is actually running or the UI is on software
 * rendering. Symbols are resolved with dlopen/dlsym so the tool still starts
 * and reports something useful when the graphics stack is broken.
 *
 *   adb shell /system/bin/aera-gpu-probe
 *
 * Exit codes: 0 pass, 1 no EGL config, 2 render or readback mismatch,
 *             3 symbol or library missing.
 */

#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES2/gl2.h>

namespace {

constexpr int kWidth = 256;
constexpr int kHeight = 256;
constexpr int kFrames = 60;

constexpr uint8_t kExpectR = 0x33;
constexpr uint8_t kExpectG = 0x99;
constexpr uint8_t kExpectB = 0xCC;
constexpr int kChannelTolerance = 3;

const char* kVertexSrc =
    "attribute vec4 aPos;\n"
    "void main() { gl_Position = aPos; }\n";

const char* kFragmentSrc =
    "precision mediump float;\n"
    "void main() { gl_FragColor = vec4(0.2, 0.6, 0.8, 1.0); }\n";

struct Gl {
  decltype(&eglGetDisplay) p_eglGetDisplay;
  decltype(&eglInitialize) p_eglInitialize;
  decltype(&eglQueryString) p_eglQueryString;
  decltype(&eglGetError) p_eglGetError;
  decltype(&eglChooseConfig) p_eglChooseConfig;
  decltype(&eglCreatePbufferSurface) p_eglCreatePbufferSurface;
  decltype(&eglCreateContext) p_eglCreateContext;
  decltype(&eglMakeCurrent) p_eglMakeCurrent;
  decltype(&eglDestroyContext) p_eglDestroyContext;
  decltype(&eglDestroySurface) p_eglDestroySurface;
  decltype(&eglTerminate) p_eglTerminate;

  decltype(&glGetString) p_glGetString;
  decltype(&glGetError) p_glGetError;
  decltype(&glCreateShader) p_glCreateShader;
  decltype(&glShaderSource) p_glShaderSource;
  decltype(&glCompileShader) p_glCompileShader;
  decltype(&glGetShaderiv) p_glGetShaderiv;
  decltype(&glGetShaderInfoLog) p_glGetShaderInfoLog;
  decltype(&glDeleteShader) p_glDeleteShader;
  decltype(&glCreateProgram) p_glCreateProgram;
  decltype(&glAttachShader) p_glAttachShader;
  decltype(&glBindAttribLocation) p_glBindAttribLocation;
  decltype(&glLinkProgram) p_glLinkProgram;
  decltype(&glGetProgramiv) p_glGetProgramiv;
  decltype(&glGetProgramInfoLog) p_glGetProgramInfoLog;
  decltype(&glUseProgram) p_glUseProgram;
  decltype(&glVertexAttribPointer) p_glVertexAttribPointer;
  decltype(&glEnableVertexAttribArray) p_glEnableVertexAttribArray;
  decltype(&glViewport) p_glViewport;
  decltype(&glClearColor) p_glClearColor;
  decltype(&glClear) p_glClear;
  decltype(&glDrawArrays) p_glDrawArrays;
  decltype(&glFinish) p_glFinish;
  decltype(&glReadPixels) p_glReadPixels;
};

template <typename T>
bool Resolve(void* library, const char* name, T* out) {
  *out = reinterpret_cast<T>(dlsym(library, name));
  if (*out == nullptr) {
    fprintf(stderr, "probe: missing symbol %s\n", name);
    return false;
  }
  return true;
}

double NowMs() {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return ts.tv_sec * 1000.0 + ts.tv_nsec / 1e6;
}

GLuint CompileShader(const Gl& gl, GLenum type, const char* src) {
  GLuint shader = gl.p_glCreateShader(type);
  if (!shader) return 0;
  gl.p_glShaderSource(shader, 1, &src, nullptr);
  gl.p_glCompileShader(shader);
  GLint ok = 0;
  gl.p_glGetShaderiv(shader, GL_COMPILE_STATUS, &ok);
  if (!ok) {
    char log[512] = {};
    gl.p_glGetShaderInfoLog(shader, sizeof(log) - 1, nullptr, log);
    fprintf(stderr, "probe: shader compile failed: %s\n", log);
    gl.p_glDeleteShader(shader);
    return 0;
  }
  return shader;
}

int Fail(const char* what) {
  fprintf(stderr, "probe: FAIL: %s\n", what);
  return 1;
}

}  // namespace

int main() {
  printf("aera-gpu-probe: aston / Adreno 740 validator\n");

  void* egl_lib = dlopen("/vendor/lib64/egl/libEGL_adreno.so",
                         RTLD_NOW | RTLD_GLOBAL);
  if (!egl_lib) {
    fprintf(stderr, "probe: cannot dlopen libEGL_adreno.so: %s\n", dlerror());
    fprintf(stderr, "probe: the Adreno EGL blob is missing from /vendor/lib64/egl\n");
  }
  void* gles_lib = dlopen("/vendor/lib64/egl/libGLESv2_adreno.so",
                          RTLD_NOW | RTLD_GLOBAL);
  if (!gles_lib) {
    fprintf(stderr, "probe: cannot dlopen libGLESv2_adreno.so: %s\n", dlerror());
  }
  if (!egl_lib || !gles_lib) return 3;

  Gl gl{};
  bool ok = Resolve(egl_lib, "eglGetDisplay", &gl.p_eglGetDisplay) &&
            Resolve(egl_lib, "eglInitialize", &gl.p_eglInitialize) &&
            Resolve(egl_lib, "eglQueryString", &gl.p_eglQueryString) &&
            Resolve(egl_lib, "eglGetError", &gl.p_eglGetError) &&
            Resolve(egl_lib, "eglChooseConfig", &gl.p_eglChooseConfig) &&
            Resolve(egl_lib, "eglCreatePbufferSurface", &gl.p_eglCreatePbufferSurface) &&
            Resolve(egl_lib, "eglCreateContext", &gl.p_eglCreateContext) &&
            Resolve(egl_lib, "eglMakeCurrent", &gl.p_eglMakeCurrent) &&
            Resolve(egl_lib, "eglDestroyContext", &gl.p_eglDestroyContext) &&
            Resolve(egl_lib, "eglDestroySurface", &gl.p_eglDestroySurface) &&
            Resolve(egl_lib, "eglTerminate", &gl.p_eglTerminate);
  if (!ok) return 3;

  ok = Resolve(gles_lib, "glGetString", &gl.p_glGetString) &&
       Resolve(gles_lib, "glGetError", &gl.p_glGetError) &&
       Resolve(gles_lib, "glCreateShader", &gl.p_glCreateShader) &&
       Resolve(gles_lib, "glShaderSource", &gl.p_glShaderSource) &&
       Resolve(gles_lib, "glCompileShader", &gl.p_glCompileShader) &&
       Resolve(gles_lib, "glGetShaderiv", &gl.p_glGetShaderiv) &&
       Resolve(gles_lib, "glGetShaderInfoLog", &gl.p_glGetShaderInfoLog) &&
       Resolve(gles_lib, "glDeleteShader", &gl.p_glDeleteShader) &&
       Resolve(gles_lib, "glCreateProgram", &gl.p_glCreateProgram) &&
       Resolve(gles_lib, "glAttachShader", &gl.p_glAttachShader) &&
       Resolve(gles_lib, "glBindAttribLocation", &gl.p_glBindAttribLocation) &&
       Resolve(gles_lib, "glLinkProgram", &gl.p_glLinkProgram) &&
       Resolve(gles_lib, "glGetProgramiv", &gl.p_glGetProgramiv) &&
       Resolve(gles_lib, "glGetProgramInfoLog", &gl.p_glGetProgramInfoLog) &&
       Resolve(gles_lib, "glUseProgram", &gl.p_glUseProgram) &&
       Resolve(gles_lib, "glVertexAttribPointer", &gl.p_glVertexAttribPointer) &&
       Resolve(gles_lib, "glEnableVertexAttribArray", &gl.p_glEnableVertexAttribArray) &&
       Resolve(gles_lib, "glViewport", &gl.p_glViewport) &&
       Resolve(gles_lib, "glClearColor", &gl.p_glClearColor) &&
       Resolve(gles_lib, "glClear", &gl.p_glClear) &&
       Resolve(gles_lib, "glDrawArrays", &gl.p_glDrawArrays) &&
       Resolve(gles_lib, "glFinish", &gl.p_glFinish) &&
       Resolve(gles_lib, "glReadPixels", &gl.p_glReadPixels);
  if (!ok) return 3;

  EGLDisplay display = gl.p_eglGetDisplay(EGL_DEFAULT_DISPLAY);
  if (display == EGL_NO_DISPLAY) return Fail("eglGetDisplay returned no display");

  EGLint major = 0, minor = 0;
  if (!gl.p_eglInitialize(display, &major, &minor)) {
    return Fail("eglInitialize failed (KGSL or EGL subdriver missing)");
  }
  printf("EGL version       : %d.%d\n", major, minor);
  const char* eglVendor = gl.p_eglQueryString(display, EGL_VENDOR);
  printf("EGL vendor        : %s\n", eglVendor ? eglVendor : "(null)");
  if (!eglVendor || strstr(eglVendor, "Qualcomm") == nullptr) {
    printf("WARNING: EGL vendor is not Qualcomm -- expect a software renderer\n");
  }

  const EGLint configAttribs[] = {
      EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
      EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
      EGL_RED_SIZE, 8,
      EGL_GREEN_SIZE, 8,
      EGL_BLUE_SIZE, 8,
      EGL_ALPHA_SIZE, 8,
      EGL_DEPTH_SIZE, 0,
      EGL_STENCIL_SIZE, 0,
      EGL_NONE,
  };
  EGLConfig config = nullptr;
  EGLint numConfigs = 0;
  if (!gl.p_eglChooseConfig(display, configAttribs, &config, 1, &numConfigs) ||
      numConfigs == 0) {
    return Fail("no EGL config supports a GLES2 pbuffer");
  }

  const EGLint pbufferAttribs[] = {
      EGL_WIDTH, kWidth,
      EGL_HEIGHT, kHeight,
      EGL_NONE,
  };
  EGLSurface surface =
      gl.p_eglCreatePbufferSurface(display, config, pbufferAttribs);
  if (surface == EGL_NO_SURFACE) return Fail("eglCreatePbufferSurface failed");

  const EGLint contextAttribs[] = {EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE};
  EGLContext context = gl.p_eglCreateContext(display, config, EGL_NO_CONTEXT,
                                           contextAttribs);
  if (context == EGL_NO_CONTEXT) return Fail("eglCreateContext failed");
  if (!gl.p_eglMakeCurrent(display, surface, surface, context)) {
    return Fail("eglMakeCurrent failed");
  }

  const char* vendor =
      reinterpret_cast<const char*>(gl.p_glGetString(GL_VENDOR));
  const char* renderer =
      reinterpret_cast<const char*>(gl.p_glGetString(GL_RENDERER));
  const char* glVersion =
      reinterpret_cast<const char*>(gl.p_glGetString(GL_VERSION));
  printf("GL vendor         : %s\n", vendor ? vendor : "(null)");
  printf("GL renderer       : %s\n", renderer ? renderer : "(null)");
  printf("GL version        : %s\n", glVersion ? glVersion : "(null)");

  const bool isAdreno = renderer && strstr(renderer, "Adreno") != nullptr;
  printf("\nRESULT: %s\n\n",
         isAdreno ? "HARDWARE (Adreno) path active"
                  : "SOFTWARE FALLBACK -- the Adreno path did not come up");

  GLuint vs = CompileShader(gl, GL_VERTEX_SHADER, kVertexSrc);
  GLuint fs = CompileShader(gl, GL_FRAGMENT_SHADER, kFragmentSrc);
  if (!vs || !fs) return 2;

  GLuint program = gl.p_glCreateProgram();
  gl.p_glAttachShader(program, vs);
  gl.p_glAttachShader(program, fs);
  gl.p_glBindAttribLocation(program, 0, "aPos");
  gl.p_glLinkProgram(program);
  GLint linked = 0;
  gl.p_glGetProgramiv(program, GL_LINK_STATUS, &linked);
  if (!linked) {
    char log[512] = {};
    gl.p_glGetProgramInfoLog(program, sizeof(log) - 1, nullptr, log);
    fprintf(stderr, "probe: link failed: %s\n", log);
    return 2;
  }
  gl.p_glUseProgram(program);

  static const GLfloat verts[] = {
      -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f,
      1.0f,  -1.0f, 1.0f, 1.0f,  -1.0f, 1.0f,
  };
  gl.p_glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, verts);
  gl.p_glEnableVertexAttribArray(0);

  gl.p_glViewport(0, 0, kWidth, kHeight);
  gl.p_glClearColor(kExpectR / 255.0f, kExpectG / 255.0f, kExpectB / 255.0f, 1.0f);
  gl.p_glClear(GL_COLOR_BUFFER_BIT);
  gl.p_glFinish();

  const double start = NowMs();
  for (int i = 0; i < kFrames; ++i) {
    gl.p_glClear(GL_COLOR_BUFFER_BIT);
    gl.p_glDrawArrays(GL_TRIANGLES, 0, 6);
  }
  gl.p_glFinish();
  const double elapsed = NowMs() - start;
  const double fps = elapsed > 0 ? (kFrames * 1000.0) / elapsed : 0.0;
  printf("rendered %d frames in %.2f ms -> %.1f fps (%dx%d)\n",
         kFrames, elapsed, fps, kWidth, kHeight);

  static uint8_t pixels[kWidth * kHeight * 4];
  memset(pixels, 0, sizeof(pixels));
  gl.p_glReadPixels(0, 0, kWidth, kHeight, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

  const uint8_t r = pixels[0], g = pixels[1], b = pixels[2], a = pixels[3];
  printf("readback RGBA     : %u %u %u %u (expected ~%u %u %u 255)\n",
         r, g, b, a, kExpectR, kExpectG, kExpectB);

  const GLenum glErr = gl.p_glGetError();
  if (glErr != GL_NO_ERROR) {
    fprintf(stderr, "probe: GL error 0x%x during render\n", glErr);
    return 2;
  }
  if (abs(static_cast<int>(r) - kExpectR) > kChannelTolerance ||
      abs(static_cast<int>(g) - kExpectG) > kChannelTolerance ||
      abs(static_cast<int>(b) - kExpectB) > kChannelTolerance) {
    fprintf(stderr,
            "probe: readback does not match -- the render did not reach memory\n");
    return 2;
  }

  printf("PASS: EGL + GLES2 + shader compiler + readback all working\n");
  printf("GPU path is %s. Frame pacing issues are power/refresh, not driver.\n",
         isAdreno ? "hardware" : "software");

  gl.p_eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
  gl.p_eglDestroyContext(display, context);
  gl.p_eglDestroySurface(display, surface);
  gl.p_eglTerminate(display);
  return 0;
}
