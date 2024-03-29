# Rueph

```
bundle install
rake
```

Rueph is a Ruby Foreign Function Interface (FFI) to the Astrodient
Swiss Ephemeris (SE) library (written in C).

To see an example of Rueph in use, look at the [horoscli github](https://github.com/jsphnecclia/horoscli).

If you run into any problems, or **functions that are in SE Library but**
**not in Rueph**, bring it up on github or (preferably!) send me an email
at parkermcgowan@horos.today! As of now, the Rueph functions are
only configured to support horoscli and a daily astrolunar calendar at www.horos.today
(However, do not look in the horos.today source code for an example of Rueph, horos.today
uses a proto version of Rueph that is structured differently than this repository or the
Rueph used in horoscli)

LICENSING

Rueph is licensed under the MIT License, but in practice it is a little more
complex.

Rueph cannot function without the Swiss Ephemeris, but once you install the SE
(through rake) you are required to fulfill the stricter licensing of the SE library,
which is a dual licensing system -- Either the AGPL3 or the Swiss Ephemeris Professional
License. Rueph is licensed this way to allow codebases to be either Open Source
(through the AGPL3) or Closed Source (through the Swiss Ephemeris Professional License). 

To use Rueph in a closed source manner, all that is required is to go through the
[Astrodienst procedure](https://www.astro.com/swisseph/swephinfo_e.htm#proflic) for acquiring a Swiss Ephemeris License. 

NOTE: If you don't choose a Swiss Ephemeris Professional license, you MUST follow
the guidelines of the AGPL3 -- which basically require you to open source your codebase.
