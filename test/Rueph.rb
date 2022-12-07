require 'minitest/autorun'
require_relative '../lib/rueph.rb'
require 'time'

class RuephTest < Minitest::Test

  Rueph::set_ephe_path 'ephe'

  # cusps, asmc = Rueph::houses(0, 0)
  # pp cusps
  # pp asmc

  #TODO
  def test_set_ephe_path
  end

  def test_get_library_path
    assert Rueph::get_library_path == "#{Dir.pwd}/src/libswe.so"
  end

  def test_system_for_house_name
    assert Rueph::house_name('P') == 'Placidus'
  end

  def test_time_to_array
    assert Rueph::time_to_array(Time.parse("2021-12-16 01:30")) == [2021, 12, 16, 1.5]
  end

  def test_time_from_array
    assert Rueph::time_from_array([2021, 12, 16, 1.5]) == Time.parse("2021-12-16 01:30")
  end

  def test_off_set_time_array
    assert Rueph::off_set_time_array([2021, 12, 16, 1.5], -1) == [2021, 12, 16, 2.5]
  end

  def test_reset_time_array
    assert Rueph::reset_time_array([2021, 12, 16, 2.5], -1) == [2021, 12, 16, 1.5]
  end

  def test_deg_to_sign
    assert Rueph::deg_to_sign(20.0) == "ARIES"
  end

  def test_deg_to_sign_deg
    assert Rueph::deg_to_sign_deg(20.0) == ["ARIES", 20.0]
  end

  def test_calc
    calc = Rueph::calc(Rueph::MOON, [2021, 12, 16, 1.5])
    
    calc.map!(&:round)

    assert calc == [51, -1, 0, 12, 1, 0]
  end

  def test_version
    assert Rueph::version == "2.10.02"
  end

end
