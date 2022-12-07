require_relative 'ruephbase.rb'

module Rueph
  include RuephBase
  extend self

  SIGNS = ['ARIES', 'TAURUS', 'GEMINI', 'CANCER', 'LEO',
           'VIRGO', 'LIBRA', 'SCORPIO', 'SAGITTARIUS',
           'CAPRICORN', 'AQUARIUS', 'PISCES']

  PLANETS = ['SUN', 'MOON', 'MERCURY', 'VENUS', 'MARS', 
             'JUPITER', 'SATURN', 'URANUS', 'NEPTUNE', 'PLUTO']

  def set_ephe_path(path)
    super(path)
  end

  # TODO Refactor
  def time_to_array(time)
    array = [time.year, time.month, time.day, time.hour + (time.min/60.0)]
  end
  
  def time_from_array(array)
    #NOTE: Never Used
    time = Time.new(array[0], array[1], array[2]) + (array[3]*60*60)
  end
 
  #TODO: remove time_array maybe, remove tz_offset for sure
  def off_set_time_array(time_array, tz_offset)
    time_array[3] -= tz_offset
    return time_array
  end
  
  def reset_time_array(time_array, tz_offset)
    time_array[3] += tz_offset
    return time_array
  end

  def deg_to_sign(deg)
    return SIGNS[(deg / 30.0).floor()]
  end

  def deg_to_sign_deg(deg)
    floored = (deg / 30.0).floor()
    return [SIGNS[floored], (deg - (floored * 30.0)).round]
  end
  #TODO end refactor

  # 3.5.  Error handling and return values
  # swe_calc() (as well as swe_calc_ut(), swe_fixstar(), and 
  # swe_fixstar_ut()) returns a 32-bit integer value. This value is >= 0, 
  # if the function call was successful, and < 0,
  # if a fatal error has occurred. In addition an error string 
  # or a warning can be returned in the string parameter serr.

  #def self.calc(time_array, planet, flags)
  def calc(planet, time = time_to_array(Time.now), flags: (FLG_SWIEPH + FLG_SPEED))
    #TODO: is time here before or after time is offset for timezone
    #time_array to time used?
    #time_array = self.time_to_array(time_array) if time_array.is_a? Time
    # Calculates Julian Day from time array
    julday = Rueph::julday(time[0], time[1],
                          time[2], time[3], GREG_CAL)
    
    # Establishes a pointer for calc_ut's results
    # and a pointer to its error string
    retpntr = FFI::MemoryPointer.new(:double, 6)
    errstring = FFI::MemoryPointer.new(:char, 255)
    iflgret = Rueph::calc_ut(julday, planet, flags, retpntr, errstring)

    # Gets data from the pointer
    # then frees the memory
    ret_errstr = errstring.read_string
    errstring.free

    ret_array = retpntr.read_array_of_double(6)
    retpntr.free

    #TODO: return multiple values in array
    #      return_array, ret_errstr, return iflgret
    
    #NOTE: this preferred method for errstrs?
    puts ret_errstr if !ret_errstr.empty?
    return ret_array
  end

  # REQUIRES SEFSTARS.TXT FOR FUNCTION FIXSTAR
  def fixstar(star, time = time_to_array(Time.now), bulk: false, flags: FLG_SWIEPH)
    #time_array = self.time_to_array(time_array) if time_array.is_a? Time
    # Calculates Julian Day from time array
    julday = Rueph.julday(time_array[0], time_array[1],
                          time_array[2], time_array[3], GREG_CAL)
    
    # Establishes pointers for fixstar
    star_str = FFI::MemoryPointer.new(:char, 40)
    star_str = star_str.write_string(star)
    retpntr = FFI::MemoryPointer.new(:double, 6)
    errstring = FFI::MemoryPointer.new(:char, 255)

    if bulk
      # Using bulk has the side effect of making star names
      # harder to find automatically. While case is still insensitive,
      # You must put a % at the end of the star_str, as a wild card
      iflgret = Rueph.fixstar2_ut(star_str, julday, flags, retpntr, errstring)
    else
      iflgret = Rueph.fixstar_ut(star_str, julday, flags, retpntr, errstring)
    end

    # frees pointers

    ret_errstr = errstring.read_string
    errstring.free

    ret_starstr = star_str.read_string
    star_str.free

    ret_array = retpntr.read_array_of_double(6)
    retpntr.free
    
    
    return ret_array
  end

  def retrograde?(planet, time = time_to_array(Time.now))
    if (calc(planet)[3] < 0)
      return true
    else # speed >= 0
      return false
    end
  end

  def sign_of(planet, time = time_to_array(Time.now))
    return deg_to_sign(calc(planet)[0])
  end

  def sign_of_degree(planet, time = time_to_array(Time.now))
    return deg_to_sign_deg(calc(planet)[0])
  end

  def house_name(char)
    return RuephBase::house_name(char.ord)
  end

  def houses(lat, long, time = time_to_array(Time.now), house_system = 'P')
    julday = Rueph::julday(time[0], time[1],
                          time[2], time[3], GREG_CAL)

    unless house_system == 'G'
      cusps = FFI::MemoryPointer.new(:double, 13)
    else
      cusps = FFI::MemoryPointer.new(:double, 37)
    end

    asmc = FFI::MemoryPointer.new(:double, 10)

    RuephBase::houses(julday, lat, long, house_system.ord, cusps, asmc)

    
    unless house_system == 'G'
      retcusps = cusps.read_array_of_double(13)
    else
      retcusps = cusps.read_array_of_double(37)
    end

    retasmc = asmc.read_array_of_double(10)

    cusps.free
    asmc.free

    return retcusps, retasmc
  end

  def house_pos(planet, lat, long, cusps, asmc, time = time_to_array(Time.now), hsystem: 'P', flags: (FLG_SWIEPH + FLG_SPEED + FLG_TOPOCTR))

    armc = asmc[Rueph::ARMC]
    eps = Rueph::calc(Rueph::ECL_NUT, time)[0]
    body_lat_long = Rueph::calc(planet, time)

    xpin = FFI::MemoryPointer.new(:double, 2)
    xpin.write_array_of_double([body_lat_long[0], body_lat_long[1]])

    errstring = FFI::MemoryPointer.new(:char, 255)

    ret_pos = RuephBase::house_pos(armc, lat, eps, hsystem.ord, xpin, errstring)

    xpin.free
    errstring.free

    return ret_pos
  end

#### The following section deals with pointers
#### used as strings in the base library
  def get_library_path
    retpntr = FFI::MemoryPointer.new(:char, 255)

    RuephBase::get_library_path(retpntr)

    ret_str = retpntr.read_string
    retpntr.free

    return ret_str
  end

  def get_body_name(body_number)
    retpntr = FFI::MemoryPointer.new(:char, 255)

    RuephBase::get_body_name(body_number, retpntr)

    ret_str = retpntr.read_string
    retpntr.free

    return ret_str
  end

  def version
    retpntr = FFI::MemoryPointer.new(:char, 255)

    RuephBase::version(retpntr)

    ret_str = retpntr.read_string
    retpntr.free

    return ret_str
  end

end
