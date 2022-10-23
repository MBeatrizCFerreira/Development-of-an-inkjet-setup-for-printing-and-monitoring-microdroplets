//======================================================================//
// Title:     Supplementary Material of "Development of an inkjet setup //
//            for printing and monitoring microdroplets"                //
// Author:    Beatriz Cavaleiro de Ferreira                             //
// Date:      22 Oct 2022                                               //
// Software:  Arduino 1.8.13                                            //
//                                                                      //
//  Based on the solution developed by Kyle's Make Blog,                //
//  avaliable in http://www.kylescholz.com/wp/waveform-generator/       //
//======================================================================//

// STEP WAVE WITH 1us RESOLUTION, FALL AND RISE TIMES OF 5us, 
// VARIABLE FREQUENCY (MIN 250Hz), VARIABLE AMPLITUDE AND VARIABLE DWELL TIME
// GIVEN THROUGH SERIAL PORT.

#define  SAMPLES  4000  //800        //250Hz, 800-5us, 4000-1us.
int sample=1000;        //1s period, which is equivelent to 1Hz 
int V_ZERO=2290;
int V_HIGH=2700;     
int V_MAX=3600;      
int V_MIN=2290;      
int V_INCREMENT=0;  
int P_WIDTH=20;
int P_MAX=75;        
int P_MIN=10;
int P_INCREMENT=0;   
int d=0;             
int i=0;
int j=0;
int k=0;
unsigned long t=0;
uint32_t l=0;
uint16_t wave[4000];

// Incantations for DAC set-up for analogue wave using DMA and timer interrupt.
// http://asf.atmel.com/docs/latest/sam3a/html/group__sam__drivers__dacc__group.html
void setupDAC() {
  pmc_enable_periph_clk (DACC_INTERFACE_ID) ;   // Start clocking DAC.
  dacc_reset(DACC);
  dacc_set_transfer_mode(DACC, 0);
  dacc_set_power_save(DACC, 0, 1);              // sleep = 0, fast wakeup = 1
  dacc_set_analog_control(DACC, DACC_ACR_IBCTLCH0(0x02) | DACC_ACR_IBCTLCH1(0x02 ) | DACC_ACR_IBCTLDACCORE(0x01));
  dacc_set_trigger(DACC, 1);
  dacc_set_channel_selection(DACC, 0);          //Sets DAC0 as the output pin
  dacc_enable_channel(DACC, 0);
  NVIC_DisableIRQ(DACC_IRQn);
  NVIC_ClearPendingIRQ(DACC_IRQn);
  NVIC_EnableIRQ(DACC_IRQn);
  dacc_enable_interrupt(DACC, DACC_IER_ENDTX);  // DACC_IER Interrupt Enable Register
  DACC->DACC_PTCR = 0x00000100;                 // DACC_IER_ENDTX End of PDC Interrupt Enable
}

void DACC_Handler(void) {
  DACC->DACC_TNPR = (uint32_t) wave;
  DACC->DACC_TNCR = SAMPLES;                    // Number of counts until Handler re-triggered
  DACC->DACC_IDR = DACC_IDR_ENDTX;
}

// System timer clock set-up for DAC wave.
void setupTC (float freq_hz) {  
  int steps = (420000000UL / freq_hz) / (10*SAMPLES);
  pmc_enable_periph_clk(TC_INTERFACE_ID);
  TcChannel * t = &(TC0->TC_CHANNEL)[0];
  t->TC_CCR = TC_CCR_CLKDIS;                // Disable TC clock.
  t->TC_IDR = 0xFFFFFFFF;
  t->TC_SR;                                 // Clear status register.
  t->TC_CMR =                               // Capture mode.
              TC_CMR_TCCLKS_TIMER_CLOCK1 |  // Set the timer clock to TCLK1 (MCK/2 = 84MHz/2 = 48MHz).
              TC_CMR_WAVE |                 // Waveform mode.
              TC_CMR_WAVSEL_UP_RC;          // Count up with automatic trigger on RC compare.
  t->TC_RC = steps;                         // Frequency.
  t->TC_RA = steps /2;                      // Duty cycle (btwn 1 and RC).
  t->TC_CMR = (t->TC_CMR & 0xFFF0FFFF) | 
              TC_CMR_ACPA_CLEAR |           // Clear TIOA on counter match with RA0.
              TC_CMR_ACPC_SET;              // Set TIOA on counter match with RC0.
  t->TC_CCR = TC_CCR_CLKEN | TC_CCR_SWTRG;  // Enables the clock if CLKDIS is not 1.
}

void setup() {
  Serial.begin(9600);
  analogWriteResolution(12);
  setupDAC();
  float freq_hz = 250;                      // Target: 250Hz
  setupTC(freq_hz);
  NVIC_EnableIRQ(DACC_IRQn);                // Enable a device specific interrupt.
  pinMode(LED_BUILTIN, OUTPUT);
  for(d=0;d<SAMPLES;d++)
    wave[d]=V_ZERO;
}

void loop() {
  //Serial port update
  if(Serial.available()>0)
  {
    DACC->DACC_IER = DACC_IER_ENDTX;
    V_HIGH=Serial.parseInt();
    P_WIDTH=Serial.parseInt();
    sample=Serial.parseInt();

    while( (millis()-t)%sample != 0){}
    t=millis();
    Serial.println("DROPSerial");
    
    DACC->DACC_IER = DACC_IER_ENDTX;
    
    delay(1);
    if (V_HIGH>V_MAX)
      V_HIGH=V_MAX;
    else if (V_HIGH<V_MIN)
      V_HIGH=V_MIN;
    if (P_WIDTH>P_MAX)
      P_WIDTH=P_MAX;
    else if (P_WIDTH<P_MIN)
      P_WIDTH=P_MIN;
    if (sample<4)
      sample=4;
          
    for(d=0;d<5;d++)
    {
      wave[d]=round((V_HIGH-V_ZERO)/5)*d+V_ZERO;
    }
    for(i=d;i<(P_WIDTH+d);i++)
    {
      wave[i]=V_HIGH;
    }
    for(j=i;j<(i+d);j++)
    {
      wave[j]=round((V_HIGH-V_ZERO)/5)*(5-(j-i))+V_ZERO;
    }
    for(k=j;k<(P_MAX+10);k++)
    {
      wave[k]=V_ZERO;
    }
    while( (millis()-t)%sample != 0){}
    t=millis();
    Serial.println("DROPUpdated");
  }
  
  DACC->DACC_IER = DACC_IER_ENDTX;
  delay(1);
  while((millis()-t)%sample != 0){}
  t=millis();
  Serial.println("DROPSimple");
}
