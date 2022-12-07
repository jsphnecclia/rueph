require 'ffi'

module RuephBase
  extend self

  extend FFI::Library
  ffi_lib 'src/libswe.so'

  # Entire List of Planet/Bodies
  ECL_NUT           =   -1
  SUN               =    0
  MOON              =    1
  MERCURY           =    2
  VENUS             =    3
  MARS              =    4
  JUPITER           =    5
  SATURN            =    6
  URANUS            =    7
  NEPTUNE           =    8
  PLUTO             =    9
  MEAN_NODE         =    10
  TRUE_NODE         =    11
  MEAN_APOG         =    12
  OSCU_APOG         =    13
  EARTH             =    14
  CHIRON            =    15
  PHOLUS            =    16
  CERES             =    17
  PALLAS            =    18
  JUNO              =    19
  VESTA             =    20
  INTP_APOG         =    21
  INTP_PERG         =    22
  NPLANETS          =    23
  FICT_OFFSET       =    40
  NFICT_ELEM        =    15
  AST_OFFSET        =    10000
  # Uranian "planets"
  CUPIDO            =    40
  HADES             =    41
  ZEUS              =    42
  KRONOS            =    43
  APOLLON           =    44
  ADMETOS           =    45
  VULKANUS          =    46
  POSEIDON          =    47
  # other fictitious bodies
  ISIS              =    48
  NIBIRU            =    49
  HARRINGTON        =    50
  NEPTUNE_LEVERRIER =    51
  NEPTUNE_ADAMS     =    52
  PLUTO_LOWELL      =    53
  PLUTO_PICKERING   =    54

  # Bitwise flags for calc
  FLG_JPLEPH      =   1               # use JPL ephemeris
  FLG_SWIEPH      =   2               # use SWISSEPH ephemeris, default
  FLG_MOSEPH      =   4               # use Moshier ephemeris
  FLG_HELCTR      =   8               # return heliocentric position
  FLG_TRUEPOS     =   16              # return true positions, not apparent
  FLG_J2000       =   32              # no precession, i.e. give J2000 equinox
  FLG_NONUT       =   64              # no nutation, i.e. mean equinox of date
  FLG_SPEED3      =   128             # speed from 3 positions (do not use it, FLG_SPEED is faster and more precise.)
  FLG_SPEED       =   256             # high precision speed (analyt. comp.)
  FLG_NOGDEFL     =   512             # turn off gravitational deflection
  FLG_NOABERR     =   1024            # turn off 'annual' aberration of light
  FLG_ASTROMETRIC =   (FLG_NOABERR|FLG_NOGDEFL) # astrometric positions
  FLG_EQUATORIAL  =   2048            # equatorial positions are wanted
  FLG_XYZ         =   4096            # cartesian, not polar, coordinates
  FLG_RADIANS     =   8192            # coordinates in radians, not degrees
  FLG_BARYCTR     =   16384           # barycentric positions
  FLG_TOPOCTR     =   (32*1024)       # topocentric positions
  FLG_SIDEREAL    =   (64*1024)       # sidereal positions
  FLG_ICRS        =   (128*1024)      # ICRS (DE406 reference frame)
  FLG_DPSIDEPS_1980 = (256*1024)      #reproduce JPL Horizons * 1962 - today to 0.002 arcsec.
  FLG_JPLHOR      =   FLG_DPSIDEPS_1980
  FLG_JPLHOR_APPROX = (512*1024)      #approximate JPL Horizons 1962 - today

  GREG_CAL        =   1

  # Defines :coordinates as a :pointer (for readability)
  typedef :pointer, :coordinates
  typedef :pointer, :cstring
  typedef :pointer, :star_name

  # ALWAYS BEGIN BY CALLING SET_EPHE_PATH (Even with NULL)
  # to initialize important functions, and clean up by calling close
  attach_function :set_ephe_path, :swe_set_ephe_path, [:string], :void
  attach_function :close, :swe_close, [], :void
  # Basic Setup
  # TODO: string to cstring in other places?
  attach_function :get_library_path, :swe_get_library_path, [:cstring], :string

  # To use a jpl ephemeris set it with the following command, then use
  # the FLG_JPLEPH in any subsequent calculations
  attach_function :set_jpl_file, :swe_set_jpl_file, [:string], :void
  attach_function :version, :swe_version, [:cstring], :string

  # Basic Calculations
  attach_function :get_body_name, :swe_get_planet_name, [:int, :cstring], :cstring
  # 4th argument to julday is almost always going to be the constant GREG_CAL
  attach_function :julday, :swe_julday, [:int, :int, :int, :double, :int], :double
  # Array returned is [longitude, latitude, distance (AU),
  #                    longitude speed, latitude speed, AU speed]
  attach_function :calc_ut, :swe_calc_ut, [:double, :int, :long, :coordinates, :cstring], :int

  # ALL FIXSTAR FUNCTIONS REQUIRE sefstars.txt
  attach_function :fixstar_ut, :swe_fixstar_ut, [:star_name, :double, :long, :coordinates, :cstring], :int

  #TODO: Add to class instance
  #set_topo(longitude, latitude, altitude)
  attach_function :set_topo, :swe_set_topo, [:double, :double, :double], :void

  #TODO:3.2.1 Additional asteroids
  #     3.2.3 Obliquity
  #     3.5 Error handling
  #       swe_calc(as well as swe_calc_ut(), swe_fixstar(), and swe_fixstar_ut())


  # Ephemeris Time
  # jul_day_ET = jul_day_UT + swe_deltat(jul_day_UT)
  attach_function :swe_deltat, [:double], :double
  attach_function :swe_calc, [:double, :int, :long, :coordinates, :string], :int
  attach_function :swe_fixstar, [:star_name, :double, :long, :coordinates, :string], :int

  # Faster fixstar if a great number of fix star calculations are done
  # requires full star name or using % in the star_str as a wild card
  attach_function :fixstar2_ut, :swe_fixstar2_ut, [:star_name, :double, :long, :coordinates, :cstring], :int
  attach_function :fixstar2, :swe_fixstar2, [:star_name, :double, :long, :coordinates, :string], :int
  
  # House systems:
  #‘P’         Placidus
  #‘K’         Koch
  #‘O’         Porphyrius
  #‘R’         Regiomontanus
  #‘C’         Campanus
  #‘A’ or ‘E’  Equal (cusp 1 is Ascendant)
  #‘W’         Whole sign
  #‘B’         Alcabitus
  #‘Y’         APC houses
  #‘X’         Axial rotation system / Meridian system / Zariel
  #‘H’         Azimuthal or horizontal system
  #‘F’         Carter "Poli-Equatorial"
  #‘D’         Equal MC (cusp 10 is MC)
  #‘N’         Equal/1=Aries
  #‘G’         Gauquelin sector
  #‘I’         Sunshine (Makransky, solution Treindl)
  #‘i’         Sunshine (Makransky, solution Makransky)
  #‘U’         Krusinski-Pisa-Goelzer
  #‘M’         Morinus
  #‘T’         Polich/Page (“topocentric” system)
  #‘L’         Pullen SD (sinusoidal delta) – ex Neo-Porphyry
  #‘Q’         Pullen SR (sinusoidal ratio)
  #‘S’         Sripati
  #‘V’         Vehlow equal (Asc. in middle of house 1)

  typedef :pointer, :cusps
  typedef :pointer, :ascmc
  typedef :pointer, :xpin
  # House Method functions
  attach_function :house_name, :swe_house_name, [:char], :string

  ASC      =     0
  MC       =     1
  ARMC     =     2
  VERTEX   =     3
  EQUASC   =     4    # "equatorial ascendant"
  COASC1   =     5    # "co-ascendant" (W. Koch)
  COASC2   =     6    # "co-ascendant" (M. Munkasey) 
  POLASC   =     7    # "polar ascendant" (M. Munkasey)
  NASCMC   =     8

  # House cusps, Ascendant, and MC
  # Arguments: Julian day, lat, long, house method, array for
  # 13 (or 37) doubles, array for 10 doubles
  # (37 when int hsys = G)
  # Eastern longitude is positive, western is negative,
  # Northern latitude is positive, southern is negative
  attach_function :houses, :swe_houses, [:double, :double, :double, :int, :cusps, :ascmc], :int

  attach_function :house_pos, :swe_house_pos, [:double, :double, :double, :int, :xpin, :cstring], :double

  #attach_function :houses_armc, :swe_houses_armc, [:double, :double, :double, :int, :cusps, :ascmc], :double
  #TODO: swe_houses_armc/swe_houses_armc_ex2
  #      swe_houses_ex/swe_houses_ex2 --extended function
  #         tropical or sidereal positions of house cusps
  #
  #     Sunshine or Makransky houses cmd + f
end
