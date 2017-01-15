RSpec.describe 'Version' do
  describe '#version' do
    it "is valid" do
      expect(Version.new('1')).not_to be nil
      expect(Version.new('1.13.3.4')).not_to be nil
      expect(Version.new('100.13.3')).not_to be nil
      expect(Version.new(Version.new('100.13.3'))).not_to be nil
      expect(Version.new).not_to be nil
      expect(Version.new('')).not_to be nil
    end
    it "is invalid" do
      expect do 
        Version.new('-1.3')
      end.to raise_error(ArgumentError, "Invalid version string '-1.3'")
      expect do 
        Version.new('1.-3') 
      end.to raise_error(ArgumentError, "Invalid version string '1.-3'")
      expect do  
        Version.new('1.0.-3') 
      end.to raise_error(ArgumentError, "Invalid version string '1.0.-3'")
      expect do
        Version.new('1.0.3.') 
      end.to raise_error(ArgumentError, "Invalid version string '1.0.3.'")
      expect do  
        Version.new('.3')
      end.to raise_error(ArgumentError, "Invalid version string '.3'")
      expect do  
        Version.new('.') 
      end.to raise_error(ArgumentError, "Invalid version string '.'")
      expect do  
        Version.new('..') 
      end.to raise_error(ArgumentError, "Invalid version string '..'")
      expect do  
        Version.new('0..3') 
      end.to raise_error(ArgumentError, "Invalid version string '0..3'")
      expect do  
        Version.new('v:1.13.3') 
      end.to raise_error(ArgumentError, "Invalid version string 'v:1.13.3'")
    end
    it "can be equal" do
      version1 = Version.new('1')
      version2 = Version.new('1.0')
      version3 = Version.new('1.0.0')
      version4 = Version.new("1.0.0.9")
      expect(version1 == version2).to eq(true)
      expect(version1 == version3).to eq(true)
      expect(version2 == version3).to eq(true)
      expect(version3 <= version4).to eq(true)
      expect(version3 <=> version4).to eq(-1)
      expect(version3 <=> version1).to eq(0)
    end
    it "can be compared" do
      expect(Version.new('1') < Version.new('1.0.1')).to eq(true)
      expect(Version.new('1.0.1') < Version.new('1.1')).to eq(true)
      expect(Version.new('1.1') < Version.new('1.1.1')).to eq(true)
      expect(Version.new('1.1.1') < Version.new('1.2')).to eq(true)
      expect(Version.new('1.2') < Version.new('2')).to eq(true)
      expect(Version.new('2') < Version.new('10')).to eq(true)
    end
    it "can remove zeros in end" do
      expect(Version.new('1.1.0').to_s).to eq('1.1')
      expect(Version.new('1.0.0.0').to_s).to eq('1')
      expect(Version.new('1.0.0').to_s).to eq('1')
      expect(Version.new('1.0').to_s).to eq('1')
      expect(Version.new('1').to_s).to eq('1')
      expect(Version.new('1.0.1').to_s).to eq('1.0.1')
      expect(Version.new('0.0.0').to_s).to eq('')
    end
    it "can get components" do
      version = Version.new('1.1.0')
      expect(version.components).to eq([1, 1])
      expect(version.components(1)).to eq([1])
      expect(version.components(2)).to eq([1, 1])
      expect(version.components(3)).to eq([1, 1, 0])
      expect(version.components(4)).to eq([1, 1, 0, 0])
      expect(version).to eq(Version.new('1.1'))
    end
  end
  describe '#range' do
    it "is version included" do
      range1 = Version::Range.new(Version.new('1'), Version.new('2'))
      range2 = Version::Range.new('1', '1.0.0')
      range3 = Version::Range.new('1', '10')
      expect(range1.include?(Version.new('1.5'))).to eq(true)
      expect(range1.include?(Version.new('3.5'))).to eq(false)
      expect(range1.include?(Version.new('0.9'))).to eq(false)
      expect(range2.include?(Version.new('1'))).to eq(false)
      expect(range3.include?(Version.new('0.9.1'))).to eq(false)
    end
    it "can find all versions" do
      range1 = Version::Range.new(Version.new('1'), Version.new('1.0.2'))
      range2 = Version::Range.new('1.0.0', '1.0.0')
      expect(range1.to_a).not_to include('1.2')
      expect(range1.to_a).not_to include('0.9')
      expect(range2.to_a).to eq([])
      expect(range1.to_a).to eq(['1', '1.0.1'])
    end
  end
end
