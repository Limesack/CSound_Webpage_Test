<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d -odac0
</CsOptions>
<CsInstruments>
; Initialize the global variables.

	sr	= 44100
	nchnls	= 2
	0dbfs	= 1

/* META DATA
*/

// Fire generator
instr fire_all
	// fetches data from website
		// amplitude
			k_control_amp init 0.5 // initial value shared by the website slider
			k_control_amp chnget "fire_amp"	// in the range 0-1
			k_control_amp portk k_control_amp, 0.005	// portamento to avoid unwanted noise
		// lapping
			k_control_lapping init 0.5 // initial value shared by the website slider
			k_control_lapping chnget "lapping"	// in the range 0-1
			k_control_lapping portk k_control_lapping, 0.005	// portamento to avoid unwanted noise
		// hissing
			k_control_hissing init 0.5 // initial value shared by the website slider
			k_control_hissing chnget "hissing"	// in the range 0-1
			k_control_hissing portk k_control_hissing, 0.005	// portamento to avoid unwanted noise
		// crackling
			k_control_crackling init 0.5 // initial value shared by the website slider
			k_control_crackling chnget "crackling"	// in the range 0-1
			k_control_crackling portk k_control_crackling, 0.005	// portamento to avoid unwanted noise

    // firegen 1
        // common white noise generator, shared the individual components
        	kmin = -1 // minimum range limit
        	kmax = 1 // maximum range limit
        	a_white_noise random kmin, kmax

        // pd hissing
            // highpass filter
                khp = 1200*k_control_hissing // the response curve's half-power point, in Hertz.
                a_hissing_noise_hp atone a_white_noise, khp
            // lowpass filter
                khp = 1 // the response curve's half-power point, in Hertz.
                a_hissing_noise_lp tone a_white_noise, khp
                a_hissing_noise_lp *= 10
            // squaring to increase dynamics
                a_hissing_noise_lp *= a_hissing_noise_lp
                a_hissing_noise_lp *= a_hissing_noise_lp
            // bring values up to a reasonable level
                a_hissing_noise_lp *= 800
            // summing hp and lp filtered noise
                a_hissing_noise = a_hissing_noise_lp * a_hissing_noise_hp
            // scaling
                a_hissing_1_out = a_hissing_noise*k_control_hissing*1.3

        // pd lapping
            // band pass filter
            	kfreq = 30*k_control_lapping // Cutoff or center frequency for each of the filters.
            	kband = 10*k_control_lapping // Bandwidth of the bandpass and bandreject filters.
            	a_lapping_noise_bp butterbp a_white_noise, kfreq, kband
            // highpass filter
                khp = 25 // the response curve's half-power point, in Hertz
                a_lapping_noise_hp atone a_lapping_noise_bp, khp
            // limit
                klow = -0.9 // low threshold
                khigh = 0.9 // high threshold
                a_lapping_noise_lim limit a_lapping_noise_hp, klow, khigh

            // highpass filter
                khp = 25 // the response curve's half-power point, in Hertz
                a_lapping_noise_lim_hp atone a_lapping_noise_lim, khp
            // amplitude scaling
                a_lapping_1_out = (a_lapping_noise_lim_hp*1.52) * (k_control_lapping)

        // pd crackles
            // control mechanism
                kamp = 1 // amplitude.
                kdensity = 10*k_control_crackling // average number of impulses per second.
                k_crackle_density dust kamp, kdensity

            // random generator, triggered by dust
            	kmin = 0 // minimum range limit
            	kmax = 50 // maximum range limit
            	ktrig = k_crackle_density // rate of random break-point generation
            	krandom trandom ktrig, kmin, kmax

            // schedules triggers of line instrument
                kmintim = 0
                kmaxnum = 1
                kwhen = 0
                kdur = krandom/1000 // converts to ms
                schedkwhen k_crackle_density, kmintim, kmaxnum, "fire_envelope_1", kwhen, kdur

            // band pass filter
            	kfreq = krandom // Cutoff or center frequency for each of the filters.
            	kband = 5000 // Bandwidth of the bandpass and bandreject filters.
            	a_crackling_bp butterbp a_white_noise, kfreq, kband
            // fetches envelope
                k_envelope_1 chnget "envelope_1_out"
            // summing
                a_crackling_sum = k_envelope_1 * a_crackling_bp
            // amplitude scaling
                a_crackling_1_out = (a_crackling_sum*0.3)*k_control_crackling

        // firegen output and final filtering
            a_firegen_out_1 = a_hissing_1_out + a_lapping_1_out + a_crackling_1_out
        // band pass filter
            kfreq = 600 // Cutoff or center frequency for each of the filters.
            kband = 200 // Bandwidth of the bandpass and bandreject filters.
            a_firegen_out_1 butterbp a_firegen_out_1, kfreq, kband

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // firegen 2
        // common white noise generator, shared the individual components
        	kmin = -1 // minimum range limit
        	kmax = 1 // maximum range limit
        	a_white_noise random kmin, kmax

        // pd hissing
            // highpass filter
                khp = 1200*k_control_hissing // the response curve's half-power point, in Hertz.
                a_hissing_noise_hp atone a_white_noise, khp
            // lowpass filter
                khp = 1 // the response curve's half-power point, in Hertz.
                a_hissing_noise_lp tone a_white_noise, khp
                a_hissing_noise_lp *= 10
            // squaring to increase dynamics
                a_hissing_noise_lp *= a_hissing_noise_lp
                a_hissing_noise_lp *= a_hissing_noise_lp
            // bring values up to a reasonable level
                a_hissing_noise_lp *= 600
            // summing hp and lp filtered noise
                a_hissing_noise = a_hissing_noise_lp * a_hissing_noise_hp
            // scaling
								a_hissing_2_out = a_hissing_noise*k_control_hissing*1.3

        // pd lapping
						// band pass filter
							kfreq = 30*k_control_lapping // Cutoff or center frequency for each of the filters.
							kband = 10*k_control_lapping // Bandwidth of the bandpass and bandreject filters.
							a_lapping_noise_bp butterbp a_white_noise, kfreq, kband
            // highpass filter
                khp = 25 // the response curve's half-power point, in Hertz
                a_lapping_noise_hp atone a_lapping_noise_bp, khp
            // limit
                klow = -0.9 // low threshold
                khigh = 0.9 // high threshold
                a_lapping_noise_lim limit a_lapping_noise_hp, klow, khigh

            // highpass filter
                khp = 25 // the response curve's half-power point, in Hertz
                a_lapping_noise_lim_hp atone a_lapping_noise_lim, khp
            // amplitude scaling
                  a_lapping_2_out = (a_lapping_noise_lim_hp*1.52) * (k_control_lapping)

        // pd crackles
            // control mechanism
							kamp = 1 // amplitude.
							kdensity = 10*k_control_crackling // average number of impulses per second.
							k_crackle_density dust kamp, kdensity

            // random generator, triggered by dust
            	kmin = 0 // minimum range limit
            	kmax = 50 // maximum range limit
            	ktrig = k_crackle_density // rate of random break-point generation
            	krandom trandom ktrig, kmin, kmax

            // schedules triggers of line instrument
                kmintim = 0
                kmaxnum = 1
                kwhen = 0
                kdur = krandom/1000 // converts to ms
                schedkwhen k_crackle_density, kmintim, kmaxnum, "fire_envelope_2", kwhen, kdur

            // band pass filter
            	kfreq = krandom // Cutoff or center frequency for each of the filters.
            	kband = 5000 // Bandwidth of the bandpass and bandreject filters.
            	a_crackling_bp butterbp a_white_noise, kfreq, kband
            // fetches envelope
                k_envelope_2 chnget "envelope_2_out"
            // summing
                a_crackling_sum = k_envelope_2 * a_crackling_bp
            // amplitude scaling
                a_crackling_2_out = (a_crackling_sum * 0.2)*k_control_crackling

        // firegen output and final filtering
            a_firegen_out_2 = a_hissing_2_out + a_lapping_2_out + a_crackling_2_out
        // band pass filter
            kfreq = 600 // Cutoff or center frequency for each of the filters.
            kband = 200 // Bandwidth of the bandpass and bandreject filters.
            a_firegen_out_2 butterbp a_firegen_out_2, kfreq, kband

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // firegen 3
        // common white noise generator, shared the individual components
        	kmin = -1 // minimum range limit
        	kmax = 1 // maximum range limit
        	a_white_noise random kmin, kmax

        // pd hissing
            // highpass filter
              	khp = 1200*k_control_hissing // the response curve's half-power point, in Hertz.
                a_hissing_noise_hp atone a_white_noise, khp
            // lowpass filter
                khp = 1 // the response curve's half-power point, in Hertz.
                a_hissing_noise_lp tone a_white_noise, khp
                a_hissing_noise_lp *= 10
            // squaring to increase dynamics
                a_hissing_noise_lp *= a_hissing_noise_lp
                a_hissing_noise_lp *= a_hissing_noise_lp
            // bring values up to a reasonable level
                a_hissing_noise_lp *= 600
            // summing hp and lp filtered noise
                a_hissing_noise = a_hissing_noise_lp * a_hissing_noise_hp
            // scaling
								a_hissing_3_out = a_hissing_noise*k_control_hissing*1.3


        // pd lapping
					// band pass filter
							kfreq = 30*k_control_lapping // Cutoff or center frequency for each of the filters.
							kband = 10*k_control_lapping // Bandwidth of the bandpass and bandreject filters.
							a_lapping_noise_bp butterbp a_white_noise, kfreq, kband
            // highpass filter
                khp = 25 // the response curve's half-power point, in Hertz
                a_lapping_noise_hp atone a_lapping_noise_bp, khp
            // limit
                klow = -0.9 // low threshold
                khigh = 0.9 // high threshold
                a_lapping_noise_lim limit a_lapping_noise_hp, klow, khigh

            // highpass filter
                khp = 25 // the response curve's half-power point, in Hertz
                a_lapping_noise_lim_hp atone a_lapping_noise_lim, khp
            // amplitude scaling
                  a_lapping_3_out = (a_lapping_noise_lim_hp*1.52) * (k_control_lapping)

        // pd crackles
            // control mechanism
                kamp = 1 // amplitude.
                kdensity = 10*k_control_crackling // average number of impulses per second.
                k_crackle_density dust kamp, kdensity

            // random generator, triggered by dust
            	kmin = 0 // minimum range limit
            	kmax = 50 // maximum range limit
            	ktrig = k_crackle_density // rate of random break-point generation
            	krandom trandom ktrig, kmin, kmax

            // schedules triggers of line instrument
                kmintim = 0
                kmaxnum = 1
                kwhen = 0
                kdur = krandom/1000 // converts to ms
                schedkwhen k_crackle_density, kmintim, kmaxnum, "fire_envelope_3", kwhen, kdur

            // band pass filter
            	kfreq = krandom // Cutoff or center frequency for each of the filters.
            	kband = 5000 // Bandwidth of the bandpass and bandreject filters.
            	a_crackling_bp butterbp a_white_noise, kfreq, kband
            // fetches envelope
                k_envelope_3 chnget "envelope_3_out"
            // summing
                a_crackling_sum = k_envelope_3 * a_crackling_bp
            // amplitude scaling
                a_crackling_3_out = (a_crackling_sum * 0.2)*k_control_crackling

        // firegen output and final filtering
            a_firegen_out_3 = a_hissing_3_out + a_lapping_3_out + a_crackling_3_out
        // band pass filter
            kfreq = 600 // Cutoff or center frequency for each of the filters.
            kband = 200 // Bandwidth of the bandpass and bandreject filters.
            a_firegen_out_3 butterbp a_firegen_out_3, kfreq, kband

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	// sum and output to website
		aoutput = k_control_amp*(a_firegen_out_1+a_firegen_out_2+a_firegen_out_3)

		outs aoutput, aoutput

endin

instr fire_envelope_1
    // linear envelope that ramps from 1 to 0 during the duration of p3
        kres linseg 1, p3*0.5, 0
        kres *= kres
        kres *= kres
        chnset kres, "envelope_1_out"
endin

instr fire_envelope_2
    // linear envelope that ramps from 1 to 0 during the duration of p3
        kres linseg 1, p3*0.5, 0
        kres *= kres
        kres *= kres
        chnset kres, "envelope_2_out"
endin

instr fire_envelope_3
    // linear envelope that ramps from 1 to 0 during the duration of p3
        kres linseg 1, p3*0.5, 0
        kres *= kres
        kres *= kres
        chnset kres, "envelope_3_out"
endin

</CsInstruments>
<CsScore>
i"fire_all" 0 86400

</CsScore>

/* Sources
Farnell, A. (2010). Designing Sound. The MIT Press. 28 Practical 11 fire (pp.408-418)
https://www.csounds.com/manual/html/index.html
*/
