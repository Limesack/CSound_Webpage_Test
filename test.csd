<CsoundSynthesizer>
<CsOptions>
-+rtmidi=NULL -M0 -m0d
</CsOptions>
<CsInstruments>
; Initialize the global variables.

	sr	= 44100
	nchnls	= 2
	0dbfs	= 1

instr 1

a1 oscili 0.5, 440

outs a1, a1

endin

</CsInstruments>
<CsScore>
i1 0 10
e
</CsScore>
</CsoundSynthesizer>
