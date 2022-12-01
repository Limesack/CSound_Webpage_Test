<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d -odac0
</CsOptions>
<CsInstruments>
; Initialize the global variables.

	sr	= 44100     // sample rate
	nchnls	= 2     // number of channels (stereo)
	0dbfs	= 1


instr police
  // fetches data from website
    // amplitude
      k_police_speed init 0.1 // initial value shared by the website slider
      k_police_speed chnget "police_speed"	// in the range 0-1
      k_police_speed portk k_police_speed, 0.005	// portamento to avoid unwanted noise
// logosc recreation
    // oscilator for signal 1 and 2
    	kcps =  k_police_speed
    	ares phasor kcps
      ares *= 2

    // Signal 1
        // min, truncates the signal to stay below 1
            amin min ares, a(1)
            amin = 1-amin
        // POW Computes one argument to the power of another argument.
            kpow = 2.71828
            amin_pow pow amin, kpow
            amin_pow = 1-amin_pow

    // Signal 2
        // max, truncates the signal to stay above 1
            amax max ares, a(1)
            amax = amax-1
            amax = 1-amax
        // POW Computes one argument to the power of another argument.
            kpow = 2.71828
            amax_pow pow amax, kpow

    // Signal 1 and 2 are summed
        asum = amin_pow + amax_pow
    // scaling and shifting back to zero
        asum *= 2
        asum -= 3

// scale and offset
    asum *= 800
    asum += 300


// logosc 2, controlled by output from logosc 1
    // oscilator for signal 1 and 2

			kcps =  asum
		//  kcps downsamp asum ; løser ikke
    	ares phasor kcps
        ares *= 2

    // Signal 1
        // min, truncates the signal to stay below 1
            amin min ares, a(1)
            amin = 1-amin
        // POW Computes one argument to the power of another argument.
            kpow = 2.71828
            amin_pow pow amin, kpow
            amin_pow = 1-amin_pow

    // Signal 2
        // max, truncates the signal to stay above 1
            amax max ares, a(1)
            amax = 1-amax
            amax = 1-amax
        // POW Computes one argument to the power of another argument.
            kpow = 2.71828
            amax_pow pow amax, kpow

    // Signal 1 and 2 are summed
        asum = amin_pow + amax_pow
        asum *= 2
        asum -= 3

// plastic horn recreation
    // limit
        klow = -0.2 // low threshold
        khigh = 0.2 // high threshold
        ahorn_lim limit asum, klow, khigh
    // band pass filter
    	kfreq = 1500 // Cutoff or center frequency for each of the filters.
    	kband = 100 // Bandwidth of the bandpass and bandreject filters.
    	ahorn_lim butterbp ahorn_lim, kfreq, kband

// enviroment recreation
    // delays
        adel1 init 0 // Initialize delayline
        adel2 init 0 // Initialize delayline
        adel3 init 0 // Initialize delayline
        kfeedback = 0.05 // shared feedback for all delaylines
        idlt = 0.165 // delaytime 1
        adel1 delay (ahorn_lim+adel1)*kfeedback, idlt
        idlt = 0.121 // delaytime 2
        adel2 delay (ahorn_lim+adel2)*kfeedback, idlt
        idlt = 0.33 // delaytime 3
        adel3 delay (ahorn_lim+adel3)*kfeedback, idlt

    // summing delaylines
        aecho = (adel1+adel2+adel3)
        adel1 = 0 // clear delayline
        adel2 = 0 // clear delayline
        adel3 = 0 // clear delayline

    // adding direct and delayed signal
        asum = (ahorn_lim*0.7)+(aecho*0.5)
           // printks "pitch %f \n", 1, kcps
					//	printk 0.1, kdddcps
            outs asum,asum
endin


</CsInstruments>
<CsScore>
i"police" 0 86400

</CsScore>

/* Sources
Farnell, A. (2010). Designing Sound. The MIT Press. 28 Practical 5 police (pp.355-364)
https://www.csounds.com/manual/html/index.html
*/
