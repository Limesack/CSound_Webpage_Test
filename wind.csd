<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d -odac0
</CsOptions>
<CsInstruments>
; Initialize the global variables.

	sr	= 44100     // sample rate
	nchnls	= 2     // number of channels (stereo)
	0dbfs	= 1


	// cosine table used by instrument
	  giCosine ftgen 0, 0, 8192, 9, 1, 1, 90

// UDO used in instrument

    opcode Farnel_Pan, aa, ak
    ain, kpan   xin             // read input parameters
    aoutL    init 0                  // initialize output
    aoutR    init 0                  // initialize output
    kpan *= 0.25
    kpan -= 0.25
    kpanL = kpan
    kpanR = kpan
    kpanL -= 0.25
    aoutL = ain * cos(kpanL*$M_PI*2)
    aoutR = ain * cos(kpanR*$M_PI*2) // endret til PD range (0-1)
    xout aoutL, aoutR               // write output

    endop


instr wind
	// fetches data from website
		// amplitude
			k_output_amp init 1 // initial value shared by the website slider
			k_output_amp chnget "wind_amp"	// in the range 0-1
			k_output_amp portk k_output_amp, 0.005	// portamento to avoid unwanted noise
		// amplitude
			k_buildings_amp init 1 // initial value shared by the website slider
			k_buildings_amp chnget "buildings_amp"	// in the range 0-1
			k_buildings_amp portk k_buildings_amp, 0.005	// portamento to avoid unwanted noise
		// amplitude
			k_doorways_amp init 1 // initial value shared by the website slider
			k_doorways_amp chnget "doorways_amp"	// in the range 0-1
			k_doorways_amp portk k_doorways_amp, 0.005	// portamento to avoid unwanted noise
		// amplitude
			k_branches_amp init 1 // initial value shared by the website slider
			k_branches_amp chnget "branches_amp"	// in the range 0-1
			k_branches_amp portk k_branches_amp, 0.005	// portamento to avoid unwanted noise
		// amplitude
			k_leaves_amp init 1 // initial value shared by the website slider
			k_leaves_amp chnget "leaves_amp"	// in the range 0-1
			k_leaves_amp portk k_leaves_amp, 0.005	// portamento to avoid unwanted noise

		// pan
			k_buildings_pan init 0.33 // initial value shared by the website slider
			k_buildings_pan chnget "buildings_pan"	// in the range 0-1
			k_buildings_pan portk k_buildings_pan, 0.005	// portamento to avoid unwanted noise
		//  pan
			k_doorways_pan init 0.8 // initial value shared by the website slider
			k_doorways_pan chnget "doorways_pan"	// in the range 0-1
			k_doorways_pan portk k_doorways_pan, 0.005	// portamento to avoid unwanted noise
		// pan
			k_branches_pan init 0.56 // initial value shared by the website slider
			k_branches_pan chnget "branches_pan"	// in the range 0-1
			k_branches_pan portk k_branches_pan, 0.005	// portamento to avoid unwanted noise
		// pan
			k_leaves_pan init 0.87 // initial value shared by the website slider
			k_leaves_pan chnget "leaves_pan"	// in the range 0-1
			k_leaves_pan portk k_leaves_pan, 0.005	// portamento to avoid unwanted noise

		// gust speed
			k_gust_speed init 0.1 // initial value shared by the website slider
			k_gust_speed chnget "gust_speed"	// in the range 0-1
			k_gust_speed portk k_gust_speed, 0.005	// portamento to avoid unwanted noise
		// squall
			k_squall_controll init 0 // initial value shared by the website slider
			k_squall_controll chnget "squall_controll"	// in the range 0-1
			k_squall_controll portk k_squall_controll, 0.005	// portamento to avoid unwanted noise


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% // local instrument separator
    // pd Windspeed start
        kamp = 1  // amplitude
        kcps = k_gust_speed // frequency in cycles per second.
		ifn = -1 // function table number, -1 which indicates a sine wave.										// shared between all intances of Oscili
		iphs = 0.25 // initial phase of sampling, expressed as a fraction of a cycle. 0.25 makes it a cosine	// shared between all intances of Oscili
        aosc  oscili kamp, kcps, ifn, iphs
        aosc += 1 //
        aosc *= 0.25 // reduces amplitude to between 0 and 0.25

    // gust
			// white noise generator
				kmin = -1 // minimum range limit
				kmax = 1 // maximum range limit
				anoise random kmin, kmax

        // 2 first-order lowpass filters
	        khp = 0.5 // the response curve's half-power point, in Hertz
	        anoise tone anoise, khp
	        anoise tone anoise, khp
        // first-order highpass filters
	        khp = 0 // the response curve's half-power point, in Hertz.
	        anoise atone anoise, khp
	        anoise *= 50 // mutliply to return to a amplitude of about 0.25

        // fetching test signal, scales it; squares it and then places it around local zero
	        agust_noise = aosc
	        agust_noise += 0.5
	        agust_noise *= agust_noise
	        agust_noise -= 0.125
        // sum and send to output
	        agust = anoise * agust_noise

    // squall
        asquall_test = aosc // fetch signal from test oscilator
        // places a lower bound asquall_test
        	asquall_max max asquall_test, a(0.4)
        // returns to base 0.0 and scales by 8 and squared to give a expanded amplitude curve
	        asquall_max -= 0.4
	        asquall_max *= 8
	        asquall_max *= asquall_max
				// white noise generator
					kmin = -1 // minimum range limit
					kmax = 1 // maximum range limit
					anoise random kmin, kmax
        // 2 first-order lowpass filters
	        khp = 3 // the response curve's half-power point, in Hertz
	        anoise tone anoise, khp
	        anoise tone anoise, khp
        // first-order highpass filters
	        khp = 0 // the response curve's half-power point, in Hertz.
	        anoise atone anoise, khp
	        anoise *= 20*k_squall_controll // mutliply to return to a amplitude of about 0.25
        // sum and send to output
        	asquall = anoise * asquall_max


        // summing before limiting
        	asum = aosc+agust+asquall
        // Limit
	        kllim = 0 // lower limit
	        kulim = 1 // upper limit
	        aWindSpeed limit asum, kllim, kulim // Sets the lower and upper limits of the value it processes.
    // pd windspeed end

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // common white noise send
			// white noise generator
				kmin = -1 // minimum range limit
				kmax = 1 // maximum range limit
				aWhiteNoise random kmin, kmax
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // buildings
        aWhiteNoise_Buildings = aWhiteNoise
        kCutoff = 1200 // cutoff frequency for filters
        anoise tone aWhiteNoise_Buildings, kCutoff
        anoise tone anoise, kCutoff
        kskal = 2.05
        anoise *= kskal // scaling to match amplitude of PD filter

        // aWindSpeed limiting
	        aWindSpeed_Buildings_Lim = aWindSpeed+0.2 // fetches output from windspeed
	        aWindSpeed_Buildings_Lim *= 0.6

        // limit
	        kllim = 0 // lower limit
	        kulim = 0.99 // upper limit
	        aWindSpeed_Buildings_Limited limit aWindSpeed_Buildings_Lim, kllim, kulim // Sets the lower and upper limits of the value it processes.

        //rzero filter, high pass filter with variable cutoff
	        anoise_del delay1 anoise
	        afilt = anoise-(aWindSpeed_Buildings_Limited*anoise_del)

        // summing
        	afilt *= 0.2

        // panning
	        kpan = k_buildings_pan
	        aBuilding_Out_L, aBuilding_Out_R Farnel_Pan afilt, kpan

        // output from buildings to CSound
	        chnset aBuilding_Out_L, "wind_Building_L"
	        chnset aBuilding_Out_R, "wind_Building_R"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // doorways 1
        aDoorways = aWindSpeed // fetches audio
        // Limit
	        kllim = 0.35 // lower limit
	        kulim = 0.6 // upper limit
	        aDoorways_Lim limit aDoorways, kllim, kulim // Sets the lower and upper limits of the value it processes.
	        aDoorways_Lim -= 0.35
	        aDoorways_Lim *= 2
	        aDoorways_Lim -= 0.25

        // cosine waveshaper
        	acosil table  aDoorways_Lim , giCosine, 1, 0, 1

        // lowpass filter
	        klp = 0.5 // the response curve's half-power point, in Hertz
	        acosil_lowpass tone acosil, klp
	        acosil_lowpass_copy = acosil_lowpass
	        acosil_lowpass *= 200
	        acosil_lowpass += 30
        // sine oscilator
	        kamp = 1 // amplitude
	        acps = acosil_lowpass // frequency in cycles per second.
	        asine_output oscili kamp, acps, ifn, iphs

        // white noise
        	aWhiteNoise_doorways = aWhiteNoise // fetches global white noise
        //anoise_buildings_filtered tone anoise_buildings_filtered, kCutoff

        // band pass filter
	        kfreq = 400 // Cutoff or center frequency for each of the filters.
	        kband = 20 // Bandwidth of the bandpass and bandreject filters.
	        anoise_buildings_filtered butterbp aWhiteNoise_doorways, kfreq, kband
        // lowpass filter
	        kCutoff = 400 // cutoff frequency for filters
	        anoise_buildings_filtered tone anoise_buildings_filtered, kCutoff
        // low boost filter
	        kfco = 400 // cutoff, corner, or center frequency, depending on filter type, in Hz.
	        klvl = 2 // level (amount of boost or cut), as amplitude gain
	        kQ = 0 // resonance (also kfco / bandwidth in many filter types).
	        kS = 0.9 // shelf slope parameter for shelving filters. Must be greater than zero
	        imode = 10 // filter mode
	        anoise_buildings_filtered rbjeq anoise_buildings_filtered, kfco, klvl, kQ, kS, imode
        // high boost filter
	        kfco = 10000 // cutoff, corner, or center frequency, depending on filter type, in Hz.
	        klvl = 2 // level (amount of boost or cut), as amplitude gain
	        kQ = 0 // resonance (also kfco / bandwidth in many filter types).
	        kS = 0.9 // shelf slope parameter for shelving filters. Must be greater than zero
	        imode = 12 // filter mode
	        anoise_buildings_filtered rbjeq anoise_buildings_filtered, kfco, klvl, kQ, kS, imode
	        anoise_buildings_filtered *= 1.15 // scaling to match amplitude of PD equivalent

        // multiplying with lowpass filtered original sound
	        aDoorways_Sum_1 = anoise_buildings_filtered * acosil_lowpass_copy
	        aDoorways_Sum_1 *= 2
        // multiplying with sine oscilator output of original sound
        	aDoorways_Sum_2 = anoise_buildings_filtered * asine_output
        // final summing of output busses
        	aDoorways_Sum_3 = aDoorways_Sum_1 * aDoorways_Sum_2
        // Mono to Stereo Panning
	        kpan = k_doorways_pan
	        aDoorways1_Out_L, aDoorways1_Out_R Farnel_Pan aDoorways_Sum_3, kpan

        // output from doorways 1 to CSound
	        chnset aDoorways1_Out_L, "wind_Doorways1_L"
	        chnset aDoorways1_Out_R, "wind_Doorways1_R"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // doorways 2
        aDoorways = aWindSpeed // fetches audio
        // Limit
	        kllim = 0.25 // lower limit
	        kulim = 0.5 // upper limit
	        aDoorways_Lim limit aDoorways, kllim, kulim // Sets the lower and upper limits of the value it processes.
	        aDoorways_Lim -= 0.25
	        aDoorways_Lim *= 2
	        aDoorways_Lim -= 0.25

        // cosine oscilator
	        kamp = 1 // amplitude
	        acps = aDoorways_Lim // frequency in cycles per second.
	        acosil oscili kamp, acps, ifn, iphs

        // lowpass filter
	        klp = 0.1 // the response curve's half-power point, in Hertz
	        acosil_lowpass tone acosil, klp
	        acosil_lowpass_copy = acosil_lowpass
	        acosil_lowpass *= 100
	        acosil_lowpass += 20
        // sine oscilator
	        kamp = 1 // amplitude
	        acps = acosil_lowpass // frequency in cycles per second.
	        asine_output oscili kamp, acps, ifn, iphs

        // white noise
        	aWhiteNoise_doorways = aWhiteNoise // fetches global white noise
        // band pass filter
	        kfreq = 200 // Cutoff or center frequency for each of the filters.
	        kband = 20 // Bandwidth of the bandpass and bandreject filters.
	        anoise_buildings_filtered butterbp aWhiteNoise_doorways, kfreq, kband
        // lowpass filter
	        kCutoff = 200 // cutoff frequency for filters
	        anoise_buildings_filtered tone anoise_buildings_filtered, kCutoff
        // low boost filter
	        kfco = 200 // cutoff, corner, or center frequency, depending on filter type, in Hz.
	        klvl = 2 // level (amount of boost or cut), as amplitude gain
	        kQ = 0 // resonance (also kfco / bandwidth in many filter types).
	        kS = 0.98 // shelf slope parameter for shelving filters. Must be greater than zero
	        imode = 10 // filter mode
	        anoise_buildings_filtered rbjeq anoise_buildings_filtered, kfco, klvl, kQ, kS, imode
        // high boost filter
	        kfco = 10000 // cutoff, corner, or center frequency, depending on filter type, in Hz.
	        klvl = 2 // level (amount of boost or cut), as amplitude gain
	        kQ = 0 // resonance (also kfco / bandwidth in many filter types).
	        kS = 0.9 // shelf slope parameter for shelving filters. Must be greater than zero
	        imode = 12 // filter mode
	        anoise_buildings_filtered rbjeq anoise_buildings_filtered, kfco, klvl, kQ, kS, imode
	        anoise_buildings_filtered *= 2.4 // scaling to match amplitude of PD equivalent

        // multiplying with lowpass filtered original sound
        	aDoorways_Sum_1 = anoise_buildings_filtered * acosil_lowpass_copy
        	aDoorways_Sum_1 *= 2
        // multiplying with sine oscilator output of original sound
        	aDoorways_Sum_2 = anoise_buildings_filtered * asine_output
        // final summing of output busses
        	aDoorways_Sum_3 = aDoorways_Sum_1 * aDoorways_Sum_2

        // Mono to Stereo Panning
        	kpan = k_doorways_pan
        	aDoorways2_Out_L, aDoorways2_Out_R Farnel_Pan aDoorways_Sum_3, kpan

        // output from doorways 2 to CSound
        	chnset aDoorways2_Out_L, "wind_Doorways2_L"
        	chnset aDoorways2_Out_R, "wind_Doorways2_R"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // branches, wires 1
        abrancheswires = aWindSpeed // fetches audio
        // creates separate busses
        // bus 1
        	abrancheswires_bus_1 = abrancheswires
        	abrancheswires_bus_1 *= abrancheswires_bus_1
        // bus 2
        	abrancheswires_bus_2 = abrancheswires
        	abrancheswires_bus_2 *= 1000
        	abrancheswires_bus_2 += 1000

        // white noise
        	aWhiteNoise_brancheswires = aWhiteNoise // fetches global white noise
        // band pass filter controlled by buss 2
        	kfreq = 1000 // Cutoff or center frequency for each of the filters.
        	kband = 60 // Bandwidth of the bandpass and bandreject filters.
        	aWhiteNoise_brancheswires_filtered butterbp aWhiteNoise_brancheswires, abrancheswires_bus_2, kband
        // multiplying filtered white noise and bus 1
        	abrancheswires_Sum = aWhiteNoise_brancheswires_filtered * abrancheswires_bus_1
        // scaling amplitude
        	abrancheswires_Sum *= 2

        // Mono to Stereo Panning
        	kpan = k_branches_pan
        	abrancheswires1_Out_L, abrancheswires1_Out_R Farnel_Pan abrancheswires_Sum, kpan

        // output from branches wires 1 to CSound
        	chnset abrancheswires1_Out_L, "wind_brancheswires1_L"
        	chnset abrancheswires1_Out_R, "wind_brancheswires1_R"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // branches, wires 2
        abrancheswires = aWindSpeed // fetches audio
        // creates separate busses
        // bus 1
	        abrancheswires_bus_1 = abrancheswires
	        abrancheswires_bus_1 += 0.12
	        abrancheswires_bus_1 *= abrancheswires_bus_1
        // bus 2
	        abrancheswires_bus_2 = abrancheswires
	        abrancheswires_bus_2 *= 400
	        abrancheswires_bus_2 += 600

        // white noise
        	aWhiteNoise_brancheswires = aWhiteNoise // fetches global white noise
        // band pass filter controlled by buss 2
	        kfreq = 1000 // Cutoff or center frequency for each of the filters.
	        kband = 60 // Bandwidth of the bandpass and bandreject filters.
	        aWhiteNoise_brancheswires_filtered butterbp aWhiteNoise_brancheswires, abrancheswires_bus_2, kband
        // multiplying filtered white noise and bus 1
        	abrancheswires_Sum = aWhiteNoise_brancheswires_filtered * abrancheswires_bus_1
        // scaling amplitude
        	abrancheswires_Sum *= 1.2

        // Mono to Stereo Panning
        	kpan = k_branches_pan
        	abrancheswires2_Out_L, abrancheswires2_Out_R Farnel_Pan abrancheswires_Sum, kpan

        // output from branches wires 2 to CSound
        	chnset abrancheswires2_Out_L, "wind_brancheswires2_L"
        	chnset abrancheswires2_Out_R, "wind_brancheswires2_R"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // tree leaves
        atreeleaves = aWindSpeed
        atreeleaves += 0.3
        // lowpass filter
        	kCutoff = 0.07 // cutoff frequency for filters
        	atreeleaves_filtered tone atreeleaves, kCutoff
        // splitting and multiplying signal
        	atreeleaves_bus1 = atreeleaves_filtered * 0.4
        	atreeleaves_bus2 = atreeleaves_filtered - 0.2

        // subtracts atreeleaves_bus1 from 1
        	atreeleaves_bus1 -= 1
        // white noise
        	aWhiteNoise_treeleaves = aWhiteNoise // fetches global white noise
        // maximum of whitenoise and atreeleaves busses
        	atreeleaves_max max aWhiteNoise_treeleaves, atreeleaves_bus1
        	atreeleaves_max *= 0.09 // scales down atreeleaves_max in order to match PD equivalent

        // multiplies max signal and atreeleaves_bus1
        	atreeleaves_max *= atreeleaves_bus1
        // first-order highpass filters
        	khp = 200 // the response curve's half-power point, in Hertz.
        	atreeleaves_filtered atone atreeleaves_max, khp
        // lowpass filter
        	khp = 4000 // the response curve's half-power point, in Hertz
        	atreeleaves_filtered tone atreeleaves_filtered, khp
        // scaling to match amplitude of PD equivalent
        	atreeleaves_filtered *= 1.2
        // multiplying with 2nd bus
        	atreeleaves_Sum = atreeleaves_filtered * atreeleaves_bus2
        // scaling
        	atreeleaves_Sum *= 0.8

        // Mono to Stereo Panning
        	kpan = k_leaves_pan
        	atreeleaves_Out_L, atreeleaves_Out_R Farnel_Pan atreeleaves_Sum, kpan

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // Output
    	aOutL = k_output_amp * (k_buildings_amp*(aBuilding_Out_L) + k_doorways_amp*(aDoorways1_Out_L+aDoorways2_Out_L) + k_branches_amp*(abrancheswires1_Out_L+abrancheswires2_Out_L) + k_leaves_amp*(atreeleaves_Out_L))
    	aOutR = k_output_amp * (k_buildings_amp*(aBuilding_Out_R) + k_doorways_amp*(aDoorways1_Out_R+aDoorways2_Out_R) + k_branches_amp*(abrancheswires1_Out_R+abrancheswires2_Out_R) + k_leaves_amp*(atreeleaves_Out_R))
    // final output to CSound
			outs aOutL, aOutR

endin

</CsInstruments>
<CsScore>
i"wind" 0 86400

</CsScore>

/* Sources
Farnell, A. (2010). Designing Sound. The MIT Press. 24 Practical 18 wind (pp.472-481)
https://www.csounds.com/manual/html/index.html
*/
