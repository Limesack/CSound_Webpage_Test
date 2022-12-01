<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d -odac0
</CsOptions>
<CsInstruments>
; Initialize the global variables.

	sr	= 44100     // sample rate
	nchnls	= 2     // number of channels (stereo)
	0dbfs	= 1

instr pedestrian_beep
		// fetches data from website
			// amplitude
				k_control_amp init 0.5 // initial value shared by the website slider
				k_control_amp chnget "pedestrian_amp"	// in the range 0-1
				k_control_amp portk k_control_amp, 0.005
			// Frequency
				k_control_freq init 2500
				k_control_freq chnget "pedestrian_freq"
				k_control_freq portk k_control_freq, 0.005
			// Rythm
				k_control_rythm init 2
				k_control_rythm chnget "pedestrian_rytm"
				k_control_rythm portk k_control_rythm, 0.005
			// length
				k_control_len init 4
				k_control_len chnget "pedestrian_len"
				k_control_len portk k_control_len, 0.005
			// intensity
				k_control_intensity init 2
				k_control_intensity chnget "pedestrian_intensity"
				k_control_intensity portk k_control_intensity, 0.005


    // metro
        kfreq = k_control_len*k_control_intensity // frequency of trigger bangs in cps
        ktrig  metro  kfreq

		// counter
        kcount init 0
        if ktrig == 1 then
            kcount += 1
        endif

    // using modulo to create duty cycle
        kmute = kcount % 2

    // oscilator
        kamp = 1
        kcps = k_control_freq*k_control_intensity
		ifn = -1 // function table number, -1 which indicates a sine wave.
		iphs = 0.25 // initial phase of sampling, expressed as a fraction of a cycle. 0.25 makes it a cosine
        aoscil oscili kamp, kcps,ifn, iphs

    // summing and output
        aoutput = aoscil * kmute
        aoutput *= 0.33
		// scaling with control singal from website
				aoutput *= k_control_amp

		// master stero ouput to website
				outs aoutput, aoutput

endin

</CsInstruments>
<CsScore>
i"pedestrian_beep" 0 86400

</CsScore>

/* Sources
Farnell, A. (2010). Designing Sound. The MIT Press. 24 Practical 1 Pedestrians (pp.333-336)
https://www.csounds.com/manual/html/index.html
*/
