# morse_code_tools
A project on automatic morse code translation using a microcontroller.
The perl tools here are for developing and testing the algorithm and
to perform simulations.

## m2a.pl
```
Usage: m2a.pl -m [--] '[morse-string]'
       m2a.pl -a [--] '[ascii-string]'
       [input-stream] | m2a.pl [options]

Convert morse-code into ascii and vice versa.

   -a       Convert from ascii to morse.
   -m       Convert from morse to ascii.
  --help    Show this help text.
  --version Show program version.
  --        Is required if morse-code starts with an '--', to
            distinguish it from an option.
  morse-string
    .       A dit.
    -       A dah.
    space   An inter-character space (length 3 x dit).
    /       An inter-word space (lenght 7 x dit).   
```

## morse_to_signal
Testing rig for the `signal_to_morse` algorithm.
* Provide a pseudo-real-time clock implementation.
* Create a pseudo-real-time binary signal from a morse code string.
* Convert a pseudo-rela-time binary signal back to morse code.
```
./morse_to_signal
morse    : -.. -/..- --
time unit: 0.1
timeout  : 0.025
sleep    : 0.0166666666666667
signal   : 111111111111111100000011111100000011111100000000000000011111111111111110000000000000000000000000000000000001111110000011111000000111111111111111100000000000000001111111111111110000011111111111111110

morse    : ..-.-. -.--/.-.. -.-/.... -.-. ----
decoded  : /-/- -.-. -.--/.-.. -.-/.... -.-. ----
```
## time_test
This is a utility to check the resolution of the implementation of the `gettimeofday` perl function.
``` 
./time_test
1000000
t-intrv: 0.0343833
100000
t-intrv: 0.0034794
10000
t-intrv: 0.0003128
1000
t-intrv: 3.14e-05
100
t-intrv: 3.6e-06
```
