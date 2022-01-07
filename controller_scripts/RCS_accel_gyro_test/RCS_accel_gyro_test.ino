/*
 * This code was developed to help with RCS for the 
 * Portland State Aerospace Society
 * 
 * Started by Max, mee5@pdx.edu
 * 
 * This code uses an object called AVERAGED_DATA, 
 * which holds a list of values of size NUM_SAMPLES.
 * Every time a new datum is sent with the update()
 * function, the sum is quickly updated with the 
 * difference between the oldest datum (from the list)
 * and the new datum, allowing the average of all 
 * elements in the list to be quickly updated.
 * 
 * There is a time delay since the average is of
 * past data. This delay will increase as NUM_SAMPLES
 * is increased. 
 * 
 * The reported program space or RAM space from
 * compliling may be and underestimate since the 
 * AVERAGED_DATA objects may not be initialized.
 * Make sure NUM_SAMPLES is not too large.
 * 
 * A generalized calibration function should be
 * made for the AVERAGED_DATA class
 * 
 *
 * This code was first compiled with an
 * Adafruit Feather Sense and utilizes the built-in
 * LSM sensor  
 */


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
// IMPORTS AND DEFINITIONS
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

// SENSORS
#include <Adafruit_LSM6DS33.h>


// PARAMETERS
#define NUM_SAMPLES       32    // Number of samples taken for averages



// CLASSES
class AVERAGED_DATA {
  
  private:
    float mean;                   // The average of the data
    float sum;                     // The sum of the data
    
    int index;                    // The index of the recently recieved data
    float values[NUM_SAMPLES];      // An arry holding all values

    unsigned long loopStartTime;
    int timeDelay;                // The time difference between now and the middle of the loop's time domain
    
    
  public:

    /*!
     * @breif   Updates the mean and stores the info
     * @param   newDatum - the newestDatum, as an float
     */
    void update(float newDatum) { 

      // Change the average
      index = (++index) % NUM_SAMPLES;            // update the index to the oldest (or next empty) value
      sum += newDatum - values[index];            // update the sum with first-in-last-out
      mean = float(sum) / float(NUM_SAMPLES);     // update the average

      // Store the info
      values[index] = newDatum;

      // Check time and record delay
      if (index == 1) {
        unsigned long resetTime = millis();             // Record the time now
        timeDelay = (resetTime - loopStartTime)/2;  // The delay is half of the loop time.
        loopStartTime = resetTime;                      // Reset the time when the loop started.
      }
    }

    /*!
     * @breif     Safely retrieves the mean-average
     * @return    The average
     */
    float getMean() {
      return mean;
    }

    /*!
     * @breif     Safely retrieves the time delay
     * @return    The time delay in milliseconds
     */
    int getDelay() {
      return timeDelay;
    }
};



// OBJECTS

Adafruit_LSM6DS33 LSM;  // accelerometer, gyroscope, temperature

AVERAGED_DATA ACCEL_X;
AVERAGED_DATA ACCEL_Y;
AVERAGED_DATA ACCEL_Z;

AVERAGED_DATA GYRO_X;
AVERAGED_DATA GYRO_Y;
AVERAGED_DATA GYRO_Z;


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
// SETUP AND LOOP
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

void setup() {

  // Serial: begins as 115200 baud
  Serial.begin(115200);


  // LSM: starts the accelerometer
  LSM.begin_I2C();

}

void loop() {

  // Reads the sensors and updates all of the averages
  readSensors();

  // Prints all of the averages, referencing the AVERAGED_DATA objects
  updateSerial();
}



////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
// USER FUNCTIONS
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////


/*!
 * @brief   Calculates the runtime in seconds
 * @return  The runtime in seconds
 */
float getRuntime() {
  static unsigned long startTime = millis();
  
  float timeMillis = millis() - startTime;      // Calculates the change in milliseconds
  float timeMinutes = timeMillis / 1000.0;     // Converts to seconds

  return timeMinutes;
}


/*!
 * @brief   Reads the sensors and updates the AVERAGED_DATA objects
 */
void readSensors() {
  // Reads sensors and updates the latest acceleration data.

  // This reads the information on the LSM module
  static sensors_event_t accel, gyro, temp;
  LSM.getEvent(&accel, &gyro, &temp);

  // Updates each AVERAGED_DATA object
  ACCEL_X.update(accel.acceleration.x);
  ACCEL_Y.update(accel.acceleration.y);
  ACCEL_Z.update(accel.acceleration.z);
  GYRO_X.update(gyro.gyro.x);
  GYRO_Y.update(gyro.gyro.y);
  GYRO_Z.update(gyro.gyro.z);
}


void printTimes() {
  Serial.print(getRuntime(), 3);
  Serial.print("\t");
  
  // Since all variables are being updated at about the same time,
  // only one update needs to be displayed
  Serial.print(ACCEL_X.getDelay());
}

void printACCEL() {
  Serial.print(ACCEL_X.getMean(), 2);
  Serial.print("\t");
  Serial.print(ACCEL_Y.getMean(), 2);
  Serial.print("\t");
  Serial.print(ACCEL_Z.getMean(), 2);
}

void printGYRO() {
  Serial.print(GYRO_X.getMean(), 2);
  Serial.print("\t");
  Serial.print(GYRO_Y.getMean(), 2);
  Serial.print("\t");
  Serial.print(GYRO_Z.getMean(), 2);
}


/*!
 * @brief   Prints a row of data in the Serial Port
 */
void updateSerial() {

  
  //printTimes();

  Serial.print("\t");
  
  //printACCEL();

  Serial.print("\t");
  
  printGYRO();
  
  Serial.println(" ");
}
