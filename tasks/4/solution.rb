RSpec.describe 'Version' do
  describe '#version' do
    it "is created given valid arguments" do
      expect(Version.new('1')).not_to be nil
      expect(Version.new('1.13.3.4')).not_to be nil
      expect(Version.new('100.13.3')).not_to be nil
      expect(Version.new(Version.new('100.13.3'))).not_to be nil
      expect(Version.new).not_to be nil
      expect(Version.new('')).not_to be nil
    end

    it "throws ecseption given invalid invalid" do
      expect { Version.new('-1.3') }.to raise_error ArgumentError
      expect { Version.new('1.-3') }.to raise_error ArgumentError
      expect { Version.new('1.0.-3') }.to raise_error ArgumentError 
      expect { Version.new('1.0.3.') }.to raise_error ArgumentError 
      expect { Version.new('.3') }.to raise_error ArgumentError
      expect { Version.new('.') }.to raise_error ArgumentError
      expect { Version.new('..') }.to raise_error ArgumentError
      expect { Version.new('0..3') }.to raise_error ArgumentError
      expect { Version.new('v:1.13.3') }.to raise_error ArgumentError
    end

    it "throws expseption with correct message" do
      expect do
        Version.new('v:1.13.3')
      end.to raise_error(ArgumentError, "Invalid version string 'v:1.13.3'")
    end

    it "can be equal" do
      version1 = Version.new('1')
      version2 = Version.new('1.0')
      version3 = Version.new('1.0.0')
      version4 = Version.new("1.0.0.9")
      expect(version1).to eq(version2)
      expect(version1).to eq(version3)
      expect(version2).to eq(version3)
      expect(version3).not_to eq(version4)
    end

    it "can be compared using <, >, <= and >=" do
      expect(Version.new('1')).to be <= Version.new('1.0.1')
      expect(Version.new('1.0.1')).not_to be <= Version.new('1')
      expect(Version.new('1.1')).to be > Version.new('1.0.1')
      expect(Version.new('1.2')).not_to be > Version.new('2')
      expect(Version.new('1.1')).to be < Version.new('1.1.1')
      expect(Version.new('10')).not_to be < Version.new('2')
      expect(Version.new('1.2')).to be >= Version.new('1.1.1')
      expect(Version.new('1.1.1')).not_to be >= Version.new('1.2')
    end
    
    it "can be compared using <=>" do
      expect(Version.new('1.2') <=> Version.new('1.1.1')).to be 1
      expect(Version.new('1.2') <=> Version.new('1.2.0')).to be 0
      expect(Version.new('1.2') <=> Version.new('1.3')).to be -1
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
    end

    it "is not able to modify the internal data of the version" do
      version = Version.new('1.2.3')
      version.components << 4
      expect(version).to eq Version.new('1.2.3')
    end
  end

  describe '#range' do
    it "can check if version is included" do
      range1 = Version::Range.new(Version.new('1'), Version.new('2'))
      range2 = Version::Range.new('1', '1.0.0')
      range3 = Version::Range.new("1", "10")
      expect(range1.include?(Version.new('1.5'))).to eq(true)
      expect(range1.include?(Version.new('3.5'))).to eq(false)
      expect(range1.include?(Version.new('0.9'))).to eq(false)
      expect(range2.include?(Version.new('1'))).to eq(false)
      expect(range3.include?(Version.new('1.9.1'))).to eq(true)
    end

    it 'can iterate simple version ranges' do
      range = Version::Range.new('1.1.2', '1.1.5')
      expect(range.to_a.map(&:to_s)).to eq ['1.1.2', '1.1.3', '1.1.4']
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
