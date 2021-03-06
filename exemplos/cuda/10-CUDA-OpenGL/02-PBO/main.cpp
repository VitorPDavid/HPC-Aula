#include <glew.h>

#include <glut.h>
#include <GL/glu.h>

#include <GL/gl.h>


#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <vector>

//CUDA includes
#include <vector_types.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <cuda_gl_interop.h>
#include <cstring>

#include <GPU.h>
#include <App.h>
#include <image.h>

tpImage    *mTexture;

uchar4     *mGPU_texture = NULL;

double     mFrames = 0.0f,
           mElapsedTime;

Stopwatch mStopWatch;

char      mWindowsLabel[256];

float     mRatio = 0.0f;



void render(void)
{

    uchar4 *ptrPBO = NULL;

    glClearColor(0.0f,0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    glPushMatrix();
    glColor3f(1.0f, 1.0f, 1.0f);


    
    CHECK_ERROR(cudaGLMapBufferObject((void**)&ptrPBO, mTexture->bufferObject));


    callCUDA(ptrPBO, mGPU_texture, mTexture->width, mTexture->height, mRatio);

    //runGPU(image3, Ratio, mPrint);

    CHECK_ERROR(cudaGLUnmapBufferObject(mTexture->bufferObject));

    glTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, mTexture->width,  mTexture->height,
                    GL_RGBA, GL_UNSIGNED_BYTE, NULL);



    glBegin(GL_POLYGON);

        glTexCoord2f(0.0f, 0.0f);
        glVertex3f(0.1f, 0.1f, 0.0f);

        glTexCoord2f(1.0f, 0.0f);
        glVertex3f(0.9f, 0.1f, 0.0f);

        glTexCoord2f(1.0f, 1.0f);
        glVertex3f(0.9f, 0.9f, 0.0f);

        glTexCoord2f(0.0f, 1.0f);
        glVertex3f(0.1f, 0.9f, 0.0f);
        glEnd();

    glPopMatrix();
      
 
      glutSwapBuffers();    
      
}

void shutDown(void)
{
    CHECK_ERROR(cudaGLUnregisterBufferObject(mTexture->bufferObject));
    CHECK_ERROR(cudaFree(mGPU_texture));

    DestroyImage(mTexture);
}

void keyboard(unsigned char key, int x, int y)
{
   
   switch (key)
   {
       case '+':
           mRatio += 0.1f;
           if (mRatio > 1.0f)
               mRatio = 1.0f;

           break;

       case '-':
           mRatio -= 0.1f;
           if (mRatio < 0.0f)
               mRatio = 0.0f;
           break;


        case 27: 
           shutDown();

           exit(EXIT_SUCCESS);
           break; 
   }
   
}

void mainLoop(void)
{   

    STOP_STOPWATCH(mStopWatch);
    mElapsedTime += mStopWatch.mElapsedTime;

    if (mFrames >= 10.0f)
    {
        mElapsedTime /= mFrames;
        sprintf(mWindowsLabel, "%lf (ms) / %lf / %f",
                mElapsedTime, (1000.0f / mElapsedTime),
                mRatio);
        glutSetWindowTitle(mWindowsLabel);
        mFrames      = 0.0f;
        mElapsedTime = 0.0f;

    }
    START_STOPWATCH(mStopWatch);
   // render();

    mFrames++;
    glutPostRedisplay();


   
}

void viewPort(int w, int h)
{

   glViewport(0, 0, w, h);  
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();

   glOrtho (0.0f, 1.0f, 0.0f, 1.0f, -10.0f, 10.0f);
   gluLookAt(0.0f, 0.0f, 0.0f, 0.0, 0.0, -10.0, 0.0, 1.0, 0.0);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
}

int main (int argc, char **argv)
{
   FREQUENCY(mStopWatch);


   glutInit(&argc, argv);
   glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
   glutInitWindowSize(800, 600);
   glutInitWindowPosition(10, 10);
   glutCreateWindow("Demo 04 - Usando PBO");

   printf("Loading extensions: %s\n", glewGetErrorString(glewInit()));
   if(!glewIsSupported(
      "GL_VERSION_2_0 " 
      "GL_ARB_pixel_buffer_object "
      "GL_EXT_framebuffer_object "
   )){
      fprintf(stderr, "ERROR: Support for necessary OpenGL extensions missing.");
      fflush(stderr);
      return EXIT_FAILURE;
   }

   glEnable(GL_TEXTURE_2D);
   glEnable(GL_DEPTH_TEST);

   mTexture = ReadPpmImage2RGBA("img2.ppm");

   int size = mTexture->width * mTexture->height * 4;
   CHECK_ERROR(cudaMalloc((void**)&mGPU_texture, size));
   CHECK_ERROR(cudaMemcpy(mGPU_texture, mTexture->bits, size, cudaMemcpyHostToDevice));

   CreateTexture(mTexture,GL_LINEAR,GL_LINEAR);
   
   CHECK_ERROR(cudaGLRegisterBufferObject(mTexture->bufferObject));

   glBindTexture(GL_TEXTURE_2D, mTexture->textureHandle);

   glutDisplayFunc(render);
   glutReshapeFunc(viewPort);
   glutKeyboardFunc(keyboard);
   glutIdleFunc(mainLoop);
   glutMainLoop();
   
}
