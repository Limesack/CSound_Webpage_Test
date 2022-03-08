<CsoundSynthesizer>
<CsOptions>
-+rtmidi=NULL -M0 -m0d
</CsOptions>
<CsInstruments>
; Initialize the global variables.

	sr	= 44100
	nchnls	= 2
	0dbfs	= 1


/* input parameters for this effect
	"kCutoff" range (50, 5000) map (expon float) label "Cutoff frequency"
	"kBW" range (0.01, 1) map (lin float) label "Bandwidth"
	input:none output: 6 stereo pairs or 1 stereo pair
tags:filtered noise,
*/


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

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% // local instrument separator
    // pd Windspeed start
        kamp = 1  // amplitude
        kcps = 0.1 // frequency in cycles per second.
        aosc  oscili kamp, kcps
        aosc += 1 //
        aosc *= 0.25 // reduces amplitude to between 0 and 0.25

    // gust
        // white noise generator
        kamp = 1 // amplitude
        kbeta = 0 // beta of the lowpass filter
        anoise noise kamp, kbeta

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
        kamp = 1 // amplitude
        kbeta = 0 // beta of the lowpass filter
        anoise noise kamp, kbeta
        // 2 first-order lowpass filters
        khp = 3 // the response curve's half-power point, in Hertz
        anoise tone anoise, khp
        anoise tone anoise, khp
        // first-order highpass filters
        khp = 0 // the response curve's half-power point, in Hertz.
        anoise atone anoise, khp
        anoise *= 20 // mutliply to return to a amplitude of about 0.25
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
        kamp = 1.25 // amplitude
        kbeta = 0 // beta of the lowpass filter
        aWhiteNoise noise kamp, kbeta

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // buildings
        aWhiteNoise_Buildings = aWhiteNoise
        // kfreq = 800 // Cutoff or center frequency for each of the filters.
        // kband = 800 // Bandwidth of the bandpass and bandreject filters.
        // band pass filter
        //    anoise butterbp aWhiteNoise_Buildings, kfreq, kband
        // high pass filter and low pass filter set at lower and upper half power points
        // lower -3 point 494, upper -3 point 1294
        // not needed
        // anoise atone aWhiteNoise_Buildings, 0
        // 2 highpass filters to temporarily emulate the bandpass filter in PD
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

        // summing
        aBuilding = aWindSpeed_Buildings_Limited * anoise
        aBuilding *= 0.2

        // panning
        kpan = 0.51
        aBuilding_Out_L, aBuilding_Out_R Farnel_Pan aBuilding, kpan

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

        // ##################################################################################### non function
        // cosine oscilator
        kamp = 1 // amplitude
        acps = aDoorways_Lim // frequency in cycles per second.
        ifn = -1 // function table number, -1 which indicates a sine wave.
        iphs = 0.25 // initial phase of sampling, expressed as a fraction of a cycle. 0.25 makes it a cosine
        acosil oscili kamp, acps, ifn, iphs

        // lowpass filter
        klp = 0.5 // the response curve's half-power point, in Hertz
        acosil_lowpass tone acosil, klp
        acosil_lowpass_copy = acosil_lowpass
        acosil_lowpass *= 200
        acosil_lowpass += 30
        // sine oscilator
        kamp = 1 // amplitude
        acps = acosil_lowpass // frequency in cycles per second.
        ifn = -1 // function table number, -1 which indicates a sine wave.
        iphs = 0 // initial phase of sampling, expressed as a fraction of a cycle.
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
        kpan = 0.91
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

        // ##################################################################################### non function
        // cosine oscilator
        kamp = 1 // amplitude
        acps = aDoorways_Lim // frequency in cycles per second.
        ifn = -1 // function table number, -1 which indicates a sine wave.
        iphs = 0.25 // initial phase of sampling, expressed as a fraction of a cycle. 0.25 makes it a cosine
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
        ifn = -1 // function table number, -1 which indicates a sine wave.
        iphs = 0 // initial phase of sampling, expressed as a fraction of a cycle.
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
        kpan = 0.03
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
        kpan = 0.64
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
        kpan = 0.28
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
    /*  these might not be neccesary, but doenst reproduce the same low frequency spectrum
        atreeleaves_max = atreeleaves_max + atreeleaves_bus1 // adds atreeleaves_bus1 back into signal due to it being missing after max opcode ?
        atreeleaves_max -= atreeleaves_bus1
    */
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
        kpan = 0.71
        atreeleaves_Out_L, atreeleaves_Out_R Farnel_Pan atreeleaves_Sum, kpan

        // output from treeleaves to CSound
        chnset atreeleaves_Out_L, "wind_treeleaves_L"
        chnset atreeleaves_Out_R, "wind_treeleaves_R"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	// fetching control channels from webpage
		kbuildings_amp chnget "buildings_amp"
		kdoorways_amp chnget "doorways_amp"
		kbranches_amp chnget "branches_amp"
		kleaves_amp chnget "leaves_amp"
		kmaster_amp chnget "master_amp"
		// Applies portamento to a step-valued control signal.
		// Applies a small portamento to limit unwanted noise in control signals
		kbuildings_amp port kbuildings_amp, 0.01
		kdoorways_amp port kdoorways_amp, 0.01
		kbranches_amp port kbranches_amp, 0.01
		kleaves_amp port kleaves_amp, 0.01
		kmaster_amp port kmaster_amp, 0.01



    // Output from the different sub-channels, scaled with the control channels from the website
    aOutL = 0.45*((aBuilding_Out_L)*kbuildings_amp+(aDoorways1_Out_L+aDoorways2_Out_L)*kdoorways_amp+(abrancheswires1_Out_L+abrancheswires2_Out_L)*kbranches_amp+(atreeleaves_Out_L)*kleaves_amp)
    aOutR = 0.45*((aBuilding_Out_R)*kbuildings_amp+(aDoorways1_Out_R+aDoorways2_Out_R)*kdoorways_amp+(abrancheswires1_Out_R+abrancheswires2_Out_R)*kbranches_amp+(atreeleaves_Out_R)*kleaves_amp)
		aOutL *= kmaster_amp
		aOutR *= kmaster_amp
		// final output to CSound
    chnset aOutL, "wind_L"
    chnset aOutR, "wind_R"

endin


instr 99
	// wind output
		 aL chnget "wind_L"
		 aR chnget "wind_R"
	 outs aL, aR
endin
</CsInstruments>
<CsScore>
// start test instrument
//i"alarm_01" 0 10
i"wind" 0 32


i99 0 32
e
</CsScore>
</CsoundSynthesizer>
