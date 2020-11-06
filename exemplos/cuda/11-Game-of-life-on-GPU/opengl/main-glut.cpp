/*
 * File Main
 * Traffic Cellular Automata simulation  TCA-S
 */

 #include <GL/glut.h>
 #include <GL/glu.h>
 #include <GL/gl.h>
#include <cstdlib>
#include <cstring>
#include <CellularAutomata.hpp>
#include <App.hpp>
extern "C" {
  #include <ModelTypes.h>
  #include <Tools.h>
}


Stopwatch stopwatch;
float     elapsedTime = 0.0f,
          FPS = 0.0f;
int       width = 800,
          height = 600;
bool      start = false;

tpConfig  config;
CellularAutomata CA;
float    mScaleX = 0.0f,
         mScaleY = 0.0f;

void render(void)
{
    glClear(GL_COLOR_BUFFER_BIT);


//------------------------------------------------------------------------------
  if (CA.isInit()){
    float dX = 0.0f,
          dY = 0.0f;

    glColor3f(0.2f, 0.8f, 0.2f);

    for (int j = 0; j < config.height; j++){
        for (int i = 0; i <  config.width; i++){

            if (CA.getLattice(i,j) == 1){
              glPushMatrix();
              glTranslatef(dX, dY, 0.0f);


                glBegin(GL_QUADS); //GL_QUADS);GL_LINE_LOOP

                glVertex3f(0.0f, 0.0f, 0.0f);
                glVertex3f(0.0f, -mScaleY, 0.0f);
                glVertex3f(mScaleX, -mScaleY, 0.0f);
                glVertex3f(mScaleX, 0.0f, 0.0f);


                glEnd();
                glPopMatrix();
            }


            dX += mScaleX;

        }
        dY -= mScaleY;
        dX = 0.0f;

      }

    }
//------------------------------------------------------------------------------

/*
    float delta  = 0.0f;
    glColor3f(0.0f, 0.0f, 1.0f);
//    for (int i = 0; i < cellularAutomata->getCellX(); i++)

    for (int j = 0; j <= config.height; j++){
        glBegin(GL_LINES); //GL_QUADS);GL_LINE_LOOP
        glVertex3f(0.0f, -delta, 0.0f);
        glVertex3f(1.0f, -delta, 0.0f);
        glEnd();
        delta += mScaleY;
    }

    delta = 0.0f;
    for (int j = 0; j <= config.width; j++){
        glBegin(GL_LINES); //GL_QUADS);GL_LINE_LOOP
        glVertex3f(delta, 0.0f, 0.0f);
        glVertex3f(delta, -1.0f, 0.0f);
        glEnd();
        delta += mScaleX;
    }
*/

    glutSwapBuffers();


}

// Função de inicialização de parâmetros (OpenGL e outros)
void init (void)
{
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
   config.width = 256   ;
   config.height = 256;
   config.prob = 0.5f;
   config.processor = GPU;


   mScaleY  = 1.0f / static_cast <float> (config.height);
   mScaleX  = 1.0f / static_cast <float> (config.width);
   CA.setConfig(config);

}

// Função de evento do teclado
void keyboardEvent(unsigned char key, int x, int y)
{
     //    glutPostRedisplay();
    switch (key) {
        case 'i':
        case 'I':
            CA.init();
            //CA.onRunning();
            break;

        case 'e':
        case 'E':
            CA.step();
            break;
        case 'r':
        case 'R':
            if (CA.isRunning())
              CA.offRunning();
            else
              CA.onRunning();
            break;

        case 'q':
        case 'Q':
        case 27:
            exit (EXIT_SUCCESS);
            break;


        default:
            break;
   }
}

// Função de evento do mouse
void mouseEvent(int button, int state, int x, int y)
{
/*
    if (button == GLUT_LEFT_BUTTON)
        if (state == GLUT_DOWN){
            float x1 = (static_cast<float>(x) / width) * static_cast<float>(cellularAutomata->getCellX());
            float y1 = (static_cast<float>(y) / height) * static_cast<float>(cellularAutomata->getCellY());
            int x2 = static_cast<int>(x1)  ;
            int y2 = static_cast<int>(y1) ;
            //x2 /=  cellularAutomata->getCellX();
            //y2 /=  cellularAutomata->getCellY();

            //cellularAutomata->changeState(x2, y2);

        }

    if (button == GLUT_RIGHT_BUTTON)
        if (state == GLUT_DOWN)
            cerr << "Right button" << endl;
*/
   glutPostRedisplay();
}

//Viewport
void viewPort(int w, int h)
{

    if(h == 0) h = 1;


    width = w;
    height = h;
    glViewport(0, 0, w, h);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho (-0.01f, 1.01f, -1.01f, 0.01f, -1.0f, 1.0f);
    glutPostRedisplay();
}

//Loop principal da visualização
void mainloop(void)
{



//    cellularAutomata->update();

    STOP_STOPWATCH(stopwatch);
    elapsedTime += stopwatch.mElapsedTime;

    CA.update();
    //if (start)
      //  cellularAutomata->update(stopwatch.mElapsedTime);

    FPS++;
    if (FPS >= 100.0f){
        float realfps = 1000.0f / (elapsedTime / 100.0f);
        char msg[1024];
//        sprintf(msg, "CA - Game of life \t \t Alive: %.2f \t Dead: %.2f \t FPS: %5.2f", cellularAutomata->getAlive(), cellularAutomata->getDead(), realfps);
        sprintf(msg, "CA - Game of life \t \t FPS: %.2f", realfps);
        glutSetWindowTitle(msg);
        FPS = 0.0f;
        elapsedTime = 0.0f;
    }
    START_STOPWATCH(stopwatch);

    glutPostRedisplay();
}


int main(int argc, char**argv)
{
    START_STOPWATCH(stopwatch);

    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
    glutInitWindowSize(width, height);
    glutCreateWindow("Cellular Automata - Game of life - v1.0");
    glutDisplayFunc(render);
    glutReshapeFunc(viewPort);
    glutMouseFunc(mouseEvent);
    glutKeyboardFunc(keyboardEvent);
    glutIdleFunc(mainloop);
    init();
    glutMainLoop();
    return EXIT_SUCCESS;
}
/*
CellularAutomata mCellularAutomata;
int main(int argc, char *argv[])
{


   if (argc > 1){
       if (strcmp(argv[1], "help") == 0){
          mCellularAutomata.help();
          return EXIT_SUCCESS;
       }

       mCellularAutomata.init() ;
       mCellularAutomata.alloc(256, 256) ;


       while (mCellularAutomata.isRunning()){
          mCellularAutomata.update();
       }

       mCellularAutomata.finalize();


   }
   return EXIT_SUCCESS;
}
*/
