#include <GL/glew.h>

#include <GL/glut.h>
#include <GL/glu.h>
#include <GL/gl.h>

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <App.h>
#include <GPU.h>
#include <vector>
#include <cassert>
/*
#include <vector_types.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <cuda_gl_interop.h>
*/
#define WIDTH  800
#define HEIGHT 600
#define RATIO static_cast <float> (WIDTH) / static_cast <float> (HEIGHT);


Stopwatch mStopWatch;

char      mWindowsLabel[256];

double    mFrames      = 0.0f,
          mElapsedTime = 0.0f;

bool      mCoord = false,
          mPause = false,
          mBWire = false;

unsigned long mTimeSimulatio = 0;

unsigned int mVBOVertice     = 0,
             mVBOCor         = 0,
             mVertexPrg      = 0,
             mPixelPrg       = 0,
             mShaderPrg      = 0;

float   *gpu_U0 = NULL,   //alocado na GPU
        *gpu_U1 = NULL,   //Alocado na GPU
        *gpu_V  = NULL,
        mCoordX = 300.0f,
        mCoordY = 300.0f,
        mCoordZ = -1024.0f,
        mEyeX = 0.0f,
        mEyeY = 0.0f,
        mEyeZ = 0.0f,
        mScale  = 1.0f;


char *textFileRead(char *fn) {


	FILE *fp;
	char *content = NULL;

	int count=0;

	if (fn != NULL) {
		fp = fopen(fn,"rt");

		if (fp != NULL) {

      fseek(fp, 0, SEEK_END);
      count = ftell(fp);
      rewind(fp);

			if (count > 0) {
				content = (char *)malloc(sizeof(char) * (count+1));
				count = fread(content,sizeof(char),count,fp);
				content[count] = '\0';
			}
			fclose(fp);
		}
	}
	return content;
}

void render(void)
{
    

   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

   
   if (mCoord)
   {
       
       //glUseProgram(mShaderPrg);
       glBegin(GL_LINES);
           glColor3f(1.0f, 0.0f, 0.0f);
           glVertex3f(-512.0f, 0.0f, 0.0f);
           glVertex3f( 512.0f, 0.0f, 0.0f);

           glColor3f(0.0f, 1.0f, 0.0f);
           glVertex3f( 0.0f, -512.0f, 0.0f);
           glVertex3f( 0.0f,  512.0f, 0.0f);

           glColor3f(0.0f, 0.0f, 1.0f);
           glVertex3f( 0.0f, 0.0f, -512.0f);
           glVertex3f( 0.0f, 0.0f,  512.0f);
       glEnd();
       glPopMatrix();
   }

   //glScalef(1.0f, 1.0f, 1.0f);
   //CHECK_ERROR(cudaMemcpy(&mScale, &gpu_U0[131328], sizeof(float), cudaMemcpyDeviceToHost));
/*
   glPushMatrix();
        glColor3f(1.0f, 0.0f, 0.0f);
        if (!mBWire)
            glutSolidSphere(mScale, 100.0f, 100.0f);
        else
            glutWireSphere(mScale, 100.0f, 100.0f);
   glPopMatrix();

   
   glPushMatrix();
        glColor3f(1.0f, 1.0f, 1.0f);
        glTranslatef(0.0f, 0.0f, 400.0f);
        glScalef(1.50f, 1.0f, 0.25f);
        if (!mBWire)
            glutSolidCube(100.0f);
        else
            glutWireCube(100.0f);
   glPopMatrix();



*/
/*
    glPushMatrix();
    glUseProgram(mShaderPrg);
    glTranslatef(-1024.0f, 0.0f, -1024.0f);
        

           

            float4 *ptrVertice = NULL;

   
            if (!mPause)
            {
                mTimeSimulatio++;
                CHECK_ERROR(cudaGLMapBufferObject((void**)&ptrVertice, mVBOVertice));

                callCUDARun(ptrVertice, gpu_U0, gpu_U1, gpu_V, XPOINTS, ZPOINTS);
                CHECK_ERROR(cudaGLUnmapBufferObject(mVBOVertice));

                float  *gpu_ptr = gpu_U1;
                        gpu_U1 = gpu_U0;
                        gpu_U0 = gpu_ptr;

            }else
            {
   
                  CHECK_ERROR(cudaGLMapBufferObject((void**)&ptrVertice, mVBOVertice));

                    callCUDAPause(ptrVertice, gpu_U0, gpu_U1, XPOINTS, ZPOINTS);
                    CHECK_ERROR(cudaGLUnmapBufferObject(mVBOVertice));

                    

       //     }
            


        //glBindBuffer(GL_ARRAY_BUFFER, mVBOCor);
        //glColorPointer(4, GL_FLOAT, 0, 0);

        glBindBuffer(GL_ARRAY_BUFFER, mVBOVertice);
        glVertexPointer(4, GL_FLOAT, 0, 0);


        glEnableClientState(GL_VERTEX_ARRAY);
        //glEnableClientState(GL_COLOR_ARRAY);

        glDrawArrays(GL_POINTS , 0, XPOINTS * ZPOINTS);
        //glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_VERTEX_ARRAY);

        glUseProgram(0);
   glPopMatrix();
 
 */
   
   glutSwapBuffers();
}

