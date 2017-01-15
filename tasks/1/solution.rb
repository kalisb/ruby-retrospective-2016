SUBSTANCE_TEMPERATURES_IN_C = {
  'water' => { melting_point: 0, boiling_point: 100 },
  'ethanol' => { melting_point: -114, boiling_point: 78.37 },
  'gold' => { melting_point: 1064, boiling_point: 2700 },
  'silver' => { melting_point: 961.8, boiling_point: 2162 },
  'copper' => { melting_point: 1085, boiling_point: 2567 }
}
FAHRENHEIT = 'F'
KELVIN = 'K'
CELSIUS = 'C'

def convert_between_temperature_units(temperature, from, to)
  convert_from_celsius(convert_to_celsius(temperature, from), to)
end

def melting_point_of_substance(substance, unit)
  convert_from_celsius(SUBSTANCE_TEMPERATURES_IN_C[substance][:melting_point], unit)
end

def boiling_point_of_substance(substance, unit)
  convert_from_celsius(SUBSTANCE_TEMPERATURES_IN_C[substance][:boiling_point], unit)
end

def convert_to_celsius(temperature, from)
  case from
  when FAHRENHEIT then (temperature - 32) * (5.0 / 9)
  when KELVIN then temperature - 273.15
  when CELSIUS then temperature
  end
end

def convert_from_celsius(temperature, to)
  case to
  when FAHRENHEIT then temperature * (9.0 / 5) + 32
  when KELVIN then temperature + 273.15
  when CELSIUS then temperature
  end
end
