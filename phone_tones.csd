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

instr phone_tones
  // fetches data from website
    // dialone amp
      k_dial_amp init 0.5 // initial value shared by the website slider
      k_dial_amp chnget "dial_amp"	// in the range 0-1
      k_dial_amp portk k_dial_amp, 0.005	// portamento to avoid unwanted noise
    // ring amp
      k_ring_amp init 0.5 // initial value shared by the website slider
      k_ring_amp chnget "ring_amp"	// in the range 0-1
      k_ring_amp portk k_ring_amp, 0.005	// portamento to avoid unwanted noise
    // ring meta
      k_ring_meta init 1 // initial value shared by the website slider
      k_ring_meta chnget "ring_meta"	// in the range 0-1
      k_ring_meta portk k_ring_meta, 0.005	// portamento to avoid unwanted noise
    // busy amp
      k_busy_amp init 0.5 // initial value shared by the website slider
      k_busy_amp chnget "busy_amp"	// in the range 0-1
      k_busy_amp portk k_busy_amp, 0.005	// portamento to avoid unwanted noise
    // busy meta
      k_busy_meta init 1 // initial value shared by the website slider
      k_busy_meta chnget "busy_meta"	// in the range 0-1
      k_busy_meta portk k_busy_meta, 0.005	// portamento to avoid unwanted noise

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% // local instrument separator


    // dialtone 2
        // sine oscilator 1
            kamp = 1 // amplitude
            kcps = 350 // frequency in cycles per second.
            a_dialtone_2_1 oscili kamp, kcps

        // sine oscilator 2
            kamp = 1 // amplitude
            kcps = 450 // frequency in cycles per second.
            a_dialtone_2_2 oscili kamp, kcps

        // summing oscilators from oscilator 1 and 2
            a_dialtone_2_sum = a_dialtone_2_1 + a_dialtone_2_2

        // approximation of the phone line and handset start
        // limit
            klow = -0.9 // low threshold
            khigh = 0.9 // high threshold
            a_dialtone_2_lim limit a_dialtone_2_sum, klow, khigh

        // bandpass filter
            a_dialtone_2_bp butterbp a_dialtone_2_lim, 2000, 12

        // scaling
            a_dialtone_2_bp_2 = a_dialtone_2_bp * 0.5
        // 2nd bandpassfilter
            a_dialtone_2_bp_2 butterbp a_dialtone_2_bp_2, 400, 3

        // limit
            klow = -0.4 // low threshold
            khigh = 0.4 // high threshold
            a_dialtone_2_lim_2 limit a_dialtone_2_bp, klow, khigh

            a_dialtone_2_lim_2 *= 0.15

        // summing before highpass filters
            a_dialtone_out = a_dialtone_2_bp_2 + a_dialtone_2_lim_2


        // highpass filter and final output
            khp = 90 // the response curve's half-power point, in Hertz
            a_dialtone_out atone a_dialtone_out, khp
            a_dialtone_out atone a_dialtone_out, khp
        // amplitude scaling
            a_dialtone_out *= 40
        // approximation of the phone line and handset end

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    // ringingtone
        // metro
            kfreq = 1+k_ring_meta // frequency of trigger bangs in cps
            ktrig  metro  kfreq
            kcount init 0
            if ktrig == 1 then
                kcount += 1
            endif

        // modulus
            kdial = kcount % (6-k_ring_meta)

        // muting
            if kdial > 2 then
                kmute = 1
            else
                kmute = 0
            endif

        // sine oscilator 1
            kamp = 1 // amplitude
            kcps = 480*k_ring_meta // frequency in cycles per second.
            aring_1 oscili kamp, kcps

        // sine oscilator 2
            kamp = 1 // amplitude
            kcps = 440*k_ring_meta // frequency in cycles per second.
            aring_2 oscili kamp, kcps

        // sine oscilator summing and muting
            aring_sum = (aring_1+aring_2)*kmute

        // approximation of the phone line and handset start
        // limit
            klow = -0.9 // low threshold
            khigh = 0.9 // high threshold
            aring_sum limit aring_sum, klow, khigh

        // bandpass filter
            aring_sum butterbp aring_sum, 2000, 12

        // scaling
            aring_sum_bp = aring_sum * 0.5
        // 2nd bandpassfilter
            aring_sum_bp butterbp aring_sum_bp, 400, 3

        // limit
            klow = -0.4 // low threshold
            khigh = 0.4 // high threshold
            aring_sum_lim limit aring_sum, klow, khigh
            aring_sum_lim *= 0.15

        // summing before highpass filters
            aring_out = aring_sum_bp + aring_sum_lim

        // highpass filter and final output
            khp = 90 // the response curve's half-power point, in Hertz
            aring_out atone aring_out, khp
            aring_out atone aring_out, khp

        // scaling Amplitude
            aring_out *= 50
        // approximation of the phone line and handset end

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    // busy signal
        // sine oscilator 1
          kamp = 1 // amplitude
          kcps = 480*k_busy_meta // frequency in cycles per second.
          a_bs_oscil_1 oscili kamp, kcps

        // sine oscilator 2
          kamp = 1 // amplitude
          kcps = 620*k_busy_meta // frequency in cycles per second.
          a_bs_oscil_2 oscili kamp, kcps

        // summing oscilators from oscilator 1 and 2
          a_bs_sum_1 = a_bs_oscil_1 + a_bs_oscil_1

        // sine oscilator 3
          kamp = 1 // amplitude
          kcps = 2*k_busy_meta // frequency in cycles per second.
          a_bs_oscil_3 oscili kamp, kcps

          a_bs_oscil_3 *= 10000

        // limit
          klow = 0 // low threshold
          khigh = 1 // high threshold
          a_bs_oscil_3_lim limit a_bs_oscil_3, klow, khigh
        // first-order lowpass filters
          khp = 100 // the response curve's half-power point, in Hertz
          a_bs_oscil_3_lp tone a_bs_oscil_3_lim, khp

        // summing all oscilators
          a_bs_out = (a_bs_sum_1 * a_bs_oscil_3_lp)*0.05

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // output
    aout = (a_dialtone_out*k_dial_amp)+(aring_out*k_ring_amp)+(a_bs_out*k_busy_amp)

    outs aout, aout

endin

</CsInstruments>
<CsScore>
i"phone_tones" 0 86400

</CsScore>

/* Sources
Farnell, A. (2010). Designing Sound. The MIT Press. 25 Practical 2 Phone Tones (pp.337-341)
https://www.csounds.com/manual/html/index.html
*/