void camera(void)
{
    float ratio = RATIO;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(90.0f, ratio, 1, 2000);
    gluLookAt(mCoordX, mCoordY, mCoordZ, //Posição da camera
              mEyeX, mEyeY, mEyeZ,     //Para onde a camera olha
              0.0f, 1.0f,0.0f);      //Orientação da camera

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    render();
}

void viewPort(int w, int h)
{
    //if(h == 0) h = 1;

    

    glViewport(0, 0, w, h);
    camera();
    
}

/*
void initialCondition(void)
{
    float X,
          Y,
          ret,
          W = (float) XPOINTS,
          H = (float) ZPOINTS,
          *cpu_U = new float [P_DOMAIN],
          *cpu_V = new float [P_DOMAIN];

    for (unsigned int x = 0; x < XPOINTS; x++)
    {
        for (unsigned int y = 0; y < ZPOINTS; y++)
        {
            X = (x - (0.5f * W)) * (x - (0.5f * H));
            Y = (y - (0.5f * W)) * (y - (0.5f * H));
            //ret = exp ( -(X + Y) / (0.000075f  * H  * W)  ); //0.000075
            ret = exp ( -(X + Y) / (0.000075 * H  * W)  ); //0.000075
            unsigned int p = y * XPOINTS + x;
            cpu_U[p] = ret * -150.0f;
            cpu_V[p] = 1.0f;
            //fprintf(stderr, "%d %d %f \n", x, y, cpu_U[p]);

            if ((x >= 237) && (x <= 274) && (y >= 352) && (y <= 360))
                cpu_V[p] = 0.0f ;//0.0f;
            
                
        }


    }

    //fprintf(stderr, "(%f, %f) \n", W, H);
    CHECK_ERROR(cudaMemcpy(gpu_V, cpu_V, P_DOMAIN * sizeof(float), cudaMemcpyHostToDevice));
    CHECK_ERROR(cudaMemcpy(gpu_U1, cpu_U, P_DOMAIN * sizeof(float), cudaMemcpyHostToDevice));
    CHECK_ERROR(cudaMemcpy(gpu_U0, cpu_U, P_DOMAIN * sizeof(float), cudaMemcpyHostToDevice));
    


    delete[] cpu_U;
    delete[] cpu_V;

    fprintf(stdout, "condicao inicial\n");fflush(stdout);
    mPause = true;
    mTimeSimulatio = 0;
}
*/

void init (void)
{
   int bsize = 0;

   fprintf(stdout, "Carregando extensoes do OpenGL [GLEW]: %s\n", glewGetErrorString(glewInit()));
   if(!glewIsSupported(
      "GL_VERSION_2_0 "
      "GL_ARB_pixel_buffer_object "
      "GL_EXT_framebuffer_object "
   )){
      fprintf(stderr, "ERROR: Support for necessary OpenGL extensions missing.");
      fflush(stderr);
      exit(EXIT_FAILURE);
   }

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glEnable(GL_POINT_SIZE);
    glEnable(GL_POINT_SMOOTH);
    glEnable(GL_DEPTH_TEST);

    //glEnable (GL_BLEND);
     //glBlendFunc(GL_ZERO, GL_SRC_COLOR);
   
    //glPointSize(0.1f);
    FREQUENCY(mStopWatch);

    int size = (XPOINTS * ZPOINTS  * 4);
    
/*
    //Alocando para vertice
    glGenBuffers(1, &mVBOVertice);
    assert(mVBOVertice != 0);

    glBindBuffer(GL_ARRAY_BUFFER, mVBOVertice);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * size,
                    0, GL_DYNAMIC_DRAW);

    //Verifica se o VBO foi realmente alocado!
    glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &bsize);
    assert(bsize == (sizeof(float) * size));

    glBindBuffer(GL_ARRAY_BUFFER, 0);

    //Registrando VBO no CUDA
    CHECK_ERROR(cudaGLRegisterBufferObject(mVBOVertice));

    //Aloca memória na GPU
    CHECK_ERROR(cudaMalloc((void**) &gpu_U0, P_DOMAIN * sizeof(float)));
    CHECK_ERROR(cudaMalloc((void**) &gpu_U1, P_DOMAIN * sizeof(float)));
    CHECK_ERROR(cudaMalloc((void**) &gpu_V, P_DOMAIN * sizeof(float)));
       //Inicializa memória
    initialCondition();
//    resetMemoryGPU();

    //Shader



    mVertexPrg = glCreateShader(GL_VERTEX_SHADER);
    mPixelPrg  = glCreateShader(GL_FRAGMENT_SHADER);

    	char *vs = textFileRead("minimal.vert");
	char *fs = textFileRead("minimal.frag");

	const char * vv = vs;
	const char * ff = fs;


    glShaderSource(mVertexPrg, 1, &vv, NULL);
    glShaderSource(mPixelPrg, 1, &ff, NULL);

    free(vs);free(fs);

    glCompileShader(mVertexPrg);
    glCompileShader(mPixelPrg);


    mShaderPrg = glCreateProgram();
    glAttachShader(mShaderPrg, mVertexPrg);
    glAttachShader(mShaderPrg, mPixelPrg);

    glLinkProgram(mShaderPrg);

	*/

}



