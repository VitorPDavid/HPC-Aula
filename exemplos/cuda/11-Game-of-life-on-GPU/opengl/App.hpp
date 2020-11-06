#ifndef _APP_HPP_
#define _APP_HPP_

 #include <time.h>
 #include <sys/time.h>
 /**
   * \brief Estrutura para tratar cronometro.
   */
 struct stStopwatch_Unix
 {
    struct timeval mStartTime;
    struct timeval mEndTime;
    double mElapsedTime;
 };
 typedef struct stStopwatch_Unix Stopwatch;



 /**
   * \brief Dispara cronometro.
   */
 #define START_STOPWATCH( prm ) {                                               \
     gettimeofday( &prm.mStartTime, 0);                                   \
 }

 /**
   * \brief Para cronometro.
   */
 #define STOP_STOPWATCH( prm ) {                                                     \
    gettimeofday( &prm.mEndTime, 0);                                                     \
    prm.mElapsedTime = (1000.0f * ( prm.mEndTime.tv_sec - prm.mStartTime.tv_sec) + (0.001f * (prm.mEndTime.tv_usec - prm.mStartTime.tv_usec)) );                                                \
 }


#endif