void keyboardEvent(unsigned char key, int x, int y)
{
    switch (key) {

        case 'p':
        case 'P':
            mPause = !mPause;
            break;
        case '1':
            mCoordX = 0.0f;
            mCoordY = 0.0f;
            mCoordZ = -1024.0f;
            mEyeX = 0.0f;
            mEyeY = 0.0f;
            mEyeZ = 0.0f;
            fprintf(stdout, "camera 1\n"); fflush(stdout);
            camera();
            break;
            
        case '2':
            mCoordX = 100.0f;
            mCoordY = 100.0f;
            mCoordZ = -100.0f;
            mEyeX = 0.0f;
            mEyeY = 0.0f;
            mEyeZ = 0.0f;

            fprintf(stdout, "camera 2\n"); fflush(stdout);
            camera();
            break;
        case '3':
            mCoordX = 300.0f;
            mCoordY = 300.0f;
            mCoordZ = -1024.0f;
            mEyeX = 0.0f;
            mEyeY = 0.0f;
            mEyeZ = 0.0f;

            fprintf(stdout, "camera 3\n"); fflush(stdout);
            camera();
            break;

        case '4':
            mCoordX = -100.0f;
            mCoordY = -100.0f;
            mCoordZ = -100.0f;
            mEyeX = 0.0f;
            mEyeY = 0.0f;
            mEyeZ = 0.0f;

            fprintf(stdout, "camera 4\n"); fflush(stdout);
            camera();
            break;

        case '5':

            mCoordX = 150.0f;
            mCoordY = 100.0f;
            mCoordZ = 400.0f;
            mEyeX = 0.0f;
            mEyeY = 0.0f;
            mEyeZ = 400.0f;

            fprintf(stdout, "camera 5\n"); fflush(stdout);
            camera();
            break;

        case 'b':
        case 'B':
            mBWire = !mBWire;
            fprintf(stdout, "Wire %d\n");fflush(stdout);
            break;
        case 'i':
        case 'I':
            //initialCondition();
            break;
        case 'r':
        case 'R':
            mCoordX = 300.0f;
            mCoordY = 300.0f;
            mCoordZ = -1024.0f;
            //initialCondition();
            
            break;
        case 'c':
        case 'C':
            mCoord = !mCoord;
            break;
        case 'q':
        case 'Q':
        case 27:
/*
            CHECK_ERROR(cudaFree(gpu_U0));
            CHECK_ERROR(cudaFree(gpu_U1));
            CHECK_ERROR(cudaFree(gpu_V));
            CHECK_ERROR(cudaGLUnregisterBufferObject(mVBOVertice));
            glDeleteBuffers( 1, &mVBOVertice);
           */
            exit (EXIT_SUCCESS);
            break;

    }
}



void mainloop(void)
{

    

    STOP_STOPWATCH(mStopWatch);
    mElapsedTime += mStopWatch.mElapsedTime;

    if (mFrames >= 10.0f)
    {
        mElapsedTime /= mFrames;
        sprintf(mWindowsLabel, "%lf (ms) / %lf / %u", mElapsedTime, (1000.0f / mElapsedTime), mTimeSimulatio);
        glutSetWindowTitle(mWindowsLabel);
        mFrames      = 0.0f;
        mElapsedTime = 0.0f;

    }
    START_STOPWATCH(mStopWatch);
    mFrames++;
    glutPostRedisplay();
   
}

int main(int argc, char**argv)
{

    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
    glutInitWindowSize(WIDTH, HEIGHT);
    glutCreateWindow("GPU rule 90");
    glutDisplayFunc(render);
    glutReshapeFunc(viewPort);
    //glutMouseFunc(MouseEvent);
    glutKeyboardFunc(keyboardEvent);
    glutIdleFunc(mainloop);
    init();
    glutMainLoop();
    return EXIT_SUCCESS;
}
